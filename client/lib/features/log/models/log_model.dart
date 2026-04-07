import 'dart:async';

import 'package:flutter/material.dart';
import 'package:talky_shared/log/log_entry.dart';
import 'package:talky_shared/log/log_level.dart';

/// 日志模型
///
/// 大一统各大服务日志，提供相关方法
class LogModel extends ChangeNotifier {
  final List<LogEntry> _logs = []; // 日志内容

  final StreamController<LogEntry> _logStreamController =
      StreamController.broadcast(); // 日志流控制器

  final List<StreamSubscription> _subscriptions = []; // 流订阅

  LogModel();

  /// 监听日志流
  ///
  /// 用户无需手动管理[StreamSubscription]，当模型销毁时将自动销毁
  StreamSubscription<LogEntry> listenStream(Stream<LogEntry> stream) {
    final subscription = stream.listen(logEntry);
    _subscriptions.add(subscription);
    return subscription;
  }

  /// 添加日志
  ///
  /// 包装[LogEntry]构造方便大量调用
  void log(LogLevel level, String m) {
    return logEntry(LogEntry(level: level, m: m));
  }

  /// 添加日志
  void logEntry(LogEntry log) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logs.add(log);
      _logStreamController.add(log);
      notifyListeners(); // 通知监听
    });
  }

  @override
  void dispose() {
    // 取消订阅
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _logStreamController.close(); // 关闭流
    super.dispose();
  }

  /// 获取日志流
  Stream<LogEntry> get logStream => _logStreamController.stream;

  /// 获取日志列表
  List<LogEntry> get logList => _logs;

  /// 日志数量
  int get logCount => _logs.length;
}
