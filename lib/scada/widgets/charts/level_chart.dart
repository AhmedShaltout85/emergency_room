
// lib/widgets/charts/level_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/station_data.dart';

class LevelChart extends StatelessWidget {
  final List<StationData> data;

  const LevelChart({super.key, required this.data});

  static const Color _primaryColor = Color(0xFF7C4DFF); // rich purple
  static const Color _secondaryColor = Color(0xFF00E5FF); // cyan accent
  static const Color _gridColor = Color(0xFFEDEEF3);
  static const Color _labelColor = Color(0xFF8B8FA3);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const _EmptyChartState();
    }

    final levels = data.map((e) => e.level ?? 0).toList();
    final maxLevel = levels.reduce((a, b) => a > b ? a : b);
    final minLevel = levels.reduce((a, b) => a < b ? a : b);
    // Give the chart a little breathing room above/below the data range.
    final range = (maxLevel - minLevel).abs();
    final padding = range == 0 ? 1.0 : range * 0.15;
    final maxY = maxLevel + padding;
    final minY = (minLevel - padding).clamp(0, double.infinity).toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: data.length - 1.0,
          minY: minY,
          maxY: maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: const Color(0xFF2A2D45),
              tooltipRoundedRadius: 12,
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  if (index < 0 || index >= data.length) return null;
                  final station = data[index];
                  return LineTooltipItem(
                    '${station.name}\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                        text: spot.y.toStringAsFixed(2),
                        style: const TextStyle(
                          color: _secondaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
            getTouchedSpotIndicator: (barData, indicators) {
              return indicators.map((index) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: _primaryColor.withOpacity(0.3),
                    strokeWidth: 2,
                    dashArray: [4, 4],
                  ),
                  FlDotData(
                    getDotPainter: (spot, percent, bar, i) {
                      return FlDotCirclePainter(
                        radius: 6,
                        color: Colors.white,
                        strokeWidth: 3,
                        strokeColor: _primaryColor,
                      );
                    },
                  ),
                );
              }).toList();
            },
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 4,
            getDrawingHorizontalLine: (value) => const FlLine(
              color: _gridColor,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }
                  // Thin out labels if there are many stations so they don't overlap.
                  final step = (data.length / 6).ceil().clamp(1, data.length);
                  if (index % step != 0 && index != data.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      data[index].name,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _labelColor,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                interval: (maxY - minY) / 4,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 11,
                      color: _labelColor,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data.asMap().entries.map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  entry.value.level ?? 0,
                );
              }).toList(),
              isCurved: true,
              curveSmoothness: 0.3,
              gradient: const LinearGradient(
                colors: [_primaryColor, _secondaryColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              barWidth: 3.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: data.length <= 20, // avoid clutter on dense datasets
                getDotPainter: (spot, percent, bar, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2.5,
                    strokeColor: _primaryColor,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    _primaryColor.withOpacity(0.25),
                    _secondaryColor.withOpacity(0.02),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      ),
    );
  }
}

class _EmptyChartState extends StatelessWidget {
  const _EmptyChartState();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDEEF3)),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.show_chart_rounded,
            size: 40,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 8),
          Text(
            'No data available',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
