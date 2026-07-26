// // // lib/widgets/charts/pumps_chart.dart

// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../../models/station_data.dart';

// class PumpsChart extends StatelessWidget {
//   final List<StationData> data;

//   const PumpsChart({super.key, required this.data});

//   @override
//   Widget build(BuildContext context) {
//     double calculateMaxY() {
//       if (data.isEmpty) return 10.0;

//       final maxPump = data.fold<double>(0, (max, e) {
//         final currentMax = (e.rawPumps ?? 0) > (e.treatedPumps ?? 0)
//             ? (e.rawPumps ?? 0).toDouble()
//             : (e.treatedPumps ?? 0).toDouble();
//         return currentMax > max ? currentMax : max;
//       });
//       return maxPump * 1.1;
//     }

//     return BarChart(
//       BarChartData(
//         barTouchData: BarTouchData(
//           enabled: true,
//           touchTooltipData: BarTouchTooltipData(
//             tooltipBgColor: Colors.blueGrey,
//             getTooltipItem: (group, groupIndex, rod, rodIndex) {
//               final station = data[groupIndex];
//               final value = rod.toY;
//               final type = rodIndex == 0 ? 'Raw' : 'Treated';
//               return BarTooltipItem(
//                 '${station.name}\n$type: $value',
//                 const TextStyle(color: Colors.white),
//               );
//             },
//           ),
//         ),
//         titlesData: FlTitlesData(
//           show: true,
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 if (value.toInt() >= data.length) return const SizedBox();
//                 return SideTitleWidget(
//                   axisSide: meta.axisSide,
//                   child: Text(
//                     data[value.toInt()].name,
//                     style: const TextStyle(fontSize: 10),
//                   ),
//                 );
//               },
//               reservedSize: 40,
//             ),
//           ),
//           leftTitles: const AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 40,
//             ),
//           ),
//         ),
//         barGroups: data.asMap().entries.map((entry) {
//           final index = entry.key;
//           final station = entry.value;
//           return BarChartGroupData(
//             x: index,
//             barRods: [
//               BarChartRodData(
//                 toY: station.rawPumps?.toDouble() ?? 0,
//                 color: Colors.red,
//                 width: 12,
//               ),
//               BarChartRodData(
//                 toY: station.treatedPumps?.toDouble() ?? 0,
//                 color: Colors.green,
//                 width: 12,
//               ),
//             ],
//           );
//         }).toList(),
//         alignment: BarChartAlignment.spaceAround,
//         maxY: calculateMaxY(),
//         gridData: const FlGridData(show: true),
//         borderData: FlBorderData(show: false),
//       ),
//     );
//   }
// }
// lib/widgets/charts/pumps_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/station_data.dart';

class PumpsChart extends StatelessWidget {
  final List<StationData> data;

  const PumpsChart({super.key, required this.data});

  static const Color _rawColorStart = Color(0xFFFF6B6B);
  static const Color _rawColorEnd = Color(0xFFEE5253);
  static const Color _treatedColorStart = Color(0xFF4ECDC4);
  static const Color _treatedColorEnd = Color(0xFF1DD1A1);

  double _calculateMaxY() {
    if (data.isEmpty) return 10.0;

    final maxPump = data.fold<double>(0, (max, e) {
      final currentMax = (e.rawPumps ?? 0) > (e.treatedPumps ?? 0)
          ? (e.rawPumps ?? 0).toDouble()
          : (e.treatedPumps ?? 0).toDouble();
      return currentMax > max ? currentMax : max;
    });

    if (maxPump == 0) return 10.0;
    return maxPump * 1.25;
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _EmptyState();
    }

    final maxY = _calculateMaxY();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
child: LayoutBuilder(
        builder: (context, constraints) {
          // Parent SizedBox(height: 300) gives ~272 after container padding.
          // Use Expanded for the chart so it absorbs remaining vertical space
          // and the Column always fits its parent (no RenderFlex overflow).
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pumps Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  _Legend(),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: const Color(0xFF2D3436),
                    tooltipRoundedRadius: 10,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final station = data[groupIndex];
                      final type = rodIndex == 0 ? 'Raw' : 'Treated';
                      return BarTooltipItem(
                        '${station.name}\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: '$type: ${rod.toY.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: rodIndex == 0
                                  ? _rawColorStart
                                  : _treatedColorStart,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    },
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
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= data.length) {
                          return const SizedBox();
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8,
                          child: Text(
                            data[index].name,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF636E72),
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: maxY / 4,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFB2BEC3),
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: const Color(0xFFEDF2F7),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final station = entry.value;
                  final raw = station.rawPumps?.toDouble() ?? 0;
                  final treated = station.treatedPumps?.toDouble() ?? 0;

                  return BarChartGroupData(
                    x: index,
                    barsSpace: 6,
                    barRods: [
                      BarChartRodData(
                        toY: raw,
                        width: 14,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [_rawColorEnd, _rawColorStart],
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: const Color(0xFFF7F9FA),
                        ),
                      ),
                      BarChartRodData(
                        toY: treated,
                        width: 14,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [_treatedColorEnd, _treatedColorStart],
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: const Color(0xFFF7F9FA),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              swapAnimationDuration: const Duration(milliseconds: 600),
              swapAnimationCurve: Curves.easeOutCubic,
            ),
          ),
            ],
          );
        },
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _LegendItem(color: PumpsChart._rawColorStart, label: 'Raw'),
        SizedBox(width: 14),
        _LegendItem(color: PumpsChart._treatedColorStart, label: 'Treated'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF636E72),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'No pump data available',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
