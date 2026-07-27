
// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';

import 'package:emergency_room/custom_widget/no_internet_widget.dart';
import 'package:emergency_room/custom_widget/offline_banner.dart';
import 'package:emergency_room/model/custom_data_table_source.dart';
import 'package:emergency_room/network/remote/remote_network_repos.dart';
import 'package:emergency_room/services/connection_dialog_service.dart';
import 'package:emergency_room/services/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

class ComplaintsReportsScreen extends StatefulWidget {
  const ComplaintsReportsScreen({super.key});

  @override
  _ComplaintsReportsScreenState createState() =>
      _ComplaintsReportsScreenState();
}

class _ComplaintsReportsScreenState extends State<ComplaintsReportsScreen> {
  CustomDataTableSource<Map<String, dynamic>>? _dataSource;
  final List<Map<String, dynamic>> _allData = [];
  List<Map<String, dynamic>> _filteredData = [];
  bool _isLoading = true;
  bool _isOnline = true;
  bool _isOnlineChecked = false;

  // --- Filter state ---
  final TextEditingController _searchController = TextEditingController();
  String? _selectedHandasahName;
  String? _selectedTechnicalName;
  String? _selectedBrokerType;
  DateTimeRange? _selectedDateRange;
  bool?
      _selectedIsFinished; // true = مكتمل (1), false = قيد الصيانة (0), null = الكل

  static const String _allValue = 'الكل';
  static const String _finishedValue = 'مكتمل';
  static const String _pendingValue = 'قيد الصيانة';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void fetchData() async {
    final online = await ConnectivityService.instance.hasConnection();
    if (!mounted) return;
    setState(() {
      _isOnline = online;
      _isOnlineChecked = true;
    });
    if (!online) {
      setState(() {
        _isLoading = false;
      });
      // Only interrupt the user with a blocking dialog when there's
      // truly nothing on screen to show. If we already have cached
      // data, the OfflineBanner is enough — showing the dialog on
      // top of a populated table is exactly the confusing behavior
      // we want to avoid.
      if (_allData.isEmpty) {
        await ConnectionDialogService.showNoInternetDialog(
          context,
          onRetry: fetchData,
        );
      }
      return;
    }
    try {
      final value =
          await DioNetworkRepos().getLocByFlagAndIsFinishedForReports();

      if (!mounted) return;
      setState(() {
        _allData.clear();
        if (value is List) {
          _allData.addAll(value.cast<Map<String, dynamic>>());
        }
        _applyFilters();
        _isLoading = false;
      });

      log("GET ALL HOTLINE LOCATIONS: $value");
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      log("Error fetching data: $e");
      final onlineAgain = await ConnectivityService.instance.hasConnection();
      if (!mounted) return;
      setState(() {
        _isOnline = onlineAgain;
      });
      // Same rule here: only block with a dialog if there's no data
      // to fall back on. Otherwise let the banner communicate it.
      if (!onlineAgain && _allData.isEmpty) {
        await ConnectionDialogService.showNoInternetDialog(
          context,
          onRetry: fetchData,
        );
      }
    }
  }

  // Builds the distinct dropdown options from the fetched data.
  List<String> _distinctValues(String key, {String excludeValue = 'free'}) {
    final values = _allData
        .map((e) => e[key])
        .whereType<String>()
        .where((v) => v.isNotEmpty && v != excludeValue)
        .toSet()
        .toList();
    values.sort();
    return values;
  }

