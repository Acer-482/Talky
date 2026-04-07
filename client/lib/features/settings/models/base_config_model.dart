import 'package:flutter/widgets.dart';
import 'package:talky_client/core/services/config_service.dart';

/// 基本配置模型
///
/// 不可直接监听，用于子类继承后共享方法
abstract class BaseConfigModel extends ChangeNotifier {
  final ConfigService configService; // 配置服务
  // 主键
  String get mainKey;

  /// 获取键
  String getKey(String key) {
    return '${mainKey}_$key';
  }

  BaseConfigModel({required this.configService}) {
    init();
  }

  /// 初始化
  Future<void> init();
}
