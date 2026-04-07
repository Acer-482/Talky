import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talky_client/features/onboarding/widgets/onboarding_card.dart';
import 'package:talky_client/features/settings/models/start_config_model.dart';

/// 引导项
class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// 引导页面
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<StatefulWidget> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController(); // 页面控制器
  int _currentPage = 0; // 当前页面索引

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: '欢迎来到晴叙',
      description: '心情记录 · AI陪伴 · 兴趣社交\n让每一次倾诉都被温柔接住',
      icon: Icons.waving_hand,
    ),
    OnboardingItem(
      title: '记录心情，看见变化',
      description: '每日心情打卡，用图表追踪情绪趋势，回顾您的情绪起伏',
      icon: Icons.insights,
    ),
    OnboardingItem(
      title: 'AI智能心理助手',
      description: '与随时在线的AI免费心里顾问，可以让您获得即时情感支持与专业建议',
      icon: Icons.smart_toy,
    ),
    OnboardingItem(
      title: '心灵树洞，温暖陪伴',
      description: '线上倾诉，AI倾听，让您的情绪有个安全的出口',
      icon: Icons.chat_bubble_outline,
    ),
    OnboardingItem(
      title: '兴趣群聊，找到同好',
      description: '内置多种兴趣爱好，根据您的兴趣推荐群聊，结识志同道合的伙伴吧',
      icon: Icons.group,
    ),
    OnboardingItem(
      title: '个性主题，随心定义',
      description: '自由切换亮暗模式，挑选喜爱的主题色，打造客制化专属界面！',
      icon: Icons.palette, // 用调色板图标更贴合主题
    ),
  ]; // 引导页面项

  // 上一页
  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 下一页
  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // 检查完成引导
  void _completeOnboarding() {
    if (_currentPage < _items.length - 1) {
      _nextPage();
    } else {
      // 标记已看过引导页 //
      final startConfig = context.read<StartConfigModel>();
      startConfig.updateShowOnboardingPage(false);
      // 关闭 //
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController, // 控制器
              onPageChanged: (index) =>
                  setState(() => _currentPage = index), // 页面更改时
              itemCount: _items.length, // 数量
              itemBuilder: (context, index) {
                final item = _items[index];
                return OnboardingCard(
                  title: item.title,
                  description: item.description,
                  icon: item.icon,
                ); // 引导卡片
              },
            ), // 页面浏览器
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(
                  _items.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Theme.of(context).focusColor
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ), // 装饰器
                  ), // 动画容器
                ), // 列表
              ],
            ), // 水平布局
          ), // 内边距
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              spacing: 10,
              mainAxisAlignment: .spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _currentPage != 0 ? () => _previousPage() : null,
                  child: Text('上一页'),
                ), // 下一步按钮
                ElevatedButton(
                  onPressed: () => _completeOnboarding(),
                  child: Text(
                    _currentPage == _items.length - 1 ? '开始体验' : '下一步',
                  ),
                ), // 下一步按钮
              ],
            ),
          ), // 内边距
        ],
      ), // 垂直布局
    ); // 页面骨架
  }
}
