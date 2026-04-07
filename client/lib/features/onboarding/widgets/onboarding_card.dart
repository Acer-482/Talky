import 'package:flutter/material.dart';

/// 引导卡片
class OnboardingCard extends StatelessWidget {
  final String title; // 标题
  final String description; // 描述
  final IconData icon; // 图标

  const OnboardingCard({
    required this.title,
    required this.description,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80), // 图标
          const SizedBox(height: 16), // 16+16像素高的间距
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ), // 标题文本
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ), // 描述文本
        ],
      ), // 垂直布局
    ); // 容器
  }
}
