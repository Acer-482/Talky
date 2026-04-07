import 'dart:async';

import 'package:flutter/material.dart';
import 'package:talky_client/core/models/toast/toast_item.dart';

/// 弹窗模型
class ToastModel extends ChangeNotifier {
  final StreamController<ToastItem> _toastStreamController =
      StreamController.broadcast();
  Stream<ToastItem> get toastStream => _toastStreamController.stream;

  ToastModel();

  /// 添加弹窗
  ///
  /// 将添加到流，由外部调用显示
  void addToast(ToastItem item) {
    _toastStreamController.add(item);
  }

  @override
  void dispose() {
    _toastStreamController.close(); // 关闭监听流
    super.dispose();
  }
}
