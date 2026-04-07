import 'package:talky_client/features/mood_record/models/mood_record_item.dart';
import 'package:talky_client/features/settings/models/base_config_model.dart';

/// 情绪记录配置模型
class MoodRecordConfigModel extends BaseConfigModel {
  static const String _keyItems = 'items'; // 数据
  static const String _keyChartMaxPointCount =
      'chart_max_point_count'; // 图表最大显示数量
  static const String _keyLastViewedStamp = 'last_viewed_stamp'; // 上次查看时间戳

  @override
  String get mainKey => 'mood_record';

  /// 数据
  late List<MoodRecordItem> items = [];

  /// 图表最大显示数量
  late int chartMaxPointCount;

  /// 上次查看时间戳
  late DateTime lastViewedStamp;

  MoodRecordConfigModel({required super.configService});

  @override
  Future<void> init() async {
    items = await configService.getList(
      getKey(_keyItems),
      [],
      MoodRecordItemMapper.fromJson,
    );
    chartMaxPointCount = await configService.getInt(
      getKey(_keyChartMaxPointCount),
      20,
    );
    lastViewedStamp = await configService.getDateTime(
      getKey(_keyLastViewedStamp),
      DateTime.now(),
    );
  }

  /// 更新数据
  Future<void> updateItems(List<MoodRecordItem> items) async {
    this.items = items;
    await configService.setList<MoodRecordItem>(
      getKey(_keyItems),
      items,
      (value) => value.toJson(),
    );
    notifyListeners();
  }

  /// 更新图表最大显示数量
  Future<void> updateMoodRecordChartMaxPointCount(
    int chartMaxPointCount,
  ) async {
    if (this.chartMaxPointCount == chartMaxPointCount) {
      return;
    }
    this.chartMaxPointCount = chartMaxPointCount;
    await configService.setInt(
      getKey(_keyChartMaxPointCount),
      chartMaxPointCount,
    );
    notifyListeners();
  }

  /// 更新上次查看时间戳
  Future<void> updateLastViewedStamp([DateTime? lastViewedStamp]) async {
    if (this.lastViewedStamp == lastViewedStamp) {
      return;
    }
    this.lastViewedStamp = lastViewedStamp ?? DateTime.now();
    await configService.setDateTime(
      getKey(_keyLastViewedStamp),
      this.lastViewedStamp,
    );
    notifyListeners();
  }
}
