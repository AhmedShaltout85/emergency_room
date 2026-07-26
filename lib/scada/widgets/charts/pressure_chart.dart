// // // lib/widgets/charts/pressure_chart.dart

// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../../models/station_data.dart';

// class PressureChart extends StatelessWidget {
//   final List<StationData> data;

//   const PressureChart({super.key, required this.data});

//   @override
//   Widget build(BuildContext context) {
//     return BarChart(
//       BarChartData(
//         barTouchData: BarTouchData(
//           enabled: true,
//           touchTooltipData: BarTouchTooltipData(
//             tooltipBgColor: Colors.blueGrey,
//             getTooltipItem: (group, groupIndex, rod, rodIndex) {
//               final station = data[groupIndex];
//               return BarTooltipItem(
//                 '${station.name}\n${station.pressure?.toStringAsFixed(2) ?? 'N/A'} bar',
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
//                 toY: station.pressure ?? 0,
//                 color: Colors.blue,
//                 width: 16,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ],
//           );
//         }).toList(),
//         gridData: const FlGridData(show: true),
//         borderData: FlBorderData(show: false),
//       ),
//     );
//   }
// }
// lib/widgets/charts/pressure_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/station_data.dart';

/// A polished bar chart that visualizes station pressure readings.
///
/// Features:
/// - Gradient bars, color-coded by pressure status (low / normal / high)
/// - Animated entrance
/// - Average reference line with label
/// - Styled tooltip with station name + value
/// - Card container with title, subtitle and legend
/// - Graceful empty state
class PressureChart extends StatefulWidget {
  final List<StationData> data;

  /// Optional thresholds for status coloring. Tune to your domain.
  final double lowThreshold;
  final double highThreshold;

  const PressureChart({
    super.key,
    required this.data,
    this.lowThreshold = 1.0,
    this.highThreshold = 3.0,
  });

  @override
  State<PressureChart> createState() => _PressureChartState();
}

class _PressureChartState extends State<PressureChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  static const _lowColor = Color(0xFFEF5350); // red
  static const _normalColor = Color(0xFF42A5F5); // blue
  static const _highColor = Color(0xFFFFA726); // amber
  static const _cardBg = Color(0xFFFFFFFF);
  static const _gridColor = Color(0xFFE7EBF0);
  static const _textMuted = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant PressureChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _colorForPressure(double? pressure) {
    if (pressure == null) return _textMuted;
    if (pressure < widget.lowThreshold) return _lowColor;
    if (pressure > widget.highThreshold) return _highColor;
    return _normalColor;
  }

  double get _maxY {
    final values = widget.data.map((s) => s.pressure ?? 0).toList();
    if (values.isEmpty) return 5;
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    // Add ~20% headroom so bars/tooltips don't touch the top edge.
    return (maxVal <= 0 ? 5 : maxVal * 1.2);
  }

  double get _average {
    final valid =
        widget.data.map((s) => s.pressure).whereType<double>().toList();
    if (valid.isEmpty) return 0;
    return valid.reduce((a, b) => a + b) / valid.length;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 24, 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Parent SizedBox(height: 300) gives ~276 after container padding.
          // Use Expanded for the chart so it absorbs remaining vertical space
          // and the Column always fits its parent (no RenderFlex overflow).
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              Expanded(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, _) => BarChart(
                    _buildChartData(),
                    swapAnimationDuration: const Duration(milliseconds: 250),
                    swapAnimationCurve: Curves.easeOut,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildLegend(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Station Pressure',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.data.length} stations · avg ${_average.toStringAsFixed(2)} bar',
                style: const TextStyle(
                  fontSize: 13,
                  color: _textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.speed_rounded, size: 14, color: _textMuted),
              SizedBox(width: 4),
              Text(
                'bar',
                style: TextStyle(
                  fontSize: 12,
                  color: _textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    Widget dot(Color color, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: _textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        dot(_lowColor, 'Below ${widget.lowThreshold} bar'),
        dot(_normalColor, 'Normal'),
        dot(_highColor, 'Above ${widget.highThreshold} bar'),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gridColor),
      ),
      child: const Column(
        children: [
          Icon(Icons.bar_chart_rounded, size: 40, color: _textMuted),
          SizedBox(height: 12),
          Text(
            'No pressure data available',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _textMuted,
            ),
          ),
        ],
      ),
    );
  }

  BarChartData _buildChartData() {
    final maxY = _maxY;
    final average = _average;

    return BarChartData(
      maxY: maxY,
      alignment: BarChartAlignment.spaceAround,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: const Color(0xFF1F2937),
          tooltipRoundedRadius: 10,
          tooltipPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final station = widget.data[groupIndex];
            final pressure = station.pressure;
            return BarTooltipItem(
              '${station.name}\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              children: [
                TextSpan(
                  text: pressure != null
                      ? '${pressure.toStringAsFixed(2)} bar'
                      : 'No data',
                  style: TextStyle(
                    color: _colorForPressure(pressure),
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
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= widget.data.length) {
                return const SizedBox();
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8,
                child: Text(
                  widget.data[index].name,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 38,
            interval: maxY / 4,
            getTitlesWidget: (value, meta) => Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 11,
                color: _textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (value) => FlLine(
          color: _gridColor,
          strokeWidth: 1,
          dashArray: [4, 4],
        ),
      ),
      borderData: FlBorderData(show: false),
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: average,
            color: const Color(0xFF9CA3AF),
            strokeWidth: 1.5,
            dashArray: [6, 4],
            label: HorizontalLineLabel(
              show: true,
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(bottom: 4, right: 4),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
              labelResolver: (line) => 'avg ${average.toStringAsFixed(2)}',
            ),
          ),
        ],
      ),
      barGroups: widget.data.asMap().entries.map((entry) {
        final index = entry.key;
        final station = entry.value;
        final pressure = station.pressure ?? 0;
        final animatedY = pressure * _animation.value;
        final color = _colorForPressure(station.pressure);

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: animatedY,
              width: 18,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [color.withOpacity(0.55), color],
              ),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY,
                color: const Color(0xFFF3F4F6),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
