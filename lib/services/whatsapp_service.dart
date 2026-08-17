// // lib/services/whatsapp_service.dart

// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';

// /// Service for WhatsApp-related operations
// class WhatsAppService {
//   /// Builds a formatted clipboard text for a complaint
//   static String buildComplaintClipboardText(Map<String, dynamic> item) {
//     DateTime? updatedAt;
//     final rawUpdatedAt = item['updatedAt'];
//     if (rawUpdatedAt != null) {
//       updatedAt = DateTime.tryParse(rawUpdatedAt.toString());
//     }

//     final String updatedDate =
//         updatedAt != null ? DateFormat('yyyy-MM-dd').format(updatedAt) : '';
//     final String updatedTime =
//         updatedAt != null ? DateFormat('HH:mm').format(updatedAt) : '';

//     String field(dynamic value) => (value ?? '').toString();

//     final buffer = StringBuffer()
//       ..writeln('رقم البلاغ: ${field(item['complaintId'])}')
//       ..writeln('العنوان: ${field(item['complaintAddress'])}')
//       ..writeln('جهة الاستلام: ${field(item['recipientDestination'])}')
//       ..writeln('مصدر الإفادة: ${field(item['reporterName'])}')
//       ..writeln('مصدر البلاغ: ${field(item['complaintSource'])}')
//       ..writeln('حالة الإصلاح: ${field(item['complaintRepairStatus'])}')
//       ..writeln('القطر: ${field(item['pumpDiameter'])}')
//       ..writeln('الملاحظات: ${field(item['complaintNote'])}')
//       ..writeln('تاريخ تغيير حالة الإصلاح: $updatedDate')
//       ..write('توقيت تغيير حالة الإصلاح: $updatedTime');

//     return buffer.toString();
//   }

//   /// Copies complaint data to clipboard
//   static Future<void> copyComplaintToClipboard(
//       Map<String, dynamic> item) async {
//     final clipboardText = buildComplaintClipboardText(item);
//     await Clipboard.setData(ClipboardData(text: clipboardText));
//   }

//   /// Gets the complaint ID
//   static String getComplaintId(Map<String, dynamic> item) {
//     return item['complaintId']?.toString() ?? '';
//   }

//   /// Formats the complaint for display in the snackbar message
//   static String getCopySuccessMessage(Map<String, dynamic> item) {
//     return 'تم نسخ بيانات البلاغ رقم ${getComplaintId(item)} إلى الحافظة';
//   }

//   /// Gets the WhatsApp share URL (for future implementation)
//   static String getWhatsAppShareUrl(String phoneNumber, String message) {
//     final encodedMessage = Uri.encodeComponent(message);
//     return 'https://wa.me/$phoneNumber?text=$encodedMessage';
//   }
// }
// lib/services/whatsapp_service.dart

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

/// Service for WhatsApp-related operations
class WhatsAppService {
  /// Builds a formatted clipboard text for a complaint
  static String buildComplaintClipboardText(Map<String, dynamic> item) {
    DateTime? updatedAt;
    final rawUpdatedAt = item['updatedAt'];
    if (rawUpdatedAt != null) {
      updatedAt = DateTime.tryParse(rawUpdatedAt.toString());
    }

    final String updatedDate =
        updatedAt != null ? DateFormat('yyyy-MM-dd').format(updatedAt) : '';
    final String updatedTime =
        updatedAt != null ? DateFormat('HH:mm').format(updatedAt) : '';

    String field(dynamic value) => (value ?? '').toString();

    final buffer = StringBuffer()
      ..writeln('رقم البلاغ: ${field(item['complaintId'])}')
      ..writeln('العنوان: ${field(item['complaintAddress'])}')
      ..writeln('جهة الاستلام: ${field(item['recipientDestination'])}')
      ..writeln('مصدر الإفادة: ${field(item['reporterName'])}')
      ..writeln('مصدر البلاغ: ${field(item['complaintSource'])}')
      ..writeln('حالة الإصلاح: ${field(item['complaintRepairStatus'])}')
      ..writeln('القطر: ${field(item['pumpDiameter'])}')
      ..writeln('الملاحظات: ${field(item['complaintNote'])}')
      ..writeln('تاريخ تغيير حالة الإصلاح: $updatedDate')
      ..write('توقيت تغيير حالة الإصلاح: $updatedTime');

    return buffer.toString();
  }

