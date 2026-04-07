part of '../talky_server.dart';

/// 服务器数据处理拓展
extension ServerDataHandler on TalkyServer {
  // 收到数据
  void _onData(WebClient client, BasePacket packet) {
    _log(LogLevel.info, "收到数据包: ${packet.toJson()}");
    if (packet is LogInRequest) _onUserLogIn(client, packet);
    if (packet is SignupRequest) _onUserSignup(client, packet);
    if (packet is ModifyAccountRequest) _onModifyAccountRequest(client, packet);
    if (packet is LogoutRequest) _onUserLogout(client, packet);

    if (packet is CreateChatGroupRequest) _onCreateChatGroup(client, packet);
    if (packet is ModifyChatGroupRequest) _onModifyChatGroup(client, packet);
    if (packet is JoinChatGroupRequest) _onJoinChatGroup(client, packet);
    if (packet is GetChatGroupsRequest) _onGetChatGroup(client, packet);

    if (packet is GetMessageListRequest) _onGetMessageList(client, packet);
    if (packet is ChatMessagePacket) _onMessage(client, packet);

    if (packet is GetAccountProfileRequest) {
      _onGetAccountProfileRequest(client, packet);
    }
  }

  /// 登录请求
  void _onUserLogIn(WebClient client, LogInRequest packet) {
    _log(LogLevel.info, "客户端登录(${client.id}): ${packet.username}...");
    int status; // 状态
    String message; // 原因
    Account? account; // 登录到的账户
    // 验证 //
    if ((account = _getAccountFromName(packet.username)) == null) {
      // 验证账户是否存在
      status = -1;
      message = '账户不存在';
    } else if (account!.password != packet.password) {
      // 验证密码是否正确
      status = 1;
      message = '账户或密码错误';
    } else if (checkLogged(account.id)) {
      status = 2;
      message = '账户已经登录';
    } else {
      status = 0;
      message = '';
      // 登录账户 //
      _loginAccount(client, account);
    }
    // 发送回调 //
    _log(LogLevel.info, "\t$status $message");
    client.send(
      LogInResponse(account: account, status: status, message: message),
    );
  }

  /// 注册请求
  void _onUserSignup(WebClient client, SignupRequest packet) {
    _log(LogLevel.info, "客户端注册(${client.id}): ${packet.username}...");
    int status; // 状态
    String message; // 原因
    Account? account; // 注册的账户
    if ((_getAccountFromName(packet.username)) != null) {
      // 账户已经创建 //
      status = -1;
      message = '账户已经存在';
    } else if (packet.username.length < 4 || packet.password.length < 6) {
      // 数据不合法 //
      status = 1;
      message = '表单不合法';
    } else {
      status = 0;
      message = '';
      // 注册 //
      account = _signupAccount(client, packet); // 注册
      _loginAccount(client, account); // 自动登录
    }

    // 发送回调 //
    _log(LogLevel.info, "\t$status $message");
    client.send(
      SignupResponse(account: account, status: status, message: message),
    );
  }

  /// 修改账户请求
  void _onModifyAccountRequest(WebClient client, ModifyAccountRequest packet) {
    _log(LogLevel.info, "客户端修改账户(${client.id}): ${packet.username}...");
    int status; // 状态
    String message; // 原因
    Account? account; // 账户
    if (!client.isLogged) {
      // 账户未登录 //
      status = -200;
      message = '账户未登录';
    } else if (packet.username != null &&
        _getAccountFromName(packet.username!) != null) {
      // 账户已经创建 //
      status = -1;
      message = '用户名已存在';
    } else {
      status = 0;
      message = '';
      // 修改 //
      account = _modifyAccount(client, packet);
    }

    // 发送回调 //
    _log(LogLevel.info, "\t$status $message");
    client.send(
      ModifyAccountResponse(account: account, status: status, message: message),
    );
  }

  /// 登出请求
  void _onUserLogout(WebClient client, LogoutRequest packet) {
    _log(LogLevel.info, "客户端登出(${client.id})...");
    int status; // 状态
    String message; // 原因
    if (!client.isLogged) {
      // 账户已经登出 //
      status = -200;
      message = '账户未登录';
    } else if (!_logoutClient(client)) {
      status = -1;
      message = '登出失败';
    } else {
      status = 0;
      message = '';
    }
    // 发送回调 //
    _log(LogLevel.info, "\t$status $message");
    client.send(LogoutResponse(status: status, message: message));
  }

  /// 创建树洞
  void _onCreateChatGroup(WebClient client, CreateChatGroupRequest packet) {
    _log(LogLevel.info, "客户端创建树洞(${client.id}): ${packet.name}...");
    ChatGroup? chatGroup;
    int status; // 状态
    String message; // 原因
    if (_chatGroups.values.any((element) => element.name == packet.name)) {
      // 组已经创建 //
      status = -1;
      message = '树洞已经存在';
    } else if (packet.name.length < 2) {
      // 数据不合法 //
      status = -2;
      message = '表单不合法';
    } else {
      status = 0;
      message = '';
      // 创建组 //
      chatGroup = _createChatGroup(client, packet);
    }
    // 发送回调 //
    _log(LogLevel.info, "\t$status $message");
    client.send(
      CreateChatGroupResponse(
        chatGroup: chatGroup,
        status: status,
        message: message,
      ),
    );
  }

