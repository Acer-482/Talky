import 'package:flutter/material.dart';
import 'package:talky_client/features/account/pages/forms/login_form_page.dart';

/// 未登录提示页面
class NotLoggedPage extends StatelessWidget {
  const NotLoggedPage({super.key});

  // 导航到登录页面
  Future<void> _navigateToLoginPage(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginFormPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToLoginPage(context),
      behavior: .translucent, // 允许响应点击空白区域
      child: const Center(
        child: Column(
          spacing: 10,
          mainAxisAlignment: .center,
          children: [Text('您暂未登录'), Text('轻触页面登录')],
        ), // 垂直布局
      ), // 居中
    ); // 手势检测器
  }
}
