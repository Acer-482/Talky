import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:shelf/shelf_io.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:talky_server/src/web_client.dart';
import 'package:talky_shared/account/account.dart';
import 'package:talky_shared/account/account_profile.dart';
import 'package:talky_shared/chat/base_chat_message.dart';
import 'package:talky_shared/chat/chat_group/chat_group.dart';
import 'package:talky_shared/log/log_entry.dart';
import 'package:talky_shared/log/log_level.dart';
import 'package:talky_shared/packets/accounts/get_account_profile_request.dart';
import 'package:talky_shared/packets/accounts/get_account_profile_response.dart';
import 'package:talky_shared/packets/accounts/log_in_request.dart';
import 'package:talky_shared/packets/accounts/log_in_response.dart';
import 'package:talky_shared/packets/accounts/logout_request.dart';
import 'package:talky_shared/packets/accounts/logout_response.dart';
import 'package:talky_shared/packets/accounts/modify_account_request.dart';
import 'package:talky_shared/packets/accounts/modify_account_response.dart';
import 'package:talky_shared/packets/accounts/signup_request.dart';
import 'package:talky_shared/packets/accounts/signup_response.dart';
import 'package:talky_shared/packets/base_packet.dart';
import 'package:talky_shared/packets/chat/chat_group/create_chat_group_request.dart';
import 'package:talky_shared/packets/chat/chat_group/create_chat_group_response.dart';
import 'package:talky_shared/packets/chat/chat_group/get_chat_group_request.dart';
import 'package:talky_shared/packets/chat/chat_group/get_chat_group_response.dart';
import 'package:talky_shared/packets/chat/chat_group/join_chat_group_request.dart';
import 'package:talky_shared/packets/chat/chat_group/join_chat_group_response.dart';
import 'package:talky_shared/packets/chat/chat_group/modify_chat_group_request.dart';
import 'package:talky_shared/packets/chat/chat_group/modify_chat_group_response.dart';
import 'package:talky_shared/packets/chat/chat_message_packet.dart';
import 'package:talky_shared/packets/chat/get_message_list_request.dart';
import 'package:talky_shared/packets/chat/get_message_list_response.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'src/server_data_handler.dart';

/// 服务端
class TalkyServer {
  final Uuid uuid = const Uuid(); // uuid生成器
  final String address; // 监听地址
  final int port; // 端口
  late final HttpServer server; // 服务器
  bool isClosed = false; // 服务器已经关闭

  final StreamController<LogEntry> _logStreamController =
      StreamController.broadcast(); // 日志流
  Stream<LogEntry> get logStream => _logStreamController.stream;

  // final DatabaseManager databaseManager; // 数据库管理器
  final Map<String, WebClient> _connections = HashMap(); // 客户端列表 - UUID : 客户端
  final Map<String, Account> _accounts = HashMap(); // 账户列表 - 账户id : 账户
  final Map<String, ChatGroup> _chatGroups = HashMap(); // 树洞列表 - 会话id : 树洞
  final Map<String, List<BaseChatMessage>> _messages =
      HashMap(); // 树洞消息 - 会话id : 消息列表

  TalkyServer({
    // required this.databaseManager,
    this.address = "0.0.0.0",
    this.port = 4821,
  });

  /// 启动服务器
  Future<void> start() async {
    _log(LogLevel.info, "正在启动服务器($address:$port)...");
    final handler = webSocketHandler(_onConnection); // 创建句柄
    server = await serve(handler, address, port); // 开始服务
    _log(LogLevel.info, "服务器已启动(${server.address.host}:${server.port})...");
  }

  /// 新连接
  void _onConnection(WebSocketChannel webSocket, String? subprotocol) {
    // 新连接 //
    final client = WebClient(
      id: uuid.v7(), // 生成客户端连接id
      webSocketChannel: webSocket,
    ); // 创建客户端
    _connections[client.id] = client; // 添加到客户端列表
    _log(LogLevel.info, "新连接: ${client.id}");
    // 监听客户端数据 //
    client.dataStream.listen(
      (data) {
        try {
          _onData(client, BasePacketMapper.fromJson(data));
        } catch (e) {
          _log(LogLevel.warning, "解析客户端数据失败: $e\n\t数据内容: $data");
        }
      },
      onDone: () {
        disconnectClient(client);
        _log(
          LogLevel.info,
          "客户端(${client.id})断开连接: ${webSocket.closeCode}: ${webSocket.closeReason}",
        );
      },
      onError: (e) {
        disconnectClient(client);
        _log(
          LogLevel.info,
          "客户端(${client.id})连接错误: $e\n\t${webSocket.closeCode}: ${webSocket.closeReason}",
        );
      },
    );
  }

  /// 登录账户
  bool _loginAccount(WebClient client, Account account) {
    _log(LogLevel.info, "客户端登录成功(${client.id}): ${account.username}");
    return client.login(account.id) && account.login(client.id);
  }

  /// 登出账户
  bool _logoutClient(WebClient client) {
    // 验证是否已经登录 //
    if (!client.isLogged || !_accounts.containsKey(client.accountId)) {
      return false;
    }
    final account = _accounts[client.accountId]!; // 账户
    _log(LogLevel.info, "客户端已登出(${client.id}): ${account.username}");
    return account.logout() && client.logout();
  }

