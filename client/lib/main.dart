import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:talky_client/core/enums/theme_brightness.dart';
import 'package:talky_client/features/account/models/account_model.dart';
import 'package:talky_client/features/ai_chat/models/ai_chat_model.dart';
import 'package:talky_client/features/chat/models/chat_model.dart';
import 'package:talky_client/features/settings/models/ai_chat_config_model.dart';
import 'package:talky_client/features/hobby_tag/models/hobby_tag_model.dart';
import 'package:talky_client/features/log/models/log_model.dart';
import 'package:talky_client/features/mood_record/models/mood_record_model.dart';
import 'package:talky_client/features/settings/models/mood_record_config_model.dart';
import 'package:talky_client/features/settings/models/network_config_model.dart';
import 'package:talky_client/features/settings/models/start_config_model.dart';
import 'package:talky_client/features/settings/models/theme_config_model.dart';
import 'package:talky_client/features/settings/models/tips_config_mode.dart';
import 'package:talky_client/features/tip/models/tips_model.dart';
import 'package:talky_client/core/models/toast/toast_model.dart';
import 'package:talky_client/core/pages/main_page.dart';
import 'package:talky_client/core/services/api_service.dart';
import 'package:talky_client/core/services/config_service.dart';
import 'package:talky_client/core/services/network_service.dart';
import 'package:talky_client/core/models/toast/toast_item.dart';
import 'package:talky_shared/mappers.dart';
import 'package:toastification/toastification.dart';

/// MAIN入口
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 初始化flutter组件

  initializeSharedMappers(); // 初始化Mapper
  await dotenv.load(fileName: 'assets/.env'); // 加载api密钥

  // 初始化配置服务与模型 //
  final configService = ConfigService();
  final startConfig = StartConfigModel(configService: configService);
  final networkConfig = NetworkConfigModel(configService: configService);
  final themeConfig = ThemeConfigModel(configService: configService);
  final tipsConfig = TipsConfigModel(configService: configService);
  final moodRecordConfig = MoodRecordConfigModel(configService: configService);
  final aiChatConfig = AiChatConfigModel(configService: configService);

  await Future.wait([
    startConfig.init(),
    networkConfig.init(),
    themeConfig.init(),
    tipsConfig.init(),
    moodRecordConfig.init(),
    aiChatConfig.init(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        Provider<ConfigService>.value(value: configService),
        ChangeNotifierProvider<StartConfigModel>.value(value: startConfig),
        ChangeNotifierProvider<NetworkConfigModel>.value(value: networkConfig),
        ChangeNotifierProvider<ThemeConfigModel>.value(value: themeConfig),
        ChangeNotifierProvider<TipsConfigModel>.value(value: tipsConfig),
        ChangeNotifierProvider<MoodRecordConfigModel>.value(
          value: moodRecordConfig,
        ),
        ChangeNotifierProvider<AiChatConfigModel>.value(value: aiChatConfig),
        ChangeNotifierProvider<LogModel>(
          create: (context) {
            // 创建日志模型 //
            final logModel = LogModel();
            // 初始化日志模型 //
            logModel.logStream.listen((data) => debugPrint(data.stdLog));
            return logModel;
          },
        ), // 日志模型
        ChangeNotifierProvider<ToastModel>(
          create: (context) {
            return ToastModel();
          },
        ), // 弹窗模型
        Provider(
          create: (context) {
            return ApiService();
          },
        ), // API服务
        ChangeNotifierProvider<AiChatModel>(
          create: (context) {
            return AiChatModel(
              apiService: context.read<ApiService>(),
              aiChatConfigModel: context.read<AiChatConfigModel>(),
            );
          },
        ), // AI聊天模型
        Provider(
          create: (context) {
            final logModel = context.read<LogModel>();
            final networkConfig = context.read<NetworkConfigModel>();
            final toastModel = context.read<ToastModel>();
            // 创建网络服务 //
            final networkService = NetworkService(configModel: networkConfig);
            // 初始化网络服务 //
            logModel.listenStream(networkService.logStream); // 监听日志流
            networkService.onStreamError = (e) => toastModel.addToast(
              ToastItem('流错误', description: '$e', type: .warning),
            ); // 监听流错误
            networkService.onConnectionError = (e) => toastModel.addToast(
              ToastItem('连接错误', description: '$e', type: .warning),
            ); // 监听连接错误
            networkService.onDataError = (e) => toastModel.addToast(
              ToastItem('数据错误', description: '$e', type: .error),
            ); // 监听数据错误
            if (networkConfig.autoConnect) networkService.connect(); // 连接到服务器
            return networkService;
          },
          dispose: (context, value) => value.dispose(),
        ), // 网络服务
        ChangeNotifierProvider<AccountModel>(
          create: (context) => AccountModel(
            networkService: context.read<NetworkService>(),
            logModel: context.read<LogModel>(),
            toastModel: context.read<ToastModel>(),
            aiChatModel: context.read<AiChatModel>(),
          ),
        ), // 账户模型
        ChangeNotifierProvider<ChatModel>(
          create: (context) => ChatModel(
            logModel: context.read<LogModel>(),
            toastModel: context.read<ToastModel>(),
            accountModel: context.read<AccountModel>(),
            networkService: context.read<NetworkService>(),
          ),
        ), // 聊天模型
        ChangeNotifierProvider<MoodRecordModel>(
          create: (context) => MoodRecordModel(
            moodRecordConfigModel: context.read<MoodRecordConfigModel>(),
          ),
        ), // 情绪记录模型
        ChangeNotifierProvider<TipsModel>(
          create: (context) => TipsModel(
            logModel: context.read<LogModel>(),
            tipsConfigModel: context.read<TipsConfigModel>(),
          ),
        ), // 提示模型
        ChangeNotifierProvider<HobbyTagModel>(
          create: (context) =>
              HobbyTagModel(logModel: context.read<LogModel>()),
        ), // 爱好标签模型
      ],
      child: const TalkyApp(), // 状态管理提供
    ),
  ); // 启动app
}

/// Talky app入口
class TalkyApp extends StatelessWidget {
  const TalkyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(child: _buildApp(context)); // 弹窗包装器
  }

  // 构建App主体
  Widget _buildApp(BuildContext context) {
    return Consumer<ThemeConfigModel>(
      builder: (context, themeConfig, child) => MaterialApp(
        title: 'Talky', // 标题
        theme: ThemeData(
          colorScheme: .fromSeed(
            seedColor: themeConfig.color,
            brightness: .light,
          ),
        ), // 亮色主题
        darkTheme: ThemeData(
          colorScheme: .fromSeed(
            seedColor: themeConfig.color,
            brightness: .dark,
          ),
        ), // 暗色主题
        themeMode: themeConfig.brightness.toThemeMode, // 主题模式
        locale: Locale('zh', 'CN'), // 语言
        supportedLocales: const [Locale('zh', 'CN')], // 语言列表
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate, // Material组件本地化
          GlobalCupertinoLocalizations.delegate, // Cupertino组件本地化
          GlobalWidgetsLocalizations.delegate, // Widget本地化
        ],
        home: const MainPage(), // 导航页面
      ), // 谷歌风格APP
    );
  }
}
