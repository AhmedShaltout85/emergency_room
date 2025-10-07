// custom_data_table_source.dart
import 'package:flutter/material.dart';

class CustomDataTableSource<T> extends DataTableSource {
  final List<T> items;
  final DataRow Function(T item) buildRow;

  CustomDataTableSource({
    required this.items,
    required this.buildRow,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= items.length) return null;
    return buildRow(items[index]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => items.length;

  @override
  int get selectedRowCount => 0;
}
