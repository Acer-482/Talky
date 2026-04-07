import 'dart:async';

import 'package:flutter/material.dart';
import 'package:talky_client/features/account/models/account_model.dart';
import 'package:talky_client/core/models/base_network_model.dart';
import 'package:talky_client/features/log/models/log_model.dart';
import 'package:talky_client/core/models/toast/toast_model.dart';
import 'package:talky_client/core/models/toast/toast_item.dart';
import 'package:talky_shared/account/account_profile.dart';
import 'package:talky_shared/chat/base_chat_message.dart';
import 'package:talky_shared/chat/chat_group/chat_group.dart';
import 'package:talky_shared/packets/accounts/get_account_profile_request.dart';
import 'package:talky_shared/packets/accounts/get_account_profile_response.dart';
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

/// 聊天模型
class ChatModel extends BaseNetworkModel {
  final LogModel logModel; // 日志模型
  final ToastModel toastModel; // 弹窗模型
  final AccountModel accountModel; // 账户模型

  late final StreamSubscription<BasePacket> _dataSubscription; // 数据订阅

  List<ChatGroup>? chatGroupList; // 用户聊天组列表
  List<ChatGroup>? allChatGroupList; // 所有聊天组列表
  Map<String, List<BaseChatMessage>> messageList = {}; // 消息列表 - 会话id : 消息列表
  final Map<String, bool> _isRefreshing = {}; // 树洞是否刷新
  final Map<String, AccountProfile> _accountProfileList = {}; // 账户资料

  ChatModel({
    required this.logModel,
    required this.toastModel,
    required this.accountModel,
    required super.networkService,
  }) {
    accountModel.addListener(() {
      // 已经登录
      if (accountModel.isLogged) {
        // 刷新树洞列表
        sendGetChatGroupRequest();
      }
      notifyListeners(); // 更新监听
    }); // 账户状态变更更新监听
    _dataSubscription = networkService.dataStream
        .where(
          (d) =>
              d is GetChatGroupResponse ||
              d is CreateChatGroupResponse ||
              d is ModifyChatGroupResponse ||
              d is JoinChatGroupResponse ||
              d is GetMessageListResponse ||
              d is ChatMessagePacket ||
              d is GetAccountProfileResponse,
        )
        .listen(_responseHandle); // 监听树洞回调
  }

  bool get isChatGroupVaild => chatGroupList != null;
  bool get isAllChatGroupVaild => allChatGroupList != null;
  bool checkMessageListVaild(String id) {
    return messageList[id] != null;
  }

  /// 获取账户资料
  AccountProfile? getAccountProfile(String id) {
    return _accountProfileList[id];
  }

