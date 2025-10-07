import 'package:flutter/material.dart';
import 'package:emergency_room/network/remote/remote_network_repos.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../utils/app_constants.dart';

class LabTestDoughnutChart extends StatelessWidget {
  final List<Map<String, dynamic>> labData;
  final String chartTitle;
  final String valueKey;
  final String labelKey;

  const LabTestDoughnutChart({
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
          const SizedBox(height: 10),
          SizedBox(
            height: 450,
            child: SfCircularChart(
              title: const ChartTitle(
                text: 'Test Results Distribution',
                textStyle: TextStyle(color: Colors.indigo),
              ),
              legend: const Legend(
                isVisible: true,
                overflowMode: LegendItemOverflowMode.wrap,
                position: LegendPosition.bottom,
                orientation: LegendItemOrientation.horizontal,
              ),
              series: <CircularSeries>[
                DoughnutSeries<ChartDoughnutData, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartDoughnutData data, _) => data.label,
                  yValueMapper: (ChartDoughnutData data, _) => data.value,
                  pointColorMapper: (ChartDoughnutData data, _) => data.color,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    connectorLineSettings: ConnectorLineSettings(
                      length: '3%',
                      width: 2,
                      color: Colors.grey,
                    ),
                  ),
                  innerRadius: '60%',
                  radius: '100%',
                  explode: true,
                  explodeOffset: '10%',
                  animationDuration: 1000,
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
                          color: Colors.indigo,
                        ),
                      ),
                      Text(
                        totalValue.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        'Tests: ${chartData.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildStatistics(chartData, totalValue),
        ],
      ),
    );
  }

  List<ChartDoughnutData> _prepareChartData() {
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

      return ChartDoughnutData(
        value: value,
        label: '$label\n${value.toStringAsFixed(1)}',
        color: color,
        rawLabel: label,
      );
    }).toList();
  }

  Color _getSegmentColor(int index) {
    // Predefined color palette for better visual distinction
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.lime,
      Colors.brown,
    ];

    return colors[index % colors.length];
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

  Widget _buildStatistics(List<ChartDoughnutData> data, double totalValue) {
    if (data.isEmpty) return const SizedBox();

    final maxValue =
        data.map((item) => item.value).reduce((a, b) => a > b ? a : b);
    final minValue =
        data.map((item) => item.value).reduce((a, b) => a < b ? a : b);
    final averageValue = totalValue / data.length;

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
              _buildStatItem('Total Tests', data.length.toString()),
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

class ChartDoughnutData {
  final double value;
  final String label;
  final Color color;
  final String rawLabel;

  ChartDoughnutData({
    required this.value,
    required this.label,
    required this.color,
    required this.rawLabel,
  });
}

//UI

class LabTestScreenDoughnut extends StatefulWidget {
  final String testName, testCode;
  final int labCode;
  const LabTestScreenDoughnut({
    Key? key,
    required this.labCode,
    required this.testCode,
    required this.testName,
  }) : super(key: key);

  @override
  _LabTestScreenState createState() => _LabTestScreenState();
}

class _LabTestScreenState extends State<LabTestScreenDoughnut> {
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
        // backgroundColor: Colors.purple[700],
        // foregroundColor: Colors.white,
        // elevation: 4,
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
        centerTitle: true,
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
                          backgroundColor: Colors.purple,
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
                      Icon(Icons.analytics_outlined,
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
                  child: LabTestDoughnutChart(
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
      //         backgroundColor: Colors.indigo,
      //         foregroundColor: Colors.white,
      //         child: const Icon(Icons.refresh),
      //       )
      //     : null,
    );
  }
}
