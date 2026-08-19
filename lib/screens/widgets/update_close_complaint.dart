// Add this import at the top of your file if not already present
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:emergency_room/network/remote/remote_network_repos.dart';
import 'package:emergency_room/services/connectivity_service.dart';
import 'package:flutter/material.dart';

// If you're in a StatefulWidget, make sure your class extends State<YourWidgetName>
// Example: class _YourWidgetState extends State<YourWidgetName>

// Add these methods to your class
void _showSuccessSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
          ),
        ),
      ),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(16),
    ),
  );
}

void _showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Cairo',
              color: Colors.white,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(16),
      elevation: 6,
    ),
  );
}

void _showLoadingIndicator(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        content: Row(
          children: [
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}



void handleCloseComplaint(
  BuildContext context,
   Map<String, dynamic> item,
   Function refreshCallback,
   ) async {
  // Show confirmation dialog first
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: const Text(
          'تأكيد الغلق',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'هل أنت متأكد من غلق هذا البلاغ؟',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Check internet connection first
                final bool isConnected =
                    await ConnectivityService.instance.hasConnection();

                if (!isConnected) {
                  if (Navigator.canPop(dialogContext)) {
                    Navigator.of(dialogContext).pop(false);
                  }
                  _showErrorSnackbar(context,
                      '❌ لا يوجد اتصال بالإنترنت، يرجى التحقق من اتصالك والمحاولة مرة أخرى.');
                  return;
                }

                final complaintId = item['complaintId'] ?? '';
                // Parse to int if it's a valid number
                final int complaintIdInt =
                    int.tryParse(complaintId.toString()) ?? 0;

                // Show loading indicator
                _showLoadingIndicator(context, 'جاري غلق البلاغ...');

                await DioNetworkRepos()
                    .closeComplaintByIsFinished(complaintIdInt);

                // Hide loading indicator
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }

                Navigator.of(dialogContext).pop(true);
                _showSuccessSnackbar(
                    context, '✅ تم غلق البلاغ رقم $complaintId');
                refreshCallback(); // Now this method exists
              } catch (e) {
                // Hide loading indicator if showing
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }

                // Pop the dialog if still showing
                if (Navigator.canPop(dialogContext)) {
                  Navigator.of(dialogContext).pop(false);
                }

                // Log the error
                developer.log('ERROR CLOSING COMPLAINT: $e');

                // Show error message
                String errorMessage = '❌ فشل غلق البلاغ';
                if (e is DioException) {
                  final responseData = e.response?.data;
                  final statusCode = e.response?.statusCode;
                  developer.log('STATUS CODE: $statusCode');
                  developer.log('RESPONSE DATA: $responseData');

                  if (responseData != null) {
                    if (responseData is Map) {
                      if (responseData.containsKey('message')) {
                        errorMessage = '❌ ${responseData['message']}';
                      } else if (responseData.containsKey('error')) {
                        errorMessage = '❌ ${responseData['error']}';
                      } else {
                        errorMessage = '❌ ${responseData.toString()}';
                      }
                    } else if (responseData is String) {
                      errorMessage = '❌ $responseData';
                    }
                  }

                  // Handle specific Dio error types
                  switch (e.type) {
                    case DioExceptionType.connectionTimeout:
                    case DioExceptionType.sendTimeout:
                    case DioExceptionType.receiveTimeout:
                      errorMessage =
                          '❌ انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.';
                      break;
                    case DioExceptionType.connectionError:
                      errorMessage =
                          '❌ لا يمكن الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت.';
                      break;
                    case DioExceptionType.badResponse:
                      if (statusCode == 404) {
                        errorMessage = '❌ البلاغ رقم $item[complaintId] غير موجود.';
                      } else if (statusCode == 401) {
                        errorMessage =
                            '❌ غير مصرح. يرجى تسجيل الدخول مرة أخرى.';
                      } else if (statusCode == 500) {
                        errorMessage =
                            '❌ خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً.';
                      }
                      break;
                    default:
                      break;
                  }
                } else {
                  errorMessage = '❌ حدث خطأ غير متوقع: ${e.toString()}';
                }

                _showErrorSnackbar(context, errorMessage);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('غلق', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    ),
  );

  // Remove the mounted check since we're not in a StatefulWidget State
  // Or if you are in a StatefulWidget, use:
  // if (confirmed != true || !mounted) return;
  if (confirmed != true) return;
}
