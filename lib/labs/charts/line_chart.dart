import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:emergency_room/network/remote/remote_network_repos.dart';

import '../../utils/app_constants.dart';

class LabTestLineChart extends StatefulWidget {
  final List<Map<String, dynamic>> labData;
  final String chartTitle;
  final String valueKey;
  final String labelKey;

  const LabTestLineChart({
    Key? key,
    required this.labData,
    required this.chartTitle,
    required this.valueKey,
    required this.labelKey,
  }) : super(key: key);

  @override
  _LabTestLineChartState createState() => _LabTestLineChartState();
}

class _LabTestLineChartState extends State<LabTestLineChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.labData.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    final chartData = _prepareChartData();
    final maxValue = _calculateMaxValue(chartData);
    final minValue = _calculateMinValue(chartData);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.chartTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: LineChart(
              mainData(chartData, maxValue, minValue),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(chartData),
          const SizedBox(height: 16),
          _buildStatistics(chartData),
        ],
      ),
    );
  }

  List<ChartLineData> _prepareChartData() {
    return widget.labData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;

      // Extract value
      double value;
      final dynamic valueData = data[widget.valueKey];
      if (valueData is num) {
        value = valueData.toDouble();
      } else if (valueData is String) {
        value = double.tryParse(valueData) ?? 0.0;
      } else {
        value = 0.0;
      }

      // Extract label
      String label = data[widget.labelKey]?.toString() ?? 'Test ${index + 1}';
      label = _formatDateLabel(label);

      return ChartLineData(
        x: index.toDouble(),
        y: value,
        label: label,
        color: _getLineColor(value, index),
      );
    }).toList();
  }

  Color _getLineColor(double value, int index) {
    // Color based on value range
    if (value > 80) return Colors.red;
    if (value > 60) return Colors.orange;
    if (value > 40) return Colors.yellow;
    if (value > 20) return Colors.green;
    return Colors.blue;
  }

  double _calculateMaxValue(List<ChartLineData> data) {
    if (data.isEmpty) return 100;
    return data.map((item) => item.y).reduce((a, b) => a > b ? a : b) * 1.2;
  }

  double _calculateMinValue(List<ChartLineData> data) {
    if (data.isEmpty) return 0;
    final minValue = data.map((item) => item.y).reduce((a, b) => a < b ? a : b);
    return minValue > 0 ? 0 : minValue * 1.2;
  }

  String _formatDateLabel(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${_getMonthAbbreviation(date.month)} ${date.day}';
    } catch (e) {
      final regex = RegExp(r'(\d{4}[-/]\d{2}[-/]\d{2})');
      final match = regex.firstMatch(dateString);
      if (match != null) {
        try {
          final date = DateTime.parse(match.group(1)!);
          return '${_getMonthAbbreviation(date.month)} ${date.day}';
        } catch (e) {
          return dateString.length > 10
              ? dateString.substring(0, 10)
              : dateString;
        }
      }
      return dateString.length > 10 ? dateString.substring(0, 10) : dateString;
    }
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  LineChartData mainData(
      List<ChartLineData> chartData, double maxValue, double minValue) {
    return LineChartData(
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
          tooltipRoundedRadius: 8,
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.toInt();
              return LineTooltipItem(
                '${chartData[index].label}\n${spot.y.toStringAsFixed(1)}',
                const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              );
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: _calculateGridInterval(maxValue - minValue),
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[300],
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey[200],
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (double value, TitleMeta meta) {
              final index = value.toInt();
              if (index >= 0 && index < chartData.length) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(
                    chartData[index].label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black87,
                    ),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: _calculateGridInterval(maxValue - minValue),
            reservedSize: 40,
            getTitlesWidget: (double value, TitleMeta meta) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 4,
                child: Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black87,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d), width: 1),
      ),
      minX: 0,
      maxX: chartData.isNotEmpty ? (chartData.length - 1).toDouble() : 0,
      minY: minValue,
      maxY: maxValue,
      lineBarsData: [
        LineChartBarData(
          spots: chartData.map((data) => FlSpot(data.x, data.y)).toList(),
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade400,
              Colors.green.shade400,
              Colors.orange.shade400,
              Colors.red.shade400,
            ],
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade400.withOpacity(0.3),
                Colors.green.shade400.withOpacity(0.3),
                Colors.orange.shade400.withOpacity(0.3),
                Colors.red.shade400.withOpacity(0.3),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _calculateGridInterval(double range) {
    if (range <= 10) return 1;
    if (range <= 50) return 5;
    if (range <= 100) return 10;
    return 20;
  }

  Widget _buildLegend(List<ChartLineData> chartData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(Colors.blue, 'Low (0-20)'),
        _buildLegendItem(Colors.green, 'Normal (20-40)'),
        _buildLegendItem(Colors.yellow, 'Elevated (40-60)'),
        _buildLegendItem(Colors.orange, 'High (60-80)'),
        _buildLegendItem(Colors.red, 'Very High (80+)'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildStatistics(List<ChartLineData> chartData) {
    if (chartData.isEmpty) return const SizedBox();

    final values = chartData.map((data) => data.y).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final averageValue =
        values.fold(0.0, (sum, value) => sum + value) / values.length;
    final totalValue = values.fold(0.0, (sum, value) => sum + value);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistics:',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.indigo),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Total Tests', chartData.length.toString()),
              _buildStatItem('Average', averageValue.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Highest', maxValue.toStringAsFixed(1)),
              _buildStatItem('Lowest', minValue.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatItem('Total Value', totalValue.toStringAsFixed(1)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class ChartLineData {
  final double x;
  final double y;
  final String label;
  final Color color;

  ChartLineData({
    required this.x,
    required this.y,
    required this.label,
    required this.color,
  });
}

//UI

class LabTestScreenLine extends StatefulWidget {
  final String testName, testCode;
  final int labCode;

  const LabTestScreenLine({
    Key? key,
    required this.labCode,
    required this.testCode,
    required this.testName,
  }) : super(key: key);

  @override
  _LabTestScreenState createState() => _LabTestScreenState();
}

class _LabTestScreenState extends State<LabTestScreenLine> {
  List<Map<String, dynamic>> labData = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLabData();
  }

  Future<void> _loadLabData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await DioNetworkRepos()
          .getAllLabsItemsByTestValueAndDate(widget.labCode, widget.testCode);
      setState(() {
        labData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data: $e';
      });
    }
  }

  String _findValueKey(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 'testValue';

    final firstItem = data.first;

    final possibleKeys = [
      'actualTestValue',
      'testValue',
      'value',
      'resultValue',
      'measurement',
      'numericValue',
      'labValue',
      'testResult'
    ];

    for (var key in possibleKeys) {
      if (firstItem.containsKey(key)) {
        return key;
      }
    }

    for (var key in firstItem.keys) {
      if (firstItem[key] is num) {
        return key;
      }
    }

    return 'testValue';
  }

  String _findDateKey(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 'testDate';

    final firstItem = data.first;

    final possibleKeys = [
      'testDate',
      'date',
      'collectionDate',
      'resultDate',
      'testTime',
      'timestamp',
      'createdAt',
      'collectionTime'
    ];

    for (var key in possibleKeys) {
      if (firstItem.containsKey(key)) {
        return key;
      }
    }

    for (var key in firstItem.keys) {
      final value = firstItem[key];
      if (value is String && _looksLikeDate(value)) {
        return key;
      }
    }

    return 'testDate';
  }

  bool _looksLikeDate(String value) {
    return RegExp(r'\d{4}[-/]\d{2}[-/]\d{2}').hasMatch(value) ||
        RegExp(r'\d{2}[-/]\d{2}[-/]\d{4}').hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,

        // title: Text(
        //   widget.testName,
        //   style: const TextStyle(
        //     color: Colors.indigo,
        //   ),
        // ),
        // centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.indigo,
            ),
            onPressed: _loadLabData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isLoading)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Loading lab test data...',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else if (errorMessage != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadLabData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry Loading'),
                      ),
                    ],
                  ),
                ),
              )
            else if (labData.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.show_chart, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No lab test data available',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Check your API connection or try refreshing',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: LabTestLineChart(
                    labData: labData,
                    chartTitle: StaticVariables.labName,
                    valueKey: _findValueKey(labData),
                    labelKey: _findDateKey(labData),
                  ),
                ),
              ),
          ],
        ),
      ),
      // floatingActionButton: labData.isNotEmpty
      //     ? FloatingActionButton(
      //         onPressed: _loadLabData,
      //         backgroundColor: Colors.blue,
      //         foregroundColor: Colors.white,
      //         tooltip: 'Refresh Data',
      //         child: const Icon(Icons.refresh),
      //       )
      //     : null,
    );
  }
}
