import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:talky_client/core/widgets/feature_card.dart';
import 'package:talky_client/features/mood_record/models/mood_record_item.dart';
import 'package:talky_client/features/mood_record/models/mood_record_model.dart';
import 'package:talky_client/features/mood_record/widgets/mood_record_chart.dart';
import 'package:talky_client/features/mood_record/widgets/mood_record_form.dart';
import 'package:talky_client/features/mood_record/widgets/mood_record_info.dart';
import 'package:talky_client/features/settings/models/mood_record_config_model.dart';

/// 情绪记录卡片
class MoodRecordCard extends StatefulWidget {
  const MoodRecordCard({super.key});
  @override
  State<StatefulWidget> createState() => _MoodRecordCardState();
}

class _MoodRecordCardState extends State<MoodRecordCard> {
  DateTime? startDate; // 日期开始
  DateTime? endDate; // 日期结束

  bool get _hasDateRange => !(startDate == null || endDate == null);

  // 显示昨日情绪记录统计
  Future<void> _showYesterdayStat(
    MoodRecordModel model,
    List<MoodRecordItem> records,
  ) async {
    // 计算统计数据 //
    final count = records.length; // 记录数量
    final totalScore = records
        .map((e) => e.score)
        .reduce((a, b) => a + b); // 总分
    final average = totalScore / count; // 平均分
    final maxScore = records
        .map((e) => e.score)
        .reduce((a, b) => a > b ? a : b); // 最高分
    final minScore = records
        .map((e) => e.score)
        .reduce((a, b) => a < b ? a : b); // 最低分
    // 分数段 //
    final low = records.where((e) => e.score <= 3).length; // 低分
    final medium = records
        .where((e) => e.score > 3 && e.score <= 7)
        .length; // 中分
    final high = records.where((e) => e.score > 7).length; // 高分

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('昨日心情记录统计'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatRow('记录条数', '$count', Icons.receipt),
              _buildStatRow('平均分', average.toStringAsFixed(1), Icons.equalizer),
              _buildStatRow(
                '最高分',
                maxScore.toString(),
                Icons.trending_up,
                valueColor: Colors.green,
              ),
              _buildStatRow(
                '最低分',
                minScore.toString(),
                Icons.trending_down,
                valueColor: Colors.red,
              ),
              const Divider(),
              _buildStatRow(
                '低分区 (0-3)',
                low.toString(),
                Icons.sentiment_dissatisfied,
              ),
              _buildStatRow(
                '中分区 (4-7)',
                medium.toString(),
                Icons.sentiment_neutral,
              ),
              _buildStatRow(
                '高分区 (8-10)',
                high.toString(),
                Icons.sentiment_satisfied,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                startDate = endDate = DateTime.now().add(Duration(days: -1));
              });
              Navigator.pop(context);
            },
            child: const Text('查看昨日心情'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 构建统计行
  Widget _buildStatRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // 显示情绪记录表单
  Future<void> _showCardRecordSheet(
    MoodRecordModel model, [
    bool newRecorded = false,
  ]) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => MoodRecordForm(
        moodRecordItem: newRecorded
            ? null
            : (model.checkTodayRecorded
                  ? model.moodRecordItems.last
                  : null), // 如果今日已记录则获取最新的记录项
      ),
    );
  }

  // 显示情绪记录信息表
  Future<void> _showCardRecordInfoSheet(MoodRecordItem item) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: .all(10),
        child: MoodRecordInfo(moodRecordItem: item),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final configModel = context.read<MoodRecordConfigModel>();
    final model = context.read<MoodRecordModel>();
    final records = model.getYesterdayRecords; // 获取昨日记录
    // 初始化时间段 //
    startDate = endDate = DateTime.now();
    // 时间戳非今天且昨日记录非空 //
    if (configModel.lastViewedStamp.day != DateTime.now().day &&
        records.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showYesterdayStat(model, records),
      );
      configModel.updateLastViewedStamp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MoodRecordConfigModel, MoodRecordModel>(
      builder: (context, configModel, moodRecordModel, child) {
        // 获取需要显示的记录 //
        final moodItems = moodRecordModel.getRecordItems(
          startDate,
          endDate,
          configModel.chartMaxPointCount,
        );
        return FeatureCard(
          title: '情绪记录',
          actions: [],
          childrenBuilder: (layoutMode, textScaler) => [
            _buildCheckInWidget(moodRecordModel, textScaler),
            Divider(height: 4),
            if (moodItems.isNotEmpty) _buildChartDateRangeTile(moodRecordModel),
            MoodRecordChart(
              onlyToday:
                  (_hasDateRange
                      ? startDate!.compareTo(endDate!) == 0
                      : false) || // 日期范围是否选为当天
                  moodRecordModel.checkOnlyToday, // 是否全为今天
              moodRecordItems: moodItems,
              onTouchedData: (index) =>
                  _showCardRecordInfoSheet(moodItems[index]),
            ), // 心情记录图表
          ],
        );
      },
    );
  }

  // 构建签到组件
  Widget _buildCheckInWidget(MoodRecordModel model, double textScaler) {
    final todayRecorded = model.checkTodayRecorded; // 今日是否已经记录
    return Row(
      mainAxisAlignment: .spaceAround,
      children: [
        Text(todayRecorded ? '今日已经记录啦' : '今日还未记录哦'),
        ElevatedButton(
          onPressed: () => _showCardRecordSheet(model, true),
          child: Text('记录情绪'),
        ),
        if (todayRecorded)
          ElevatedButton(
            onPressed: () => _showCardRecordSheet(model),
            child: Text('修改记录'),
          ),
      ],
    );
  }

  // 构建图表日期选择项
  Widget _buildChartDateRangeTile(MoodRecordModel moodRecordModel) {
    return ListTile(
      title: const Text('图表显示日期'),
      subtitle: Text('显示指定天数的数据\n当前：${_formatCurrentDateString()}'),
      trailing: Row(
        spacing: 10,
        mainAxisSize: .min,
        children: [
          TextButton(
            onPressed: () async {
              final ret = await showDateRangePicker(
                context: context,
                firstDate: moodRecordModel.getFirstDate, // 最早可选日期
                lastDate: moodRecordModel.getLastDate, // 最晚可选日期
                initialDateRange: !_hasDateRange
                    ? null
                    : DateTimeRange(start: startDate!, end: endDate!),
              );
              // 选取成功则设置 //
              if (ret != null) {
                setState(() {
                  startDate = ret.start;
                  endDate = ret.end;
                });
              }
            }, // 显示日期选择器
            child: const Text('选取日期'),
          ), // 选取按钮
          if (_hasDateRange)
            IconButton(
              onPressed: () => setState(() {
                startDate = endDate = null; // 清空
              }),
              icon: const Icon(Icons.cancel),
              tooltip: '取消选择',
            ),
        ],
      ),
    ); // 图表显示日期
  }

  // 获取当前区间字符串
  String _formatCurrentDateString() {
    if (!_hasDateRange) return '无限制';
    if (startDate!.compareTo(endDate!) == 0) {
      return '${_formatDateTime(startDate!)}当天';
    }
    return '${_formatDateTime(startDate!)}到${_formatDateTime(endDate!)}';
  }

  // 格式化时间
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy年MM月dd日').format(dateTime);
  }
}
