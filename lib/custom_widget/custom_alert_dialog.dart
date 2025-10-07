import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final String positiveButtonText;
  final String negativeButtonText;
  final VoidCallback onPositivePressed;
  final VoidCallback onNegativePressed;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.message,
    required this.positiveButtonText,
    required this.negativeButtonText,
    required this.onPositivePressed,
    required this.onNegativePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 16.0,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onNegativePressed,
          child: Text(
            negativeButtonText,
            style: const TextStyle(color: Colors.red),
          ),
        ),
        TextButton(
          onPressed: onPositivePressed,
          child: Text(
            positiveButtonText,
          ),
        ),
      ],
    );
  }
}


// Usage Example
// Here’s how you can use this class to display a custom alert dialog:

// void showCustomDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return CustomAlertDialog(
//         title: "Confirm Action",
//         message: "Are you sure you want to proceed?",
//         positiveButtonText: "Yes",
//         negativeButtonText: "No",
//         onPositivePressed: () {
//           Navigator.of(context).pop();
//           // Add positive action here
//         },
//         onNegativePressed: () {
//           Navigator.of(context).pop();
//         },
//       );
//     },
//   );
// }
