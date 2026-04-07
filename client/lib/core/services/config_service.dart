import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 配置服务
///
/// 提供基本的保存读取配置的功能
class ConfigService {
  /// SharedPreferences实例
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// 重置所有设置
  Future<bool> clearAll() async {
    return await (await _prefs).clear();
  }

  /// 删除配置
  Future<bool> remove(String key) async {
    return await (await _prefs).remove(key);
  }

  // ---------- 设置配置 ---------- //

  /// 设置 字符串值 配置
  Future<bool> setString(String key, String value) async =>
      (await _prefs).setString(key, value);

  /// 设置 布尔值 配置
  Future<bool> setBool(String key, bool value) async =>
      (await _prefs).setBool(key, value);

  /// 设置 整型值 配置
  Future<bool> setInt(String key, int value) async =>
      (await _prefs).setInt(key, value);

  /// 设置 浮点值 配置
  Future<bool> setDouble(String key, double value) async =>
      (await _prefs).setDouble(key, value);

  /// 设置 字符串列表 配置
  Future<bool> setStringList(String key, List<String> value) async =>
      (await _prefs).setStringList(key, value);

  /// 设置 类列表 配置
  Future<bool> setList<T>(
    String key,
    List<T> value,
    String Function(T value) toJson,
  ) async =>
      (await _prefs).setStringList(key, value.map((e) => toJson(e)).toList());

  /// 设置 枚举 配置
  Future<void> setEnum(String key, Enum value) async {
    await (await _prefs).setString(key, value.name);
  }

  /// 设置 时间 配置
  Future<void> setDateTime(String key, DateTime value) async {
    await (await _prefs).setString(key, value.toIso8601String());
  }

  /// 设置 颜色 配置
  Future<void> setColor(String key, Color value) async {
    await (await _prefs).setInt(key, value.toARGB32());
  }

  // ---------- 读取配置 ---------- //

  /// 获取 字符串值 配置
  Future<String> getString(String key, String defaultValue) async =>
      (await _prefs).getString(key) ?? defaultValue;

  /// 获取 布尔值 配置
  Future<bool> getBool(String key, bool defaultValue) async =>
      (await _prefs).getBool(key) ?? defaultValue;

  /// 获取 整型值 配置
  Future<int> getInt(String key, int defaultValue) async =>
      (await _prefs).getInt(key) ?? defaultValue;

  /// 获取 浮点值 配置
  Future<double> getDouble(String key, double defaultValue) async =>
      (await _prefs).getDouble(key) ?? defaultValue;

  /// 获取 字符串列表 配置
  Future<List<String>> getStringList(
    String key,
    List<String> defaultValue,
  ) async => (await _prefs).getStringList(key) ?? defaultValue;

  /// 获取 类列表 配置
  Future<List<T>> getList<T>(
    String key,
    List<T> defaultValue,
    T Function(String json) fromJson,
  ) async {
    try {
      final list = (await _prefs).getStringList(key)!;
      return list.map((e) => fromJson(e)).toList();
    } catch (_) {
      return defaultValue;
    }
  }

  /// 获取 枚举 配置
  Future<T> getEnum<T extends Enum>(
    String key,
    List<T> enumValues,
    T defaultValue,
  ) async {
    try {
      final enumName = (await _prefs).getString(key)!;
      return enumValues.firstWhere((e) => e.name == enumName);
    } catch (_) {
      return defaultValue;
    }
  }

  /// 获取 时间 配置
  Future<DateTime> getDateTime(String key, DateTime defaultValue) async {
    try {
      return DateTime.parse((await _prefs).getString(key)!);
    } catch (_) {
      return defaultValue;
    }
  }

  /// 获取 颜色 配置
  Future<Color> getColor(String key, Color defaultValue) async {
    try {
      return Color((await _prefs).getInt(key)!);
    } catch (_) {
      return defaultValue;
    }
  }
}
