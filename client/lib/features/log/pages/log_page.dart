import 'package:flutter/material.dart';
import 'package:talky_client/features/log/widgets/logs_widget.dart';

/// 日志页面
class LogPage extends StatelessWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .all(10),
      child: Card(child: LogWidget()),
    );
  }
}