  /// 转发消息
  void _forwardMessage(WebClient client, ChatMessagePacket packet) {
    for (var accountId in _chatGroups[packet.chatMessage.target]!.members) {
      // 验证账户是否有效且不为当前登录的账户
      if (_accounts.containsKey(accountId) && client.accountId != accountId) {
        final account = _accounts[accountId]!; // 获取账户
        // 账户已登录且登录账户的客户端存在
        if (_connections.containsKey(account.clientId)) {
          _connections[account.clientId]!.send(packet);
        }
      }
    }
  }

  /// 断开客户端连接
  void disconnectClient(WebClient client) {
    _connections.remove(client.id); // 移除客户端
    // 如果登录了则登出客户端
    if (client.accountId != null) {
      _logoutClient(client);
    }
  }

  /// 注册账户
  ///
  /// 返回创建的账号
  Account _signupAccount(WebClient client, SignupRequest packet) {
    final id = uuid.v4(); // 生成账户id
    final account = Account(
      id: id,
      username: packet.username,
      password: packet.password,
      age: packet.age,
      hobbyTags: packet.hobbies,
      signature: packet.signature,
      phoneNumber: packet.phoneNumber,
      email: packet.email,
    ); // 创建账号
    _accounts[id] = account; // 添加到字典
    return account;
  }

  /// 修改账户
  ///
  /// 返回修改后的账号
  Account _modifyAccount(WebClient client, ModifyAccountRequest packet) {
    final account = _accounts[client.accountId]!;
    account.username = packet.username ?? account.username;
    account.password = packet.password ?? account.password;
    account.age = packet.age ?? account.age;
    account.hobbyTags = packet.hobbies ?? account.hobbyTags;
    account.signature = packet.signature ?? account.signature;
    account.phoneNumber = packet.phoneNumber ?? account.phoneNumber;
    account.email = packet.email ?? account.email;
    return account;
  }

  /// 创建树洞
  ChatGroup _createChatGroup(WebClient client, CreateChatGroupRequest packet) {
    final id = uuid.v7(); // 生成树洞id
    final chatGroup = ChatGroup(
      id: id,
      name: packet.name,
      description: packet.description,
      hobbyTags: packet.hobbyTags,
      owner: client.accountId!, // 所有者为客户端
      members: [client.accountId!], // 将所有者添加到成员列表
    ); // 创建树洞
    _chatGroups[chatGroup.id] = chatGroup; // 添加到树洞组
    _accounts[client.accountId]!.joinedChatGroup.add(id); // 添加树洞到账户
    _messages[chatGroup.id] = []; // 初始化消息列表
    return chatGroup;
  }

  /// 修改树洞
  ChatGroup _modifyChatGroup(WebClient client, ModifyChatGroupRequest packet) {
    final newChatGroup = packet.chatGroup;
    final chatGroup = _chatGroups[newChatGroup.id]!;
    chatGroup.name = newChatGroup.name;
    chatGroup.description = newChatGroup.description;
    chatGroup.hobbyTags = newChatGroup.hobbyTags;
    return chatGroup;
  }

  /// 加入树洞
  void _joinChatGroup(WebClient client, ChatGroup chatGroup) {
    final accountId = client.accountId!; // 账户id
    chatGroup.members.add(accountId); // 添加到组
    _accounts[accountId]!.joinedChatGroup.add(chatGroup.id); // 添加到账户
  }

  /// 关闭服务器
  Future<dynamic> closeServer() async {
    if (!isClosed) {
      _log(LogLevel.info, "正在关闭服务器");
      isClosed = true; // 标记关闭
      // 关闭所有客户端
      for (var client in _connections.values) {
        client.close(0, "Server closed");
      }
      return await server.close();
    }
  }

  /// 释放资源
  void dispose() {
    _logStreamController.close();
  }

  /// 通过用户名获取用户
  Account? _getAccountFromName(String username) {
    for (var account in _accounts.values) {
      if (account.username == username) return account;
    }
    return null;
  }

  /// 通过id检查用户是否登录
  bool checkLogged(String id) {
    for (var client in _connections.values) {
      if (client.accountId == id) return client.isLogged;
    }
    return false;
  }

  /// 获取账户的有效树洞
  List<ChatGroup> getAccountChatGroup(Account account) {
    return account.joinedChatGroup
        .where((id) => _chatGroups.containsKey(id))
        .map((id) => _chatGroups[id]!)
        .toList();
  }

  /// 获取树洞的消息
  List<BaseChatMessage>? getMessageList(String id, String? startId, int count) {
    if (!_messages.containsKey(id)) return null;
    final messageList = _messages[id]!;

    if (startId != null) {
      int startIndex = messageList.indexWhere(
        (element) => element.id == startId,
      );
      if (startIndex == -1) return null; // 未找到指定消息

      int start = max(0, startIndex - count); // 起始索引，确保不小于0
      return messageList.sublist(start, startIndex);
    } else {
      int start = max(messageList.length - count, 0);
      return messageList.sublist(start);
    }
  }

  /// 清理账户的无效树洞
  void cleanInvalidChatGroups(Account account) {
    account.joinedChatGroup.removeWhere((id) => !_chatGroups.containsKey(id));
  }

  /// 记录日志
  void _log(LogLevel level, String m) {
    _logStreamController.add(LogEntry(level: level, m: m));
  }
}
