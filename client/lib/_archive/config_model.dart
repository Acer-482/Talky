// import 'package:flutter/widgets.dart';
// import 'package:talky_client/core/services/config_service.dart';

// /// 配置模型
// class ConfigModel extends ChangeNotifier {
//   final ConfigService configService; // 配置服务
//   bool isLoaded = false; // 加载完成

//   /// 创建配置模型
//   ConfigModel({required this.configService});

//   // 初始化
//   Future<void> init() async {
//     if (isLoaded) return;
//     isLoaded = true; // 加载完成
//     // 通知监听 //
//     notifyListeners();
//   }

//   /// 重置所有设置
//   Future<bool> cleanAll() async {
//     final ret = await configService.clearAll();
//     notifyListeners();
//     return ret;
//   }
// }
