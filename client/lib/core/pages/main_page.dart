import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talky_client/features/log/models/log_model.dart';
import 'package:talky_client/core/models/toast/toast_model.dart';
import 'package:talky_client/features/account/pages/account_page.dart';
import 'package:talky_client/features/ai_chat/pages/ai_chat_page.dart';
import 'package:talky_client/features/chat/pages/chat_list_page.dart';
import 'package:talky_client/core/pages/home_page.dart';
import 'package:talky_client/features/onboarding/pages/onboarding_page.dart';
import 'package:talky_client/features/settings/models/start_config_model.dart';
import 'package:talky_client/features/settings/pages/settings_and_logs_page.dart';

/// 导航项
class NavigatorItem {
  /// 文本
  final String text;

  /// 图标数据
  final IconData iconData;

  /// 选中图标数据
  final IconData? selectedIconData;

  /// 悬停提示
  final String toolTip;

  /// 构建主体内容
  final Widget Function(BuildContext context)? buildBody;
  const NavigatorItem({
    required this.text,
    required this.iconData,
    this.selectedIconData,
    required this.toolTip,
    this.buildBody,
  });
}

/// 主页面
///
/// 初始化、管理和导航所有页面
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() => _MainPageState();

  /// 获取布局模式
  ///
  /// 返回值：
  /// - `1` - 移动
  /// - `2` - 平板
  /// - `3` - 桌面
  static int getLayoutMode(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // 获取屏幕宽度
    if (screenWidth < 600) {
      return 1; // 移动
    } else if (screenWidth < 1024) {
      return 2; // 平板
    } else {
      return 3; // 桌面
    }
  }
}

class _MainPageState extends State<MainPage> {
  late final List<NavigatorItem> _navigatorItems; // 导航项

  late final PageController _pageController; // 页面控制器
  int _pageIndex = 0; // 页面索引

  // 切换到设置页面
  Future<void> _navigationToSettingsPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsAndLogsPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    final toastModel = context.read<ToastModel>();
    final logModel = context.read<LogModel>();
    final startConfig = context.read<StartConfigModel>();
    // 显示引导页面
    if (startConfig.showOnboardingPage) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingPage()),
        ),
      );
    }
    // 监听弹窗 //
    toastModel.toastStream.listen(
      (data) {
        final currentContext = context; // 获取上下文
        if (currentContext.mounted) {
          data.show(currentContext);
        }
      },
      onError: (e) {
        final context = this.context;
        if (context.mounted) logModel.log(.error, '显示弹窗时出错：$e');
      },
    );
    // 初始化页面 //
    _pageController = PageController();
    _navigatorItems = [
      NavigatorItem(
        text: '首页',
        iconData: Icons.home_outlined,
        selectedIconData: Icons.home,
        toolTip: '',
        buildBody: (context) => const HomePage(),
      ),
      NavigatorItem(
        text: '树洞',
        iconData: Icons.chat_outlined,
        selectedIconData: Icons.chat_rounded,
        toolTip: '与其他小伙伴一起聊天',
        buildBody: (context) => const ChatListPage(),
      ),
      NavigatorItem(
        text: '心理助手',
        iconData: Icons.chat_outlined,
        selectedIconData: Icons.chat,
        toolTip: '与心理助手AI聊天',
        buildBody: (context) => const AiChatPage(),
      ),
      NavigatorItem(
        text: '我的',
        iconData: Icons.person_outline,
        selectedIconData: Icons.person,
        toolTip: '查看个人信息',
        buildBody: (context) => const AccountPage(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ToastModel>(
      builder: (context, _, _) => _buildScaffold(),
    ); // 构建骨架
  }

  // 构建骨架
  Scaffold _buildScaffold() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context),
      bottomNavigationBar: MainPage.getLayoutMode(context) == 1
          ? _buildBottomNavigationBar(context)
          : null,
      // floatingActionButton:
      //     context.read<NetworkService>().connectionState == .disconnected
      //     ? FloatingActionButton(
      //         onPressed: () {
      //           final networkService = context.read<NetworkService>();
      //           networkService.connect(); // 连接到服务器
      //         },
      //         tooltip: '连接到服务器',
      //         child: const Icon(Icons.connect_without_contact),
      //       )
      //     : null,
    );
  }

  /// 构建菜单栏
  AppBar _buildAppBar() {
    return AppBar(
      title: Text('晴叙 - Talky'),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: _navigationToSettingsPage,
          icon: const Icon(Icons.settings),
        ),
      ],
    );
  }

  /// 构建导航栏
  Widget _buildBody(BuildContext context) {
    final layoutMode = MainPage.getLayoutMode(context);
    final list = _navigatorItems
        .map((item) => item.buildBody?.call(context) ?? Container())
        .toList();
    return Row(
      children: [
        if (layoutMode > 1) _buildRailBody(context, layoutMode),
        Expanded(
          child: PageView(
            controller: _pageController, // 控制器
            onPageChanged: (value) => setState(() {
              _pageIndex = value;
            }), // 更新页面
            scrollDirection: layoutMode == 1
                ? .horizontal
                : .vertical, // 根据模式设置滚动方向
            children: list,
          ),
        ),
      ],
    );
  }

  /// 构建侧边导航栏
  Widget _buildRailBody(BuildContext context, int layoutMode) {
    return NavigationRail(
      selectedIndex: _pageIndex, // 索引
      onDestinationSelected: _swapPage,
      extended: layoutMode == 3, // 桌面模式时变更为拓展模式
      labelType: layoutMode == 3 ? .none : .selected, // 标签类型
      destinations: _navigatorItems
          .map(
            (item) => NavigationRailDestination(
              icon: Icon(item.iconData),
              selectedIcon: item.selectedIconData != null
                  ? Icon(item.selectedIconData)
                  : null,
              label: Text(item.text),
            ),
          )
          .toList(),
    );
  }

  /// 构建底部导航栏
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // 固定类型
      currentIndex: _pageIndex, // 索引
      onTap: _swapPage, // 更新页面
      items: _navigatorItems
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.iconData),
              activeIcon: Icon(item.selectedIconData),
              label: item.text,
              tooltip: item.toolTip,
            ),
          )
          .toList(),
    );
  }

  /// 切换页面
  void _swapPage(int newINdex) {
    setState(() {
      _pageIndex = newINdex;
      _pageController.animateToPage(
        _pageIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.fastEaseInToSlowEaseOut,
      );
    });
  }
}
