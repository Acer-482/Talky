import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:talky_client/features/mood_record/models/mood_record_item.dart';

/// 情绪记录信息
class MoodRecordInfo extends StatelessWidget {
  // 情绪记录信息项
  final MoodRecordItem moodRecordItem;

  const MoodRecordInfo({required this.moodRecordItem, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        ListTile(
          leading: Icon(Icons.score),
          title: const Text('情绪分数'),
          trailing: SelectableText(moodRecordItem.score.toString()),
        ),
        ListTile(
          leading: Icon(Icons.timelapse_rounded),
          title: const Text('记录时间'),
          trailing: SelectableText(
            DateFormat('yyyy年MM月dd日 HH:mm:ss').format(moodRecordItem.stamp),
            textAlign: .right,
          ),
        ),
        if (moodRecordItem.diary != null && moodRecordItem.diary!.isNotEmpty)
          Card(
            child: Container(
              padding: .all(10),
              child: Column(
                spacing: 10,
                crossAxisAlignment: .start,
                children: [
                  const Row(
                    spacing: 10,
                    children: [
                      Icon(Icons.text_snippet),
                      Text('日志内容', textScaler: .linear(1.4)),
                    ],
                  ),
                  SelectableText(moodRecordItem.diary!),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
