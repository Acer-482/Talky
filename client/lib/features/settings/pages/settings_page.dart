import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talky_client/core/enums/theme_brightness.dart';
import 'package:talky_client/core/models/toast/toast_item.dart';
import 'package:talky_client/core/models/toast/toast_model.dart';
import 'package:talky_client/core/pages/forms/base_form_page.dart';
import 'package:talky_client/core/services/config_service.dart';
import 'package:talky_client/core/services/network_service.dart';
import 'package:talky_client/core/widgets/color_picker.dart';
import 'package:talky_client/core/widgets/network_option.dart';
import 'package:talky_client/core/widgets/option_group.dart';
import 'package:talky_client/features/settings/models/mood_record_config_model.dart';
import 'package:talky_client/features/settings/models/network_config_model.dart';
import 'package:talky_client/features/settings/models/theme_config_model.dart';
import 'package:talky_client/features/settings/models/tips_config_mode.dart';

/// 选项
class _OptionItem<T> {
  final String title;
  final List<Widget> Function(BuildContext context, T model) builder;

  _OptionItem({required this.title, required this.builder});

  /// 构建
  Widget build(BuildContext context) {
    return Consumer<T>(
      builder: (context, value, child) =>
          OptionGroup(title: title, children: builder(context, value)),
    );
  }
}

/// 设置页面
class SettingsPage extends BaseFormPage<SettingsPage> {
  const SettingsPage({super.key});

  @override
  BaseFormPageState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends BaseFormPageState<SettingsPage> {
  late final StreamSubscription _networkStateSubscription; // 网络状态订阅

  // 显示更改服务器地址窗口
  void _showModifyServerAddressDialog() async {
    showDialog(context: context, builder: (_) => ModifyServerAddressDialog());
  }

  // 显示颜色选择器
  void _showColorPicker(ThemeConfigModel config) async {
    final ret = await showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(color: config.color),
    );
    if (ret != null) {
      config.updateColor(ret); // 更新主题颜色
    }
  }

  @override
  void initState() {
    super.initState();
    final networkService = context.read<NetworkService>(); // 网络服务
    // 添加网络服务监听 //
    _networkStateSubscription = networkService.stateStream.listen(
      (event) => setState(() {}),
    );
  }

  @override
  void dispose() {
    // 取消订阅 //
    _networkStateSubscription.cancel();
    super.dispose();
  }