  /// 响应处理
  void _responseHandle(BasePacket response) {
    try {
      if (response is GetChatGroupResponse) {
        // 树洞列表更新 //`
        if (response.status != 0) {
          _warningTipLog('树洞列表更新失败', '${response.message}(${response.status})');
        } else if (response.chatGroupList == null ||
            response.allChatGroups == null) {
          _warningTipLog('树洞列表更新失败', '服务器数据不合法');
        } else {
          logModel.log(.info, '树洞列表已更新');
          if (response.allChatGroups!) {
            allChatGroupList = response.chatGroupList!; // 更新所有树洞
          } else {
            chatGroupList = response.chatGroupList!; // 更新用户树洞
          }
          notifyListeners(); // 通知监听
        }
      } else if (response is CreateChatGroupResponse) {
        // 创建树洞 //
        if (response.status != 0) {
          _warningTipLog('创建树洞失败', '${response.message}(${response.status})');
        } else if (response.chatGroup == null) {
          _warningTipLog('创建树洞失败', '服务器数据不合法');
        } else {
          logModel.log(.info, '成功创建树洞');
          toastModel.addToast(
            ToastItem(
              '成功创建树洞',
              description: '成功创建了树洞${response.chatGroup!.name}，快来邀请好友加入吧！',
              type: .success,
            ),
          );
          notifyListeners(); // 通知监听
          sendGetChatGroupRequest(); // 请求更新树洞列表
        }
      } else if (response is ModifyChatGroupResponse) {
        // 创建树洞 //
        if (response.status != 0) {
          _warningTipLog('修改树洞失败', '${response.message}(${response.status})');
        } else if (response.chatGroup == null) {
          _warningTipLog('修改树洞失败', '服务器数据不合法');
        } else {
          logModel.log(.info, '成功修改树洞');
          toastModel.addToast(
            ToastItem(
              '成功修改树洞',
              description: '成功修改了树洞${response.chatGroup!.name}数据',
              type: .success,
            ),
          );
          notifyListeners(); // 通知监听
        }
      } else if (response is JoinChatGroupResponse) {
        // 加入树洞 //
        if (response.status != 0) {
          _warningTipLog('加入树洞失败', '${response.message}(${response.status})');
        } else if (response.chatGroup == null) {
          _warningTipLog('加入树洞失败', '服务器数据不合法');
        } else {
          logModel.log(.info, '成功加入树洞');
          toastModel.addToast(
            ToastItem(
              '成功加入树洞',
              description: '成功加入树洞${response.chatGroup!.name}',
              type: .success,
            ),
          );
          notifyListeners(); // 通知监听
          sendGetChatGroupRequest(); // 请求更新树洞列表
        }
      } else if (response is GetMessageListResponse) {
        // 消息列表更新 //
        if (response.status != 0) {
          _warningTipLog('更新消息列表失败', '${response.message}(${response.status})');
        } else if (response.id == null ||
            response.messageList == null ||
            response.isFinish == null) {
          _warningTipLog('更新消息列表失败', '服务器数据不合法');
        } else {
          logModel.log(.info, '消息列表已更新');
          if (messageList[response.id!] == null) {
            messageList[response.id!] = [];
          }
          final currentMessageList = messageList[response.id]!; // 当前消息列表
          final newMessages = response.messageList!; // 新消息
          // 更新列表 //
          if (_isRefreshing[response.id] ??
              false || currentMessageList.isEmpty) {
            // 刷新页面 //
            messageList[response.id!] = newMessages; // 覆盖列表
          } else {
            // 加载更多 //
            // 新消息插入头部，并去重
            final existingIds = currentMessageList.map((m) => m.id).toSet();
            final uniqueNew = newMessages
                .where((m) => !existingIds.contains(m.id))
                .toList();
            currentMessageList.insertAll(0, uniqueNew);
          }
          notifyListeners(); // 通知监听
        }
      } else if (response is ChatMessagePacket) {
        logModel.log(.info, '收到转发的消息(目标树洞: ${response.chatMessage.target})...');
        final targetId = response.chatMessage.target;
        // 新消息 //
        if (!messageList.containsKey(targetId)) {
          // 找不到目标组
          _warningTipLog('接收消息错误', '找不到组$targetId');
        } else {
          messageList[targetId]!.add(response.chatMessage); // 添加消息到当前聊天
          logModel.log(.info, '添加成功');
          notifyListeners(); // 通知监听
        }
      } else if (response is GetAccountProfileResponse) {
        // 获取账户资料 //
        if (response.status != 0) {
          _warningTipLog('获取账户资料失败', '${response.message}(${response.status})');
        } else if (response.profile == null) {
          _warningTipLog('获取账户资料失败', '服务器数据不合法');
        } else {
          logModel.log(.info, '获取账户资料成功');
          final profile = response.profile!; // 获取账户资料
          _accountProfileList[profile.id] = profile; // 保存资料
          notifyListeners(); // 通知监听
        }
      }
    } catch (e) {
      _warningTipLog('处理数据时发生错误', e.toString());
    }
  }

  /// 发送更新树洞请求
  bool sendGetChatGroupRequest({bool allChatGroups = false}) {
    if (networkService.connectionState != .connected) return false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      logModel.log(.info, '正在请求更新树洞列表...');
      networkService.send(GetChatGroupsRequest(allChatGroups: allChatGroups));
    });
    return true;
  }

  /// 发送创建树洞请求
  bool sendCreateChatGroupRequest(CreateChatGroupRequest packet) {
    if (networkService.connectionState != .connected) return false;
    logModel.log(.info, '正在请求创建树洞...');
    networkService.send(packet);
    return true;
  }

  /// 发送修改树洞请求
  bool sendModifyChatGroupRequest(ModifyChatGroupRequest packet) {
    if (networkService.connectionState != .connected) return false;
    logModel.log(.info, '正在请求修改树洞...');
    networkService.send(packet);
    return true;
  }

  /// 发送加入树洞请求
  bool sendJoinChatGroupRequest(JoinChatGroupRequest packet) {
    if (networkService.connectionState != .connected) return false;
    logModel.log(.info, '正在请求加入树洞...');
    networkService.send(packet);
    return true;
  }

  /// 发送获取消息请求
  bool sendGetMessageListRequest(GetMessageListRequest packet) {
    if (networkService.connectionState != .connected) return false;
    _isRefreshing[packet.id] = packet.startId == null; // 是否刷新
    logModel.log(.info, '正在请求更新消息列表...');
    networkService.send(packet);
    return true;
  }

  /// 发送消息
  ///
  /// 将会添加到消息列表并通知更新
  bool sendMessage(String targetId, ChatMessagePacket packet) {
    if (networkService.connectionState != .connected) return false;
    if (!messageList.containsKey(targetId)) return false;
    messageList[targetId]!.add(packet.chatMessage); // 添加消息到本地
    networkService.send(packet); // 发送数据包
    notifyListeners(); // 通知监听
    return true;
  }

  /// 发送获取账户资料请求
  bool sendGetAccountProfileRequest(String id) {
    if (networkService.connectionState != .connected) return false;
    logModel.log(.info, '正在请求账户资料($id)...');
    networkService.send(GetAccountProfileRequest(id: id));
    return true;
  }

  /// 警告提示和日志
  void _warningTipLog(String title, String description) {
    toastModel.addToast(
      ToastItem(title, description: description, type: .warning),
    );
    logModel.log(.info, '$title: $description');
  }

  @override
  void dispose() {
    _dataSubscription.cancel();
    super.dispose();
  }
}
