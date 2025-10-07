import 'package:flutter/material.dart';
import 'package:mrx_charts/mrx_charts.dart';
import 'package:emergency_room/network/remote/remote_network_repos.dart';
import 'package:emergency_room/utils/app_constants.dart';

// Helper class to store chart data
class ChartBarData {
  final int x;
  final double value;
  final String label;

  ChartBarData({
    required this.x,
    required this.value,
    required this.label,
  });
}

class LabTestBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> labData;
  final String chartTitle;
  final String valueKey;
  final String labelKey;

  const LabTestBarChart({
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

    // Prepare data for the chart
    final chartItems = _prepareChartData();

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
            height: 300,
            child: Chart(
              layers: [
                ChartAxisLayer(
                  settings: ChartAxisSettings(
                    x: ChartAxisSettingsAxis(
                      frequency: 1,
                      max: chartItems.length.toDouble(),
                      min: 0,
                      textStyle: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 10,
                      ),
                    ),
                    y: ChartAxisSettingsAxis(
                      frequency: _calculateYFrequency(chartItems),
                      max: _calculateYMax(chartItems),
                      min: 0,
                      textStyle: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  labelX: (value) {
                    final index = value.toInt() - 1;
                    if (index >= 0 && index < chartItems.length) {
                      return _formatDateLabel(chartItems[index].label);
                    }
                    return '';
                  },
                  labelY: (value) => value.toStringAsFixed(1),
                ),
                ChartBarLayer(
                  items: chartItems.map((item) {
                    return ChartBarDataItem(
                      x: item.x.toDouble(),
                      value: item.value,
                      color: _getBarColor(item.value, chartItems),
                    );
                  }).toList(),
                  settings: const ChartBarSettings(
                    thickness: 20,
                    radius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<ChartBarData> _prepareChartData() {
    return labData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;

      // Extract value - handle different data types
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
      final label = data[labelKey]?.toString() ?? 'Item ${index + 1}';

      return ChartBarData(
        x: index + 1,
        value: value,
        label: label,
      );
    }).toList();
  }

  double _calculateYMax(List<ChartBarData> items) {
    if (items.isEmpty) return 100;

    final maxValue =
        items.map((item) => item.value).reduce((a, b) => a > b ? a : b);
    // Add some padding to the max value
    return maxValue * 1.2;
  }

  double _calculateYFrequency(List<ChartBarData> items) {
    final maxValue = _calculateYMax(items);
    if (maxValue <= 10) return 1;
    if (maxValue <= 50) return 5;
    if (maxValue <= 100) return 10;
    return 20;
  }

  Color _getBarColor(double value, List<ChartBarData> items) {
    final maxValue = _calculateYMax(items);
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
      // If parsing fails, try to extract date from string
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
}

//UI and chart Page
class LabTestScreenBar extends StatefulWidget {
  final String testName, testCode;
  final int labCode;
  const LabTestScreenBar({
    Key? key,
    required this.labCode,
    required this.testCode,
    required this.testName,
  }) : super(key: key);

  @override
  _LabTestScreenState createState() => _LabTestScreenState();
}

class _LabTestScreenState extends State<LabTestScreenBar> {
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

  // Helper method to find the correct keys in your API response
  String _findValueKey(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 'testValue';

    final firstItem = data.first;

    // Try common key names for test values
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

    // Fallback: return the first numeric field
    for (var key in firstItem.keys) {
      if (firstItem[key] is num) {
        return key;
      }
    }

    return 'testValue'; // Default fallback
  }

  String _findDateKey(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 'testDate';

    final firstItem = data.first;

    // Try common key names for dates
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

    // Fallback: return the first string field that looks like a date
    for (var key in firstItem.keys) {
      final value = firstItem[key];
      if (value is String && _looksLikeDate(value)) {
        return key;
      }
    }

    return 'testDate'; // Default fallback
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.indigo,
            ),
            onPressed: _loadLabData,
          ),
        ],
        centerTitle: true,
        elevation: 7,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (errorMessage != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadLabData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (labData.isEmpty)
              const Expanded(
                child: Center(child: Text('No data available')),
              )
            else
              Expanded(
                flex: 2,
                child: LabTestBarChart(
                  labData: labData,
                  chartTitle: StaticVariables.labName,
                  valueKey: _findValueKey(labData),
                  labelKey: _findDateKey(labData),
                ),
              ),
            const Expanded(
              flex: 1,
              child: SizedBox(
                  // width: 200,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
