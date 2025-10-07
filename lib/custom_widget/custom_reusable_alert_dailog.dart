import 'package:flutter/material.dart';

class CustomReusableAlertDialog extends StatefulWidget {
  final String title;
  final List<String> fieldLabels;
  final Function(List<String>) onSubmit;

  const CustomReusableAlertDialog({
    super.key,
    required this.title,
    required this.fieldLabels,
    required this.onSubmit,
  });

  @override
  State<CustomReusableAlertDialog> createState() =>
      _CustomReusableAlertDialogState();
}

class _CustomReusableAlertDialogState extends State<CustomReusableAlertDialog> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.fieldLabels.length,
      (index) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        textAlign: TextAlign.center,
        widget.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.indigo,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.fieldLabels.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                textAlign: TextAlign.right,
                controller: _controllers[index],
                decoration: InputDecoration(
                  labelText: widget.fieldLabels[index],
                  border: const OutlineInputBorder(),
                ),
              ),
            );
          }),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
          },
          child: const Text("إلغاء"),
        ),
        ElevatedButton(
          onPressed: () {
            List<String> values = _controllers
                .map((controller) => controller.text.trim())
                .toList();
            widget.onSubmit(values); // Pass values to callback
            Navigator.of(context).pop(); // Close dialog
          },
          child: const Text("حفظ"),
        ),
      ],
    );
  }
}
