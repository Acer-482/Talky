import 'package:flutter/material.dart';
import 'package:talky_client/features/mood_record/widgets/mood_record_card.dart';
import 'package:talky_client/features/tip/widgets/day_tips_card.dart';

/// 主页面
class HomePage extends StatefulWidget {
  /// 最大宽度
  final double maxWidth = 10;
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .all(10), // 内边距
      constraints: BoxConstraints(maxWidth: widget.maxWidth), // 宽度限制
      child: ListView(children: [MoodRecordCard(), DayTipsCard()]),
    );
  }
}
