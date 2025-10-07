// // lib/widgets/charts/pumps_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/station_data.dart';

class PumpsChart extends StatelessWidget {
  final List<StationData> data;

  const PumpsChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    double calculateMaxY() {
      if (data.isEmpty) return 10.0;

      final maxPump = data.fold<double>(0, (max, e) {
        final currentMax = (e.rawPumps ?? 0) > (e.treatedPumps ?? 0)
            ? (e.rawPumps ?? 0).toDouble()
            : (e.treatedPumps ?? 0).toDouble();
        return currentMax > max ? currentMax : max;
      });
      return maxPump * 1.1;
    }

    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final station = data[groupIndex];
              final value = rod.toY;
              final type = rodIndex == 0 ? 'Raw' : 'Treated';
              return BarTooltipItem(
                '${station.name}\n$type: $value',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= data.length) return const SizedBox();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    data[value.toInt()].name,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
            ),
          ),
        ),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final station = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: station.rawPumps?.toDouble() ?? 0,
                color: Colors.red,
                width: 12,
              ),
              BarChartRodData(
                toY: station.treatedPumps?.toDouble() ?? 0,
                color: Colors.green,
                width: 12,
              ),
            ],
          );
        }).toList(),
        alignment: BarChartAlignment.spaceAround,
        maxY: calculateMaxY(),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
