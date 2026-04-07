import 'package:flutter/material.dart';

/// 选项组
class OptionGroup extends StatelessWidget {
  /// 标题
  final String? title;

  /// 内边距
  final EdgeInsetsGeometry padding;

  /// 组件间隔
  final double spacing;

  /// 子组件
  final List<Widget> children;

  const OptionGroup({
    this.title,
    this.padding = const .all(12),
    this.spacing = 12,
    required this.children,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          spacing: spacing,
          children: <Widget>[
            if (title != null)
              Text(
                title!,
                style: TextStyle(fontWeight: .bold),
                textScaler: TextScaler.linear(1.4),
              ),
            ...children,
          ],
        ), // 垂直布局
      ), // 内边距
    ); // 卡片
  }
}
