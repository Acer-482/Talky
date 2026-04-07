import 'package:talky_client/features/settings/models/base_config_model.dart';

/// 开始配置模型
class StartConfigModel extends BaseConfigModel {
  static const String _keyShowOnboardingPage = 'showOnboardingPage'; // 显示引导页面

  @override
  String get mainKey => 'start';

  late bool showOnboardingPage;

  StartConfigModel({required super.configService});

  @override
  Future<void> init() async {
    showOnboardingPage = await configService.getBool(
      getKey(_keyShowOnboardingPage),
      true,
    );
  }

  /// 更新显示引导页面
  Future<void> updateShowOnboardingPage(bool showOnboardingPage) async {
    if (this.showOnboardingPage == showOnboardingPage) return;
    this.showOnboardingPage = showOnboardingPage;
    await configService.setBool(
      getKey(_keyShowOnboardingPage),
      showOnboardingPage,
    );
    notifyListeners();
  }
}
