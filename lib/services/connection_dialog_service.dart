
// // lib/services/dialog_service.dart (ACTIVE-WITH-WEB-MOBILE)
// import 'package:emergency_room/services/connectivity_service.dart';
// import 'package:flutter/material.dart';

// class ConnectionDialogService {
//   static ConnectivityService? _connectivityService;

//   static Future<void> showNoInternetDialog(
//     BuildContext context, {
//     VoidCallback? onRetry,
//   }) async {
//     // Better mounting check
//     if (!context.mounted) return;

//     // Ensure dialog is shown after a short delay (helps with web)
//     await Future.delayed(Duration.zero);

//     if (!context.mounted) return;

//     return showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) => AlertDialog(
//         title: const Row(
//           children: [
//             Icon(Icons.wifi_off, color: Colors.red, size: 28),
//             SizedBox(width: 8),
//             Text(
//               'لا يوجد اتصال بالإنترنت',
//               style: TextStyle(fontFamily: 'Cairo'),
//             ),
//           ],
//         ),
//         content: const Text(
//           'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى',
//           textAlign: TextAlign.center,
//           style: TextStyle(fontFamily: 'Cairo'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               if (Navigator.canPop(dialogContext)) Navigator.pop(dialogContext);
//             },
//             child: const Text(
//               'إلغاء',
//               style: TextStyle(fontFamily: 'Cairo'),
//             ),
//           ),
//           if (onRetry != null)
//             ElevatedButton(
//               onPressed: () async {
//                 // Close dialog immediately to prevent issues
//                 if (Navigator.canPop(dialogContext))
//                   Navigator.pop(dialogContext);

//                 // Wait for dialog to close
//                 await Future.delayed(const Duration(milliseconds: 100));

//                 _connectivityService = ConnectivityService.instance;
//                 final hasConnection =
//                     await _connectivityService!.hasConnection();

//                 if (!hasConnection && context.mounted) {
//                   // Still no connection, show snackbar
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Center(
//                         child: Text(
//                           'ما زال لا يوجد اتصال بالإنترنت',
//                           style: TextStyle(fontFamily: 'Cairo'),
//                         ),
//                       ),
//                       backgroundColor: Colors.red,
//                       duration: Duration(seconds: 3),
//                     ),
//                   );
//                   // Optionally show dialog again
//                   if (context.mounted) {
//                     await showNoInternetDialog(context, onRetry: onRetry);
//                   }
//                   return;
//                 }

//                 if (context.mounted && onRetry != null) {
//                   onRetry();
//                 }
//               },
//               child: const Text(
//                 'إعادة المحاولة',
//                 style: TextStyle(fontFamily: 'Cairo'),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   static Future<bool> checkAndHandleConnection(
//     BuildContext context, {
//     VoidCallback? onConnected,
//   }) async {
//     if (!context.mounted) return false;

//     _connectivityService = ConnectivityService.instance;
//     final hasConnection = await _connectivityService!.hasConnection();

//     if (!hasConnection && context.mounted) {
//       await showNoInternetDialog(
//         context,
//         onRetry: onConnected,
//       );
//       return false;
//     }

//     return hasConnection;
//   }
// }

import 'package:flutter/material.dart';

/// Centralized service for showing the "no internet connection" dialog.
///
/// Replaces the old pattern of every screen defining its own
/// `_showNoInternetDialog()` + a local `_isNoInternetDialogShowing` guard.
/// That per-screen guard only stopped a single screen from stacking a
/// dialog on itself — it didn't stop two *different* screens (e.g. two
/// tabs kept alive at once) from each independently popping their own
/// dialog at the same time. This service tracks a single app-wide
/// "is a dialog currently showing" flag, so no matter which screen asks,
/// only one no-internet dialog can ever be on screen.
class ConnectionDialogService {
  ConnectionDialogService._();

  static bool _isShowing = false;

  /// Shows the no-internet dialog, unless one is already showing anywhere
  /// in the app. If [onRetry] is provided, an "إعادة المحاولة" (Retry)
  /// action is shown that dismisses the dialog and invokes it.
  static Future<void> showNoInternetDialog(
    BuildContext context, {
    VoidCallback? onRetry,
    String title = 'لا يوجد اتصال بالإنترنت',
    String message = 'يرجى التحقق من الاتصال والمحاولة مرة اخرى',
  }) async {
    if (_isShowing || !context.mounted) return;
    _isShowing = true;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(title, style: const TextStyle(fontFamily: 'Cairo')),
            content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
            actions: [
              if (onRetry != null)
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    onRetry();
                  },
                  child: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(
                  'حسناً',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ],
          ),
        );
      },
    );

    _isShowing = false;
  }
}
