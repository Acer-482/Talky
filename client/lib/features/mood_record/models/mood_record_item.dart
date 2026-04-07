import 'package:dart_mappable/dart_mappable.dart';

part 'mood_record_item.mapper.dart';

/// 情绪记录项
@MappableClass()
class MoodRecordItem with MoodRecordItemMappable {
  /// 今日情绪分数
  ///
  /// 值介于0~10之间
  final int score;

  /// 日记
  final String? diary;

  /// 创建时间戳
  final DateTime stamp;

  MoodRecordItem({required this.score, this.diary, DateTime? stamp})
    : stamp = stamp ?? DateTime.now();
}
