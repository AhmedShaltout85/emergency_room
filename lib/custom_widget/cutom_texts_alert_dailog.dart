import 'package:flutter/material.dart';

class CustomReusableTextAlertDialog extends StatelessWidget {
  final String? title;
  final List<String> messages;
  final List<Widget>? actions;

  const CustomReusableTextAlertDialog({
    super.key,
    this.title,
    required this.messages,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(
                  color: Colors.indigo,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            )
          : null,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: messages
              .map((message) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        message,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
      actions: actions ??
          [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
    );
  }
}
