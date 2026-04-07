import 'package:flutter/material.dart';
import 'package:talky_client/core/services/network_service.dart';

/// 基本网络模型
///
/// 与网络服务配合进行依赖注入
abstract class BaseNetworkModel extends ChangeNotifier {
  BaseNetworkModel({required this.networkService});

  final NetworkService networkService; // 网络服务

  bool get isConnected => networkService.connectionState == .connected; // 已连接
  bool get isDisconnected =>
      networkService.connectionState == .disconnected; // 未连接
}
