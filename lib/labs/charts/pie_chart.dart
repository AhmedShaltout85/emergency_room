import 'package:flutter/material.dart';
import 'package:emergency_room/network/remote/dio_network_repos.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../utils/dio_http_constants.dart';

class LabTestPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> labData;
  final String chartTitle;
  final String valueKey;
  final String labelKey;

  const LabTestPieChart({
    Key? key,
    required this.labData,
    required this.chartTitle,
    required this.valueKey,
    required this.labelKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (labData.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    final chartData = _prepareChartData();
    final totalValue = chartData.fold(0.0, (sum, item) => sum + item.value);
    final maxValue =
        chartData.map((item) => item.value).reduce((a, b) => a > b ? a : b);

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
            chartTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 400,
            child: SfCircularChart(
              title: const ChartTitle(
                text: 'Test Results Distribution',
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.indigo,
                ),
              ),
              legend: const Legend(
                isVisible: true,
                overflowMode: LegendItemOverflowMode.wrap,
                position: LegendPosition.bottom,
                orientation: LegendItemOrientation.horizontal,
                textStyle: TextStyle(fontSize: 12),
              ),
              series: <CircularSeries>[
                PieSeries<ChartPieData, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartPieData data, _) => data.label,
                  yValueMapper: (ChartPieData data, _) => data.value,
                  pointColorMapper: (ChartPieData data, _) => data.color,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.inside,
                    textStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    showZeroValue: false,
                  ),
                  radius: '80%',
                  explode: true,
                  explodeIndex: _findLargestSegmentIndex(chartData),
                  explodeOffset: '10%',
                  animationDuration: 1500,
                  enableTooltip: true,

                  // tooltipSettings: const TooltipSettings(
                  //   enable: true,
                  //   format: 'point.x : point.y',
                  //   textStyle: TextStyle(fontSize: 14),
                  // ),
                ),
              ],
              annotations: <CircularChartAnnotation>[
                CircularChartAnnotation(
                  widget: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        totalValue.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        '${chartData.length} Tests',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailedStatistics(chartData, totalValue, maxValue),
        ],
      ),
    );
  }

  List<ChartPieData> _prepareChartData() {
    return labData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;

      // Extract value
      double value;
      final dynamic valueData = data[valueKey];
      if (valueData is num) {
        value = valueData.toDouble();
      } else if (valueData is String) {
        value = double.tryParse(valueData) ?? 0.0;
      } else {
        value = 0.0;
      }

      // Extract label
      String label = data[labelKey]?.toString() ?? 'Test ${index + 1}';
      label = _formatDateLabel(label);

      // Get unique color for each segment
      final color = _getSegmentColor(index);

      return ChartPieData(
        value: value,
        label: label,
        color: color,
        percentage: 0, // Will be calculated later
        formattedValue: value.toStringAsFixed(1),
      );
    }).toList();
  }

  Color _getSegmentColor(int index) {
    // Vibrant color palette for pie chart
    final colors = [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.red.shade600,
      Colors.teal.shade600,
      Colors.pink.shade600,
      Colors.indigo.shade600,
      Colors.amber.shade600,
      Colors.cyan.shade600,
      Colors.lime.shade600,
      Colors.deepOrange.shade600,
      Colors.deepPurple.shade600,
      Colors.lightBlue.shade600,
      Colors.lightGreen.shade600,
    ];

    return colors[index % colors.length];
  }

  int _findLargestSegmentIndex(List<ChartPieData> data) {
    if (data.isEmpty) return 0;

    double maxValue = 0;
    int maxIndex = 0;

    for (int i = 0; i < data.length; i++) {
      if (data[i].value > maxValue) {
        maxValue = data[i].value;
        maxIndex = i;
      }
    }

    return maxIndex;
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

  Widget _buildDetailedStatistics(
      List<ChartPieData> data, double totalValue, double maxValue) {
    if (data.isEmpty) return const SizedBox();

    final minValue =
        data.map((item) => item.value).reduce((a, b) => a < b ? a : b);
    final averageValue = totalValue / data.length;
    final largestSegment = data[_findLargestSegmentIndex(data)];

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detailed Statistics',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.indigo),
          ),
          const SizedBox(height: 5),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 4,
            childAspectRatio: 9.0,
            children: [
              _buildStatCard('Total Tests', data.length.toString(),
                  Icons.analytics, Colors.blue),
              _buildStatCard('Total Value', totalValue.toStringAsFixed(1),
                  Icons.summarize, Colors.green),
              _buildStatCard('Average', averageValue.toStringAsFixed(1),
                  Icons.trending_up, Colors.orange),
              _buildStatCard('Highest', maxValue.toStringAsFixed(1),
                  Icons.arrow_upward, Colors.red),
              _buildStatCard('Lowest', minValue.toStringAsFixed(1),
                  Icons.arrow_downward, Colors.purple),
              _buildStatCard('Largest Segment', largestSegment.label,
                  Icons.star, Colors.amber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon(icon, size: 5, color: color),
          const SizedBox(width: 3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartPieData {
  final double value;
  final String label;
  final Color color;
  final double percentage;
  final String formattedValue;

  ChartPieData({
    required this.value,
    required this.label,
    required this.color,
    required this.percentage,
    required this.formattedValue,
  });
}

//UI

class LabTestScreenPie extends StatefulWidget {
  final String testName, testCode;
  final int labCode;
  const LabTestScreenPie({
    Key? key,
    required this.labCode,
    required this.testCode,
    required this.testName,
  }) : super(key: key);

  @override
  _LabTestScreenState createState() => _LabTestScreenState();
}

class _LabTestScreenState extends State<LabTestScreenPie> {
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
        title: Text(
          widget.testName,
          style: const TextStyle(color: Colors.indigo),
        ),
        centerTitle: true,
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
                          backgroundColor: Colors.red,
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
                      Icon(Icons.pie_chart_outline,
                          size: 64, color: Colors.grey),
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
                  child: LabTestPieChart(
                    labData: labData,
                    chartTitle: DataStatic.labName,
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
      //         backgroundColor: Colors.red,
      //         foregroundColor: Colors.white,
      //         tooltip: 'Refresh Data',
      //         child: const Icon(Icons.refresh),
      //       )
      //     : null,
    );
  }
}
