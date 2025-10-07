import 'package:flutter/material.dart';

class CustomDropDownMenuTools extends StatelessWidget {
  final List<String> items;
  final String? value;
  final String hintText;
  final ValueChanged<String?> onChanged;
  final bool isExpanded;

  const CustomDropDownMenuTools({
    super.key,
    required this.items,
    required this.value,
    required this.hintText,
    required this.onChanged,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    // Validate that value exists in items when not null
    final isValidValue = value != null && items.contains(value);

    return DropdownButton<String>(
      alignment: AlignmentDirectional.center,
      isExpanded: isExpanded,
      value: isValidValue ? value : null,
      hint: Text(
        hintText,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.indigo,
          fontWeight: FontWeight.bold,
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          alignment: AlignmentDirectional.center,
          value: item,
          child: Center(
            child: Text(
              item,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