  List<_OptionItem> buildOptionItems(BuildContext context) {
    final networkService = context.read<NetworkService>();
    final toastModel = context.read<ToastModel>();
    return [
      _OptionItem<NetworkConfigModel>(
        title: '网络与连接',
        builder: (context, configModel) => [
          ListTile(
            leading: const Icon(Icons.abc),
            title: const Text('服务器地址'),
            subtitle: Text(networkService.buildUri().toString()), // 地址uri
            trailing: TextButton(
              onPressed: networkService.connectionState == .disconnected
                  ? _showModifyServerAddressDialog // 仅限未连接时允许点击
                  : null,
              child: const Text('更改地址'),
            ),
          ), // 服务器地址
          ListTile(
            leading: const Icon(Icons.wifi),
            title: const Text('服务器状态'),
            subtitle: Text(switch (networkService.connectionState) {
              .connected => '已连接',
              .connecting => '正在连接',
              .disconnected => '未连接',
            }),
            trailing: networkService.connectionState == .disconnected
                ? TextButton(
                    onPressed: () async {
                      await networkService.connect(); // 连接
                    },
                    child: const Text('连接'),
                  )
                : networkService.connectionState == .connected
                ? TextButton(
                    onPressed: () {
                      networkService.close(); // 断开连接
                    },
                    child: const Text('断开连接'),
                  )
                : CircularProgressIndicator(),
          ), // 服务器状态
          ListTile(
            leading: const Icon(Icons.connect_without_contact),
            title: const Text('自动连接'),
            subtitle: const Text('进入应用后自动连接到服务器'),
            trailing: Switch(
              value: configModel.autoConnect,
              onChanged: (value) => configModel.updateAutoConnect(value),
            ),
          ), // 自动连接
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('自动登录'),
            subtitle: const Text('在未登录时自动跳转到登录页面'),
            trailing: Switch(
              value: configModel.autoLogin,
              onChanged: (value) => configModel.updateAutoLogin(value),
            ),
          ), // 自动登录
        ],
      ), // 网络与连接
      _OptionItem<ThemeConfigModel>(
        title: '主题',
        builder: (context, themeConfigModel) => [
          ListTile(
            leading: const Icon(Icons.colorize),
            title: Text('主题颜色'),
            trailing: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: themeConfigModel.color,
                shape: BoxShape.circle,
              ),
            ),
            onTap: () => _showColorPicker(themeConfigModel),
          ), // 主题颜色
          ListTile(
            leading: const Icon(Icons.light_mode),
            title: Text('主题亮暗'),
            trailing: DropdownButton(
              borderRadius: .all(.circular(4)), // 圆角
              value: themeConfigModel.brightness, // 当前值
              items: ThemeBrightness.values
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Padding(
                        padding: .all(4),
                        child: Text(e.displayName),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => themeConfigModel.updateBrightness(
                value ?? ThemeBrightness.system,
              ), // 更改模式
            ),
          ), // 主题亮暗
        ],
      ), // 主题
      _OptionItem<MoodRecordConfigModel>(
        title: '主页 - 情绪记录',
        builder: (context, config) => [
          ListTile(
            leading: const Icon(Icons.numbers),
            title: const Text('图表最大显示数量'),
            subtitle: const Text('提示：数量过高易导致日期重叠'),
            trailing: DropdownButton(
              borderRadius: .all(.circular(4)), // 圆角
              value: config.chartMaxPointCount,
              items: [3, 5, 7, 10, 14, 15, 20, 30, 60, 90, 120, 360, 720, -1]
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e != -1 ? e.toString() : '无限制'),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  config.updateMoodRecordChartMaxPointCount(value!),
            ),
          ), // 图表最大显示数量
        ],
      ), // 主页 - 情绪记录
      _OptionItem<TipsConfigModel>(
        title: '主页 - 心理小知识',
        builder: (context, config) => [
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('心理小知识生成数量'),
            subtitle: const Text('将在下一次生成时生效'),
            trailing: DropdownButton(
              borderRadius: .all(.circular(4)), // 圆角
              value: config.spawnCount,
              items: [1, 3, 5, 6, 8, 10]
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Padding(
                        padding: .all(4),
                        child: Text(e.toString()),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => config.updateSpawnCount(value!),
            ),
          ), // 心理小知识生成数量
        ],
      ), // 主页 - 提示
      _OptionItem<ConfigService>(
        title: '其他',
        builder: (context, configService) => [
          ListTile(
            leading: const Icon(Icons.clear_all),
            title: const Text('清空所有设置'),
            subtitle: const Text('清空所有选项、设置和数据'),
            trailing: TextButton.icon(
              onPressed: () async {
                final ret = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('清空所有设置'),
                    content: Text('将清空所有选项、设置和数据\n该操作不可撤销！\n数据无价，谨慎操作！'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('确定'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('取消'),
                      ),
                    ],
                    actionsAlignment: .center,
                  ),
                );
                if (ret) {
                  if (await configService.clearAll()) {
                    toastModel.addToast(
                      ToastItem(
                        '清空成功',
                        description: '成功清空所有设置',
                        type: .success,
                      ),
                    );
                    setState(() {}); // 更新UI
                  } else {
                    toastModel.addToast(
                      ToastItem('清空失败', description: '无法清空设置', type: .warning),
                    );
                  }
                }
              },
              icon: const Icon(Icons.clear),
              label: const Text('清空', style: TextStyle(color: Colors.red)),
            ),
          ), // 清空所有设置
        ],
      ), // 其他
    ];
  }

  @override
  List<Widget> buildChildren(BuildContext context) {
    return buildOptionItems(context).map((e) => e.build(context)).toList();
  }

  @override
  void onSubmit() {
    Navigator.pop(context); // 返回
  }

  @override
  String? get title => null;

  @override
  String? get floatingActionButtonText => null;
}
