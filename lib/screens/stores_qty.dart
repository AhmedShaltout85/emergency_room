import 'dart:developer';

import 'package:flutter/material.dart';

import '../custom_widget/no_internet_widget.dart';
import '../custom_widget/offline_banner.dart';
import '../network/remote/remote_network_repos.dart';
import '../services/connection_dialog_service.dart';
import '../services/connectivity_service.dart';

// ============================================================================
// Static store model + list (from your DB table)
// ============================================================================
class StoreEntry {
  final String handsashName;
  final String storeName;
  final int storeNumber;

  const StoreEntry({
    required this.handsashName,
    required this.storeName,
    required this.storeNumber,
  });
}

const List<StoreEntry> kStores = [
  StoreEntry(
      handsashName: 'هندسة فرع ابو قير',
      storeName: 'مخزن فرع ابو قير',
      storeNumber: 3),
  StoreEntry(
      handsashName: 'هندسة فرع المنتزه',
      storeName: 'مخزن فرع المنتزه',
      storeNumber: 1300),
  StoreEntry(
      handsashName: 'هندسة فرع سيدى بشر',
      storeName: 'مخزن فرع سيدى بشر',
      storeNumber: 500),
  StoreEntry(
      handsashName: 'هندسة فرع الرمل',
      storeName: 'مخزن فرع الرمل',
      storeNumber: 600),
  StoreEntry(
      handsashName: 'هندسة فرع الابراهيمية',
      storeName: 'مخزن فرع الابراهيمية',
      storeNumber: 700),
  StoreEntry(
      handsashName: 'هندسة فرع النزهه',
      storeName: 'مخزن هندسة فرع النزهه',
      storeNumber: 1018),
  StoreEntry(
      handsashName: 'هندسة فرع البلد',
      storeName: 'مخزن فرع البلد',
      storeNumber: 800),
  StoreEntry(
      handsashName: 'هندسة فرع العمارى',
      storeName: 'مخزن فرع العمارى',
      storeNumber: 900),
  StoreEntry(
      handsashName: 'هندسة فرع العجمى',
      storeName: 'مخزن فرع العجمى',
      storeNumber: 1500),
  StoreEntry(
      handsashName: 'هندسة النوبارية',
      storeName: 'السيارات النوبارية',
      storeNumber: 1003),
  StoreEntry(
      handsashName: 'هندسة العامرية',
      storeName: 'فرع العامرية',
      storeNumber: 1900),
  StoreEntry(
      handsashName: 'هندسة بحرى السكر',
      storeName: 'بحرى السكر',
      storeNumber: 2300),
  StoreEntry(
      handsashName: 'هندسة ل 59', storeName: 'مخزن ل 59', storeNumber: 1025),
  StoreEntry(
      handsashName: 'هندسة فرع البرج الجديده',
      storeName: 'مخزن توصيلات وشبكات برج العرب الجديده',
      storeNumber: 2001),
  
];

class StoresQty extends StatefulWidget {
  final String? initialStoreName;

  const StoresQty({
    super.key,
    this.initialStoreName,
  });

  @override
  State<StoresQty> createState() =>
      _StoresQtyState();
}