  /// Copies complaint data to clipboard
  static Future<void> copyComplaintToClipboard(
      Map<String, dynamic> item) async {
    final clipboardText = buildComplaintClipboardText(item);
    await Clipboard.setData(ClipboardData(text: clipboardText));
  }

  /// Gets the complaint ID
  static String getComplaintId(Map<String, dynamic> item) {
    return item['complaintId']?.toString() ?? '';
  }

  /// Formats the complaint for display in the snackbar message
  static String getCopySuccessMessage(Map<String, dynamic> item) {
    return 'تم نسخ بيانات البلاغ رقم ${getComplaintId(item)} إلى الحافظة';
  }

  /// Format phone number for WhatsApp
  static String formatPhoneNumberForWhatsApp(String phoneNumber) {
    // Remove all non-numeric characters except '+'
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    // If the number starts with '00', replace with '+'
    if (cleaned.startsWith('00')) {
      cleaned = '+' + cleaned.substring(2);
    }

    // If the number doesn't start with '+', add '+'
    if (!cleaned.startsWith('+')) {
      if (cleaned.startsWith('010') ||
          cleaned.startsWith('011') ||
          cleaned.startsWith('012') ||
          cleaned.startsWith('015')) {
        cleaned = '+20' + cleaned.substring(1);
      } else if (cleaned.startsWith('10') ||
          cleaned.startsWith('11') ||
          cleaned.startsWith('12') ||
          cleaned.startsWith('15')) {
        cleaned = '+20' + cleaned;
      } else {
        cleaned = '+' + cleaned;
      }
    }

    return cleaned;
  }

  /// Validates if the phone number is valid for WhatsApp
  static bool isValidWhatsAppNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return false;
    final formatted = formatPhoneNumberForWhatsApp(phoneNumber);
    final digitsOnly = formatted.replaceAll(RegExp(r'[^0-9]'), '');
    return digitsOnly.length >= 8;
  }

  /// Gets the WhatsApp share URL with formatted phone number
  static String getWhatsAppShareUrl(String phoneNumber, String message) {
    final formattedNumber = formatPhoneNumberForWhatsApp(phoneNumber);
    final encodedMessage = Uri.encodeComponent(message);
    return 'https://wa.me/$formattedNumber?text=$encodedMessage';
  }

  /// Extracts phone number from complaint data
  static String getPhoneNumberFromComplaint(Map<String, dynamic> complaint) {
    String phone = complaint['reporterPhone']?.toString() ?? '';
    if (phone.isEmpty) {
      phone = complaint['phone']?.toString() ?? '';
    }
    if (phone.isEmpty) {
      phone = complaint['mobile']?.toString() ?? '';
    }
    if (phone.isEmpty) {
      phone = complaint['phoneNumber']?.toString() ?? '';
    }
    return phone;
  }

  /// Check if WhatsApp is installed
  static Future<bool> isWhatsAppInstalled() async {
    try {
      const url = 'https://wa.me/';
      return await canLaunchUrl(Uri.parse(url));
    } catch (e) {
      return false;
    }
  }

  /// Opens WhatsApp with a pre-filled phone number
  static Future<void> sendToWhatsAppNumber({
    required Map<String, dynamic> complaint,
    required String phoneNumber,
  }) async {
    try {
      final formattedNumber = formatPhoneNumberForWhatsApp(phoneNumber);

      if (!isValidWhatsAppNumber(formattedNumber)) {
        throw Exception('رقم الهاتف غير صحيح: $phoneNumber');
      }

      final message = buildComplaintClipboardText(complaint);
      final url =
          'https://wa.me/$formattedNumber?text=${Uri.encodeComponent(message)}';

      debugPrint('Sending to WhatsApp: $url');

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw Exception('لا يمكن فتح واتساب');
      }
    } catch (e) {
      rethrow;
    }
  }
}
