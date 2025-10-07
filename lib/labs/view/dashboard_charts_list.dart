import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:emergency_room/labs/charts/bar_chart.dart';
import 'package:emergency_room/labs/charts/doughnut_chart.dart';
import 'package:emergency_room/labs/charts/line_chart.dart';
import 'package:emergency_room/labs/charts/pie_chart.dart';
import 'package:emergency_room/labs/charts/radial_chart.dart';
import 'package:emergency_room/labs/charts/rose_chart.dart';
import 'package:emergency_room/utils/dio_http_constants.dart';

import '../model/grid_view_items.dart';
import '../widget/custom_reusable_grid_view.dart';

class DashboardChartsList extends StatelessWidget {
  final List<GridItem> gridItems = [
    GridItem(
      title: 'العكارة',
      testCode: 1.toString(),
      // icon: Icons.ac_unit,
    ),
    GridItem(
      title: 'المنسوب',
      testCode: 1045.toString(),
      // icon: Icons.person,
    ),
    GridItem(
      title: 'الأس الهيدروجيني',
      testCode: 3.toString(),
      // icon: Icons.person,
    ),
    GridItem(
      title: 'الكلور الحر',
      testCode: 82.toString(),
      // icon: Icons.person,
    ),
    GridItem(
      title: 'الأمونيا الحرة',
      testCode: 88.toString(),
      // icon: Icons.person,
    ),
    GridItem(
      title: 'جرعة المروب المعملية',
      testCode: 1050.toString(),
      // icon: Icons.person,
    ),
    GridItem(
      title: 'التوصيل الكهربي',
      testCode: 87.toString(),
      // icon: Icons.person,
    ),
    GridItem(
      title: 'الكلور المتبقى',
      testCode: 82.toString(),
      // icon: Icons.person,
    ),
    GridItem(
      title: 'جرعة الكلور النهائي المعملية',
      testCode: 1052.toString(),
      // icon: Icons.person,
    ),
  ];

  DashboardChartsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          DataStatic.labName,
          style: const TextStyle(color: Colors.indigo),
        ),
        centerTitle: true,
      ),
      body: CustomGridView(
        items: gridItems,
        crossAxisCount: 3,
        childAspectRatio: 7.0,
        mainAxisSpacing: 15.0,
        crossAxisSpacing: 15.0,
        // Optional: Custom onItemTap handler
        onItemTap: (item) {
          log('Custom handler for: ${item.title}');
          log('Custom handler for: ${item.testCode}');
          // Add custom navigation logic here
          if (item.title == "العكارة") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => LabTestScreenBar(
                  labCode: DataStatic.labCode,
                  testCode: item.testCode,
                  testName: item.title,
                ),
              ),
            );
          } else if (item.title == "المنسوب") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => LabTestScreenDoughnut(
                  labCode: DataStatic.labCode,
                  testCode: item.testCode,
                  testName: item.title,
                ),
              ),
            );
          } else if (item.title == 'الأس الهيدروجيني') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => LabTestScreenLine(
                  labCode: DataStatic.labCode,
                  testCode: item.testCode,
                  testName: item.title,
                ),
              ),
            );
          } else if (item.title == 'الكلور الحر') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => LabTestScreenPie(
                  labCode: DataStatic.labCode,
                  testCode: item.testCode,
                  testName: item.title,
                ),
              ),
            );
          } else if (item.title == 'الأمونيا الحرة') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => LabTestScreenRadial(
                  labCode: DataStatic.labCode,
                  testCode: item.testCode,
                  testName: item.title,
                ),
              ),
            );
          } else if (item.title == 'جرعة المروب المعملية') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => LabTestScreenRose(
                  labCode: DataStatic.labCode,
                  testCode: item.testCode,
                  testName: item.title,
                ),
              ),
            );
          } else if (item.title == 'التوصيل الكهربي') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => LabTestScreenBar(
                  labCode: DataStatic.labCode,
                  testCode: item.testCode,
                  testName: item.title,
                ),
              ),
            );
          } else if (item.title == 'الكلور المتبقى') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => LabTestScreenDoughnut(
                  labCode: DataStatic.labCode,
                  testCode: item.testCode,
                  testName: item.title,
                ),
              ),
            );
          } else if (item.title == 'جرعة الكلور النهائي المعملية') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => LabTestScreenRose(
                  labCode: DataStatic.labCode,
                  testCode: item.testCode,
                  testName: item.title,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
