import 'package:flutter/material.dart';

class TextButtonDropdown extends StatelessWidget {
  final String label;
  final List<String> options;
  final void Function(String value) onSelected;

  const TextButtonDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      elevation: 0,
      style: const TextStyle(fontWeight: FontWeight.bold),
      alignment: AlignmentDirectional.center,
      hint: Text(
        label,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: const TextStyle(color: Colors.indigo),
      ),
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          alignment: AlignmentDirectional.centerEnd,
          value: option,
          child: TextButton(
            onPressed: () => onSelected(option),
            child: Text(
              option,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(color: Colors.indigo),
            ),
          ),
        );
      }).toList(),
      onChanged: (_) {
        // Optional: you can show selected text or do nothing
      },
      underline: Container(),
      icon: const Icon(Icons.arrow_drop_down),
    );
  }
}
