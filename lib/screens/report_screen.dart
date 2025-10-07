// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

import '../model/custom_data_table_source.dart';
import '../network/remote/dio_network_repos.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late CustomDataTableSource<Map<String, dynamic>> _dataSource;
  final List<Map<String, dynamic>> _sampleData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      final value =
          await DioNetworkRepos().getLocByFlagAndIsFinishedForReports();

      setState(() {
        _sampleData.clear();
        _sampleData.addAll(value.cast<Map<String, dynamic>>());

        _dataSource = CustomDataTableSource<Map<String, dynamic>>(
          items: _sampleData,
          buildRow: (item) => DataRow(
            color: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.blue.withOpacity(0.2);
                }
                return item["id"] % 2 == 0 ? Colors.grey[100] : null;
              },
            ),
            cells: [
              DataCell(Text(item["id"].toString(),
                  style: const TextStyle(
                    color: Colors.indigo,
                  ))),
              DataCell(Text(
                item["address"] ?? '',
                style: const TextStyle(color: Colors.indigo),
              )),
              DataCell(Text(
                item["handasah_name"] ?? '',
                style: const TextStyle(color: Colors.indigo),
              )),
              DataCell(Text(
                item['latitude'].toString(),
                style: const TextStyle(color: Colors.indigo),
              )),
              DataCell(Text(
                item['longitude'].toString(),
                style: const TextStyle(color: Colors.indigo),
              )),
              DataCell(Text(
                item['caller_name'] ?? '',
                style: const TextStyle(color: Colors.indigo),
              )),
              DataCell(Text(
                item['caller_phone'] ?? '',
                style: const TextStyle(color: Colors.indigo),
              )),
            ],
          ),
        );

        _isLoading = false;
      });

      log("GET ALL HOTLINE LOCATIONS: $value");
    } catch (e) {
      log("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'التقارير',
          style: TextStyle(
            color: Colors.indigo,
          ),
        ),
        centerTitle: true,
        // backgroundColor: Colors.white,
        // iconTheme: const IconThemeData(
        //   color: Colors.indigo,
        // ),
        elevation: 7.0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.indigo),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
      ),
      body: _buildBody(),
    );
    // _isLoading
    //     ? const Center(child: CircularProgressIndicator())
    //     : Padding(
    //         padding: const EdgeInsets.all(16.0),
    //         child: PaginatedDataTable2(
    //           columns: const [
    //             DataColumn(
    //                 label: Text('ID',
    //                     style: TextStyle(
    //                       fontWeight: FontWeight.bold,
    //                       fontSize: 16,
    //                       color: Colors.indigo,
    //                     ))),
    //             DataColumn(
    //                 label: Text('العنوان',
    //                     style: TextStyle(
    //                       fontWeight: FontWeight.bold,
    //                       fontSize: 16,
    //                       color: Colors.indigo,
    //                     ))),
    //             DataColumn(
    //                 label: Text('إسم الهندسة',
    //                     style: TextStyle(
    //                         fontWeight: FontWeight.bold,
    //                         fontSize: 16,
    //                         color: Colors.indigo))),
    //             DataColumn(
    //                 label: Text('خط العرض',
    //                     style: TextStyle(
    //                       fontWeight: FontWeight.bold,
    //                       fontSize: 16,
    //                       color: Colors.indigo,
    //                     ))),
    //             DataColumn(
    //                 label: Text('خط الطول',
    //                     style: TextStyle(
    //                       fontWeight: FontWeight.bold,
    //                       fontSize: 16,
    //                       color: Colors.indigo,
    //                     ))),
    //             DataColumn(
    //                 label: Text('إسم المبلغ',
    //                     style: TextStyle(
    //                       fontWeight: FontWeight.bold,
    //                       fontSize: 16,
    //                       color: Colors.indigo,
    //                     ))),
    //             DataColumn(
    //                 label: Text('رقم موبيل المبلغ',
    //                     style: TextStyle(
    //                       fontWeight: FontWeight.bold,
    //                       fontSize: 16,
    //                       color: Colors.indigo,
    //                     ))),
    //           ],
    //           source: _dataSource,
    //           rowsPerPage: 10,
    //           columnSpacing: 20,
    //           horizontalMargin: 12,
    //           showCheckboxColumn: false,
    //           headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
    //         ),
    //       );
  }

  _buildBody() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: PaginatedDataTable2(
              columns: const [
                DataColumn(
                    label: Text('ID',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.indigo,
                        ))),
                DataColumn(
                    label: Text('العنوان',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.indigo,
                        ))),
                DataColumn(
                    label: Text('إسم الهندسة',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.indigo))),
                DataColumn(
                    label: Text('خط العرض',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.indigo,
                        ))),
                DataColumn(
                    label: Text('خط الطول',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.indigo,
                        ))),
                DataColumn(
                    label: Text('إسم المبلغ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.indigo,
                        ))),
                DataColumn(
                    label: Text('رقم موبيل المبلغ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.indigo,
                        ))),
              ],
              source: _dataSource,
              rowsPerPage: 10,
              columnSpacing: 20,
              horizontalMargin: 12,
              showCheckboxColumn: false,
              headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
            ),
          );
  }
}
