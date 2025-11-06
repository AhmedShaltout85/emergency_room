import 'package:flutter/material.dart';
import 'package:emergency_room/network/remote/remote_network_repos.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../utils/app_constants.dart';

class LabTestRadialChart extends StatelessWidget {
  final List<Map<String, dynamic>> labData;
  final String chartTitle;
  final String valueKey;
  final String labelKey;

  const LabTestRadialChart({
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.indigo,
            blurRadius: 4,
            offset: Offset(0, 2),
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
            height: 350,
            child: SfCircularChart(
              title: const ChartTitle(
                text: 'Test Results Distribution',
                textStyle: TextStyle(
                  color: Colors.indigo,
                ),
              ),
              legend: const Legend(
                isVisible: true,
                overflowMode: LegendItemOverflowMode.wrap,
                position: LegendPosition.bottom,
              ),
              series: <CircularSeries>[
                RadialBarSeries<ChartRadialData, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartRadialData data, _) => data.label,
                  yValueMapper: (ChartRadialData data, _) => data.value,
                  pointColorMapper: (ChartRadialData data, _) => data.color,
                  maximumValue: _calculateMaxValue(chartData),
                  innerRadius: '40%',
                  radius: '100%',
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    textStyle:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  cornerStyle: CornerStyle.bothCurve,
                  gap: '2%',
                  trackOpacity: 0.3,
                  trackColor: Colors.grey,
                  trackBorderWidth: 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildValueRangesLegend(chartData),
        ],
      ),
    );
  }

  List<ChartRadialData> _prepareChartData() {
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

      // Get color based on value
      final maxValue = labData.map((item) {
            final val = item[valueKey];
            if (val is num) return val.toDouble();
            if (val is String) return double.tryParse(val) ?? 0.0;
            return 0.0;
          }).reduce((a, b) => a > b ? a : b) *
          1.2;

      final color = _getBarColor(value, maxValue);

      return ChartRadialData(
        value: value,
        label: label,
        color: color,
      );
    }).toList();
  }

  double _calculateMaxValue(List<ChartRadialData> data) {
    if (data.isEmpty) return 100;

    final maxValue =
        data.map((item) => item.value).reduce((a, b) => a > b ? a : b);
    return maxValue * 1.2;
  }

  Color _getBarColor(double value, double maxValue) {
    final percentage = value / maxValue;

    if (percentage > 0.8) return Colors.red;
    if (percentage > 0.6) return Colors.orange;
    if (percentage > 0.4) return Colors.green;
    if (percentage > 0.2) return Colors.yellow;
    return Colors.blue;
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

  Widget _buildValueRangesLegend(List<ChartRadialData> data) {
    // final maxValue = _calculateMaxValue(data);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Value Ranges:',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, color: Colors.indigo),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLegendItem(Colors.blue, 'Low (0-20%)'),
            _buildLegendItem(Colors.green, 'Normal (20-40%)'),
            _buildLegendItem(Colors.yellow, 'Elevated (40-60%)'),
            _buildLegendItem(Colors.orange, 'High (60-80%)'),
            _buildLegendItem(Colors.red, 'Very High (80-100%)'),
          ],
        ),
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
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}

class ChartRadialData {
  final double value;
  final String label;
  final Color color;

  ChartRadialData({
    required this.value,
    required this.label,
    required this.color,
  });
}

//UI
class LabTestScreenRadial extends StatefulWidget {
  final String testName, testCode;
  final int labCode;
  const LabTestScreenRadial({
    Key? key,
    required this.labCode,
    required this.testCode,
    required this.testName,
  }) : super(key: key);

  @override
  _LabTestScreenState createState() => _LabTestScreenState();
}

class _LabTestScreenState extends State<LabTestScreenRadial> {
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
        //   style: const TextStyle(color: Colors.indigo),
        // ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.indigo),
            onPressed: _loadLabData,
          ),
        ],
        // centerTitle: true,
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
                      Text('Loading lab data...'),
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
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadLabData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Retry Loading Data'),
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
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No lab data available',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pull to refresh or check your connection',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: LabTestRadialChart(
                  labData: labData,
                  chartTitle: StaticVariables.labName,
                  valueKey: _findValueKey(labData),
                  labelKey: _findDateKey(labData),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
