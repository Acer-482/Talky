import 'package:flutter/material.dart';
import 'package:talky_client/core/enums/theme_brightness.dart';
import 'package:talky_client/features/settings/models/base_config_model.dart';

/// 主题配置模型
class ThemeConfigModel extends BaseConfigModel {
  static const String _keyColor = 'color'; // 颜色
  static const String _keyBrightness = 'brightness'; // 亮暗

  @override
  String get mainKey => 'theme';

  /// 颜色
  late Color color;

  /// 亮暗
  late ThemeBrightness brightness;

  ThemeConfigModel({required super.configService});

  @override
  Future<void> init() async {
    color = await configService.getColor(
      getKey(_keyColor),
      Colors.blue.shade400,
    );
    brightness = await configService.getEnum<ThemeBrightness>(
      getKey(_keyBrightness),
      ThemeBrightness.values,
      ThemeBrightness.system,
    );
  }

  /// 更新颜色
  Future<void> updateColor(Color color) async {
    if (this.color == color) return;
    this.color = color;
    await configService.setColor(getKey(_keyColor), color);
    notifyListeners();
  }

  /// 更新亮暗
  Future<void> updateBrightness(ThemeBrightness brightness) async {
    if (this.brightness == brightness) return;
    this.brightness = brightness;
    await configService.setEnum(getKey(_keyBrightness), brightness);
    notifyListeners();
  }
}
