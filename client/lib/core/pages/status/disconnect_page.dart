import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talky_client/core/services/network_service.dart';

/// 未连接页面
class DisconnectPage extends StatelessWidget {
  const DisconnectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final networkService = context.read<NetworkService>();
    return GestureDetector(
      onTap: () {
        if (networkService.connectionState == .disconnected) {
          networkService.connect(); // 连接到服务器
        }
      },
      behavior: .translucent, // 允许响应点击空白区域
      child: const Center(
        child: Column(
          spacing: 10,
          mainAxisAlignment: .center,
          children: [Text('未连接到服务器'), Text('轻触页面连接到服务器')],
        ), // 垂直布局
      ), // 中心布局
    ); // 点击响应
  }
}
