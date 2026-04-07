import 'package:flutter/material.dart';
import 'package:talky_client/features/log/pages/log_page.dart';
import 'package:talky_client/features/settings/pages/settings_page.dart';

/// 设置与日志页面
class SettingsAndLogsPage extends StatefulWidget {
  const SettingsAndLogsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsAndLogsPageState();
}

class _SettingsAndLogsPageState extends State<SettingsAndLogsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController; // 标签控制器
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置与日志'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '设置'),
            Tab(text: '日志'),
          ],
        ), // 标签栏
      ), // 标题栏
      body: TabBarView(
        controller: _tabController,
        children: [SettingsPage(), LogPage()],
      ), // 标签浏览器
    );
  }
}
