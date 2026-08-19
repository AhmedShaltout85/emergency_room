// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:emergency_room/custom_widget/custom_browser_redirect.dart';
import 'package:emergency_room/screens/widgets/reusable_widgets/update_complaint_custom_reusable_alert_dialog.dart';
import 'package:emergency_room/screens/widgets/update_close_complaint.dart';
import 'package:emergency_room/screens/widgets/update_delete_complaint.dart';
import 'package:emergency_room/screens/widgets/update_join_as_repeated_address.dart';
import 'package:emergency_room/screens/widgets/update_obtain_approval.dart';
import 'package:emergency_room/screens/widgets/update_recipient_destination.dart';
import 'package:emergency_room/screens/widgets/update_urgency_number.dart';
import 'package:emergency_room/services/whatsapp_service.dart';
import 'package:emergency_room/services/widget/whatsapp_dialog.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

import '../custom_widget/no_internet_widget.dart';
import '../custom_widget/offline_banner.dart';
import '../model/custom_data_table_source.dart';
import '../network/remote/remote_network_repos.dart';
import '../services/connection_dialog_service.dart';
import '../services/connectivity_service.dart';

class MonitorOpeningComplaintsScreen extends StatefulWidget {
  const MonitorOpeningComplaintsScreen({super.key});

  @override
  _MonitorOpeningComplaintsScreenState createState() =>
      _MonitorOpeningComplaintsScreenState();
}

