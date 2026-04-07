import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talky_client/core/widgets/feature_card.dart';
import 'package:talky_client/features/tip/models/tips_model.dart';

/// 每日提示卡片
class DayTipsCard extends StatelessWidget {
  const DayTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // 主题
    /// 构建UI //
    return Consumer<TipsModel>(
      builder: (context, tipsModel, child) {
        // 检查并更新 //
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => tipsModel.checkAndRefresh(),
        );
        return FeatureCard(
          title: '心理小知识',
          actions: [
            TextButton.icon(
              onPressed: () {
                tipsModel.spawnDayTips();
              },
              icon: const Icon(Icons.refresh),
              label: Text('换一换'),
            ), // 换一换按钮
          ],
          childrenBuilder: (layoutMode, textScaler) => [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              key: ValueKey(DateTime.now().toIso8601String()), // 标识key
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(), // 禁止列表滚动
                shrinkWrap: true, // 收缩
                itemCount: tipsModel.dayTips.length, // 项目数量
                itemBuilder: (context, i) => Padding(
                  padding: .all(layoutMode == 1 ? 5 : 8), // 内边距
                  child: Row(
                    spacing: 6,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: .all(.circular(8)),
                          color: theme.focusColor,
                        ),
                        padding: .fromLTRB(10, 4, 10, 4),
                        child: Text('${i + 1}'),
                      ), // 数字小标签
                      Expanded(
                        child: SelectableText(
                          tipsModel.dayTips[i].content,
                          textScaler: .linear(textScaler),
                        ), // 可选中文本
                      ), // 填满父容器 让文本知道应该自动换行
                    ],
                  ), // 水平布局
                ), // 内边距
              ), // 列表
            ), // 动画切换器
          ],
        ); // 功能卡片
      },
    );
  }
}
