
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

//   // Color scheme for tabs
//   final Color selectedTabColor = Colors.blue.shade700;
//   final Color unselectedTabColor = Colors.grey.shade300;
//   final Color selectedTextColor = Colors.white;
//   final Color unselectedTextColor = Colors.black87;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: tabItems.length, vsync: this);
//     // Add listener to update the UI when tab changes
//     _tabController.addListener(_handleTabSelection);
//   }

//   void _handleTabSelection() {
//     if (_tabController.indexIsChanging) {
//       setState(() {});
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.removeListener(_handleTabSelection);
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
//         // automaticallyImplyLeading: false,
//         title: Text(
//           StaticVariables.labName,
//           style: const TextStyle(color: Colors.indigo),
//         ),
//         centerTitle: true,
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(60.0),
//           child: Column(
//             children: [
//               TabBar(
//                 controller: _tabController,
//                 isScrollable: true,
//                 tabs: List.generate(tabItems.length, (index) {
//                   final item = tabItems[index];
//                   final isSelected = _tabController.index == index;

//                   return Tab(
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 8),
//                       decoration: BoxDecoration(
//                         color:
//                             isSelected ? selectedTabColor : unselectedTabColor,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color: Colors.grey.shade400,
//                           width: 1,
//                         ),
//                       ),
//                       child: Text(
//                         item['title']!,
//                         style: TextStyle(
//                           color: isSelected
//                               ? selectedTextColor
//                               : unselectedTextColor,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   );
//                 }),
//                 indicator: const BoxDecoration(
//                   color: Colors.transparent,
//                 ),
//                 indicatorSize: TabBarIndicatorSize.label,
//                 labelPadding: const EdgeInsets.symmetric(horizontal: 4),
//               ),
//             ],
//           ),
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
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:emergency_room/custom_widget/no_internet_widget.dart';
import 'package:emergency_room/custom_widget/offline_banner.dart';
import 'package:emergency_room/labs/charts/bar_chart.dart';
import 'package:emergency_room/labs/charts/doughnut_chart.dart';
import 'package:emergency_room/labs/charts/line_chart.dart';
import 'package:emergency_room/labs/charts/pie_chart.dart';
import 'package:emergency_room/labs/charts/radial_chart.dart';
import 'package:emergency_room/labs/charts/rose_chart.dart';
import 'package:emergency_room/services/connectivity_service.dart';
import 'package:emergency_room/utils/app_constants.dart';

class DashboardChartsList extends StatefulWidget {
  const DashboardChartsList({super.key});

  @override
  State<DashboardChartsList> createState() => _DashboardChartsListState();
}

class _DashboardChartsListState extends State<DashboardChartsList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- Internet connection state ---
  bool _isOnline = true;
  bool _isOnlineChecked = false;

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
    _checkInternetConnection();
    _tabController = TabController(length: tabItems.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  Future<void> _checkInternetConnection() async {
    final online = await ConnectivityService.instance.hasConnection();
    if (!mounted) return;
    setState(() {
      _isOnline = online;
      _isOnlineChecked = true;
    });
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
    if (!_isOnline) {
      return _buildOfflineChartWidget(index);
    }

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

  Widget _buildOfflineChartWidget(int index) {
    final item = tabItems[index];
    final String title = item['title']!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'لا يوجد إتصال بالإنترنت',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 10),
          Text(
            'يرجى التحقق من الإتصال والمحاولة مرة أخرى',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              setState(() {
                _isOnline = false;
                _isOnlineChecked = true;
              });
              await _checkInternetConnection();
              if (_isOnline && mounted) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'تم الإتصال بالإنترنت بنجاح',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshAllCharts() async {
    final online = await ConnectivityService.instance.hasConnection();
    if (!mounted) return;

    setState(() {
      _isOnline = online;
      _isOnlineChecked = true;
    });

    if (online) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم تحديث البيانات بنجاح',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لا يوجد إتصال بالإنترنت. يرجى التحقق من الإتصال والمحاولة مرة أخرى.',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          StaticVariables.labName,
          style: const TextStyle(color: Colors.indigo),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "تحديث البيانات",
            icon: const Icon(
              Icons.refresh,
              color: Colors.indigo,
            ),
            onPressed: _refreshAllCharts,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Column(
            children: [
              OfflineBanner(visible: !_isOnline && _isOnlineChecked),
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
