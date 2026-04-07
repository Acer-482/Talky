/// 日志等级
enum LogLevel { info, warning, error }

/// 日志等级拓展
extension LogLevelExtension on LogLevel {
  String get displayName => switch (this) {
    LogLevel.info => "INFO",
    LogLevel.warning => "WARNING",
    LogLevel.error => "ERROR",
  };
}
