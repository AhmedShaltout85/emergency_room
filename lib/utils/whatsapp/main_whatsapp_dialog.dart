// lib/widgets/whatsapp_dialog.dart

import 'package:emergency_room/utils/whatsapp/main_whatsapp_service.dart';
import 'package:flutter/material.dart';

/// A dialog for sending complaint data to WhatsApp
class MainWhatsAppDialog {
  /// Shows a dialog to enter phone number and send to WhatsApp
  static Future<String?> showPhoneNumberDialog({
    required BuildContext context,
    String? initialPhoneNumber,
    Map<String, dynamic>? complaint,
  }) async {
    final TextEditingController phoneController = TextEditingController(
      text: initialPhoneNumber ?? '00201032743609',
    );

    // If complaint is provided, show a preview of the message
    String previewMessage = '';
    if (complaint != null) {
      final message = MainWhatsAppService.buildComplaintMessage(complaint);
      // Show first 3 lines as preview
      final lines = message.split('\n');
      previewMessage = lines.take(3).join('\n');
      if (lines.length > 3) {
        previewMessage += '\n...';
      }
    }

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Directionality(
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
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Cairo',
                  ),
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    hintText: '00201032743609',
                    prefixIcon: const Icon(Icons.phone, color: Colors.indigo),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'الصيغة المدعومة: 00201032743609 أو 01032743609',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontFamily: 'Cairo',
                  ),
                ),
                if (previewMessage.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'معاينة الرسالة:',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          previewMessage,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
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
                    Navigator.pop(context, phone);
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Shows a simple dialog with copy option when WhatsApp is not available
  static Future<void> showCopyDialog({
    required BuildContext context,
    required Map<String, dynamic> complaint,
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: const Text(
              'واتساب غير مثبت',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            content: const Text(
              'لا يمكن فتح واتساب. هل تريد نسخ البيانات إلى الحافظة؟',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'إلغاء',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await MainWhatsAppService.copyComplaintToClipboard(complaint);
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تم نسخ البيانات إلى الحافظة',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: Colors.indigo,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text(
                  'نسخ',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
