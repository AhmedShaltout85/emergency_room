// lib/utils/complaint_formatter.dart

import 'package:intl/intl.dart';

/// Utility class for formatting complaint data
class ComplaintFormatter {
  /// Format date from raw value
  static String formatDate(dynamic raw) {
    if (raw == null) return '';
    final parsed = DateTime.tryParse(raw.toString());
    if (parsed == null) return raw.toString();
    return DateFormat('yyyy-MM-dd').format(parsed);
  }

  /// Format time from raw value
  static String formatTime(dynamic raw) {
    if (raw == null) return '';
    final parsed = DateTime.tryParse(raw.toString());
    if (parsed == null) return '';
    return DateFormat('HH:mm').format(parsed);
  }

  /// Format date and time from raw value
  static String formatDateTime(dynamic raw) {
    if (raw == null) return '';
    final parsed = DateTime.tryParse(raw.toString());
    if (parsed == null) return raw.toString();
    return DateFormat('yyyy-MM-dd HH:mm').format(parsed);
  }

  /// Get field value as string
  static String getField(Map<String, dynamic> item, String key) {
    return item[key]?.toString() ?? '';
  }

  /// Get field value with default
  static String getFieldWithDefault(
      Map<String, dynamic> item, String key, String defaultValue) {
    final value = item[key]?.toString();
    return (value != null && value.isNotEmpty) ? value : defaultValue;
  }

  /// Builds a formatted WhatsApp message from complaint data
  static String buildWhatsAppMessage(Map<String, dynamic> item) {
    final buffer = StringBuffer();

    // Complaint ID
    buffer.writeln('رقم البلاغ: ${getField(item, 'complaintId')}');

    // Complaint Type
    buffer.writeln(
        'نوع البلاغ: ${getFieldWithDefault(item, 'complaintType', '-')}');

    // Date and Time
    final createdAt = item['createdAt'];
    buffer.writeln('تاريخ البلاغ: ${formatDate(createdAt)}');
    buffer.writeln('توقيت البلاغ: ${formatTime(createdAt)}');

    // Reporter Info
    buffer.writeln(
        'اسم المبلغ: ${getFieldWithDefault(item, 'reporterName', '-')}');
    buffer.writeln(
        'رقم الهاتف: ${getFieldWithDefault(item, 'reporterPhone', '-')}');

    // Address
    buffer.writeln(
        'العنوان: ${getFieldWithDefault(item, 'complaintAddress', '-')}');
    buffer.writeln('الحي: ${getFieldWithDefault(item, 'neighborhood', '-')}');

    // Recipient Info
    buffer
        .writeln('المستلم: ${getFieldWithDefault(item, 'recipientName', '-')}');
    buffer.writeln(
        'جهة الاستلام: ${getFieldWithDefault(item, 'recipientDestination', '-')}');

    // Complaint Details
    buffer.writeln(
        'مصدر البلاغ: ${getFieldWithDefault(item, 'complaintSource', '-')}');
    buffer.writeln(
        'حالة الإصلاح: ${getFieldWithDefault(item, 'complaintRepairStatus', '-')}');
    buffer.writeln(
        'مصدر الإفادة: ${getFieldWithDefault(item, 'reporterName', '-')}');
    buffer.writeln('القطر: ${getFieldWithDefault(item, 'pumpDiameter', '-')}');
    buffer.writeln(
        'الملاحظات: ${getFieldWithDefault(item, 'complaintNote', 'لا توجد ملاحظات')}');

    return buffer.toString();
  }

  /// Builds a formatted clipboard text from complaint data (alternative format)
  static String buildClipboardText(Map<String, dynamic> item) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('=' * 40);
    buffer.writeln('            تفاصيل البلاغ');
    buffer.writeln('=' * 40);

    // Complaint ID
    buffer.writeln('رقم البلاغ: ${getField(item, 'complaintId')}');
    buffer.writeln('-' * 40);

    // Basic Info
    buffer.writeln(
        'نوع البلاغ: ${getFieldWithDefault(item, 'complaintType', '-')}');

    final createdAt = item['createdAt'];
    buffer.writeln('تاريخ البلاغ: ${formatDate(createdAt)}');
    buffer.writeln('توقيت البلاغ: ${formatTime(createdAt)}');

    buffer.writeln('-' * 40);

    // Reporter Info
    buffer.writeln(
        'اسم المبلغ: ${getFieldWithDefault(item, 'reporterName', '-')}');
    buffer.writeln(
        'رقم الهاتف: ${getFieldWithDefault(item, 'reporterPhone', '-')}');

    buffer.writeln('-' * 40);

    // Location Info
    buffer.writeln(
        'العنوان: ${getFieldWithDefault(item, 'complaintAddress', '-')}');
    buffer.writeln('الحي: ${getFieldWithDefault(item, 'neighborhood', '-')}');

    buffer.writeln('-' * 40);

    // Recipient Info
    buffer
        .writeln('المستلم: ${getFieldWithDefault(item, 'recipientName', '-')}');
    buffer.writeln(
        'جهة الاستلام: ${getFieldWithDefault(item, 'recipientDestination', '-')}');

    buffer.writeln('-' * 40);

    // Complaint Details
    buffer.writeln(
        'مصدر البلاغ: ${getFieldWithDefault(item, 'complaintSource', '-')}');
    buffer.writeln(
        'حالة الإصلاح: ${getFieldWithDefault(item, 'complaintRepairStatus', '-')}');
    buffer.writeln(
        'مصدر الإفادة: ${getFieldWithDefault(item, 'reporterName', '-')}');
    buffer.writeln('القطر: ${getFieldWithDefault(item, 'pumpDiameter', '-')}');
    buffer.writeln(
        'الملاحظات: ${getFieldWithDefault(item, 'complaintNote', 'لا توجد ملاحظات')}');

    buffer.writeln('=' * 40);

    return buffer.toString();
  }

  /// Get complaint summary for quick view
  static String getComplaintSummary(Map<String, dynamic> item) {
    return 'بلاغ رقم ${getField(item, 'complaintId')} - ${getFieldWithDefault(item, 'complaintType', '')}';
  }
}
