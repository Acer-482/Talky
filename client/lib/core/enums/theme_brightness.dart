import 'package:flutter/material.dart';

/// 主题亮暗
enum ThemeBrightness { system, light, dart }

/// 拓展
extension ThemeBrightnessExtension on ThemeBrightness {
  /// 显示名称
  String get displayName => switch (this) {
    .system => '跟随系统',
    .light => '亮色主题',
    .dart => '暗色主题',
  };

  /// 转为主题模式
  ThemeMode get toThemeMode => switch (this) {
    .system => .system,
    .light => .light,
    .dart => .dark,
  };
}
