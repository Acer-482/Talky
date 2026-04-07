import 'package:flutter/material.dart';

/// 按钮工具类
class ButtonUtils {
  /// 构建大按钮
  ///
  /// 参数：
  /// - [label] - 按钮标签
  /// - [icon] - 图标数据
  /// - [onPressed] - 当按钮按下时
  /// - [padding] - 内边距
  static Widget buildLargeButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    EdgeInsetsGeometry? padding = const .all(4)
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 16,
        ), // 内边距
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ), // 圆角矩形边框
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ), // 文本样式
      ), // 样式
      child: Container(padding: padding, child:  Column(
        spacing: 8, // 间距
        mainAxisSize: .min,
        children: [
          Icon(icon, size: 32), // 图标
          Text(label), // 内容
        ],
      )), // 垂直布局
    ); // 高架按钮
  }
}
