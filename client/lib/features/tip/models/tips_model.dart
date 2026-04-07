import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:talky_client/features/log/models/log_model.dart';
import 'package:talky_client/features/settings/models/tips_config_mode.dart';
import 'package:talky_client/features/tip/models/tip.dart';

/// 提示模型
class TipsModel extends ChangeNotifier {
  final String _tipsPath = 'assets/data/tips.json'; // 提示json文件路径

  final LogModel logModel; // 日志模型
  final TipsConfigModel tipsConfigModel; // 提示配置模型

  final List<Tip> _tips = []; // 所有提示

  /// 获取每日提示
  List<Tip> get dayTips => tipsConfigModel.dayItems;

  TipsModel({required this.logModel, required this.tipsConfigModel});

  /// 加载所有提示
  Future<bool> load() async {
    if (_tips.isNotEmpty) {
      _tips.clear();
    }
    // 解析为列表 //
    final jsonString = await rootBundle.loadString(_tipsPath); // 读取json字符串
    final List<dynamic> jsonList = jsonDecode(jsonString); // 解码json
    try {
      _tips.addAll(jsonList.map((e) => TipMapper.fromMap(e)).toList()); // 添加到提示
      return true;
    } catch (e) {
      logModel.log(.warning, '加载提示失败：$e');
      return false;
    }
  }

  /// 检查并更新 每日提示
  Future<void> checkAndRefresh() async {
    // 每日提示为空或者时间戳超过一天则更新 //
    if (tipsConfigModel.dayItems.isEmpty ||
        tipsConfigModel.stamp.day != DateTime.now().day) {
      await spawnDayTips(); // 更新每日提示
    }
  }

  /// 生成每日提示
  Future<void> spawnDayTips() async {
    // 检查是否有提示 //
    if (_tips.isEmpty) {
      if (await load()) {
        spawnDayTips();
        return;
      }
      logModel.log(.warning, '无提示，生成今日提示失败');
      return;
    }
    // 生成每日提示 //
    final List<Tip> dayTips = [];
    for (int i = 0; i < tipsConfigModel.spawnCount; i++) {
      dayTips.add(_tips[Random().nextInt(_tips.length)]); // 添加随机提示
    }
    await tipsConfigModel.updateStamp(DateTime.now()); // 更新时间戳
    await tipsConfigModel.updateDayItems(dayTips); // 更新每日提示
    logModel.log(.info, '今日提示已更新'); // 日志
    notifyListeners(); // 通知更新
  }
}
