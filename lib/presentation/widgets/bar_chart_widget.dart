// bar_chart_widget.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  const BarChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 5, color: Colors.green)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 7, color: Colors.green)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 3, color: Colors.green)]),
          ],
        ),
      ),
    );
  }
}
