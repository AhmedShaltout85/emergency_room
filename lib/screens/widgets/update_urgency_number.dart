import 'package:dio/dio.dart';
import 'package:emergency_room/services/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'reusable_widgets/update_complaint_custom_reusable_alert_dialog.dart';
import '../../network/remote/remote_network_repos.dart';

void handleMarkUrgent(
  BuildContext context,
  Map<String, dynamic> item,
  Function refreshCallback,
) {
  final complaintId = item['complaintId']?.toString() ?? '';
  final currentUrgencyNumber = item['urgencyNumber']?.toString() ?? '0';
  final complaintNote = item['complaintNote']?.toString() ?? '';

  context.showUpdateComplaintDialog(
    id: complaintId,
    currentValue: currentUrgencyNumber,
    valueLabel: 'رقم الاستعجال',
    dialogTitle: 'تحديث حالة الاستعجال',
    complaintNote: complaintNote,
    onUpdate: (newValue) async {
      try {
        // Check internet connection first
        final bool isConnected = await ConnectivityService.instance.hasConnection();

        if (!isConnected) {
          _showErrorSnackbar(context,
              '❌ لا يوجد اتصال بالإنترنت، يرجى التحقق من اتصالك والمحاولة مرة أخرى.');
          return;
        }

        // Show loading indicator
        _showLoadingIndicator(context);

        // Call the API to update urgency number
        await DioNetworkRepos().updateComplaintByIdAndUrgencyNumber(
          complaintId,
          newValue,
        );

        // Hide loading indicator
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Show success message
        _showSuccessSnackbar(context,
            '✅ تم تحديث رقم الاستعجال للبلاغ رقم $complaintId من $currentUrgencyNumber إلى $newValue');

        // Refresh the list or update the item
        refreshCallback();
      } catch (e) {
        // Hide loading indicator if showing
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Handle different types of errors
        _handleError(context, e, complaintId);
      }
    },
  );
}



// Error handling method
void _handleError(BuildContext context, dynamic error, String complaintId) {
  String errorMessage = '❌ فشل تحديث حالة الاستعجال';

  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = '❌ انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 400) {
          errorMessage = '❌ طلب غير صحيح. يرجى التحقق من البيانات المدخلة.';
        } else if (statusCode == 401) {
          errorMessage = '❌ غير مصرح. يرجى تسجيل الدخول مرة أخرى.';
        } else if (statusCode == 404) {
          errorMessage = '❌ البلاغ رقم $complaintId غير موجود.';
        } else if (statusCode == 500) {
          errorMessage = '❌ خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً.';
        } else {
          errorMessage = '❌ حدث خطأ في الخادم (الرمز: $statusCode)';
        }
        break;
      case DioExceptionType.connectionError:
        errorMessage =
            '❌ لا يمكن الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت.';
        break;
      case DioExceptionType.cancel:
        errorMessage = '❌ تم إلغاء الطلب.';
        break;
      default:
        errorMessage = '❌ حدث خطأ غير متوقع: ${error.message}';
    }
  } else {
    errorMessage = '❌ حدث خطأ غير متوقع: ${error.toString()}';
  }

  _showErrorSnackbar(context, errorMessage);
}

// Show loading indicator
void _showLoadingIndicator(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        content: Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              ),
            ),
            SizedBox(width: 16),
            Text(
              'جاري التحديث...',
              style: TextStyle(
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Show success snackbar
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

// Show error snackbar
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