class _StoresQtyState
    extends State<StoresQty> {
  // --- Selected store ---
  late StoreEntry _selectedStore;

  // --- Internet connection state ---
  bool _isLoading = false;
  bool _isOnline = true;
  bool _isOnlineChecked = false;
  bool _hasData = false;
  List<Map<String, dynamic>> _cachedItems = [];

  // --- Search and Filter state ---
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredItems = [];
  String _selectedFilter = 'الكل';
  final List<String> _filterOptions = [
    'الكل',
    'متوفر',
    'مخزون منخفض',
    'نفد من المخزون'
  ];

  // --- Sort state ---
  String _sortBy = 'name';
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _selectedStore = kStores.first;

    if (widget.initialStoreName != null) {
      final match = kStores.firstWhere(
        (s) => s.handsashName == widget.initialStoreName,
        orElse: () => kStores.first,
      );
      _selectedStore = match;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // Unified data fetch
  // ==========================================================================
  Future<void> _fetchStoreItems({bool showSuccessSnackbar = false}) async {
    if (!mounted) return;

    final online = await ConnectivityService.instance.hasConnection();
    if (!mounted) return;

    setState(() {
      _isOnline = online;
      _isOnlineChecked = true;
    });

    if (!online) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      if (!_hasData) {
        await ConnectionDialogService.showNoInternetDialog(
          context,
          onRetry: () =>
              _fetchStoreItems(showSuccessSnackbar: showSuccessSnackbar),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    // 1. Execute temp store QTY (Wrapped in its own try-catch)
    // This fixes the CORS error breaking the entire UI fetch.
    try {
      await DioNetworkRepos().excuteTempStoreQty(_selectedStore.storeName);
      // Short delay to allow backend to process the sync
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      // Log the CORS error, but DO NOT stop the fetch!
      log("Warning: excuteTempStoreQty failed (likely CORS): $e");
    }

    // 2. Fetch all QTY from server
    try {
      final data = await DioNetworkRepos().getStoreAllItemsQtyFromStoreServer();

      // CRITICAL FIX: Check if widget is still mounted before setState
      if (!mounted) return;

      List<Map<String, dynamic>> convertedData = [];
      if (data != null && data is List) {
        for (var item in data) {
          if (item is Map<String, dynamic>) {
            convertedData.add(item);
          } else if (item is Map) {
            Map<String, dynamic> convertedItem = {};
            item.forEach((key, value) {
              convertedItem[key.toString()] = value;
            });
            convertedData.add(convertedItem);
          }
        }
      }

      setState(() {
        _cachedItems = convertedData;
        _applyFiltersAndSort();
        _hasData = convertedData.isNotEmpty;
        _isLoading = false;
      });

      if (showSuccessSnackbar && mounted) {
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
      }
    } catch (e) {
      log("Error fetching store items: $e");
      if (!mounted) return;

      final onlineAgain = await ConnectivityService.instance.hasConnection();
      if (!mounted) return;

      setState(() {
        _isOnline = onlineAgain;
        _isLoading = false;
        if (_cachedItems.isEmpty) {
          _hasData = false;
        }
      });

      if (!onlineAgain && !_hasData) {
        await ConnectionDialogService.showNoInternetDialog(
          context,
          onRetry: () =>
              _fetchStoreItems(showSuccessSnackbar: showSuccessSnackbar),
        );
      } else if (showSuccessSnackbar && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ في جلب البيانات: $e',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _onRefreshPressed() async {
    final online = await ConnectivityService.instance.hasConnection();
    if (!mounted) return;

    if (!online) {
      setState(() {
        _isOnline = false;
        _isOnlineChecked = true;
      });
      ConnectionDialogService.showNoInternetDialog(context);
      return;
    }

    await _fetchStoreItems(showSuccessSnackbar: true);
  }

  Future<void> _onLoadPressed() async {
    if (!mounted) return;
    setState(() {
      _cachedItems = [];
      _filteredItems = [];
      _hasData = false;
      _selectedFilter = 'الكل';
      _searchController.clear();
    });
    await _fetchStoreItems(showSuccessSnackbar: true);
  }

  void _applyFiltersAndSort() {
    List<Map<String, dynamic>> items = List.from(_cachedItems);

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      items = items.where((item) {
        final name = item['itemName']?.toString().toLowerCase() ?? '';
        final number = item['itemNumber']?.toString().toLowerCase() ?? '';
        return name.contains(query) || number.contains(query);
      }).toList();
    }

    if (_selectedFilter != 'الكل') {
      items = items.where((item) {
        final sbal = item['sbal'];
        if (sbal is! num) return false;

        switch (_selectedFilter) {
          case 'متوفر':
            return sbal > 10;
          case 'مخزون منخفض':
            return sbal > 0 && sbal <= 10;
          case 'نفد من المخزون':
            return sbal == 0;
          default:
            return true;
        }
      }).toList();
    }

    items.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = (a['itemName']?.toString() ?? '')
              .compareTo(b['itemName']?.toString() ?? '');
          break;
        case 'number':
          comparison = (a['itemNumber']?.toString() ?? '')
              .compareTo(b['itemNumber']?.toString() ?? '');
          break;
        case 'stock':
          final aStock = a['sbal'] is num ? a['sbal'] : 0;
          final bStock = b['sbal'] is num ? b['sbal'] : 0;
          comparison = aStock.compareTo(bStock);
          break;
      }
      return _isAscending ? comparison : -comparison;
    });

    if (!mounted) return;
    setState(() {
      _filteredItems = items;
    });
  }

  void _toggleSort(String field) {
    if (_sortBy == field) {
      _isAscending = !_isAscending;
    } else {
      _sortBy = field;
      _isAscending = true;
    }
    _applyFiltersAndSort();
  }

  String _getStockStatus(dynamic sbal) {
    if (sbal is! num) return 'unknown';
    if (sbal <= 0) return 'out';
    if (sbal <= 10) return 'low';
    return 'available';
  }

  Color _getStockColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'low':
        return Colors.orange;
      case 'out':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStockLabel(String status) {
    switch (status) {
      case 'available':
        return 'متوفر';
      case 'low':
        return 'مخزون منخفض';
      case 'out':
        return 'نفد من المخزون';
      default:
        return 'غير معروف';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 900;
    final showNoInternet = !_isOnline && !_hasData && _isOnlineChecked;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "جرد : ${_selectedStore.handsashName}",
          style: const TextStyle(
            color: Colors.indigo,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: "تحديث الجرد",
            icon: const Icon(Icons.refresh, color: Colors.indigo),
            onPressed: _onRefreshPressed,
          ),
        ],
      ),
      body: Column(
        children: [
          OfflineBanner(visible: !_isOnline && _isOnlineChecked),
          _buildStoreSelectorBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.indigo),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'جاري تحميل البيانات...',
                          style: TextStyle(
                            color: Colors.indigo,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : showNoInternet
                    ? NoInternetWidget(
                        onRetry: () {
                          if (!mounted) return;
                          setState(() {
                            _isLoading = true;
                            _hasData = false;
                          });
                          _fetchStoreItems();
                        },
                      )
                    : !_hasData && _cachedItems.isEmpty
                        ? _buildInitialPrompt()
                        : Container(
                            constraints: const BoxConstraints(maxWidth: 1400),
                            child: isWeb
                                ? _buildWebLayout(screenWidth)
                                : _buildMobileLayout(),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreSelectorBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Colors.indigo.shade50,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          const Text(
            'اختر المخزن:',
            style: TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 220, maxWidth: 380),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.indigo.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<StoreEntry>(
                isExpanded: true,
                value: _selectedStore,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.indigo),
                style: const TextStyle(
                  color: Colors.indigo,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                items: kStores.map((s) {
                  return DropdownMenuItem<StoreEntry>(
                    value: s,
                    child: Text(
                      s.storeName,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedStore = value;
                    _cachedItems = [];
                    _filteredItems = [];
                    _hasData = false;
                  });
                },
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _onLoadPressed,
            icon: const Icon(Icons.cloud_download, size: 18),
            label: const Text(
              'تحميل الكميات',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'اختر المخزن ثم اضغط "تحميل الكميات"',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'المخزن المحدد حالياً: ${_selectedStore.storeName}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebLayout(double screenWidth) {
    final sidebarWidth = screenWidth * 0.22;
    final isLargeScreen = screenWidth > 1200;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: sidebarWidth.clamp(220, 320),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(
              right: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 20),
                Text(
                  'تصفية حسب المخزون',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                ..._filterOptions.map((filter) => RadioListTile<String>(
                      title: Text(
                        filter,
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.right,
                      ),
                      value: filter,
                      groupValue: _selectedFilter,
                      activeColor: Colors.indigo,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.trailing,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedFilter = value;
                          _applyFiltersAndSort();
                        });
                      },
                    )),
                const SizedBox(height: 20),
                Text(
                  'ترتيب حسب',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                _buildSortOption('الاسم', 'name'),
                _buildSortOption('الرقم', 'number'),
                _buildSortOption('المخزون', 'stock'),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.indigo.shade100,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow(
                          'إجمالي الأصناف', _filteredItems.length.toString()),
                      const Divider(),
                      _buildStatRow(
                        'متوفر',
                        _filteredItems
                            .where((item) =>
                                _getStockStatus(item['sbal']) == 'available')
                            .length
                            .toString(),
                        color: Colors.green,
                      ),
                      _buildStatRow(
                        'مخزون منخفض',
                        _filteredItems
                            .where((item) =>
                                _getStockStatus(item['sbal']) == 'low')
                            .length
                            .toString(),
                        color: Colors.orange,
                      ),
                      _buildStatRow(
                        'نفد من المخزون',
                        _filteredItems
                            .where((item) =>
                                _getStockStatus(item['sbal']) == 'out')
                            .length
                            .toString(),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _filteredItems.isEmpty
              ? _buildEmptyState()
              : _buildWebItemsGrid(_filteredItems, isLargeScreen),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: _buildSearchBar(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: FilterChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.indigo,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                        _applyFiltersAndSort();
                      });
                    },
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Text(
                'ترتيب:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              _buildSortChip('الاسم', 'name'),
              const SizedBox(width: 4),
              _buildSortChip('الرقم', 'number'),
              const SizedBox(width: 4),
              _buildSortChip('المخزون', 'stock'),
              const Spacer(),
              IconButton(
                icon: Icon(
                  _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 20,
                  color: Colors.indigo,
                ),
                onPressed: () {
                  _isAscending = !_isAscending;
                  _applyFiltersAndSort();
                },
                tooltip: _isAscending ? 'ترتيب تصاعدي' : 'ترتيب تنازلي',
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMobileStat('الإجمالي', _filteredItems.length.toString(),
                    Colors.indigo),
                _buildMobileStat(
                  'متوفر',
                  _filteredItems
                      .where((item) =>
                          _getStockStatus(item['sbal']) == 'available')
                      .length
                      .toString(),
                  Colors.green,
                ),
                _buildMobileStat(
                  'منخفض',
                  _filteredItems
                      .where((item) => _getStockStatus(item['sbal']) == 'low')
                      .length
                      .toString(),
                  Colors.orange,
                ),
                _buildMobileStat(
                  'نفد',
                  _filteredItems
                      .where((item) => _getStockStatus(item['sbal']) == 'out')
                      .length
                      .toString(),
                  Colors.red,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: _filteredItems.isEmpty
              ? _buildEmptyState()
              : _buildMobileItemsList(_filteredItems),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: 'بحث بالاسم أو رقم الصنف...',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: Colors.indigo),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                onPressed: () {
                  _searchController.clear();
                  _applyFiltersAndSort();
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade100, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade100, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: (_) => _applyFiltersAndSort(),
      style: const TextStyle(color: Colors.indigo, fontSize: 14),
    );
  }

  Widget _buildSortOption(String label, String field) {
    final isSelected = _sortBy == field;
    return InkWell(
      onTap: () => _toggleSort(field),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isSelected)
              Icon(
                _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16,
                color: Colors.indigo,
              ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.indigo : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(width: 4),
            Radio<String>(
              value: field,
              groupValue: _sortBy,
              activeColor: Colors.indigo,
              onChanged: (value) => _toggleSort(field),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, String field) {
    final isSelected = _sortBy == field;
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : Colors.grey.shade600,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      backgroundColor: isSelected ? Colors.indigo : Colors.grey.shade200,
      onPressed: () => _toggleSort(field),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.indigo,
            ),
            textAlign: TextAlign.left,
          ),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildWebItemsGrid(
      List<Map<String, dynamic>> items, bool isLargeScreen) {
    final crossAxisCount = isLargeScreen ? 3 : 2;
    final childAspectRatio = isLargeScreen ? 1.1 : 1.0;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(items[index]);
      },
    );
  }

  Widget _buildMobileItemsList(List<Map<String, dynamic>> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildItemCard(items[index]),
        );
      },
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final status = _getStockStatus(item['sbal']);
    final color = _getStockColor(status);
    final label = _getStockLabel(status);
    final sbal = item['sbal'] is num ? item['sbal'] : 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showItemDetailsDialog(item),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item['itemName']?.toString() ?? '---',
                      style: const TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'رقم الصنف',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['itemNumber']?.toString() ?? '---',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.indigo,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الرصيد',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sbal.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'آخر تحديث: ${item['lastDate']?.toString() ?? '---'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchController.text.isNotEmpty
                ? Icons.search_off
                : Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty
                ? 'لا توجد نتائج مطابقة للبحث'
                : 'لا توجد أصناف في هذا المخزن',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'جرب البحث بكلمة أخرى',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  void _showItemDetailsDialog(Map<String, dynamic> item) {
    final status = _getStockStatus(item['sbal']);
    final color = _getStockColor(status);
    final label = _getStockLabel(status);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.info_outline, color: color),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'تفاصيل الصنف',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.indigo,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDialogDetailRow(
                  'إسم الصنف', item['itemName']?.toString() ?? '---'),
              const Divider(),
              _buildDialogDetailRow(
                  'رقم الصنف', item['itemNumber']?.toString() ?? '---'),
              const Divider(),
              _buildDialogDetailRow(
                'الرصيد الحالي',
                item['sbal']?.toString() ?? '---',
                isHighlighted: true,
                color: color,
              ),
              const Divider(),
              _buildDialogDetailRow('حالة المخزون', label, color: color),
              const Divider(),
              _buildDialogDetailRow(
                  'آخر تحديث', item['lastDate']?.toString() ?? '---'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إغلاق',
              style: TextStyle(color: Colors.indigo),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildDialogDetailRow(String label, String value,
      {bool isHighlighted = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: color ?? Colors.black87,
                fontSize: 14,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
