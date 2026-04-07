import 'package:talky_server/talky_server.dart';
import 'package:talky_shared/log/log_entry.dart';
import 'package:talky_shared/mappers.dart';

late final TalkyServer server;

/// MAIN
void main(List<String> args) async {
  try {
    init();
    await server.start(); // 启动服务端
  } catch (e) {
    _log(LogEntry(level: .error, m: e.toString()));
  }
}

// 初始化
void init() {
  initializeSharedMappers();
  
  server = TalkyServer(); // 创建服务器
  server.logStream.listen(_log); // 设置日志监听器
}

// 日志
void _log(LogEntry logEntry) {
  print(logEntry.stdLog);
}