  /// 修改树洞
  void _onModifyChatGroup(WebClient client, ModifyChatGroupRequest packet) {
    _log(LogLevel.info, "客户端修改树洞(${client.id}): ${packet.chatGroup.id}...");
    int status; // 状态
    String message; // 原因
    if (!_chatGroups.containsKey(packet.chatGroup.id)) {
      // 树洞不存在 //
      status = -1;
      message = '树洞不存在';
    } else {
      status = 0;
      message = '';
      // 修改组 //
      _modifyChatGroup(client, packet);
    }
    // 发送回调 //
    _log(LogLevel.info, "\t$status $message");
    client.send(
      ModifyChatGroupResponse(
        chatGroup: status == 0 ? packet.chatGroup : null,
        status: status,
        message: message,
      ),
    );
  }

  /// 加入树洞
  void _onJoinChatGroup(WebClient client, JoinChatGroupRequest packet) {
    _log(LogLevel.info, "客户端加入树洞(${client.id}): ${packet.id}...");
    int status; // 状态
    String message; // 原因
    ChatGroup? chatGroup;
    if (!client.isLogged) {
      // 用户未登录 //
      status = -1;
      message = '用户未登录';
    } else if (!_chatGroups.containsKey(packet.id)) {
      // 树洞不存在 //
      status = -2;
      message = '树洞不存在';
    } else if (_chatGroups[packet.id]!.members.contains(client.accountId!)) {
      // 树洞不存在 //
      status = -3;
      message = '已经加入树洞';
    } else {
      status = 0;
      message = '';
      // 让用户加入树洞 //
      chatGroup = _chatGroups[packet.id]!;
      _joinChatGroup(client, chatGroup);
    }
    // 发送回调 //
    _log(LogLevel.info, "\t$status $message");
    client.send(
      JoinChatGroupResponse(
        chatGroup: chatGroup,
        status: status,
        message: message,
      ),
    );
  }

  /// 获取树洞列表
  void _onGetChatGroup(WebClient client, GetChatGroupsRequest packet) {
    _log(LogLevel.info, "客户端获取树洞列表(${client.id})...");
    int status; // 状态
    String message; // 原因
    List<ChatGroup>? chatGroups; // 聊天组
    if (client.accountId == null) {
      status = -200;
      message = '未登录';
    } else {
      status = 0;
      message = '';
      if (packet.allChatGroups) {
        // 获取所有树洞
        chatGroups = _chatGroups.values.toList();
      } else {
        // 获取账户的有效树洞
        chatGroups = getAccountChatGroup(_accounts[client.accountId]!);
      }
    }
    // 发送回调 //
    _log(LogLevel.info, "\t$status $message");
    client.send(
      GetChatGroupResponse(
        chatGroupList: chatGroups,
        allChatGroups: packet.allChatGroups,
        status: status,
        message: message,
      ),
    );
  }

  /// 获取消息列表
  void _onGetMessageList(WebClient client, GetMessageListRequest packet) {
    _log(LogLevel.info, "客户端获取树洞(${packet.id})消息(${client.id})...");
    int status; // 状态
    String message; // 原因
    String? id; // ID
    List<BaseChatMessage>? messageList; // 消息列表
    bool? isFinish; // 已完成
    if (client.accountId == null) {
      status = -1;
      message = '未登录';
    } else if ((messageList = getMessageList(
          packet.id,
          packet.startId,
          packet.count,
        )) ==
        null) {
      status = 1;
      message = '获取失败';
    } else {
      status = 0;
      message = '';
      // 获取树洞消息 //
      id = packet.id;
      isFinish =
          _messages[packet.id]!.isEmpty ||
          (messageList!.isNotEmpty &&
              _messages[packet.id]![0] == messageList[0]);
    }
    // 发送回调 //
    _log(LogLevel.info, "\t$status $message");
    client.send(
      GetMessageListResponse(
        id: id,
        messageList: messageList,
        isFinish: isFinish,
        status: status,
        message: message,
      ),
    );
  }

  /// 收到消息
  void _onMessage(WebClient client, ChatMessagePacket packet) {
    _log(LogLevel.info, "客户端消息(${client.id})...");
    if (_messages.containsKey(packet.chatMessage.target)) {
      _log(LogLevel.info, "已保存并转发消息: ${packet.chatMessage.id}");
      _messages[packet.chatMessage.target]!.add(packet.chatMessage); // 保存消息
      _forwardMessage(client, packet); // 转发客户端的消息
    } else {
      _log(LogLevel.info, "消息无效, 已抛弃");
    }
  }

  /// 获取账户资料
  void _onGetAccountProfileRequest(
    WebClient client,
    GetAccountProfileRequest packet,
  ) {
    int status; // 状态
    String message; // 原因
    AccountProfile? profile; // 账户资料
    if (client.accountId == null) {
      status = -1;
      message = '未登录';
    } else if (!_accounts.containsKey(packet.id)) {
      status = 1;
      message = '账户ID无效';
    } else {
      status = 0;
      message = '';
      // 获取账户资料 //
      final account = _accounts[packet.id]!;
      profile = AccountProfile.fromAccount(account);
    }
    // 发送回调 //
    _log(LogLevel.info, "\t$status $message");
    client.send(
      GetAccountProfileResponse(
        profile: profile,
        status: status,
        message: message,
      ),
    );
  }
}
