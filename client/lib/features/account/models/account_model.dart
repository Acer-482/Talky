import 'dart:async';

import 'package:flutter/material.dart';
import 'package:talky_client/features/ai_chat/models/ai_chat_model.dart';
import 'package:talky_client/core/models/base_network_model.dart';
import 'package:talky_client/core/enums/network_connection_state.dart';
import 'package:talky_client/features/log/models/log_model.dart';
import 'package:talky_client/core/models/toast/toast_model.dart';
import 'package:talky_client/core/models/toast/toast_item.dart';
import 'package:talky_shared/account/account.dart';
import 'package:talky_shared/packets/accounts/log_in_request.dart';
import 'package:talky_shared/packets/accounts/log_in_response.dart';
import 'package:talky_shared/packets/accounts/logout_request.dart';
import 'package:talky_shared/packets/accounts/logout_response.dart';
import 'package:talky_shared/packets/accounts/modify_account_request.dart';
import 'package:talky_shared/packets/accounts/modify_account_response.dart';
import 'package:talky_shared/packets/accounts/signup_response.dart';
import 'package:talky_shared/packets/accounts/signup_request.dart';
import 'package:talky_shared/packets/base_packet.dart';

/// 账户模型
///
/// 管理账户信息、注册和登录一类操作和事件
class AccountModel extends BaseNetworkModel {
  final LogModel logModel; // 日志模型
  final ToastModel toastModel; // 弹窗模型
  final AiChatModel aiChatModel; // AI聊天模型

  Account? account; // 当前账户
  bool isLogging = false; // 正在请求登录

  late final StreamSubscription<NetworkConnectionState>
  _stateSubscription; // 状态订阅
  late final StreamSubscription<BasePacket> _dataSubscription; // 数据订阅

  AccountModel({
    required super.networkService,
    required this.logModel,
    required this.toastModel,
    required this.aiChatModel,
  }) {
    _stateSubscription = networkService.stateStream.listen(
      _onStateChange,
    ); // 状态变更更新监听
    _dataSubscription = networkService.dataStream
        .where(
          (d) =>
              d is LogInResponse ||
              d is SignupResponse ||
              d is ModifyAccountResponse ||
              d is LogoutResponse,
        )
        .listen(_dataHandle); // 监听注册回调
  }

  /// 账户是否登录
  bool get isLogged => account != null;

  // 状态变更
  void _onStateChange(NetworkConnectionState state) {
    if (state == .connected) {
      // 连接成功 //
      toastModel.addToast(
        ToastItem('连接成功', description: '成功连接到服务器', type: .success),
      );
    } else if (state == .disconnected) {
      // 断开连接 //
      isLogging = false; // 取消请求状态
      account = null; // 移除账户
      toastModel.addToast(ToastItem('连接断开', description: '与服务器断开连接'));
    }
    notifyListeners();
  }

  // 数据处理
  void _dataHandle(BasePacket response) {
    try {
      if (response is LogInResponse) {
        isLogging = false; // 取消请求状态
        // 登录回调 //
        if (response.status == 0) {
          account = response.account!;
          toastModel.addToast(
            ToastItem(
              '登录成功',
              description: '${account!.username}，欢迎回来！',
              type: .success,
            ),
          );
          logModel.log(.info, '成功登录');
          aiChatModel.sendSystemMessage(
            '用户在软件内登录到了账户，账户数据如下（作为参考）：\n${account!.toJson()}',
          ); // 发送系统消息告诉AI
          notifyListeners(); // 通知监听
        } else {
          toastModel.addToast(
            ToastItem('登录失败', description: response.message, type: .warning),
          );
          logModel.log(.info, '登录失败: ${response.message}(${response.status})');
        }
      } else if (response is SignupResponse) {
        isLogging = false; // 取消请求状态
        // 注册回调 //
        if (response.status == 0) {
          account = response.account!;
          toastModel.addToast(
            ToastItem(
              '注册成功',
              description: '成功注册了账号${account!.username}，欢迎来到Talky！',
              type: .success,
            ),
          );
          logModel.log(.info, '成功注册');
          notifyListeners(); // 通知监听
        } else {
          toastModel.addToast(
            ToastItem('注册失败', description: response.message, type: .warning),
          );
          logModel.log(.info, '注册失败: ${response.message}(${response.status})');
        }
      } else if (response is ModifyAccountResponse) {
        // 修改账户回调 //
        if (response.status != 0) {
          toastModel.addToast(
            ToastItem('修改账户失败', description: response.message, type: .warning),
          );
          logModel.log(
            .info,
            '修改账户失败: ${response.message}(${response.status})',
          );
        } else if (response.account == null) {
          toastModel.addToast(
            ToastItem('修改账户失败', description: '服务器数据不合法', type: .warning),
          );
          logModel.log(.info, '修改账户失败: 服务器数据不合法');
        } else {
          toastModel.addToast(
            ToastItem(
              '修改账户成功',
              description: '成功修改账户${account!.username}的数据',
              type: .success,
            ),
          );
          account = response.account!;
          logModel.log(.info, '成功修改账户');
          notifyListeners(); // 通知监听
        }
      } else if (response is LogoutResponse) {
        // 登出回调 //
        if (response.status == 0) {
          toastModel.addToast(
            ToastItem(
              '登出成功',
              description: '成功登出账号${account!.username}',
              type: .success,
            ),
          );
          account = null; // 账户设置为空
          logModel.log(.info, '成功登出');
          notifyListeners(); // 通知监听
        } else {
          toastModel.addToast(
            ToastItem('登出失败', description: response.message, type: .warning),
          );
          logModel.log(.info, '登出失败: ${response.message}(${response.status})');
        }
      }
    } catch (e) {
      toastModel.addToast(
        ToastItem('处理数据时发生错误', description: e.toString(), type: .error),
      );
      logModel.log(.info, '处理数据时发生错误: $e');
    }
  }

  // 发送登录请求
  bool sendLoginRequest(LogInRequest packet) {
    if (networkService.connectionState != .connected) return false;
    logModel.log(.info, '正在请求登录...');
    networkService.send(packet);
    isLogging = true; // 设置请求状态
    return true;
  }

  // 发送注册请求
  bool sendSignUpRequest(SignupRequest packet) {
    if (networkService.connectionState != .connected) return false;
    logModel.log(.info, '正在请求注册...');
    networkService.send(packet);
    isLogging = true; // 设置请求状态
    return true;
  }

  // 发送更改账户请求
  bool sendModifyAccountRequest(ModifyAccountRequest packet) {
    if (networkService.connectionState != .connected) return false;
    logModel.log(.info, '正在请求修改账户...');
    networkService.send(packet);
    return true;
  }

  // 发送登出请求
  bool sendLogoutRequest() {
    if (networkService.connectionState != .connected) return false;
    logModel.log(.info, '正在请求登出...');
    networkService.send(LogoutRequest());
    isLogging = true; // 设置请求状态
    return true;
  }

  /// 构建头像
  Widget? buildAvatar() {
    return account == null ? null : getAvatar(account!.username);
  }

  /// 获取头像
  Widget getAvatar(String name) {
    return CircleAvatar(
      child: Text(name.substring(0, 1), style: TextStyle(fontWeight: .bold)),
    );
  }

  @override
  void dispose() {
    _stateSubscription.cancel();
    _dataSubscription.cancel();
    super.dispose();
  }
}
