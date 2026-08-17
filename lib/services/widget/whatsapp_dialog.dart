// lib/widgets/whatsapp_dialog.dart

import 'dart:async'; // Add this import for Completer
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A dialog for sending complaint data to WhatsApp
class WhatsAppDialog {
  /// Shows a dialog to enter phone number and send to WhatsApp
  static Future<String?> showPhoneNumberDialog({
    required BuildContext context,
    String? initialPhoneNumber,
  }) async {
    final TextEditingController phoneController = TextEditingController(
      text: initialPhoneNumber ?? '00201032743609',
    );

    // Use a completer to handle the result properly
    final completer = Completer<String?>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            if (!completer.isCompleted) {
              completer.complete(null);
            }
            return true;
          },
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              title: const Row(
                children: [
                  Icon(Icons.chat, color: Colors.green, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'إرسال إلى واتساب',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'أدخل رقم الهاتف لإرسال البلاغ إليه',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.indigo.shade200),
                    ),
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Cairo',
                      ),
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف',
                        hintText: '00201032743609',
                        prefixIcon: Icon(Icons.phone, color: Colors.indigo),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.blue.shade700, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'يمكنك استخدام الصيغ التالية:\n00201032743609 أو 01032743609',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade700,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (!completer.isCompleted) {
                      completer.complete(null);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final phone = phoneController.text.trim();
                    if (phone.isNotEmpty && phone.length >= 8) {
                      if (!completer.isCompleted) {
                        completer.complete(phone);
                      }
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'الرجاء إدخال رقم هاتف صحيح',
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,
                          ),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text(
                    'إرسال',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });

    return completer.future;
  }
}
