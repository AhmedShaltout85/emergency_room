
// Field type enum to distinguish between text fields and dropdowns
import 'package:flutter/material.dart';

enum FieldType { textField, dropdown }

// Class to define field configuration
class FieldConfig {
  final String label;
  final FieldType type;
  final List<String>? dropdownItems; // Only used for dropdown fields
  final String? initialValue; // Initial value for the field

  const FieldConfig({
    required this.label,
    required this.type,
    this.dropdownItems,
    this.initialValue,
  });
}

class CustomReusableAlertDialogWithDropdown extends StatefulWidget {
  final String title;
  final List<FieldConfig>
      fieldConfigs; // Changed from fieldLabels to fieldConfigs
  final Function(List<String>) onSubmit;

  const CustomReusableAlertDialogWithDropdown({
    super.key,
    required this.title,
    required this.fieldConfigs,
    required this.onSubmit,
  });

  @override
  State<CustomReusableAlertDialogWithDropdown> createState() =>
      _CustomReusableAlertDialogState();
}

class _CustomReusableAlertDialogState extends State<CustomReusableAlertDialogWithDropdown> {
  late List<TextEditingController> _controllers;
  late List<String?> _dropdownValues;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.fieldConfigs.length,
      (index) => TextEditingController(
        text: widget.fieldConfigs[index].type == FieldType.textField
            ? (widget.fieldConfigs[index].initialValue ?? '')
            : '',
      ),
    );

    _dropdownValues = List.generate(
      widget.fieldConfigs.length,
      (index) => widget.fieldConfigs[index].type == FieldType.dropdown
          ? widget.fieldConfigs[index].initialValue
          : null,
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildField(int index) {
    final config = widget.fieldConfigs[index];

    if (config.type == FieldType.dropdown) {
      return DropdownButtonFormField<String>(
        value: _dropdownValues[index],
        decoration: InputDecoration(
          labelText: config.label,
          border: const OutlineInputBorder(),
        ),
        items: config.dropdownItems?.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              textAlign: TextAlign.right,
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _dropdownValues[index] = newValue;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'يرجى اختيار قيمة';
          }
          return null;
        },
      );
    } else {
      return TextFormField(
        textAlign: TextAlign.right,
        controller: _controllers[index],
        decoration: InputDecoration(
          labelText: config.label,
          border: const OutlineInputBorder(),
        ),
      );
    }
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
          children: List.generate(widget.fieldConfigs.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: _buildField(index),
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
            List<String> values = [];

            for (int i = 0; i < widget.fieldConfigs.length; i++) {
              if (widget.fieldConfigs[i].type == FieldType.dropdown) {
                values.add(_dropdownValues[i] ?? '');
              } else {
                values.add(_controllers[i].text.trim());
              }
            }

            widget.onSubmit(values); // Pass values to callback
            Navigator.of(context).pop(); // Close dialog
          },
          child: const Text("حفظ"),
        ),
      ],
    );
  }
}
