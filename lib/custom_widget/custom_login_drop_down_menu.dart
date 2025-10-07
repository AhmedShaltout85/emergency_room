import 'package:flutter/material.dart';

class CustomLoginDropdown extends StatelessWidget {
  final List<String> items;
  final String? value;
  final String hintText;
  final bool isExpanded;
  final Function(String?) onChanged;

  const CustomLoginDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.hintText,
    required this.onChanged,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    // Only use value if it's actually in the list of items
    final safeValue = items.contains(value) ? value : null;

    return DropdownButton<String>(
      isExpanded: isExpanded,
      value: safeValue,
      hint: Text(
        hintText,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          color: Colors.indigo,
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.indigo,
                  ),
                ),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
