
// complaints_report_dashboard.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../network/remote/remote_network_repos.dart';
import '../services/connectivity_service.dart';

class ComplaintsReportDashboard extends StatefulWidget {
  const ComplaintsReportDashboard({super.key});

  @override
  State<ComplaintsReportDashboard> createState() =>
      _ComplaintsReportDashboardState();
}

class _ComplaintsReportDashboardState extends State<ComplaintsReportDashboard>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _complaints = [];
  List<Map<String, dynamic>> _filteredComplaints = [];
  bool _isLoading = true;
  bool _isOnline = true;
  bool _isFilterExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Filter controllers
  final TextEditingController _searchController = TextEditingController();
  String? _selectedNeighborhood;
  String? _selectedRepairStatus;
  String? _selectedComplaintStatus;
  String? _selectedSeriousStatus;
  String? _selectedPumpDiameter;
  String? _selectedRecipientDestination;
  String? _selectedComplaintSource;
  String? _selectedSectorName;
  String? _selectedComplaintType;
  String? _selectedCurrentUsername;
  DateTime? _fromDate;
  DateTime? _toDate;

  // Chart type selection - use the value, not the label
  String _selectedChartType = 'Status Distribution';

  final List<Map<String, dynamic>> _chartTypes = [
    {
      'label': 'توزيع الحالة',
      'value': 'Status Distribution',
      'icon': Icons.pie_chart
    },
    {'label': 'حالة الإصلاح', 'value': 'Repair Status', 'icon': Icons.build},
    {
      'label': 'مدى الخطورة',
      'value': 'Serious Status',
      'icon': Icons.warning_amber
    },
    {
      'label': 'توزيع الأحياء',
      'value': 'Neighborhood Distribution',
      'icon': Icons.location_city
    },
    {
      'label': 'أقطار المواسير',
      'value': 'Pump Diameter Distribution',
      'icon': Icons.settings
    },
    {
      'label': 'اتجاهات شهرية',
      'value': 'Monthly Trends',
      'icon': Icons.trending_up
    },
    {'label': 'مصدر البلاغ', 'value': 'Complaint Source', 'icon': Icons.source},
    {
      'label': 'جهة الاستلام',
      'value': 'Recipient Destination',
      'icon': Icons.business
    },
    // NEW: Current User Distribution
    {
      'label': 'توزيع المستخدمين',
      'value': 'Current User Distribution',
      'icon': Icons.people
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    final today = DateTime.now();
    _fromDate = DateTime(today.year, today.month, 1);
    _toDate = today;
    _fetchComplaints();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchComplaints() async {
    setState(() => _isLoading = true);

    final online = await ConnectivityService.instance.hasConnection();
    if (!mounted) return;

    if (!online) {
      setState(() {
        _isOnline = false;
        _isLoading = false;
      });
      return;
    }

    try {
      final data = await DioNetworkRepos().getAllComplaints();
      if (!mounted) return;

      setState(() {
        _complaints = data;
        _filteredComplaints = List.from(data);
        _isLoading = false;
        _isOnline = true;
      });

      _animationController.forward();
      log("Loaded ${_complaints.length} complaints");
    } catch (e) {
      log("Error fetching complaints: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      final query = _searchController.text.trim().toLowerCase();

      _filteredComplaints = _complaints.where((item) {
        // Search filter
        if (query.isNotEmpty) {
          final address =
              (item['complaintAddress'] ?? '').toString().toLowerCase();
          final reporter =
              (item['reporterName'] ?? '').toString().toLowerCase();
          final phone = (item['reporterPhone'] ?? '').toString().toLowerCase();
          final note = (item['complaintNote'] ?? '').toString().toLowerCase();
          final complaintType =
              (item['complaintType'] ?? '').toString().toLowerCase();
          final sectorName =
              (item['sectorName'] ?? '').toString().toLowerCase();
          final currentUsername =
              (item['currentUsername'] ?? '').toString().toLowerCase();
          final matchesSearch = address.contains(query) ||
              reporter.contains(query) ||
              phone.contains(query) ||
              note.contains(query) ||
              complaintType.contains(query) ||
              sectorName.contains(query) ||
              currentUsername.contains(query);
          if (!matchesSearch) return false;
        }

        if (_selectedNeighborhood != null &&
            item['neighborhood'] != _selectedNeighborhood) return false;

        if (_selectedRepairStatus != null &&
            item['complaintRepairStatus'] != _selectedRepairStatus)
          return false;

        if (_selectedComplaintStatus != null &&
            item['complaintStatus'] != _selectedComplaintStatus) return false;

        if (_selectedSeriousStatus != null &&
            item['seriousStatus'] != _selectedSeriousStatus) return false;

        if (_selectedPumpDiameter != null &&
            item['pumpDiameter'] != _selectedPumpDiameter) return false;

        if (_selectedRecipientDestination != null &&
            item['recipientDestination'] != _selectedRecipientDestination)
          return false;

        if (_selectedComplaintSource != null &&
            item['complaintSource'] != _selectedComplaintSource) return false;

        if (_selectedSectorName != null &&
            (item['sectorName']?.toString() ?? '') != _selectedSectorName)
          return false;

        if (_selectedComplaintType != null &&
            (item['complaintType']?.toString() ?? '') != _selectedComplaintType)
          return false;

        if (_selectedCurrentUsername != null &&
            (item['currentUsername']?.toString() ?? '') !=
                _selectedCurrentUsername) return false;

        if (_fromDate != null || _toDate != null) {
          final createdAt =
              DateTime.tryParse((item['createdAt'] ?? '').toString());
          if (createdAt == null) return false;
          final dateOnly =
              DateTime(createdAt.year, createdAt.month, createdAt.day);

          if (_fromDate != null && dateOnly.isBefore(_fromDate!)) return false;
          if (_toDate != null && dateOnly.isAfter(_toDate!)) return false;
        }

        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedNeighborhood = null;
      _selectedRepairStatus = null;
      _selectedComplaintStatus = null;
      _selectedSeriousStatus = null;
      _selectedPumpDiameter = null;
      _selectedRecipientDestination = null;
      _selectedComplaintSource = null;
      _selectedSectorName = null;
      _selectedComplaintType = null;
      _selectedCurrentUsername = null;
      final today = DateTime.now();
      _fromDate = DateTime(today.year, today.month, 1);
      _toDate = today;
      _applyFilters();
    });
  }

  List<String> _getDistinctValues(String key) {
    final values = _complaints
        .map((e) => e[key])
        .whereType<String>()
        .where((v) => v.isNotEmpty && v != 'free')
        .toSet()
        .toList();
    values.sort();
    return values;
  }

  // ==================== Chart Data Builders ====================

  List<ChartData> _buildStatusDistributionData() {
    final Map<String, int> statusCount = {};
    for (var item in _filteredComplaints) {
      final status = item['complaintStatus'] ?? 'غير محدد';
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple
    ];
    var index = 0;
    return statusCount.entries.map((e) {
      final color = colors[index % colors.length];
      index++;
      return ChartData(e.key, e.value.toDouble(), color);
    }).toList();
  }

  List<ChartData> _buildRepairStatusData() {
    final Map<String, int> statusCount = {};
    for (var item in _filteredComplaints) {
      final status = item['complaintRepairStatus'] ?? 'غير محدد';
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }
    final colors = [Colors.green, Colors.orange, Colors.red, Colors.blue];
    var index = 0;
    return statusCount.entries.map((e) {
      final color = colors[index % colors.length];
      index++;
      return ChartData(e.key, e.value.toDouble(), color);
    }).toList();
  }

  List<ChartData> _buildSeriousStatusData() {
    final Map<String, int> statusCount = {};
    for (var item in _filteredComplaints) {
      final status = item['seriousStatus'] ?? 'غير محدد';
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }
    final colors = [Colors.red, Colors.orange, Colors.green];
    var index = 0;
    return statusCount.entries.map((e) {
      final color = colors[index % colors.length];
      index++;
      return ChartData(e.key, e.value.toDouble(), color);
    }).toList();
  }

  List<ChartData> _buildNeighborhoodData() {
    final Map<String, int> neighborhoodCount = {};
    for (var item in _filteredComplaints) {
      final neighborhood = item['neighborhood'] ?? 'غير محدد';
      neighborhoodCount[neighborhood] =
          (neighborhoodCount[neighborhood] ?? 0) + 1;
    }
    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.teal,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.pink,
      Colors.indigo
    ];
    var index = 0;
    return neighborhoodCount.entries.map((e) {
      final color = colors[index % colors.length];
      index++;
      return ChartData(e.key, e.value.toDouble(), color);
    }).toList();
  }

  List<ChartData> _buildPumpDiameterData() {
    final Map<String, int> diameterCount = {};
    for (var item in _filteredComplaints) {
      final diameter = item['pumpDiameter'] ?? 'غير محدد';
      diameterCount[diameter] = (diameterCount[diameter] ?? 0) + 1;
    }
    final colors = [
      Colors.orange,
      Colors.deepOrange,
      Colors.amber,
      Colors.yellow
    ];
    var index = 0;
    return diameterCount.entries.map((e) {
      final color = colors[index % colors.length];
      index++;
      return ChartData(e.key, e.value.toDouble(), color);
    }).toList();
  }

  List<ChartData> _buildMonthlyTrendData() {
    final Map<String, int> monthlyCount = {};
    for (var item in _filteredComplaints) {
      final createdAt = DateTime.tryParse((item['createdAt'] ?? '').toString());
      if (createdAt != null) {
        final months = [
          'يناير',
          'فبراير',
          'مارس',
          'أبريل',
          'مايو',
          'يونيو',
          'يوليو',
          'أغسطس',
          'سبتمبر',
          'أكتوبر',
          'نوفمبر',
          'ديسمبر'
        ];
        final key = months[createdAt.month - 1];
        monthlyCount[key] = (monthlyCount[key] ?? 0) + 1;
      }
    }
    final monthOrder = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    final sortedEntries = monthOrder
        .where((m) => monthlyCount.containsKey(m))
        .map((m) => MapEntry(m, monthlyCount[m]!));
    return sortedEntries
        .map((e) => ChartData(e.key, e.value.toDouble(), Colors.teal))
        .toList();
  }

  List<ChartData> _buildComplaintSourceData() {
    final Map<String, int> sourceCount = {};
    for (var item in _filteredComplaints) {
      final source = item['complaintSource'] ?? 'غير محدد';
      sourceCount[source] = (sourceCount[source] ?? 0) + 1;
    }
    final colors = [Colors.cyan, Colors.lightBlue, Colors.blue, Colors.indigo];
    var index = 0;
    return sourceCount.entries.map((e) {
      final color = colors[index % colors.length];
      index++;
      return ChartData(e.key, e.value.toDouble(), color);
    }).toList();
  }

  List<ChartData> _buildRecipientDestinationData() {
    final Map<String, int> destCount = {};
    for (var item in _filteredComplaints) {
      final dest = item['recipientDestination'] ?? 'غير محدد';
      destCount[dest] = (destCount[dest] ?? 0) + 1;
    }
    final colors = [Colors.indigo, Colors.blue, Colors.teal, Colors.green];
    var index = 0;
    return destCount.entries.map((e) {
      final color = colors[index % colors.length];
      index++;
      return ChartData(e.key, e.value.toDouble(), color);
    }).toList();
  }

  // NEW: Build Current User Distribution Data
  List<ChartData> _buildCurrentUserDistributionData() {
    final Map<String, int> userCount = {};
    for (var item in _filteredComplaints) {
      final user = item['currentUsername']?.toString() ?? 'غير محدد';
      userCount[user] = (userCount[user] ?? 0) + 1;
    }
    final colors = [
      Colors.cyan,
      Colors.teal,
      Colors.lightBlue,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
      Colors.deepPurple
    ];
    var index = 0;
    return userCount.entries.map((e) {
      final color = colors[index % colors.length];
      index++;
      return ChartData(e.key, e.value.toDouble(), color);
    }).toList();
  }

  List<ChartData> _getChartData() {
    switch (_selectedChartType) {
      case 'Status Distribution':
        return _buildStatusDistributionData();
      case 'Repair Status':
        return _buildRepairStatusData();
      case 'Serious Status':
        return _buildSeriousStatusData();
      case 'Neighborhood Distribution':
        return _buildNeighborhoodData();
      case 'Pump Diameter Distribution':
        return _buildPumpDiameterData();
      case 'Monthly Trends':
        return _buildMonthlyTrendData();
      case 'Complaint Source':
        return _buildComplaintSourceData();
      case 'Recipient Destination':
        return _buildRecipientDestinationData();
      // NEW: Current User Distribution
      case 'Current User Distribution':
        return _buildCurrentUserDistributionData();
      default:
        return [];
    }
  }

  Color _getChartColor() {
    switch (_selectedChartType) {
      case 'Status Distribution':
        return Colors.blue;
      case 'Repair Status':
        return Colors.green;
      case 'Serious Status':
        return Colors.red;
      case 'Neighborhood Distribution':
        return Colors.purple;
      case 'Pump Diameter Distribution':
        return Colors.orange;
      case 'Monthly Trends':
        return Colors.teal;
      case 'Complaint Source':
        return Colors.cyan;
      case 'Recipient Destination':
        return Colors.indigo;
      // NEW: Current User Distribution
      case 'Current User Distribution':
        return Colors.cyan;
      default:
        return Colors.blue;
    }
  }

  IconData _getChartIcon() {
    switch (_selectedChartType) {
      case 'Status Distribution':
        return Icons.pie_chart;
      case 'Repair Status':
        return Icons.build;
      case 'Serious Status':
        return Icons.warning_amber;
      case 'Neighborhood Distribution':
        return Icons.location_city;
      case 'Pump Diameter Distribution':
        return Icons.settings;
      case 'Monthly Trends':
        return Icons.trending_up;
      case 'Complaint Source':
        return Icons.source;
      case 'Recipient Destination':
        return Icons.business;
      // NEW: Current User Distribution
      case 'Current User Distribution':
        return Icons.people;
      default:
        return Icons.bar_chart;
    }
  }

  // ==================== Widget Builders ====================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text(
            'لوحة تحكم التقارير',
            style: TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              fontFamily: 'Cairo',
            ),
          ),
          centerTitle: true,
          elevation: 2,
          backgroundColor: Colors.white,
          foregroundColor: Colors.indigo,
          actions: [
            IconButton(
              tooltip: 'تحديث البيانات',
              icon: const Icon(Icons.refresh, color: Colors.indigo),
              onPressed: _fetchComplaints,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'جاري تحميل البيانات...',
                      style: TextStyle(
                        color: Colors.indigo,
                        fontSize: 16,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: _buildDashboard(),
              ),
      ),
    );
  }

  Widget _buildDashboard() {
    if (_complaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'لا توجد بيانات تقارير',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'قم بتحديث البيانات أو تحقق من الاتصال',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Improved Summary Cards
          _buildImprovedSummaryCards(),
          const SizedBox(height: 16),

          // Filters
          _buildFilterBar(),
          const SizedBox(height: 16),

          // Chart Selection and Display
          _buildChartSection(),
          const SizedBox(height: 16),

          // Improved Data Table
          _buildImprovedDataTable(),
        ],
      ),
    );
  }

  // ==================== IMPROVED SUMMARY CARDS ====================

  Widget _buildImprovedSummaryCards() {
    final total = _filteredComplaints.length;
    final open = _filteredComplaints
        .where((e) =>
            e['complaintStatus'] == 'مفتوح' ||
            e['complaintStatus'] == 'عالى الأهمية' ||
            e['complaintStatus'] == 'متوسط الأهمية')
        .length;
    final processing = _filteredComplaints
        .where((e) =>
            e['complaintRepairStatus'] == 'جارى الاصلاح' ||
            e['complaintRepairStatus'] == 'قيد المعالجة')
        .length;
    final deleted = _filteredComplaints
        .where((e) => e['isDeleted'] == 1 || e['isDeleted'] == true)
        .length;
    final finished = _filteredComplaints
        .where((e) => e['isFinished'] == 1 || e['isFinished'] == true)
        .length;
    final tracked = _filteredComplaints
        .where((e) => e['isTracked'] == 1 || e['isTracked'] == true)
        .length;

    final cards = [
      {
        'title': 'إجمالي البلاغات',
        'value': total,
        'icon': Icons.assignment,
        'color': Colors.blue,
        'subtitle': 'جميع البلاغات',
      },
      {
        'title': 'مفتوحة / قيد المتابعة',
        'value': open,
        'icon': Icons.pending_actions,
        'color': Colors.orange,
        'subtitle': 'بلاغات نشطة',
      },
      {
        'title': 'قيد المعالجة',
        'value': processing,
        'icon': Icons.build_circle,
        'color': Colors.purple,
        'subtitle': 'جاري الإصلاح',
      },
      {
        'title': 'مغلقة / منتهية',
        'value': finished,
        'icon': Icons.check_circle,
        'color': Colors.green,
        'subtitle': 'تم الانتهاء',
      },
      {
        'title': 'محذوفة',
        'value': deleted,
        'icon': Icons.delete_forever,
        'color': Colors.red,
        'subtitle': 'تم الحذف',
      },
      {
        'title': 'متابعة',
        'value': tracked,
        'icon': Icons.track_changes,
        'color': Colors.teal,
        'subtitle': 'قيد التتبع',
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 6,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.8,
      children: cards.map((card) {
        return _buildSummaryCard(
          card['title'] as String,
          card['value'].toString(),
          card['icon'] as IconData,
          card['color'] as Color,
          card['subtitle'] as String,
        );
      }).toList(),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, color.withOpacity(0.08)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontFamily: 'Cairo',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final neighborhoods = _getDistinctValues('neighborhood');
    final repairStatuses = _getDistinctValues('complaintRepairStatus');
    final complaintStatuses = _getDistinctValues('complaintStatus');
    final seriousStatuses = _getDistinctValues('seriousStatus');
    final pumpDiameters = _getDistinctValues('pumpDiameter');
    final recipientDestinations = _getDistinctValues('recipientDestination');
    final complaintSources = _getDistinctValues('complaintSource');
    final sectorNames = _getDistinctValues('sectorName');
    final complaintTypes = _getDistinctValues('complaintType');
    final currentUsernames = _getDistinctValues('currentUsername');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          initiallyExpanded: true,
          onExpansionChanged: (value) {
            setState(() => _isFilterExpanded = value);
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.filter_alt,
                    color: Colors.indigo, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'فلاتر البحث المتقدم',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                  fontSize: 16,
                  fontFamily: 'Cairo',
                ),
              ),
              if (_filteredComplaints.length != _complaints.length)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_filteredComplaints.length} / ${_complaints.length}',
                    style: TextStyle(
                      color: Colors.indigo.shade700,
                      fontSize: 12,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isFilterExpanded)
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text(
                    'مسح الكل',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.indigo,
                    backgroundColor: Colors.indigo.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                _isFilterExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.indigo,
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: 280,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: TextField(
                            controller: _searchController,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 14, fontFamily: 'Cairo'),
                            decoration: const InputDecoration(
                              labelText: 'بحث في جميع الحقول',
                              labelStyle: TextStyle(
                                fontSize: 13,
                                color: Colors.indigo,
                                fontFamily: 'Cairo',
                              ),
                              prefixIcon: Icon(Icons.search,
                                  size: 22, color: Colors.indigo),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                            ),
                            onChanged: (_) => _applyFilters(),
                          ),
                        ),
                      ),
                      _buildDropdownFilter(
                        label: 'الحي',
                        value: _selectedNeighborhood,
                        options: neighborhoods,
                        onChanged: (v) => setState(() {
                          _selectedNeighborhood = v;
                          _applyFilters();
                        }),
                      ),
                      _buildDropdownFilter(
                        label: 'حالة الإصلاح',
                        value: _selectedRepairStatus,
                        options: repairStatuses,
                        onChanged: (v) => setState(() {
                          _selectedRepairStatus = v;
                          _applyFilters();
                        }),
                      ),
                      _buildDropdownFilter(
                        label: 'حالة المتابعة',
                        value: _selectedComplaintStatus,
                        options: complaintStatuses,
                        onChanged: (v) => setState(() {
                          _selectedComplaintStatus = v;
                          _applyFilters();
                        }),
                      ),
                      _buildDropdownFilter(
                        label: 'مدى الخطورة',
                        value: _selectedSeriousStatus,
                        options: seriousStatuses,
                        onChanged: (v) => setState(() {
                          _selectedSeriousStatus = v;
                          _applyFilters();
                        }),
                      ),
                      _buildDropdownFilter(
                        label: 'نوع الكسر',
                        value: _selectedPumpDiameter,
                        options: pumpDiameters,
                        onChanged: (v) => setState(() {
                          _selectedPumpDiameter = v;
                          _applyFilters();
                        }),
                        width: 150,
                      ),
                      _buildDropdownFilter(
                        label: 'جهة الاستلام',
                        value: _selectedRecipientDestination,
                        options: recipientDestinations,
                        onChanged: (v) => setState(() {
                          _selectedRecipientDestination = v;
                          _applyFilters();
                        }),
                      ),
                      _buildDropdownFilter(
                        label: 'مصدر البلاغ',
                        value: _selectedComplaintSource,
                        options: complaintSources,
                        onChanged: (v) => setState(() {
                          _selectedComplaintSource = v;
                          _applyFilters();
                        }),
                      ),
                      _buildDropdownFilter(
                        label: 'القطاع',
                        value: _selectedSectorName,
                        options: sectorNames,
                        onChanged: (v) => setState(() {
                          _selectedSectorName = v;
                          _applyFilters();
                        }),
                      ),
                      _buildDropdownFilter(
                        label: 'نوع البلاغ',
                        value: _selectedComplaintType,
                        options: complaintTypes,
                        onChanged: (v) => setState(() {
                          _selectedComplaintType = v;
                          _applyFilters();
                        }),
                      ),
                      _buildDropdownFilter(
                        label: 'المستخدم الحالي',
                        value: _selectedCurrentUsername,
                        options: currentUsernames,
                        onChanged: (v) => setState(() {
                          _selectedCurrentUsername = v;
                          _applyFilters();
                        }),
                      ),
                      _buildDateFilter(
                        label: 'من تاريخ',
                        value: _fromDate,
                        isFrom: true,
                      ),
                      _buildDateFilter(
                        label: 'إلى تاريخ',
                        value: _toDate,
                        isFrom: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    double width = 180,
  }) {
    if (options.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          alignment: AlignmentDirectional.centerEnd,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontFamily: 'Cairo',
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              fontSize: 13,
              color: Colors.indigo,
              fontFamily: 'Cairo',
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          hint: const Text(
            'الكل',
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 13, fontFamily: 'Cairo', color: Colors.grey),
          ),
          items: [
            const DropdownMenuItem(
              value: null,
              alignment: AlignmentDirectional.centerEnd,
              child: Text('الكل',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 13)),
            ),
            ...options.map(
              (v) => DropdownMenuItem(
                value: v,
                alignment: AlignmentDirectional.centerEnd,
                child: Text(v,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDateFilter({
    required String label,
    required DateTime? value,
    required bool isFrom,
  }) {
    return SizedBox(
      width: 200,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            setState(() {
              if (isFrom) {
                _fromDate = DateTime(picked.year, picked.month, picked.day);
              } else {
                _toDate = DateTime(picked.year, picked.month, picked.day);
              }
              _applyFilters();
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.calendar_month,
                    size: 20, color: Colors.indigo),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.indigo,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        value == null ? '—' : _formatDateArabic(value),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateArabic(DateTime d) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Widget _buildChartSection() {
    final chartData = _getChartData();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getChartColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(_getChartIcon(), color: _getChartColor(), size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'الرسوم البيانية',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                    fontSize: 18,
                    fontFamily: 'Cairo',
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedChartType,
                      style: const TextStyle(
                        color: Colors.indigo,
                        fontFamily: 'Cairo',
                        fontSize: 14,
                      ),
                      items: _chartTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type['value'] as String,
                          child: Row(
                            children: [
                              Icon(type['icon'] as IconData,
                                  size: 20, color: Colors.indigo.shade400),
                              const SizedBox(width: 8),
                              Text(type['label'] as String,
                                  style: const TextStyle(fontFamily: 'Cairo')),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedChartType = value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (chartData.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.bar_chart, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'لا توجد بيانات للرسم البياني',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.grey,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 320,
                child: _selectedChartType == 'Monthly Trends'
                    ? _buildLineChart(chartData)
                    : _buildBarChart(chartData),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List<ChartData> data) {
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(
        labelRotation: -45,
        labelStyle: TextStyle(
            fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w500),
        majorGridLines: MajorGridLines(width: 0),
        axisLine: AxisLine(width: 0),
      ),
      primaryYAxis: const NumericAxis(
        labelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 11),
        majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey),
        axisLine: AxisLine(width: 0),
      ),
      series: <CartesianSeries>[
        ColumnSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.label,
          yValueMapper: (ChartData data, _) => data.value,
          pointColorMapper: (ChartData data, _) => data.color,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.outer,
            textStyle: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          animationDuration: 500,
        ),
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        header: '',
        canShowMarker: true,
        textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
      ),
    );
  }

  Widget _buildLineChart(List<ChartData> data) {
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(
        labelRotation: -45,
        labelStyle: TextStyle(
            fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w500),
        majorGridLines: MajorGridLines(width: 0),
        axisLine: AxisLine(width: 0),
      ),
      primaryYAxis: const NumericAxis(
        labelStyle: TextStyle(fontFamily: 'Cairo', fontSize: 11),
        majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey),
        axisLine: AxisLine(width: 0),
      ),
      series: <CartesianSeries>[
        LineSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.label,
          yValueMapper: (ChartData data, _) => data.value,
          color: Colors.teal,
          markerSettings: const MarkerSettings(
            isVisible: true,
            shape: DataMarkerType.circle,
            borderColor: Colors.teal,
            borderWidth: 2,
          ),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.outer,
            textStyle: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          animationDuration: 500,
        ),
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        header: '',
        canShowMarker: true,
        textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
      ),
    );
  }

  // ==================== IMPROVED DATA TABLE ====================

  Widget _buildImprovedDataTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.table_chart,
                      color: Colors.indigo, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'قائمة البلاغات',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                    fontSize: 18,
                    fontFamily: 'Cairo',
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.indigo.shade50,
                        Colors.indigo.shade100.withOpacity(0.3)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.list_alt,
                          size: 18, color: Colors.indigo.shade700),
                      const SizedBox(width: 8),
                      Text(
                        '${_filteredComplaints.length} بلاغ',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.indigo.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Table with improved styling
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 14,
                    headingRowColor:
                        WidgetStateProperty.all(Colors.indigo.shade50),
                    headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: Colors.indigo,
                    ),
                    dataTextStyle: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                    ),
                    columns: const [
                      DataColumn(
                          label: Text('#',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13))),
                      DataColumn(
                          label: Text('التاريخ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13))),
                      DataColumn(
                          label: Text('رقم البلاغ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13))),
                      DataColumn(
                          label: Text('نوع الكسر',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13))),
                      DataColumn(
                          label: Text('الحي',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13))),
                      DataColumn(
                          label: Text('المبلغ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13))),
                      DataColumn(
                          label: Text('المصدر',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13))),
                      DataColumn(
                          label: Text('الحالة',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13))),
                      DataColumn(
                          label: Text('الخطورة',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13))),
                      DataColumn(
                          label: Text('جهة الاستلام',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13))),
                      DataColumn(
                          label: Text('القطاع',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13))),
                      DataColumn(
                          label: Text('نوع البلاغ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13))),
                      DataColumn(
                          label: Text('المستخدم',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13))),
                    ],
                    rows: _filteredComplaints.take(50).map((item) {
                      final index = _filteredComplaints.indexOf(item) + 1;
                      final isEven = index % 2 == 0;
                      return DataRow(
                        color: WidgetStateProperty.resolveWith<Color?>(
                          (Set<WidgetState> states) {
                            return isEven ? Colors.grey.shade50 : Colors.white;
                          },
                        ),
                        cells: [
                          // #
                          DataCell(
                            Container(
                              width: 30,
                              alignment: Alignment.center,
                              child: Text(
                                index.toString(),
                                style: TextStyle(
                                  color: Colors.indigo.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // التاريخ
                          DataCell(
                            Text(
                              _formatDateOnly(item['createdAt']),
                              style: const TextStyle(
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          // الرقم
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item['complaintId']?.toString() ?? '-',
                                style: TextStyle(
                                  color: Colors.indigo.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                          // نوع الكسر
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border:
                                    Border.all(color: Colors.orange.shade200),
                              ),
                              child: Text(
                                item['pumpDiameter']?.toString() ?? '-',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                          // الحي
                          DataCell(
                            Text(
                              item['neighborhood']?.toString() ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // المبلغ
                          DataCell(
                            Text(
                              item['reporterName']?.toString() ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // المصدر
                          DataCell(
                            Text(
                              item['complaintSource']?.toString() ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // الحالة - with color coding
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _getStatusColor(item['complaintStatus'])
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color:
                                      _getStatusColor(item['complaintStatus']),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                item['complaintStatus']?.toString() ?? '-',
                                style: TextStyle(
                                  color:
                                      _getStatusColor(item['complaintStatus']),
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // الخطورة - with color coding
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _getSeriousColor(item['seriousStatus'])
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color:
                                      _getSeriousColor(item['seriousStatus']),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                item['seriousStatus']?.toString() ?? '-',
                                style: TextStyle(
                                  color:
                                      _getSeriousColor(item['seriousStatus']),
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // جهة الاستلام
                          DataCell(
                            Text(
                              item['recipientDestination']?.toString() ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // القطاع
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border:
                                    Border.all(color: Colors.green.shade200),
                              ),
                              child: Text(
                                item['sectorName']?.toString() ?? '-',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                          // نوع البلاغ
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border:
                                    Border.all(color: Colors.purple.shade200),
                              ),
                              child: Text(
                                item['complaintType']?.toString() ?? '-',
                                style: TextStyle(
                                  color: Colors.purple.shade700,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                          // currentUsername
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.cyan.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.cyan.shade200),
                              ),
                              child: Text(
                                item['currentUsername']?.toString() ?? '-',
                                style: TextStyle(
                                  color: Colors.cyan.shade700,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            if (_filteredComplaints.length > 50)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'عرض أول 50 بلاغ من ${_filteredComplaints.length}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateOnly(dynamic raw) {
    if (raw == null) return '';
    final parsed = DateTime.tryParse(raw.toString());
    if (parsed == null) return raw.toString();
    return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'مفتوح':
        return Colors.orange;
      case 'مغلق':
        return Colors.green;
      case 'عالى الأهمية':
      case 'عالية الأهمية':
        return Colors.red;
      case 'متوسط الأهمية':
        return Colors.orange;
      case 'عادى':
      case 'عادي':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getSeriousColor(String? status) {
    switch (status) {
      case 'عالي':
      case 'عالى':
        return Colors.red;
      case 'متوسط':
        return Colors.orange;
      case 'منخفض':
        return Colors.green;
      case 'مستقر':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

// Chart Data Model
class ChartData {
  final String label;
  final double value;
  final Color color;

  ChartData(this.label, this.value, this.color);
}
