import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talky_client/core/models/toast/toast_item.dart';
import 'package:talky_client/core/models/toast/toast_model.dart';
import 'package:talky_client/features/mood_record/models/mood_record_item.dart';
import 'package:talky_client/features/mood_record/models/mood_record_model.dart';

/// 情绪记录表单
class MoodRecordForm extends StatefulWidget {
  final MoodRecordItem? moodRecordItem;

  const MoodRecordForm({this.moodRecordItem, super.key});

  @override
  State<StatefulWidget> createState() => _MoodRecordFormState();
}

class _MoodRecordFormState extends State<MoodRecordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey(); // 表单
  late final TextEditingController _diaryController; // 日记 输入控制器

  late int _score; // 分数

  @override
  void initState() {
    super.initState();

    /// 初始化表单 //
    final item = widget.moodRecordItem;
    _score = item?.score ?? 5;
    _diaryController = TextEditingController(text: item?.diary);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Container(
        padding: .all(12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: .min,
            spacing: 8,
            children: [
              Container(
                padding: .all(12),
                decoration: BoxDecoration(
                  borderRadius: .all(.circular(20)),
                  color: theme.cardColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('心情评分 (0-10)'),
                    Slider(
                      value: _score.toDouble(), // 当前分数
                      min: 0, // 最小值
                      max: 10, // 最大值
                      divisions: 10,
                      label: '${_score.round()}',
                      onChanged: (value) {
                        setState(() {
                          _score = value.toInt();
                        });
                      },
                    ),
                    Text(
                      '当前分数：${_score.round()}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              TextFormField(
                controller: _diaryController,
                decoration: InputDecoration(
                  labelText: '日记',
                  hintText: '今天记录些什么呢...?',
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 5,
              ),
              Row(
                mainAxisAlignment: .spaceBetween, // 平均位置
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.cancel),
                    label: const Text('取消'),
                  ), // 取消
                  if (widget.moodRecordItem != null)
                    ElevatedButton.icon(
                      onPressed: _delete,
                      icon: const Icon(Icons.delete),
                      label: Text('删除'),
                    ), // 删除
                  ElevatedButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check),
                    label: Text(widget.moodRecordItem == null ? '创建' : '修改'),
                  ), // 创建 & 修改
                ],
              ), // 水平布局
            ],
          ), // 垂直布局
        ), // 滚动
      ), // 容器
    ); // 表单
  }

  // 提交
  void _submit() {
    final toastModel = context.read<ToastModel>(); // 弹窗模型
    final moodRecordModel = context.read<MoodRecordModel>(); // 情绪记录模型
    if (_formKey.currentState!.validate()) {
      // 创建 / 修改 //
      if (widget.moodRecordItem == null) {
        // 创建 //
        moodRecordModel.recordMood(
          MoodRecordItem(score: _score, diary: _diaryController.text),
        );
        toastModel.addToast(
          ToastItem('记录成功', description: '今日记录成功', type: .success),
        );
      } else {
        // 修改 //
        moodRecordModel.recordMood(
          MoodRecordItem(score: _score, diary: _diaryController.text),
        );
        toastModel.addToast(
          ToastItem('修改记录成功', description: '成功修改了情绪记录', type: .success),
        );
      }
      Navigator.pop(context); // 关闭表单
    }
  }

  // 删除
  void _delete() {
    final toastModel = context.read<ToastModel>(); // 弹窗模型
    final moodRecordModel = context.read<MoodRecordModel>(); // 情绪记录模型
    // 删除 //
    if (widget.moodRecordItem != null) {
      moodRecordModel.removeLast();
      toastModel.addToast(
        ToastItem('删除记录成功', description: '成功删除了最后一条记录', type: .success),
      );
    }
    Navigator.pop(context); // 关闭表单
  }
}
