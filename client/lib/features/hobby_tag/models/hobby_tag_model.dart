import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talky_client/features/log/models/log_model.dart';
import 'package:talky_shared/hobby_tag/hobby_tag.dart';

/// 爱好标签模型
///
/// 提供爱好标签
class HobbyTagModel extends ChangeNotifier {
  final String _hobbyTagsPath = 'assets/data/hobby_tags.json'; // 爱好标签json文件路径

  final LogModel logModel; // 日志模型

  final List<HobbyTag> _hobbyTags = []; // 所有爱好标签

  List<HobbyTag> get hobbyTags => _hobbyTags; // 返回爱好标签

  bool get isReady => _hobbyTags.isNotEmpty; // 检测是否已经准备好

  HobbyTagModel({required this.logModel});

  /// 获取所有标签
  Future<bool> getHobbyTags() async {
    if (isReady) return true; // 已经加载
    // 解析为列表 //
    try {
      final jsonString = await rootBundle.loadString(
        _hobbyTagsPath,
      ); // 读取json字符串
      final List<dynamic> jsonList = jsonDecode(jsonString); // 解码json
      _hobbyTags.addAll(
        jsonList.map((e) => HobbyTagMapper.fromMap(e)).toList(),
      ); // 添加到提示
      notifyListeners(); // 通知监听
      return true;
    } catch (e) {
      logModel.log(.warning, '加载爱好标签失败：$e');
      return false;
    }
  }
}
