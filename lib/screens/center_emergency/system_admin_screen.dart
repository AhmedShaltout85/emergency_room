import 'package:emergency_room/screens/center_emergency/complaints_reports_screen.dart';
import 'package:emergency_room/screens/center_emergency/labs_reports_dashboard_screen.dart';
import 'package:emergency_room/screens/center_emergency/map_screen.dart';
import 'package:emergency_room/screens/center_emergency/scada_dashboard_screen.dart';
import 'package:emergency_room/utils/responsive_helper.dart';
import 'package:flutter/material.dart';

class SystemAdminScreen extends StatefulWidget {
  const SystemAdminScreen({super.key});

  @override
  State<SystemAdminScreen> createState() => _SystemAdminScreenState();
}

class _SystemAdminScreenState extends State<SystemAdminScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  final List<_TabItem> _tabs = const [
    _TabItem(
      label: 'الخريطة',
      icon: Icons.map_outlined,
      activeIcon: Icons.map,
    ),
    _TabItem(
      label: 'لوحة SCADA',
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
    ),
    _TabItem(
      label: 'تقارير المعامل',
      icon: Icons.science_outlined,
      activeIcon: Icons.science,
    ),
    _TabItem(
      label: 'تقارير الشكاوى',
      icon: Icons.report_outlined,
      activeIcon: Icons.report,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.indigo.shade50,
        appBar: _buildAppBar(context),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return TabBarView(
              controller: _tabController,
              children: const [
                _KeepAliveWrapper(
                  child: MapScreen(
                    latitude: '31.205753',
                    longitude: '29.924526',
                    // address: 'الإسكندرية - مركز التحكم',
                    // technicianName: 'الفني',
                  ),
                ),
                _KeepAliveWrapper(child: ScadaDashboardScreen()),
                _KeepAliveWrapper(child: LabsReportsDashboardScreen()),
                _KeepAliveWrapper(child: ComplaintsReportsScreen()),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.indigo,
      elevation: 4,
      centerTitle: true,
      title: Text(
        'الطوارئ المركزية',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
          fontSize: ResponsiveHelper.titleFontSize(context),
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(ResponsiveHelper.tabBarHeight(context)),
        child: _buildTabBar(context),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final isCompact = ResponsiveHelper.isMobile(context);

    return Container(
      color: Colors.indigo.shade700,
      child: TabBar(
        controller: _tabController,
        isScrollable: isCompact,
        labelPadding: EdgeInsets.symmetric(
          horizontal: isCompact ? 4 : 8,
        ),
        indicator: const BoxDecoration(color: Colors.transparent),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        tabs: List.generate(_tabs.length, (index) {
          final tab = _tabs[index];
          final isSelected = _tabController.index == index;

          return Tab(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 10 : 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.35),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? tab.activeIcon : tab.icon,
                    color: isSelected ? Colors.indigo : Colors.white,
                    size: ResponsiveHelper.tabBarIconSize(context),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    tab.label,
                    style: TextStyle(
                      color: isSelected ? Colors.indigo : Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontFamily: 'Cairo',
                      fontSize: ResponsiveHelper.tabBarFontSize(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _TabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const _KeepAliveWrapper({required this.child});

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
