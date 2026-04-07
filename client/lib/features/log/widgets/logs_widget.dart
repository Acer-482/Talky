import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talky_client/features/log/models/log_model.dart';
import 'package:talky_shared/log/log_level.dart';

// 日志组件
class LogWidget extends StatelessWidget {
  const LogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LogModel>(
      builder: (context, logModel, child) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: .all(.circular(10)),
        ), // 装饰器
        padding: .all(10),
        child: SelectionArea(
          child: ListView.builder(
            shrinkWrap: true, // 收缩组件
            reverse: true, // 反转
            itemCount: logModel.logCount, // 日志数量
            itemBuilder: (context, index) {
              final log =
                  logModel.logList[logModel.logCount - index - 1]; // 获取当前日志
              final color = switch (log.level) {
                LogLevel.info => Theme.of(context).textTheme.bodyMedium?.color,
                LogLevel.warning => Colors.yellow,
                LogLevel.error => Colors.red,
              }; // 获取日志颜色
              return ListTile(
                dense: true, // 紧凑模式
                subtitle: SelectableText(log.stamp.toIso8601String()),
                title: SelectableText(
                  log.m, // 日志内容
                  style: TextStyle(color: color), // 文本样式
                ), // 可选择文本
              );
            }, // 构建器
          ), // 日志列表
        ),
      ), // 容器
    ); // 日志模型 状态提供
  }
}