  DateTime? _tryParseDate(dynamic raw) {
    if (raw == null) return null;
    final str = raw.toString();
    return DateTime.tryParse(str);
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();

    _filteredData = _allData.where((item) {
      // Search across address, caller name, caller phone
      if (query.isNotEmpty) {
        final address = (item['address'] ?? '').toString().toLowerCase();
        final callerName = (item['caller_name'] ?? '').toString().toLowerCase();
        final callerPhone =
            (item['caller_phone'] ?? '').toString().toLowerCase();
        final matchesSearch = address.contains(query) ||
            callerName.contains(query) ||
            callerPhone.contains(query);
        if (!matchesSearch) return false;
      }

      if (_selectedHandasahName != null &&
          item['handasah_name'] != _selectedHandasahName) {
        return false;
      }

      if (_selectedTechnicalName != null &&
          item['technical_name'] != _selectedTechnicalName) {
        return false;
      }

      if (_selectedBrokerType != null &&
          item['broker_type'] != _selectedBrokerType) {
        return false;
      }

      if (_selectedIsFinished != null) {
        final isFinished = item['is_finished'] == 1;
        if (isFinished != _selectedIsFinished) return false;
      }

      if (_selectedDateRange != null) {
        final itemDate = _tryParseDate(item['date']);
        if (itemDate == null) return false;
        final startOk = !itemDate.isBefore(_selectedDateRange!.start);
        final endOk = !itemDate.isAfter(
          _selectedDateRange!.end.add(const Duration(days: 1)),
        );
        if (!startOk || !endOk) return false;
      }

      return true;
    }).toList();

    _dataSource = CustomDataTableSource<Map<String, dynamic>>(
      items: _filteredData,
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
          DataCell(Text(
            item["address"] ?? '',
            style: const TextStyle(color: Colors.indigo),
          )),
          DataCell(Text(
            item["handasah_name"] == 'free'
                ? 'لم يدرج اسم الهندسة'
                : item["handasah_name"] ?? 'لم يدرج اسم الهندسة',
            style: const TextStyle(color: Colors.indigo),
          )),
          DataCell(Text(
            item["technical_name"] == 'free'
                ? 'لم يدرج اسم الفني'
                : item["technical_name"] ?? 'لم يدرج اسم الفني',
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
          DataCell(Text(
            item['broker_type'] ?? 'لم يدرج نوع الكسر',
            style: const TextStyle(color: Colors.indigo),
          )),
          DataCell(Text(
            item['date'] ?? '',
            style: const TextStyle(color: Colors.indigo),
          )),
          DataCell(Text(
            item['is_finished'] == 1 ? 'مكتمل' : 'قيد الصيانة',
            style: const TextStyle(color: Colors.indigo),
          )),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedHandasahName = null;
      _selectedTechnicalName = null;
      _selectedBrokerType = null;
      _selectedDateRange = null;
      _selectedIsFinished = null;
      _applyFilters();
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _applyFilters();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OfflineBanner(visible: !_isOnline && _isOnlineChecked),
        Expanded(
          child: Container(
            color: Colors.indigo.shade50,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : (!_isOnline && _allData.isEmpty)
                    ? NoInternetWidget(onRetry: fetchData)
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildFilterBar(),
                            const SizedBox(height: 12),
                            Expanded(child: _buildTable()),
                          ],
                        ),
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Card(
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 420,
              child: TextField(
                controller: _searchController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: 'بحث (العنوان / إسم المبلغ / الموبيل)',
                  prefixIcon: const Icon(Icons.search),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (_) => setState(_applyFilters),
              ),
            ),
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                value: _selectedHandasahName ?? _allValue,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'إسم الهندسة',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                      value: _allValue, child: Text(_allValue)),
                  ..._distinctValues('handasah_name')
                      .map((v) => DropdownMenuItem(value: v, child: Text(v))),
                ],
                onChanged: (v) => setState(() {
                  _selectedHandasahName = (v == _allValue) ? null : v;
                  _applyFilters();
                }),
              ),
            ),
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                value: _selectedTechnicalName ?? _allValue,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'إسم الفني',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                      value: _allValue, child: Text(_allValue)),
                  ..._distinctValues('technical_name')
                      .map((v) => DropdownMenuItem(value: v, child: Text(v))),
                ],
                onChanged: (v) => setState(() {
                  _selectedTechnicalName = (v == _allValue) ? null : v;
                  _applyFilters();
                }),
              ),
            ),
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                value: _selectedBrokerType ?? _allValue,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'قطر الكسر',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                      value: _allValue, child: Text(_allValue)),
                  ..._distinctValues('broker_type')
                      .map((v) => DropdownMenuItem(value: v, child: Text(v))),
                ],
                onChanged: (v) => setState(() {
                  _selectedBrokerType = (v == _allValue) ? null : v;
                  _applyFilters();
                }),
              ),
            ),
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                value: _selectedIsFinished == null
                    ? _allValue
                    : (_selectedIsFinished! ? _finishedValue : _pendingValue),
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'حالة الكسر',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: _allValue, child: Text(_allValue)),
                  DropdownMenuItem(
                      value: _finishedValue, child: Text(_finishedValue)),
                  DropdownMenuItem(
                      value: _pendingValue, child: Text(_pendingValue)),
                ],
                onChanged: (v) => setState(() {
                  if (v == _allValue) {
                    _selectedIsFinished = null;
                  } else if (v == _finishedValue) {
                    _selectedIsFinished = true;
                  } else {
                    _selectedIsFinished = false;
                  }
                  _applyFilters();
                }),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _pickDateRange,
              icon: const Icon(Icons.date_range),
              label: Text(
                _selectedDateRange == null
                    ? 'تاريخ الكسر'
                    : '${_selectedDateRange!.start.toString().split(' ').first} - ${_selectedDateRange!.end.toString().split(' ').first}',
              ),
            ),
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear, color: Colors.red),
              label: const Text('مسح الفلاتر',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable() {
    final source = _dataSource;
    if (source == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return PaginatedDataTable2(
      columns: const [
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
            label: Text('إسم الفني',
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
        DataColumn(
            label: Text('قطر الكسر',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.indigo,
                ))),
        DataColumn(
            label: Text('تاريخ الكسر',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.indigo,
                ))),
        DataColumn(
            label: Text('حالة الكسر',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.indigo,
                ))),
      ],
      source: source,
      rowsPerPage: 10,
      columnSpacing: 20,
      horizontalMargin: 12,
      showCheckboxColumn: false,
      headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
    );
  }
}
