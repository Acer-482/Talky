import 'package:talky_client/features/settings/models/base_config_model.dart';

/// 网络配置模型
class NetworkConfigModel extends BaseConfigModel {
  static const String _keyServerHost = 'server_host'; // 服务器地址
  static const String _keyServerPort = 'server_port'; // 服务器端口
  static const String _keyAutoConnect = 'auto_connect'; // 自动连接
  static const String _keyAutoLogin = 'auto_login'; // 自动登录

  @override
  String get mainKey => 'network';

  /// 服务器地址
  late String host;

  /// 服务器端口
  late int port;

  /// 自动连接
  late bool autoConnect;

  /// 自动登录
  late bool autoLogin;

  NetworkConfigModel({required super.configService});

  @override
  Future<void> init() async {
    host = await configService.getString(getKey(_keyServerHost), '127.0.0.1');
    port = await configService.getInt(getKey(_keyServerPort), 4821);
    autoConnect = await configService.getBool(getKey(_keyAutoConnect), true);
    autoLogin = await configService.getBool(getKey(_keyAutoLogin), true);
  }

  /// 更新服务器地址
  Future<void> updateServerHost(String host) async {
    if (this.host == host) return;
    this.host = host;
    await configService.setString(getKey(_keyServerHost), host);
    notifyListeners();
  }

  /// 更新服务器端口
  Future<void> updateServerPort(int port) async {
    if (this.port == port) return;
    this.port = port;
    await configService.setInt(getKey(_keyServerPort), port);
    notifyListeners();
  }

  /// 更新自动连接
  Future<void> updateAutoConnect(bool autoConnect) async {
    if (this.autoConnect == autoConnect) return;
    this.autoConnect = autoConnect;
    await configService.setBool(getKey(_keyAutoConnect), autoConnect);
    notifyListeners();
  }

  /// 更新自动登录
  Future<void> updateAutoLogin(bool autoLogin) async {
    if (this.autoLogin == autoLogin) return;
    this.autoLogin = autoLogin;
    await configService.setBool(getKey(_keyAutoLogin), autoLogin);
    notifyListeners();
  }
}
