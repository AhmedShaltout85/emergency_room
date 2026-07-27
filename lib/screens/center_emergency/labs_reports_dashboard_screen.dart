
import 'package:emergency_room/custom_widget/offline_banner.dart';
import 'package:emergency_room/labs/charts/bar_chart.dart';
import 'package:emergency_room/labs/charts/doughnut_chart.dart';
import 'package:emergency_room/labs/charts/line_chart.dart';
import 'package:emergency_room/labs/charts/pie_chart.dart';
import 'package:emergency_room/labs/charts/radial_chart.dart';
import 'package:emergency_room/labs/charts/rose_chart.dart';
import 'package:emergency_room/labs/widget/convert_lab_code_to_lab_name.dart';
import 'package:emergency_room/services/connection_dialog_service.dart';
import 'package:emergency_room/services/connectivity_service.dart';
import 'package:emergency_room/utils/app_constants.dart';
import 'package:emergency_room/utils/responsive_helper.dart';
import 'package:flutter/material.dart';

class LabsReportsDashboardScreen extends StatefulWidget {
  const LabsReportsDashboardScreen({super.key});

  @override
  State<LabsReportsDashboardScreen> createState() =>
      _LabsReportsDashboardScreenState();
}

class _LabsReportsDashboardScreenState extends State<LabsReportsDashboardScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  int? _selectedLabCode;

  static const List<Map<String, String>> _labs = [
    {'code': '7', 'name': 'معمل محطة السيوف'},
    {'code': '8', 'name': 'معمل محطة المعمورة'},
    {'code': '9', 'name': 'معمل محطة شرقي'},
    {'code': '10', 'name': 'معمل محطة المنشية 2'},
    {'code': '11', 'name': 'معمل محطة المنشية 1'},
    {'code': '13', 'name': 'معمل محطة مريوط 1'},
  ];

  final List<Map<String, String>> _tabItems = const [
    {'title': 'العكارة', 'testCode': '1'},
    {'title': 'المنسوب', 'testCode': '1045'},
    {'title': 'الأس الهيدروجيني', 'testCode': '3'},
    {'title': 'الكلور الحر', 'testCode': '82'},
    {'title': 'الأمونيا الحرة', 'testCode': '88'},
    {'title': 'جرعة المروب المعملية', 'testCode': '1050'},
    {'title': 'التوصيل الكهربي', 'testCode': '87'},
    {'title': 'الكلور المتبقى', 'testCode': '82'},
    {'title': 'جرعة الكلور النهائي المعملية', 'testCode': '1052'},
  ];

  final Color _selectedTabColor = Colors.indigo;
  final Color _unselectedTextColor = Colors.indigo;
  bool _isOnline = true;
  bool _isOnlineChecked = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabItems.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) setState(() {});
    });
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final online = await ConnectivityService.instance.hasConnection();
    if (!mounted) return;
    setState(() {
      _isOnline = online;
      _isOnlineChecked = true;
    });
    if (!online) {
      // Only interrupt with a blocking dialog if there's nothing useful
      // on screen yet (no lab selected, so no charts to look at). If a
      // lab is already selected and its charts are visible, the
      // OfflineBanner alone is enough.
      if (_selectedLabCode == null) {
        ConnectionDialogService.showNoInternetDialog(
          context,
          onRetry: _checkConnectivity,
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onLabChanged(int? code) {
    if (code == null) return;
    if (!_isOnline) {
      // This is a direct user action being blocked, so an explicit
      // notice is appropriate here regardless of what's on screen.
      ConnectionDialogService.showNoInternetDialog(context);
      return;
    }
    setState(() {
      _selectedLabCode = code;
      StaticVariables.labCode = code;
      StaticVariables.labName = convertLabCodeToLabName(code);
    });
  }

  Widget _buildChart(int index) {
    final code = _selectedLabCode ?? 0;
    final title = _tabItems[index]['title']!;
    final testCode = _tabItems[index]['testCode']!;

    switch (title) {
      case 'العكارة':
      case 'التوصيل الكهربي':
        return LabTestScreenBar(
          labCode: code,
          testCode: testCode,
          testName: title,
        );
      case 'المنسوب':
      case 'الكلور المتبقى':
        return LabTestScreenDoughnut(
          labCode: code,
          testCode: testCode,
          testName: title,
        );
      case 'الأس الهيدروجيني':
        return LabTestScreenLine(
          labCode: code,
          testCode: testCode,
          testName: title,
        );
      case 'الكلور الحر':
        return LabTestScreenPie(
          labCode: code,
          testCode: testCode,
          testName: title,
        );
      case 'الأمونيا الحرة':
        return LabTestScreenRadial(
          labCode: code,
          testCode: testCode,
          testName: title,
        );
      case 'جرعة المروب المعملية':
      case 'جرعة الكلور النهائي المعملية':
        return LabTestScreenRose(
          labCode: code,
          testCode: testCode,
          testName: title,
        );
      default:
        return Center(
          child: Text(
            'لا يوجد رسم بياني متوفر لـ $title',
            style: const TextStyle(fontSize: 18, color: Colors.indigo),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final selectedName = _selectedLabCode == null
        ? 'اختر المعمل لعرض التقارير'
        : convertLabCodeToLabName(_selectedLabCode!);

    return Container(
      color: Colors.indigo.shade50,
      child: Column(
        children: [
          OfflineBanner(visible: !_isOnline && _isOnlineChecked),
          _buildLabSelector(context, selectedName, isMobile),
          _buildTabBar(context, isMobile),
          Expanded(
            child: _selectedLabCode == null
                ? _buildEmptyState(context)
                : TabBarView(
                    controller: _tabController,
                    children: List.generate(_tabItems.length, _buildChart),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabSelector(
    BuildContext context,
    String selectedName,
    bool isMobile,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.horizontalPadding(context),
        vertical: 12,
      ),
      child: Card(
        elevation: 3,
        shadowColor: Colors.indigo.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.science, color: Colors.indigo, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'المعمل المختار',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.indigo.shade400,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                        fontFamily: 'Cairo',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: isMobile ? 180 : 220,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    border: Border.all(color: Colors.indigo.shade200, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _selectedLabCode,
                      hint: Text(
                        'اختر معمل',
                        style: TextStyle(
                          color: Colors.indigo.shade400,
                          fontFamily: 'Cairo',
                          fontSize: isMobile ? 12 : 13,
                        ),
                      ),
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.indigo),
                      style: const TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Cairo',
                        fontSize: 13,
                      ),
                      items: _labs.map((lab) {
                        return DropdownMenuItem<int>(
                          value: int.parse(lab['code']!),
                          child: Text(
                            lab['name']!,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: _onLabChanged,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, bool isMobile) {
    return Container(
      color: Colors.indigo.shade100,
      child: TabBar(
        controller: _tabController,
        isScrollable: isMobile,
        indicatorColor: Colors.indigo,
        indicatorWeight: 3,
        labelColor: _selectedTabColor,
        unselectedLabelColor: _unselectedTextColor,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
          fontSize: ResponsiveHelper.tabBarFontSize(context),
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontFamily: 'Cairo',
          fontSize: ResponsiveHelper.tabBarFontSize(context),
        ),
        tabs: _tabItems.map((item) => Tab(text: item['title']!)).toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.science_outlined,
              size: 80,
              color: Colors.indigo.shade300,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لم يتم اختيار معمل',
            style: TextStyle(
              fontSize: ResponsiveHelper.titleFontSize(context) + 2,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'فضلا اختر المعمل من القائمة بالأعلى لعرض التقارير والرسوم البيانية',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.indigo.shade400,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
