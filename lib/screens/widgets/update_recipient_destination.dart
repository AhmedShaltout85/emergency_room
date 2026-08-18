
import 'package:dio/dio.dart';
import 'package:emergency_room/screens/widgets/reusable_widgets/update_complaint_custom_reusable_alertdialog_with_dropdown.dart';
import 'package:emergency_room/services/connectivity_service.dart';
import 'package:flutter/material.dart';
import '../../network/remote/remote_network_repos.dart';

void handleForwardComplaint(
  BuildContext context,
  Map<String, dynamic> item,
  Function refreshCallback,
) async {
  final complaintId = item['complaintId']?.toString() ?? '';
  final currentRecipientDestination =
      item['recipientDestination']?.toString() ?? ' لم يدرج';
  final complaintNote = item['complaintNote']?.toString() ?? '';

  // Show loading indicator while fetching options
  _showLoadingIndicator(context, 'جاري تحميل الخيارات...');

  try {
    // Fetch status options from API
    final dynamic response =
        await DioNetworkRepos().fetchHandasatItemsDropdownMenu();

    // Hide loading indicator
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // Parse the response to List<String>
    List<String> statusOptions = [];

    if (response is List) {
      // Direct list response
      statusOptions = response.map((item) => item.toString()).toList();
    } else if (response is Map<String, dynamic>) {
      // Handle map response with data or items key
      if (response.containsKey('data') && response['data'] is List) {
        statusOptions =
            (response['data'] as List).map((item) => item.toString()).toList();
      } else if (response.containsKey('items') && response['items'] is List) {
        statusOptions =
            (response['items'] as List).map((item) => item.toString()).toList();
      } else {
        // Try to find any list in the map values
        for (var value in response.values) {
          if (value is List) {
            statusOptions = value.map((item) => item.toString()).toList();
            break;
          }
        }
      }
    } else if (response is String) {
      // If response is a single string
      statusOptions = [response];
    } else {
      // Fallback - try to convert to string
      statusOptions = [response.toString()];
    }

    // Log for debugging
    print('PARSED OPTIONS COUNT: ${statusOptions.length}');
    print('CURRENT VALUE: $currentRecipientDestination');

    // Check if we have options
    if (statusOptions.isEmpty) {
      _showErrorSnackbar(context, '❌ لا توجد خيارات متاحة للتوجيه');
      return;
    }

    // Determine the default selected value
    String selectedValue = currentRecipientDestination;
    if (!statusOptions.contains(currentRecipientDestination)) {
      selectedValue = statusOptions.first;
      print('Current value not found. Using: "$selectedValue"');
    }

    // Show the dropdown dialog with parsed options
    context.showUpdateComplaintDialogWithDropDown(
      id: complaintId,
      currentValue: selectedValue,
      valueLabel: 'جهة التوجيه',
      dialogTitle: 'إعادة توجيه البلاغ',
      complaintNote: complaintNote,
      options: statusOptions,
      onUpdate: (newValue) async {
        try {
          // Check internet connection first
          final bool isConnected =
              await ConnectivityService.instance.hasConnection();

          if (!isConnected) {
            _showErrorSnackbar(context,
                '❌ لا يوجد اتصال بالإنترنت، يرجى التحقق من اتصالك والمحاولة مرة أخرى.');
            return;
          }

          // Show loading indicator
          _showLoadingIndicator(context, 'جاري التحديث...');

          // Validate the new value before sending
          if (newValue.isEmpty) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            _showErrorSnackbar(
                context, '❌ القيمة الجديدة لا يمكن أن تكون فارغة');
            return;
          }

          // Log the update request
          print('UPDATING COMPLAINT: $complaintId');
          print('NEW DESTINATION: $newValue');

          // Call the API to update complaint destination
          // Try with different field names that the API might expect
          final result =
              await DioNetworkRepos().updateComplaintByIdAndRecieptAndUserDestination(
            complaintId,
            newValue,
          );

          // Hide loading indicator
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          // Show success message
          _showSuccessSnackbar(context,
              '✅ تم تحويل البلاغ رقم $complaintId من "$currentRecipientDestination" إلى "$newValue"');

          // Refresh the list or update the item
          refreshCallback();
        } catch (e) {
          // Hide loading indicator if showing
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          // Log the error
          print('ERROR UPDATING COMPLAINT: $e');

          // Try to get more details from the error
          if (e is DioException) {
            final responseData = e.response?.data;
            final statusCode = e.response?.statusCode;
            print('STATUS CODE: $statusCode');
            print('RESPONSE DATA: $responseData');

            String errorMessage = '❌ فشل تحويل البلاغ';
            if (responseData != null) {
              if (responseData is Map) {
                if (responseData.containsKey('message')) {
                  errorMessage = '❌ ${responseData['message']}';
                } else if (responseData.containsKey('error')) {
                  errorMessage = '❌ ${responseData['error']}';
                } else if (responseData.containsKey('errors')) {
                  final errors = responseData['errors'];
                  if (errors is Map) {
                    final firstError = errors.values.first;
                    if (firstError is List && firstError.isNotEmpty) {
                      errorMessage = '❌ ${firstError.first}';
                    }
                  }
                } else {
                  errorMessage = '❌ ${responseData.toString()}';
                }
              } else if (responseData is String) {
                errorMessage = '❌ $responseData';
              }
            }
            _showErrorSnackbar(context, errorMessage);
          } else {
            _handleError(context, e, complaintId);
          }
        }
      },
    );
  } catch (e) {
    // Hide loading indicator if showing
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // Handle error fetching dropdown options
    String errorMessage = '❌ فشل تحميل خيارات التوجيه';

    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = '❌ انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage =
            '❌ لا يمكن الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت.';
      } else {
        errorMessage = '❌ حدث خطأ أثناء تحميل الخيارات: ${e.message}';
      }
    } else {
      errorMessage = '❌ حدث خطأ غير متوقع: ${e.toString()}';
    }

    _showErrorSnackbar(context, errorMessage);
  }
}

// Error handling method
void _handleError(BuildContext context, dynamic error, String complaintId) {
  String errorMessage = '❌ فشل تحويل البلاغ';

  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = '❌ انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        print('ERROR RESPONSE: $responseData');

        if (statusCode == 400) {
          if (responseData != null) {
            if (responseData is Map && responseData.containsKey('message')) {
              errorMessage = '❌ ${responseData['message']}';
            } else if (responseData is String) {
              errorMessage = '❌ $responseData';
            } else {
              errorMessage = '❌ طلب غير صحيح. يرجى التحقق من البيانات المدخلة.';
            }
          } else {
            errorMessage = '❌ طلب غير صحيح. يرجى التحقق من البيانات المدخلة.';
          }
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

// Show loading indicator with custom message
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
