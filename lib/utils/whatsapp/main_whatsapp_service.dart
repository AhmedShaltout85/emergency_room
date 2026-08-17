// lib/services/whatsapp_service.dart

import 'package:emergency_room/utils/whatsapp/complaint_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service for WhatsApp-related operations
class MainWhatsAppService {
  /// Builds a formatted message from complaint data
  static String buildComplaintMessage(Map<String, dynamic> complaint) {
    return ComplaintFormatter.buildWhatsAppMessage(complaint);
  }

  /// Builds a formatted clipboard text from complaint data
  static String buildClipboardText(Map<String, dynamic> complaint) {
    return ComplaintFormatter.buildClipboardText(complaint);
  }

  /// Copies complaint data to clipboard
  static Future<void> copyComplaintToClipboard(
      Map<String, dynamic> complaint) async {
    final clipboardText = buildClipboardText(complaint);
    await Clipboard.setData(ClipboardData(text: clipboardText));
  }

  /// Gets the complaint ID
  static String getComplaintId(Map<String, dynamic> complaint) {
    return complaint['complaintId']?.toString() ?? '';
  }

  /// Gets the copy success message
  static String getCopySuccessMessage(Map<String, dynamic> complaint) {
    return 'تم نسخ بيانات البلاغ رقم ${getComplaintId(complaint)} إلى الحافظة';
  }

  /// Format phone number for WhatsApp
  static String formatPhoneNumberForWhatsApp(String phoneNumber) {
    // Remove all non-numeric characters except '+'
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    // If the number starts with '00', replace with '+'
    if (cleaned.startsWith('00')) {
      cleaned = '+${cleaned.substring(2)}';
    }

    // If the number doesn't start with '+', add '+'
    if (!cleaned.startsWith('+')) {
      if (cleaned.startsWith('010') ||
          cleaned.startsWith('011') ||
          cleaned.startsWith('012') ||
          cleaned.startsWith('015')) {
        cleaned = '+20${cleaned.substring(1)}';
      } else if (cleaned.startsWith('10') ||
          cleaned.startsWith('11') ||
          cleaned.startsWith('12') ||
          cleaned.startsWith('15')) {
        cleaned = '+20$cleaned';
      } else {
        cleaned = '+$cleaned';
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

      final message = buildComplaintMessage(complaint);
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

  /// Opens WhatsApp with the complaint data (without specifying a number)
  static Future<void> shareComplaintOnWhatsAppGeneric(
      Map<String, dynamic> complaint) async {
    try {
      final message = buildComplaintMessage(complaint);
      final url = 'https://wa.me/?text=${Uri.encodeComponent(message)}';

      debugPrint('Opening WhatsApp: $url');

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
