import 'package:talky_shared/log/log_level.dart';

/// 日志项
///
/// 方便流传递与统一输出
class LogEntry {
  /// 日志等级
  final LogLevel level;

  /// 日志内容
  final String m;

  /// 时间戳
  final DateTime stamp;

  LogEntry({required this.level, required this.m}) : stamp = DateTime.now();

  String get stdLog => "[${stamp.toIso8601String()} ${level.displayName}] $m";
}
