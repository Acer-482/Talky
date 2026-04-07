import 'package:flutter/material.dart';
import 'package:talky_client/features/mood_record/models/mood_record_item.dart';
import 'package:talky_client/features/settings/models/mood_record_config_model.dart';

/// 情绪记录模型
class MoodRecordModel extends ChangeNotifier {
  final MoodRecordConfigModel moodRecordConfigModel;

  /// 获取情绪记录项
  List<MoodRecordItem> get moodRecordItems => moodRecordConfigModel.items;

  /// 获取最早记录
  DateTime get getFirstDate => moodRecordItems.first.stamp;

  /// 获取最晚记录
  DateTime get getLastDate => moodRecordItems.last.stamp;

  MoodRecordModel({required this.moodRecordConfigModel});

  /// 检查今日是否记录
  bool get checkTodayRecorded =>
      moodRecordItems.isNotEmpty &&
      moodRecordItems.last.stamp.day == DateTime.now().day;

  /// 检查是否全为一天的记录
  bool get checkOnlyToday =>
      moodRecordItems.isNotEmpty &&
      moodRecordConfigModel.items.every(
        (item) => item.stamp.day == DateTime.now().day,
      );

  /// 获取昨天记录
  List<MoodRecordItem> get getYesterdayRecords {
    final yesterday = DateTime.now().add(Duration(days: -1));
    return getRecordItems(yesterday, yesterday);
  }

  /// 记录情绪
  void recordMood(MoodRecordItem item) {
    moodRecordItems.add(item); // 添加
    moodRecordConfigModel.updateItems(moodRecordItems);
    notifyListeners(); // 通知监听
  }

  /// 删除最后一个记录
  void removeLast() {
    moodRecordItems.removeLast(); // 删除最后一个
    notifyListeners(); // 通知监听
  }

  /// 更改记录情绪
  ///
  /// 将更改最后一个记录
  void modifyRecordMood(MoodRecordItem item) {
    moodRecordItems.removeLast(); // 删除最后一个
    recordMood(item); // 记录情绪并通知监听
  }

  /// 获取情绪记录
  ///
  /// 参数：
  /// - [startDate] - 开始日期
  /// - [endDate] - 结束日期
  /// - [day] - 获取数量 当值为-1时则无限制
  List<MoodRecordItem> getRecordItems([
    DateTime? startDate,
    DateTime? endDate,
    int day = -1,
  ]) {
    List<MoodRecordItem> items = List.from(moodRecordItems); // 浅拷贝
    // 过滤日期内的记录 //
    if (startDate != null || endDate != null) {
      final start = startDate != null
          ? DateTime(startDate.year, startDate.month, startDate.day)
          : null;
      final end = endDate != null
          ? DateTime(endDate.year, endDate.month, endDate.day)
          : null;
      items = items.where((e) {
        final stampDate = DateTime(e.stamp.year, e.stamp.month, e.stamp.day);
        bool include = true;
        if (start != null) {
          include =
              include &&
              (stampDate.isAfter(start) || stampDate.isAtSameMomentAs(start));
        }
        if (end != null) {
          include =
              include &&
              (stampDate.isBefore(end) || stampDate.isAtSameMomentAs(end));
        }
        return include;
      }).toList();
    }
    // 根据开始索引获取指定数量的记录 //
    if (day != -1) {
      final i = moodRecordItems.length - day; // 获取开始索引
      items = i < 0 ? items : items.sublist(i);
    }
    return items;
  }
}
