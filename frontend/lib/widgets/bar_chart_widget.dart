import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget extends StatelessWidget {
  final Map<String, double> data;
  final String title;
  final Color color;

  const BarChartWidget({
    super.key,
    required this.data,
    required this.title,
    this.color = Colors.deepPurple,
  });

  @override
  Widget build(BuildContext context) {
    final keys = data.keys.toList();
    final values = data.values.toList();
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= keys.length) return const SizedBox();
                          return Text(keys[idx], style: const TextStyle(fontSize: 10));
                        },
                        reservedSize: 32,
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: List.generate(keys.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: values[i],
                          color: color,
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
