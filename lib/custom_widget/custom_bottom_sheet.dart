// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class CustomBottomSheet extends StatefulWidget {
  final String title;
  final String message;
  final String hintText;
  final List<String> dropdownItems;
  final Function(String?)? onItemSelected;
  final VoidCallback onPressed;

  const CustomBottomSheet({
    super.key,
    required this.title,
    required this.message,
    required this.dropdownItems,
    this.onItemSelected,
    required this.onPressed,
    required this.hintText,
  });

  @override
  _CustomBottomSheetState createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                const SizedBox(height: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    alignment: AlignmentDirectional.center,
                    value: selectedValue,
                    decoration: const InputDecoration(
                      constraints: BoxConstraints(maxWidth: 140),
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    hint: Text(widget.hintText,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          color: Colors.indigo,
                        )),
                    items: widget.dropdownItems.map((item) {
                      return DropdownMenuItem(
                        alignment: Alignment.center,
                        value: item,
                        child: Text(
                          textAlign: TextAlign.center,
                          // textDirection: TextDirection.rtl,
                          item,
                          style: const TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value;
                      });
                      if (widget.onItemSelected != null) {
                        widget.onItemSelected!(value);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: widget.onPressed,
            child: const Text(
              "حفظ",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
