import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:talky_client/features/mood_record/models/mood_record_item.dart';

/// 情绪记录图表
class MoodRecordChart extends StatelessWidget {
  /// 仅当天
  ///
  /// 将在底部显示时间 而不是日期
  final bool onlyToday;

  /// 情绪记录项
  final List<MoodRecordItem> moodRecordItems;

  /// 点击数据
  final Function(int index)? onTouchedData;

  const MoodRecordChart({
    this.onlyToday = false,
    required this.moodRecordItems,
    this.onTouchedData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // 设置高度为300
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (moodRecordItems.length - 1).toDouble(),
          minY: 0,
          maxY: 10,
          gridData: const FlGridData(show: true), // 网格数据
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ), // 顶部标题
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final dateTime = moodRecordItems[value.toInt()].stamp;
                  return Padding(
                    padding: .all(12),
                    child: Transform.rotate(
                      angle: -45 * (3.1415926 / 180),
                      child: Text(
                        onlyToday
                            ? '${dateTime.hour}时${dateTime.minute}分'
                            : '${dateTime.month}月${dateTime.day}日',
                        style: TextStyle(
                          fontSize: moodRecordItems.length > 16 ? 10 : 12,
                        ), // 构建底部日期/时间
                      ),
                    ), // 旋转45度
                  );
                }, // 构建标题
                interval: 1, // 每1个值显示一次
                reservedSize: 44,
              ),
            ), // 底部标题
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString());
                },
                interval: 2, // 每2个值显示一次
              ),
            ), // 左侧标题
            // 顶部和右侧标题可关闭
          ), // 标题数据
          borderData: FlBorderData(show: true, border: .all()), // 边界数据
          lineTouchData: LineTouchData(
            enabled: true,
            touchCallback: (event, response) {
              if (event is FlTapUpEvent && response != null) {
                final touchedSpot =
                    response.lineBarSpots?.firstOrNull; // 获取第一个触摸到的点
                if (touchedSpot != null) {
                  onTouchedData?.call(touchedSpot.x.toInt());
                }
              }
            },
          ), // 点击数据
          lineBarsData: [
            LineChartBarData(
              spots: moodRecordItems.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.score.toDouble());
              }).toList(), // 构建数据
              isCurved: true, // 过渡
              barWidth: 3, // 宽度
              belowBarData: BarAreaData(show: true), // 条形区域数据
              dotData: const FlDotData(show: true), // 点数据
            ),
          ], // 线条数据
        ), // 折线图数据
      ), // 折线图
    ); // 大小盒
  }
}
