import 'package:talky_client/features/settings/models/base_config_model.dart';
import 'package:talky_client/features/tip/models/tip.dart';

/// 提示配置模型
class TipsConfigModel extends BaseConfigModel {
  static const String _keyDayItems = 'day_items'; // 每日提示数据
  static const String _keyStamp = 'stamp'; // 上次生成时间戳
  static const String _keySpawnCount = 'spawn_count'; // 生成数量

  @override
  String get mainKey => 'tips';

  /// 每日提示数据
  late List<Tip> dayItems;

  /// 时间戳
  late DateTime stamp;

  /// 提示生成数量
  late int spawnCount;

  TipsConfigModel({required super.configService});

  @override
  Future<void> init() async {
    dayItems = await configService.getList(
      getKey(_keyDayItems),
      [],
      TipMapper.fromJson,
    );
    stamp = await configService.getDateTime(getKey(_keyStamp), DateTime.now());
    spawnCount = await configService.getInt(getKey(_keySpawnCount), 5);
  }

  /// 更新每日数据
  Future<void> updateDayItems(List<Tip> dayItems) async {
    this.dayItems = dayItems;
    await configService.setList(
      getKey(_keyDayItems),
      dayItems,
      (json) => json.toJson(),
    );
    notifyListeners();
  }

  /// 更新时间戳
  Future<void> updateStamp(DateTime stamp) async {
    if (this.stamp == stamp) return;
    this.stamp = stamp;
    await configService.setDateTime(getKey(_keyStamp), stamp);
    notifyListeners();
  }

  /// 更新生成数量
  Future<void> updateSpawnCount(int spawnCount) async {
    if (this.spawnCount == spawnCount) return;
    this.spawnCount = spawnCount;
    await configService.setInt(getKey(_keySpawnCount), spawnCount);
    notifyListeners();
  }
}
