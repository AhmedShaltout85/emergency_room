import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:emergency_room/network/remote/dio_network_repos.dart';

import '../../utils/dio_http_constants.dart';

class LabTestRoseChart extends StatelessWidget {
  final List<Map<String, dynamic>> labData;
  final String chartTitle;
  final String valueKey;
  final String labelKey;

  const LabTestRoseChart({
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
            height: 350,
            child: Chart(
              data: chartData,
              variables: {
                'label': Variable(
                  accessor: (Map datum) => datum['label'] as String,
                ),
                'value': Variable(
                  accessor: (Map datum) => datum['value'] as num,
                ),
              },
              transforms: [
                Proportion(
                  variable: 'value',
                  as: 'percent',
                ),
              ],
              marks: [
                IntervalMark(
                  position: Varset('label') * Varset('percent'),
                  color: ColorEncode(
                    variable: 'label',
                    values: _generateColors(chartData.length),
                  ),
                )
              ],
              coord: PolarCoord(transposed: true),
              axes: [
                Defaults.radialAxis,
                Defaults.circularAxis,
              ],
              selections: {
                'touchMove': PointSelection(
                  on: {
                    GestureType.scaleUpdate,
                    GestureType.tapDown,
                    GestureType.longPressMoveUpdate
                  },
                  dim: Dim.x,
                )
              },
              tooltip: TooltipGuide(
                followPointer: [false, true],
                align: Alignment.topLeft,
                offset: const Offset(-20, -20),
                backgroundColor: Colors.black.withOpacity(0.8),
                elevation: 4,
                padding: const EdgeInsets.all(10),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                multiTuples: true,
                variables: ['label', 'value'],
              ),
              crosshair: CrosshairGuide(
                followPointer: [false, true],
              ),
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

  List<Map<String, dynamic>> _prepareChartData() {
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

      return {
        'label': label,
        'value': value,
        'index': index,
      };
    }).toList();
  }

  List<Color> _generateColors(int count) {
    return List.generate(count, (index) {
      final data = labData[index];
      double value;
      final dynamic valueData = data[valueKey];
      if (valueData is num) {
        value = valueData.toDouble();
      } else if (valueData is String) {
        value = double.tryParse(valueData) ?? 0.0;
      } else {
        value = 0.0;
      }
      return _getSegmentColor(value, index);
    });
  }

  Color _getSegmentColor(double value, int index) {
    // Color based on value range
    if (value > 80) return Colors.red.shade600;
    if (value > 60) return Colors.orange.shade600;
    if (value > 40) return Colors.yellow.shade600;
    if (value > 20) return Colors.green.shade600;
    return Colors.blue.shade600;
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

  Widget _buildLegend(List<Map<String, dynamic>> chartData) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        _buildLegendItem(Colors.blue.shade600, 'Low (0-20)'),
        _buildLegendItem(Colors.green.shade600, 'Normal (20-40)'),
        _buildLegendItem(Colors.yellow.shade600, 'Elevated (40-60)'),
        _buildLegendItem(Colors.orange.shade600, 'High (60-80)'),
        _buildLegendItem(Colors.red.shade600, 'Very High (80+)'),
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

  Widget _buildStatistics(List<Map<String, dynamic>> chartData) {
    if (chartData.isEmpty) return const SizedBox();

    final values = chartData.map((data) => data['value'] as double).toList();
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

//UI

class LabTestScreenRose extends StatefulWidget {
  final String testName, testCode;
  final int labCode;
  const LabTestScreenRose({
    Key? key,
    required this.labCode,
    required this.testCode,
    required this.testName,
  }) : super(key: key);

  @override
  _LabTestScreenState createState() => _LabTestScreenState();
}

class _LabTestScreenState extends State<LabTestScreenRose> {
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
            icon: const Icon(Icons.refresh, color: Colors.indigo),
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
                      Icon(Icons.auto_awesome, size: 64, color: Colors.grey),
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
                  child: LabTestRoseChart(
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
      //         backgroundColor: Colors.purple,
      //         foregroundColor: Colors.white,
      //         tooltip: 'Refresh Data',
      //         child: const Icon(Icons.refresh),
      //       )
      //     : null,
    );
  }
}