class _MonitorOpeningComplaintsScreenState
    extends State<MonitorOpeningComplaintsScreen> {
  late CustomDataTableSource<Map<String, dynamic>> _dataSource;
  final List<Map<String, dynamic>> _sampleData = [];
  List<Map<String, dynamic>> _filteredData = [];

  // --- Internet connection state ---
  bool _isLoading = true;
  bool _isOnline = true;
  bool _isOnlineChecked = false;
  bool _hasData = false;

  // --- Filter state ---
  final TextEditingController _searchController = TextEditingController();

  // إسم الهندسة / جهة الاستلام
  String? _selectedRecipientDestination;
  // الحي
  String? _selectedNeighborhood;
  // حالة الإصلاح
  String? _selectedRepairStatus;
  // حالة المتابعة
  String? _selectedComplaintStatus;
  // مدى الخطورة
  String? _selectedSeriousStatus;
  // نوع الكسر (pumpDiameter)
  String? _selectedOutageType;
  // إسم المستخدم الحالي
  String? _selectedCurrentUsername;
  // ربط مكرر
  String? _selectedRepeatComplaintNumber;
  // القطاع (sectorName)
  String? _selectedSectorName;
  // نوع البلاغ (complaintType)
  String? _selectedComplaintType;
  // NEW: رقم الاستعجال (urgencyNumber)
  String? _selectedUrgencyNumber;

  // من تاريخ / إلى تاريخ
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    // Pre-fill with today's date
    final today = DateTime.now();
    _fromDate = DateTime(today.year, 1, 1);
    _toDate = DateTime(today.year, today.month, today.day);
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // Unified data fetch
  // ==========================================================================
  Future<void> _fetchData({bool showSuccessSnackbar = false}) async {
    if (!mounted) return;

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
      if (!_hasData) {
        await ConnectionDialogService.showNoInternetDialog(
          context,
          onRetry: _fetchData,
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final value = await DioNetworkRepos().getAllComplaintsNotFinished();

      if (!mounted) return;

      setState(() {
        _sampleData.clear();
        if (value is List) {
          final all = value.cast<Map<String, dynamic>>();
          _sampleData.addAll(all.where((item) => !_asBool(item['isDeleted'])));
        }
        _applyFilters(skipSetState: true);
        _hasData = _sampleData.isNotEmpty;
        _updateDataSource();
        _isLoading = false;
      });

      log("GET ALL COMPLAINTS LOCATIONS: $value");

      if (showSuccessSnackbar) {
        if (!mounted) return;
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
      log("Error fetching data: $e");
      if (!mounted) return;

      final onlineAgain = await ConnectivityService.instance.hasConnection();
      if (!mounted) return;

      setState(() {
        _isOnline = onlineAgain;
        _isLoading = false;
        if (_sampleData.isEmpty) {
          _hasData = false;
        }
      });

      if (!onlineAgain && !_hasData) {
        await ConnectionDialogService.showNoInternetDialog(
          context,
          onRetry: _fetchData,
        );
      } else if (showSuccessSnackbar) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء تحديث البيانات: $e',
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

    await _fetchData(showSuccessSnackbar: true);
  }

  // ==========================================================================
  // Helpers
  // ==========================================================================

  String _formatDateOnly(dynamic raw) {
    if (raw == null) return '';
    final parsed = DateTime.tryParse(raw.toString());
    if (parsed == null) return raw.toString();
    return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // Arabic date format: يوم شهر سنة
  String _fmtDateArabic(DateTime d) {
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
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'مفتوح':
      case 'عالى الأهمية':
        return Colors.red;
      case 'متوسط الأهمية':
        return Colors.orange;
      case 'مغلق':
      case 'عادى':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  bool _asBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) return v == '1' || v.toLowerCase() == 'true';
    return false;
  }

  // ==========================================================================
  // Opening complaints ticker (top banner)
  // ==========================================================================

  List<Map<String, dynamic>> _openingComplaints() {
    return _sampleData.where((item) => !_asBool(item['isFinished'])).toList();
  }

  Color _severityColor(String? severity) {
    if (severity == null || severity.isEmpty) return Colors.grey.shade600;
    if (severity.contains('عالي') || severity.contains('عالى')) {
      return Colors.red.shade600;
    }
    if (severity.contains('خطير')) {
      return Colors.amber.shade800;
    }
    if (severity.contains('متوسط')) {
      return Colors.green.shade600;
    }
    return Colors.grey.shade600;
  }

  IconData _severityIcon(String? severity) {
    if (severity == null || severity.isEmpty) return Icons.help_outline;
    if (severity.contains('عالي') || severity.contains('عالى')) {
      return Icons.dangerous_outlined;
    }
    if (severity.contains('خطير')) {
      return Icons.warning_amber_rounded;
    }
    if (severity.contains('متوسط')) {
      return Icons.check_circle_outline;
    }
    return Icons.help_outline;
  }

  Widget _tickerDivider() => Container(
        width: 1,
        height: 14,
        color: Colors.white.withOpacity(0.6),
      );

  Widget _tickerField(String text) => Text(
        text,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'Cairo',
        ),
      );

  Widget _tickerFieldBold(String text) => Text(
        text,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      );

  Widget _buildOpeningComplaintsTicker() {
    final opening = _openingComplaints();

    if (opening.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'لا توجد بلاغات مفتوحة حالياً',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      constraints: BoxConstraints(
        maxHeight: opening.length > 4 ? 220 : opening.length * 44.0 + 8,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: opening.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final item = opening[index];
          final severity = item['seriousStatus']?.toString();
          final color = _severityColor(severity);

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  textDirection: TextDirection.rtl,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(_severityIcon(severity),
                        color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    _tickerFieldBold(severity == null || severity.isEmpty
                        ? 'غير محدد'
                        : severity),
                    const SizedBox(width: 14),
                    _tickerDivider(),
                    const SizedBox(width: 14),
                    _tickerField(
                      'جهة الاستلام: ${(item['recipientDestination'] == null || item['recipientDestination'].toString().isEmpty) ? 'لم يدرج' : item['recipientDestination']}',
                    ),
                    const SizedBox(width: 14),
                    _tickerDivider(),
                    const SizedBox(width: 14),
                    _tickerField(
                      'التوقيت: ${_formatDateOnly(item['createdAt'])}',
                    ),
                    const SizedBox(width: 14),
                    _tickerDivider(),
                    const SizedBox(width: 14),
                    _tickerField(
                      'بلاغ: ${item['complaintId']?.toString() ?? item['reportNumber']?.toString() ?? ''}',
                    ),
                    const SizedBox(width: 14),
                    _tickerDivider(),
                    const SizedBox(width: 14),
                    _tickerField(
                      'النوع: ${item['pumpDiameter']?.toString() ?? '-'}',
                    ),
                    const SizedBox(width: 14),
                    _tickerDivider(),
                    const SizedBox(width: 14),
                    _tickerField(
                      'العنوان: ${item['complaintAddress']?.toString() ?? ''}',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _updateDataSource() {
    _dataSource = CustomDataTableSource<Map<String, dynamic>>(
      items: _filteredData,
      buildRow: (item) => DataRow(
        color: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.blue.withOpacity(0.2);
            }
            final id = item["complaintId"];
            return (id is int && id % 2 == 0) ? Colors.grey[100] : null;
          },
        ),
        cells: [
          DataCell(Text(
            (_filteredData.indexOf(item) + 1).toString(),
            style: const TextStyle(color: Colors.indigo, fontFamily: 'Cairo'),
          )),
          DataCell(Text(
            _formatDateOnly(item['createdAt']),
            style: const TextStyle(color: Colors.indigo, fontFamily: 'Cairo'),
          )),
          DataCell(Text(
            item['complaintId']?.toString() ?? '',
            style: const TextStyle(color: Colors.indigo, fontFamily: 'Cairo'),
          )),
          DataCell(Text(
            item['pumpDiameter']?.toString() ?? '-',
            style: const TextStyle(color: Colors.indigo, fontFamily: 'Cairo'),
          )),
          DataCell(Text(
            item['complaintType']?.toString() ?? '-',
            style: const TextStyle(color: Colors.indigo, fontFamily: 'Cairo'),
          )),
          DataCell(Text(
            item['recipientDestination'] == null ||
                    item['recipientDestination'].toString().isEmpty
                ? 'لم يدرج'
                : item['recipientDestination'],
            style: const TextStyle(color: Colors.indigo, fontFamily: 'Cairo'),
          )),
          DataCell(Text(
            item['complaintAddress'] ?? '',
            style: const TextStyle(color: Colors.indigo, fontFamily: 'Cairo'),
          )),
          DataCell(Text(
            item['reportNumber']?.toString() ?? '',
            style: const TextStyle(color: Colors.indigo, fontFamily: 'Cairo'),
          )),
          DataCell(Text(
            item['reporterName'] ?? '',
            style: const TextStyle(color: Colors.indigo, fontFamily: 'Cairo'),
          )),
          DataCell(Text(
            item['complaintSource'] ?? '',
            style: const TextStyle(color: Colors.indigo, fontFamily: 'Cairo'),
          )),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(item['complaintStatus']).withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _statusColor(item['complaintStatus']),
                  width: 1,
                ),
              ),
              child: Text(
                item['complaintStatus'] ?? '',
                style: TextStyle(
                  color: _statusColor(item['complaintStatus']),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
          DataCell(
            Builder(
              builder: (buttonContext) => IconButton(
                tooltip: 'عرض التفاصيل',
                icon: const Icon(Icons.visibility,
                    color: Colors.indigo, size: 20),
                onPressed: () => _openActionsMenu(buttonContext, item),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // Actions menu (opened from the "عرض التفاصيل" row button)
  // ==========================================================================

  void _openActionsMenu(BuildContext buttonContext, Map<String, dynamic> item) {
    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(buttonContext).context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    _showActionsMenu(position, item);
  }

  Future<void> _showActionsMenu(
      RelativeRect position, Map<String, dynamic> item) async {
    final selected = await showMenu<String>(
      context: context,
      position: position,
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      items: [
        _buildActionMenuItem(
          value: 'details',
          icon: Icons.remove_red_eye_outlined,
          iconColor: Colors.blue,
          label: 'عرض التفاصيل',
        ),
        _buildActionMenuItem(
          value: 'location',
          icon: Icons.location_on_outlined,
          iconColor: Colors.teal,
          label: 'عرض الموقع',
        ),
        _buildActionMenuItem(
          value: 'whatsapp',
          icon: Icons.chat_outlined,
          iconColor: Colors.green,
          label: 'إرسال إلى واتساب',
        ),
        _buildActionMenuItem(
          value: 'close',
          icon: Icons.close_outlined,
          iconColor: Colors.red.shade600,
          label: 'غلق البلاغ',
        ),
        _buildActionMenuItem(
          value: 'urgent',
          icon: Icons.bolt_outlined,
          iconColor: Colors.deepOrange,
          label: 'استعجال',
        ),
        _buildActionMenuItem(
          value: 'forward',
          icon: Icons.forward_outlined,
          iconColor: Colors.cyan.shade700,
          label: 'إعادة توجيه',
        ),
        _buildActionMenuItem(
          value: 'link_informant',
          icon: Icons.link,
          iconColor: Colors.purple,
          label: 'ربط كمكرر',
        ),
        _buildActionMenuItem(
          value: 'approval',
          icon: Icons.check_circle_outline,
          iconColor: Colors.green.shade700,
          label: 'تم الحصول على الموافقة',
        ),
        const PopupMenuItem<String>(
          enabled: false,
          height: 1,
          padding: EdgeInsets.zero,
          child: Divider(height: 1),
        ),
        _buildActionMenuItem(
          value: 'delete',
          icon: Icons.delete_outline,
          iconColor: Colors.red,
          label: 'حذف',
          labelColor: Colors.red,
        ),
      ],
    );

    if (selected == null || !mounted) return;

    switch (selected) {
      case 'details':
        _showDetailsDialog(item);
        break;
      case 'location':
        _handleShowLocation(item);
        break;
      case 'whatsapp':
        _handleSendToWhatsapp(item);
        break;
      case 'close':
        _handleCloseComplaint(item);
        break;
      case 'urgent':
        _handleMarkUrgent(item);
        break;
      case 'forward':
        _handleForwardComplaint(item);
        break;
      case 'link_informant':
        _handleLinkAsInformant(item);
        break;
      case 'approval':
        _handleApprovalObtained(item);
        break;
      case 'delete':
        _handleDeleteComplaint(item);
        break;
    }
  }

  PopupMenuItem<String> _buildActionMenuItem({
    required String value,
    required IconData icon,
    required Color iconColor,
    required String label,
    Color? labelColor,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 42,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w500,
                  color: labelColor ?? Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Action handlers ---------------------------------------------------
  void _handleShowLocation(Map<String, dynamic> item) {
    final lat = item['latitude']?.toString();
    final lng = item['longitude']?.toString();
    final gisUrl = item['gisLink']?.toString();
    if (lat == null || lng == null || lat.isEmpty || lng.isEmpty) {
      _showActionSnackbar('لا يوجد إحداثيات مسجلة لهذا البلاغ', isError: true);
      return;
    }
    debugPrint('gisUrl:--> $gisUrl');

    if (gisUrl != null &&
        gisUrl.isNotEmpty &&
        lng.isNotEmpty &&
        lat.isNotEmpty) {
      CustomBrowserRedirect.openInBrowser(gisUrl);
    } else {
      CustomBrowserRedirect.openInBrowser(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    }
  }

// In your screen file - Use this handler

  Future<void> _handleSendToWhatsapp(Map<String, dynamic> item) async {
    try {
      // Check if WhatsApp is installed
      final whatsAppInstalled = await WhatsAppService.isWhatsAppInstalled();
      if (!whatsAppInstalled) {
        await WhatsAppService.copyComplaintToClipboard(item);
        _showActionSnackbar(
          'واتساب غير مثبت، تم نسخ البيانات إلى الحافظة',
          isError: true,
        );
        return;
      }

      // Show the dialog
      final phoneNumber = await WhatsAppDialog.showPhoneNumberDialog(
        context: context,
        initialPhoneNumber: '00201032743609',
      );

      if (phoneNumber == null || phoneNumber.isEmpty) {
        // User cancelled
        _showActionSnackbar('تم إلغاء الإرسال');
        return;
      }

      // Send to WhatsApp
      await WhatsAppService.sendToWhatsAppNumber(
        complaint: item,
        phoneNumber: phoneNumber,
      );

      _showActionSnackbar('تم فتح واتساب بنجاح');
    } catch (e) {
      debugPrint('WhatsApp error: $e');

      // Fallback: Copy to clipboard
      try {
        await WhatsAppService.copyComplaintToClipboard(item);
        _showActionSnackbar(
          'حدث خطأ، تم نسخ البيانات إلى الحافظة',
          isError: true,
        );
      } catch (copyError) {
        _showActionSnackbar(
          'حدث خطأ: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  //TODO: add close complaint
  // void _handleCloseComplaint(Map<String, dynamic> item) async {
  //   try {
  //     final complaintId = item['complaintId'] ?? '';
  //     // Parse to int if it's a valid number
  //     final int complaintIdInt = int.tryParse(complaintId.toString()) ?? 0;
  //     await DioNetworkRepos().closeComplaintByIsFinished(complaintIdInt);
  //     _showActionSnackbar('تم غلق البلاغ رقم $complaintId');
  //     _fetchData();
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  void _handleCloseComplaint(Map<String, dynamic> item) {
    handleCloseComplaint(
      context,
      item,
      _fetchData,
    );
  }

  // void _handleMarkUrgent(Map<String, dynamic> item) {
  //   _showActionSnackbar(
  //       'تم تحديد البلاغ رقم ${item['complaintId'] ?? ''} كمستعجل');
  // }
  //TODO: add mark urgent
  // For updating urgency number
  // void _handleMarkUrgent(Map<String, dynamic> item) {
  //   context.showUpdateComplaintDialog(
  //     id: item['complaintId']?.toString() ?? '',
  //     currentValue: item['urgencyNumber']?.toString() ?? '0',
  //     valueLabel: 'رقم الاستعجال',
  //     dialogTitle: 'تحديث حالة الاستعجال',
  //     complaintNote: item['complaintNote']?.toString() ?? '',
  //     onUpdate: (newValue) async {
  //       if (!mounted) return;

  //       final online = await ConnectivityService.instance.hasConnection();
  //       if (!mounted) return;

  //       setState(() {
  //         _isOnline = online;
  //         _isOnlineChecked = true;
  //       });

  //       if (!online) {
  //         setState(() {
  //           _isLoading = false;
  //         });
  //         if (!_hasData) {
  //           await ConnectionDialogService.showNoInternetDialog(
  //             context,
  //             onRetry: _fetchData,
  //           );
  //         }
  //         return;
  //       }

  //       setState(() {
  //         _isLoading = true;
  //       });
  //       try {
  //         // Call the API to update urgency number
  //         await DioNetworkRepos().updateComplaintByIdAndUrgencyNumber(
  //           item['complaintId']?.toString() ?? '',
  //           newValue,
  //         );
  //         _fetchData();
  //       } catch (e) {
  //         log("Error fetching data: $e");
  //         if (!mounted) return;

  //         final onlineAgain =
  //             await ConnectivityService.instance.hasConnection();
  //         if (!mounted) return;

  //         setState(() {
  //           _isOnline = onlineAgain;
  //           _isLoading = false;
  //           if (_sampleData.isEmpty) {
  //             _hasData = false;
  //           }
  //         });

  //         if (!onlineAgain && !_hasData) {
  //           await ConnectionDialogService.showNoInternetDialog(
  //             context,
  //             onRetry: _fetchData,
  //           );
  //         }
  //       }
  //     },
  //   );
  // }

//TODO: add mark urgent
  void _handleMarkUrgent(Map<String, dynamic> item) {
    handleMarkUrgent(
      context,
      item,
      _fetchData,
    );
  }

//TODO: add Reciept Destination
  void _handleForwardComplaint(Map<String, dynamic> item) {
    handleForwardComplaint(
      context,
      item,
      _fetchData,
    );
  }

//TODO: add link as repeated
  void _handleLinkAsInformant(Map<String, dynamic> item) {
    handleLinkAsInformant(
      context,
      item,
      _fetchData,
    );
  }

//TODO: add approval obtained
  void _handleApprovalObtained(Map<String, dynamic> item) {
    handleApprovalObtained(
      context,
      item,
      _fetchData,
    );
  }

//TODO: add delete complaint
void _handleDeleteComplaint(Map<String, dynamic> item) {
  handleDeleteComplaint(
    context,
    item,
    _fetchData,
  );
}
  // Future<void> _handleDeleteComplaint(Map<String, dynamic> item) async {
  //   final confirmed = await showDialog<bool>(
  //     context: context,
  //     builder: (dialogContext) => Directionality(
  //       textDirection: TextDirection.rtl,
  //       child: AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(14),
  //         ),
  //         title: const Text(
  //           'تأكيد الحذف',
  //           style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
  //         ),
  //         content: const Text(
  //           'هل أنت متأكد من حذف هذا البلاغ؟ لا يمكن التراجع عن هذا الإجراء.',
  //           style: TextStyle(fontFamily: 'Cairo'),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(dialogContext).pop(false),
  //             child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               try {
  //                 // Check internet connection first
  //                 final bool isConnected =
  //                     await ConnectivityService.instance.hasConnection();

  //                 if (!isConnected) {
  //                   if (Navigator.canPop(dialogContext)) {
  //                     Navigator.of(dialogContext).pop(false);
  //                   }
  //                   ConnectionDialogService.showNoInternetDialog(context,
  //                       title: "لا يوجد اتصال بالإنترنت",
  //                       message:
  //                           '❌ لا يوجد اتصال بالإنترنت، يرجى التحقق من اتصالك والمحاولة مرة أخرى.');
  //                   return;
  //                 }
  //                 final complaintId = item.entries
  //                     .firstWhere((element) => element.key == 'complaintId')
  //                     .value;
  //                 await DioNetworkRepos()
  //                     .deleteComplaintByIdAndUpdateIsFinishedAndIsDeleted(
  //                   complaintId,
  //                 );
  //                 Navigator.of(dialogContext).pop(true);
  //                 _fetchData();
  //               } catch (e) {
  //                 log(e.toString());
  //               }
  //             },
  //             style: TextButton.styleFrom(foregroundColor: Colors.red),
  //             child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo')),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );

  //   if (confirmed != true || !mounted) return;

  //   _showActionSnackbar('تم حذف البلاغ رقم ${item['complaintId'] ?? ''}');
  // }

  void _showActionSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: isError ? Colors.red : Colors.indigo,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDetailsDialog(Map<String, dynamic> item) {
    final entries = <MapEntry<String, String>>[
      MapEntry('رقم البلاغ', item['complaintId']?.toString() ?? ''),
      MapEntry('رقم البلاغ المرجعي', item['reportNumber']?.toString() ?? ''),
      MapEntry('الحي', item['neighborhood']?.toString() ?? ''),
      MapEntry('ربط مكرر', item['repeatComplaintNumber']?.toString() ?? ''),
      MapEntry('مصدر البلاغ', item['complaintSource']?.toString() ?? ''),
      MapEntry('إسم المبلغ', item['reporterName']?.toString() ?? ''),
      MapEntry('موبيل المبلغ', item['reporterPhone']?.toString() ?? ''),
      MapEntry('العنوان', item['complaintAddress']?.toString() ?? ''),
      MapEntry('حالة الإصلاح', item['complaintRepairStatus']?.toString() ?? ''),
      MapEntry('جهة الاعتماد', item['approvalAuthority']?.toString() ?? ''),
      MapEntry('نوع الكسر', item['pumpDiameter']?.toString() ?? ''),
      MapEntry('نوع البلاغ', item['complaintType']?.toString() ?? ''),
      MapEntry('مدى الخطورة', item['seriousStatus']?.toString() ?? ''),
      MapEntry('الحالة', item['complaintStatus']?.toString() ?? ''),
      MapEntry('ملاحظات البلاغ', item['complaintNote']?.toString() ?? ''),
      MapEntry('جهة الاستلام', item['recipientDestination']?.toString() ?? ''),
      MapEntry('المستلم', item['recipientUser']?.toString() ?? ''),
      MapEntry('إسم المستلم', item['recipientName']?.toString() ?? ''),
      MapEntry(
          'إسم المستخدم الحالي', item['currentUsername']?.toString() ?? ''),
      MapEntry('رابط الخريطة (GIS)', item['gisLink']?.toString() ?? ''),
      MapEntry('خط الطول', item['longitude']?.toString() ?? ''),
      MapEntry('خط العرض', item['latitude']?.toString() ?? ''),
      MapEntry('القطاع', item['sectorName']?.toString() ?? ''),
      MapEntry('رقم الاستعجال', item['urgencyNumber']?.toString() ?? ''),
      MapEntry('تاريخ الإنشاء', _formatDateOnly(item['createdAt'])),
      MapEntry('آخر تحديث', _formatDateOnly(item['updatedAt'])),
      MapEntry('تاريخ الانتهاء', _formatDateOnly(item['finishedAt'])),
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          title: Row(
            children: [
              const Icon(Icons.assignment_outlined, color: Colors.indigo),
              const SizedBox(width: 8),
              const Text(
                'تفاصيل البلاغ',
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
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      _statusColor(item['complaintStatus']).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _statusColor(item['complaintStatus']),
                  ),
                ),
                child: Text(
                  item['complaintStatus']?.toString() ?? '',
                  style: TextStyle(
                    color: _statusColor(item['complaintStatus']),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: entries
                    .where((e) => e.value.isNotEmpty)
                    .map(
                      (e) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 130,
                              child: Text(
                                e.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                  fontSize: 13,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                            Expanded(
                              child: SelectableText(
                                e.value,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(),
              icon: const Icon(Icons.close, size: 18),
              label: const Text(
                'إغلاق',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              style: TextButton.styleFrom(foregroundColor: Colors.indigo),
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilters({bool skipSetState = false}) {
    final query = _searchController.text.trim().toLowerCase();

    _filteredData = _sampleData.where((item) {
      if (query.isNotEmpty) {
        final address =
            (item['complaintAddress'] ?? '').toString().toLowerCase();
        final callerName =
            (item['reporterName'] ?? '').toString().toLowerCase();
        final callerPhone =
            (item['reporterPhone'] ?? '').toString().toLowerCase();
        final matchesSearch = address.contains(query) ||
            callerName.contains(query) ||
            callerPhone.contains(query);
        if (!matchesSearch) return false;
      }

      if (_selectedRecipientDestination != null &&
          item['recipientDestination'] != _selectedRecipientDestination) {
        return false;
      }

      if (_selectedNeighborhood != null &&
          item['neighborhood'] != _selectedNeighborhood) {
        return false;
      }

      if (_selectedRepairStatus != null &&
          item['complaintRepairStatus'] != _selectedRepairStatus) {
        return false;
      }

      if (_selectedComplaintStatus != null &&
          item['complaintStatus'] != _selectedComplaintStatus) {
        return false;
      }

      if (_selectedSeriousStatus != null &&
          item['seriousStatus'] != _selectedSeriousStatus) {
        return false;
      }

      if (_selectedOutageType != null &&
          item['pumpDiameter'] != _selectedOutageType) {
        return false;
      }

      if (_selectedCurrentUsername != null &&
          (item['currentUsername']?.toString() ?? '') !=
              _selectedCurrentUsername) {
        return false;
      }

      if (_selectedRepeatComplaintNumber != null &&
          (item['repeatComplaintNumber']?.toString() ?? '') !=
              _selectedRepeatComplaintNumber) {
        return false;
      }

      if (_selectedSectorName != null &&
          (item['sectorName']?.toString() ?? '') != _selectedSectorName) {
        return false;
      }

      if (_selectedComplaintType != null &&
          (item['complaintType']?.toString() ?? '') != _selectedComplaintType) {
        return false;
      }

      if (_selectedUrgencyNumber != null &&
          (item['urgencyNumber']?.toString() ?? '') != _selectedUrgencyNumber) {
        return false;
      }

      if (_fromDate != null || _toDate != null) {
        final createdAt =
            DateTime.tryParse((item['createdAt'] ?? '').toString());
        if (createdAt == null) return false;
        final createdDateOnly =
            DateTime(createdAt.year, createdAt.month, createdAt.day);
        if (_fromDate != null && createdDateOnly.isBefore(_fromDate!)) {
          return false;
        }
        if (_toDate != null && createdDateOnly.isAfter(_toDate!)) {
          return false;
        }
      }

      return true;
    }).toList();

    _updateDataSource();
    if (!skipSetState) setState(() {});
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedRecipientDestination = null;
      _selectedNeighborhood = null;
      _selectedRepairStatus = null;
      _selectedComplaintStatus = null;
      _selectedSeriousStatus = null;
      _selectedOutageType = null;
      _selectedCurrentUsername = null;
      _selectedRepeatComplaintNumber = null;
      _selectedSectorName = null;
      _selectedComplaintType = null;
      _selectedUrgencyNumber = null;
      final today = DateTime.now();
      _fromDate = DateTime(today.year, 1, 1);
      _toDate = DateTime(today.year, today.month, today.day);
      _applyFilters(skipSetState: true);
    });
  }

  List<String> _distinctValues(String key) {
    final values = _sampleData
        .map((e) => e[key])
        .whereType<String>()
        .where((v) => v.isNotEmpty && v != 'free')
        .toSet()
        .toList();
    values.sort();
    return values;
  }

  List<String> _distinctValuesAsString(String key) {
    final values = _sampleData
        .map((e) => e[key])
        .where((v) =>
            v != null && v.toString().isNotEmpty && v.toString() != 'free')
        .map((v) => v.toString())
        .toSet()
        .toList();
    final allNumeric = values.every((v) => num.tryParse(v) != null);
    if (allNumeric) {
      values.sort((a, b) => num.parse(a).compareTo(num.parse(b)));
    } else {
      values.sort();
    }
    return values;
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = (isFrom ? _fromDate : _toDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _fromDate = DateTime(picked.year, picked.month, picked.day);
      } else {
        _toDate = DateTime(picked.year, picked.month, picked.day);
      }
      _applyFilters(skipSetState: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final showNoInternet = !_isOnline && !_hasData && _isOnlineChecked;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'متابعة البلاغات المفتوحة',
            style: TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              fontFamily: 'Cairo',
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.indigo,
          actions: [
            IconButton(
              tooltip: "تحديث التقرير",
              icon: const Icon(
                Icons.refresh,
                color: Colors.indigo,
              ),
              onPressed: _onRefreshPressed,
            ),
          ],
        ),
        body: Column(
          children: [
            OfflineBanner(visible: !_isOnline && _isOnlineChecked),
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
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    )
                  : showNoInternet
                      ? NoInternetWidget(
                          onRetry: () {
                            setState(() {
                              _isLoading = true;
                              _hasData = false;
                            });
                            _fetchData();
                          },
                        )
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_sampleData.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد بيانات تقارير',
              style: TextStyle(
                color: Colors.indigo,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOpeningComplaintsTicker(),
          _buildFilterBar(),
          const SizedBox(height: 12),
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: PaginatedDataTable2(
                  minWidth: 1400,
                  columns: const [
                    DataColumn(
                      label: Text(
                        'مسلسل',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.indigo,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'تاريخ البلاغ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.indigo,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'رقم البلاغ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.indigo,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'نوع الكسر',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.indigo,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'نوع البلاغ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.indigo,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'جهة الاستلام',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.indigo,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'العنوان',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.indigo,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'رقم الإشارة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.indigo,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'المبلغ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.indigo,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'مصدر البلاغ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.indigo,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'الحالة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.indigo,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'الإجراءات',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.indigo,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                  source: _dataSource,
                  rowsPerPage: 10,
                  columnSpacing: 20,
                  horizontalMargin: 12,
                  showCheckboxColumn: false,
                  headingRowColor:
                      WidgetStateProperty.all(Colors.indigo.shade50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // IMPROVED FILTER BAR - Enhanced UI with better organization
  // ==========================================================================

  Widget _buildFilterBar() {
    final recipientDestinationOptions = _distinctValues('recipientDestination');
    final neighborhoodOptions = _distinctValues('neighborhood');
    final repairStatusOptions = _distinctValues('complaintRepairStatus');
    final complaintStatusOptions = _distinctValues('complaintStatus');
    final seriousStatusOptions = _distinctValues('seriousStatus');
    final outageTypeOptions = _distinctValues('pumpDiameter');
    final currentUsernameOptions = _distinctValuesAsString('currentUsername');
    final repeatComplaintNumberOptions =
        _distinctValuesAsString('repeatComplaintNumber');
    final sectorNameOptions = _distinctValues('sectorName');
    final complaintTypeOptions = _distinctValues('complaintType');
    final urgencyNumberOptions = _distinctValuesAsString('urgencyNumber');

    return Card(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.indigo.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.indigo.shade100, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row with title and clear button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo.shade400, Colors.indigo.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.filter_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'فلاتر البحث المتقدم',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                    fontSize: 17,
                    fontFamily: 'Cairo',
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade100, Colors.grey.shade200],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text(
                      'مسح الكل',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.indigo.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Field - Full Width
            Container(
              decoration: BoxDecoration(
                color: Colors.indigo.shade50.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.shade200, width: 1),
              ),
              child: TextField(
                controller: _searchController,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Cairo',
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  labelText: 'بحث في العنوان / إسم المبلغ / الموبيل',
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    color: Colors.indigo,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Cairo',
                  ),
                  floatingLabelStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(10),
                    child: const Icon(
                      Icons.search,
                      size: 22,
                      color: Colors.indigo,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (_) => _applyFilters(),
              ),
            ),
            const SizedBox(height: 16),

            // Filter Grid - Organized in rows
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildFilterChip(
                  label: 'مدى الخطورة',
                  value: _selectedSeriousStatus,
                  options: seriousStatusOptions,
                  onChanged: (v) => setState(() {
                    _selectedSeriousStatus = v;
                    _applyFilters(skipSetState: true);
                  }),
                  icon: Icons.warning_amber_rounded,
                ),
                _buildFilterChip(
                  label: 'حالة المتابعة',
                  value: _selectedComplaintStatus,
                  options: complaintStatusOptions,
                  onChanged: (v) => setState(() {
                    _selectedComplaintStatus = v;
                    _applyFilters(skipSetState: true);
                  }),
                  icon: Icons.track_changes,
                ),
                _buildFilterChip(
                  label: 'حالة الإصلاح',
                  value: _selectedRepairStatus,
                  options: repairStatusOptions,
                  onChanged: (v) => setState(() {
                    _selectedRepairStatus = v;
                    _applyFilters(skipSetState: true);
                  }),
                  icon: Icons.build,
                ),
                _buildFilterChip(
                  label: 'الحي',
                  value: _selectedNeighborhood,
                  options: neighborhoodOptions,
                  onChanged: (v) => setState(() {
                    _selectedNeighborhood = v;
                    _applyFilters(skipSetState: true);
                  }),
                  icon: Icons.location_city,
                ),
                _buildFilterChip(
                  label: 'جهة الاستلام',
                  value: _selectedRecipientDestination,
                  options: recipientDestinationOptions,
                  onChanged: (v) => setState(() {
                    _selectedRecipientDestination = v;
                    _applyFilters(skipSetState: true);
                  }),
                  icon: Icons.business_center,
                ),
                _buildFilterChip(
                  label: 'نوع الكسر',
                  value: _selectedOutageType,
                  options: outageTypeOptions,
                  onChanged: (v) => setState(() {
                    _selectedOutageType = v;
                    _applyFilters(skipSetState: true);
                  }),
                  icon: Icons.settings,
                ),
                _buildFilterChip(
                  label: 'إسم المستخدم الحالي',
                  value: _selectedCurrentUsername,
                  options: currentUsernameOptions,
                  onChanged: (v) => setState(() {
                    _selectedCurrentUsername = v;
                    _applyFilters(skipSetState: true);
                  }),
                  icon: Icons.person,
                ),
                _buildFilterChip(
                  label: 'ربط مكرر',
                  value: _selectedRepeatComplaintNumber,
                  options: repeatComplaintNumberOptions,
                  onChanged: (v) => setState(() {
                    _selectedRepeatComplaintNumber = v;
                    _applyFilters(skipSetState: true);
                  }),
                  icon: Icons.repeat,
                ),
                _buildFilterChip(
                  label: 'القطاع',
                  value: _selectedSectorName,
                  options: sectorNameOptions,
                  onChanged: (v) => setState(() {
                    _selectedSectorName = v;
                    _applyFilters(skipSetState: true);
                  }),
                  icon: Icons.account_tree,
                ),
                _buildFilterChip(
                  label: 'نوع البلاغ',
                  value: _selectedComplaintType,
                  options: complaintTypeOptions,
                  onChanged: (v) => setState(() {
                    _selectedComplaintType = v;
                    _applyFilters(skipSetState: true);
                  }),
                  icon: Icons.label,
                ),
                _buildFilterChip(
                  label: 'رقم الاستعجال',
                  value: _selectedUrgencyNumber,
                  options: urgencyNumberOptions,
                  onChanged: (v) => setState(() {
                    _selectedUrgencyNumber = v;
                    _applyFilters(skipSetState: true);
                  }),
                  icon: Icons.bolt,
                ),
                // Date Filters
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
            const SizedBox(height: 16),

            // Footer with total count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.indigo.shade50,
                    Colors.indigo.shade100.withOpacity(0.3)
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.indigo.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade600,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.table_rows,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'إجمالي السجلات: ${_filteredData.length}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade700,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                  if (_filteredData.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Text(
                        'تم العثور على ${_filteredData.length} نتيجة',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // IMPROVED FILTER CHIP - Modern design with icon
  // ==========================================================================

  Widget _buildFilterChip({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150, maxWidth: 200),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        alignment: AlignmentDirectional.centerEnd,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.black87,
          fontFamily: 'Cairo',
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 12,
            color: Colors.indigo,
            fontWeight: FontWeight.w600,
            fontFamily: 'Cairo',
          ),
          floatingLabelStyle: const TextStyle(
            fontSize: 13,
            color: Colors.indigo,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
          isDense: true,
          filled: true,
          fillColor: Colors.indigo.shade50.withOpacity(0.4),
          prefixIcon: Icon(
            icon,
            size: 18,
            color: value != null ? Colors.indigo : Colors.indigo.shade300,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: value != null
                  ? Colors.indigo.shade400
                  : Colors.indigo.shade200,
              width: value != null ? 2 : 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: value != null
                  ? Colors.indigo.shade400
                  : Colors.indigo.shade200,
              width: value != null ? 2 : 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.indigo, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        hint: Text(
          'الكل',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 12,
            color: Colors.indigo.shade300,
            fontFamily: 'Cairo',
          ),
        ),
        items: [
          const DropdownMenuItem(
            value: null,
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              'الكل',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12, fontFamily: 'Cairo'),
            ),
          ),
          ...options.map(
            (v) => DropdownMenuItem(
              value: v,
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                v,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12, fontFamily: 'Cairo'),
              ),
            ),
          ),
        ],
        onChanged: onChanged,
        icon: Icon(
          Icons.arrow_drop_down,
          color: value != null ? Colors.indigo : Colors.indigo.shade300,
        ),
      ),
    );
  }

  // ==========================================================================
  // IMPROVED DATE FILTER - Better visual design
  // ==========================================================================

  Widget _buildDateFilter({
    required String label,
    required DateTime? value,
    required bool isFrom,
  }) {
    return Container(
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 200),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _pickDate(isFrom: isFrom),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(
              fontSize: 12,
              color: Colors.indigo,
              fontWeight: FontWeight.w600,
              fontFamily: 'Cairo',
            ),
            floatingLabelStyle: const TextStyle(
              fontSize: 13,
              color: Colors.indigo,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
            isDense: true,
            filled: true,
            fillColor: Colors.indigo.shade50.withOpacity(0.4),
            prefixIcon: const Icon(
              Icons.calendar_month,
              size: 18,
              color: Colors.indigo,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: value != null
                    ? Colors.indigo.shade400
                    : Colors.indigo.shade200,
                width: value != null ? 2 : 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: value != null
                    ? Colors.indigo.shade400
                    : Colors.indigo.shade200,
                width: value != null ? 2 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.indigo, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          child: Text(
            value == null ? '—' : _fmtDateArabic(value),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: value != null ? Colors.black87 : Colors.indigo.shade300,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ),
    );
  }
}
