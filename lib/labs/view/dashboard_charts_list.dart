

// import 'package:flutter/material.dart';
// import 'package:emergency_room/labs/charts/bar_chart.dart';
// import 'package:emergency_room/labs/charts/doughnut_chart.dart';
// import 'package:emergency_room/labs/charts/line_chart.dart';
// import 'package:emergency_room/labs/charts/pie_chart.dart';
// import 'package:emergency_room/labs/charts/radial_chart.dart';
// import 'package:emergency_room/labs/charts/rose_chart.dart';
// import 'package:emergency_room/utils/app_constants.dart';

// class DashboardChartsList extends StatefulWidget {
//   const DashboardChartsList({super.key});

//   @override
//   State<DashboardChartsList> createState() => _DashboardChartsListState();
// }

// class _DashboardChartsListState extends State<DashboardChartsList>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   final List<Map<String, String>> tabItems = [
//     {
//       'title': 'العكارة',
//       'testCode': '1',
//     },
//     {
//       'title': 'المنسوب',
//       'testCode': '1045',
//     },
//     {
//       'title': 'الأس الهيدروجيني',
//       'testCode': '3',
//     },
//     {
//       'title': 'الكلور الحر',
//       'testCode': '82',
//     },
//     {
//       'title': 'الأمونيا الحرة',
//       'testCode': '88',
//     },
//     {
//       'title': 'جرعة المروب المعملية',
//       'testCode': '1050',
//     },
//     {
//       'title': 'التوصيل الكهربي',
//       'testCode': '87',
//     },
//     {
//       'title': 'الكلور المتبقى',
//       'testCode': '82',
//     },
//     {
//       'title': 'جرعة الكلور النهائي المعملية',
//       'testCode': '1052',
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: tabItems.length, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Widget _buildChartWidget(int index) {
//     final item = tabItems[index];
//     final String title = item['title']!;
//     final String testCode = item['testCode']!;

//     switch (title) {
//       case 'العكارة':
//       case 'التوصيل الكهربي':
//         return LabTestScreenBar(
//           labCode: StaticVariables.labCode,
//           testCode: testCode,
//           testName: title,
//         );
//       case 'المنسوب':
//       case 'الكلور المتبقى':
//         return LabTestScreenDoughnut(
//           labCode: StaticVariables.labCode,
//           testCode: testCode,
//           testName: title,
//         );
//       case 'الأس الهيدروجيني':
//         return LabTestScreenLine(
//           labCode: StaticVariables.labCode,
//           testCode: testCode,
//           testName: title,
//         );
//       case 'الكلور الحر':
//         return LabTestScreenPie(
//           labCode: StaticVariables.labCode,
//           testCode: testCode,
//           testName: title,
//         );
//       case 'الأمونيا الحرة':
//         return LabTestScreenRadial(
//           labCode: StaticVariables.labCode,
//           testCode: testCode,
//           testName: title,
//         );
//       case 'جرعة المروب المعملية':
//       case 'جرعة الكلور النهائي المعملية':
//         return LabTestScreenRose(
//           labCode: StaticVariables.labCode,
//           testCode: testCode,
//           testName: title,
//         );
//       default:
//         return Center(
//           child: Text(
//             'لا يوجد رسم بياني متوفر لـ $title',
//             style: const TextStyle(fontSize: 18),
//           ),
//         );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Text(
//           StaticVariables.labName,
//           style: const TextStyle(color: Colors.indigo),
//         ),
//         centerTitle: true,
//         bottom: TabBar(
//           labelStyle: const TextStyle(
//             fontSize: 17,
//             fontWeight: FontWeight.bold,
//             color: Colors.indigo,
//           ),
//           controller: _tabController,
//           isScrollable: true,
//           tabs: tabItems.map((item) {
//             return Tab(
//               text: item['title'],
//             );
//           }).toList(),
//           labelColor: Colors.indigo,
//           unselectedLabelColor: Colors.grey,
//           indicatorColor: Colors.indigo,
//           indicatorWeight: 3.0,
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: List.generate(tabItems.length, (index) {
//           return _buildChartWidget(index);
//         }),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:emergency_room/labs/charts/bar_chart.dart';
import 'package:emergency_room/labs/charts/doughnut_chart.dart';
import 'package:emergency_room/labs/charts/line_chart.dart';
import 'package:emergency_room/labs/charts/pie_chart.dart';
import 'package:emergency_room/labs/charts/radial_chart.dart';
import 'package:emergency_room/labs/charts/rose_chart.dart';
import 'package:emergency_room/utils/app_constants.dart';

class DashboardChartsList extends StatefulWidget {
  const DashboardChartsList({super.key});

  @override
  State<DashboardChartsList> createState() => _DashboardChartsListState();
}

class _DashboardChartsListState extends State<DashboardChartsList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> tabItems = [
    {
      'title': 'العكارة',
      'testCode': '1',
    },
    {
      'title': 'المنسوب',
      'testCode': '1045',
    },
    {
      'title': 'الأس الهيدروجيني',
      'testCode': '3',
    },
    {
      'title': 'الكلور الحر',
      'testCode': '82',
    },
    {
      'title': 'الأمونيا الحرة',
      'testCode': '88',
    },
    {
      'title': 'جرعة المروب المعملية',
      'testCode': '1050',
    },
    {
      'title': 'التوصيل الكهربي',
      'testCode': '87',
    },
    {
      'title': 'الكلور المتبقى',
      'testCode': '82',
    },
    {
      'title': 'جرعة الكلور النهائي المعملية',
      'testCode': '1052',
    },
  ];

  // Color scheme for tabs
  final Color selectedTabColor = Colors.blue.shade700;
  final Color unselectedTabColor = Colors.grey.shade300;
  final Color selectedTextColor = Colors.white;
  final Color unselectedTextColor = Colors.black87;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabItems.length, vsync: this);
    // Add listener to update the UI when tab changes
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildChartWidget(int index) {
    final item = tabItems[index];
    final String title = item['title']!;
    final String testCode = item['testCode']!;

    switch (title) {
      case 'العكارة':
      case 'التوصيل الكهربي':
        return LabTestScreenBar(
          labCode: StaticVariables.labCode,
          testCode: testCode,
          testName: title,
        );
      case 'المنسوب':
      case 'الكلور المتبقى':
        return LabTestScreenDoughnut(
          labCode: StaticVariables.labCode,
          testCode: testCode,
          testName: title,
        );
      case 'الأس الهيدروجيني':
        return LabTestScreenLine(
          labCode: StaticVariables.labCode,
          testCode: testCode,
          testName: title,
        );
      case 'الكلور الحر':
        return LabTestScreenPie(
          labCode: StaticVariables.labCode,
          testCode: testCode,
          testName: title,
        );
      case 'الأمونيا الحرة':
        return LabTestScreenRadial(
          labCode: StaticVariables.labCode,
          testCode: testCode,
          testName: title,
        );
      case 'جرعة المروب المعملية':
      case 'جرعة الكلور النهائي المعملية':
        return LabTestScreenRose(
          labCode: StaticVariables.labCode,
          testCode: testCode,
          testName: title,
        );
      default:
        return Center(
          child: Text(
            'لا يوجد رسم بياني متوفر لـ $title',
            style: const TextStyle(fontSize: 18),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: Text(
          StaticVariables.labName,
          style: const TextStyle(color: Colors.indigo),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: List.generate(tabItems.length, (index) {
                  final item = tabItems[index];
                  final isSelected = _tabController.index == index;

                  return Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? selectedTabColor : unselectedTabColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        item['title']!,
                        style: TextStyle(
                          color: isSelected
                              ? selectedTextColor
                              : unselectedTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),
                indicator: const BoxDecoration(
                  color: Colors.transparent,
                ),
                indicatorSize: TabBarIndicatorSize.label,
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(tabItems.length, (index) {
          return _buildChartWidget(index);
        }),
      ),
    );
  }
}
