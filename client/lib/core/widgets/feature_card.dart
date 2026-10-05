import 'package:flutter/material.dart';
import 'package:talky_client/core/pages/main_page.dart';

/// 功能卡片
///
/// 用于在主页展示某种功能的卡片
class FeatureCard extends StatelessWidget {
  /// 标题
  final String title;

  /// 操作组件
  final List<Widget>? actions;

  /// 间距
  final double spacing;

  /// 子组件构建器
  final List<Widget> Function(int layoutMode, double textScaler)
  childrenBuilder;

  const FeatureCard({
    required this.title,
    this.actions,
    this.spacing = 10,
    required this.childrenBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final layoutMode = MainPage.getLayoutMode(context); // 获取布局模式
    // 根据布局模式调整UI //
    final double titleScaler = layoutMode == 1 ? 1.2 : 1.4; // 标题缩放
    final double outerPadding = layoutMode == 1 ? 12 : 16; // 卡片内边距
    final double textScaler = layoutMode == 1 ? 0.9 : 1; // 文本缩放
    return Card(
      child: Container(
        padding: .all(outerPadding),
        child: Column(
          spacing: spacing, // 间距
          mainAxisSize: .min, // 收缩组件
          crossAxisAlignment: .center,
          children: [
            Row(
              children: [
                Text(title, textScaler: .linear(titleScaler)),
                const Spacer(),
                ...?actions,
              ],
            ),
            ...childrenBuilder.call(layoutMode, textScaler),
          ],
        ), // 垂直布局
      ), // 容器
    ); // 卡片
  }
}
