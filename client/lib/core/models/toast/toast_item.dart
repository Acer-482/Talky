import 'package:flutter/material.dart';
import 'package:talky_client/core/pages/main_page.dart';
import 'package:toastification/toastification.dart';

/// 弹窗项
class ToastItem {
  final String title;
  final String? description;
  final Icon? icon;
  final ToastificationType type;
  final ToastificationStyle? style;
  final Duration autoCloseDuration;
  final Alignment? alignment;

  const ToastItem(
    this.title, {
    this.description,
    this.icon,
    this.type = .info,
    this.style,
    this.autoCloseDuration = const Duration(seconds: 3),
    this.alignment,
  });

  ToastificationItem show(BuildContext context) {
    final layoutMode = MainPage.getLayoutMode(context);
    return toastification.show(
      context: context,
      title: Text(title), // 标题
      description: description != null ? Text(description!) : null, // 详细信息
      icon: icon, // 图标
      type: type, // 类型
      style: style ?? (layoutMode == 1 ? .fillColored : .flatColored), // 样式
      autoCloseDuration: autoCloseDuration, // 自动关闭时间
      alignment:
          alignment ??
          (layoutMode == 1
              ? .topCenter // 移动端 顶部居中
              : .topRight), // 平板/桌面端 右上角
      showProgressBar: true, // 显示进度条
    );
  }
}
