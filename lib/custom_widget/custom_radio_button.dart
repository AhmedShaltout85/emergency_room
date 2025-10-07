// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class CustomRadioButton<T> extends StatefulWidget {
  final List<RadioOption<T>> options;
  final T? initialValue;
  final ValueChanged<T?>? onChanged;
  final Axis direction;
  final double spacing;
  final double runSpacing;
  final TextStyle? textStyle;
  final Color? activeColor;
  final Color? inactiveColor;
  final double radioSize;

  const CustomRadioButton({
    super.key,
    required this.options,
    this.initialValue,
    this.onChanged,
    this.direction = Axis.horizontal,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.textStyle,
    this.activeColor,
    this.inactiveColor,
    this.radioSize = 24.0,
  });

  @override
  _CustomRadioButtonState<T> createState() => _CustomRadioButtonState<T>();
}

class _CustomRadioButtonState<T> extends State<CustomRadioButton<T>> {
  late T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: widget.direction,
      spacing: widget.spacing,
      runSpacing: widget.runSpacing,
      children: widget.options.map((option) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedValue = option.value;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(_selectedValue);
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                option.label,
                style:
                    widget.textStyle ?? Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 3),
              Container(
                width: widget.radioSize,
                height: widget.radioSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _selectedValue == option.value
                        ? widget.activeColor ?? Theme.of(context).primaryColor
                        : widget.inactiveColor ?? Colors.grey,
                    width: 2.0,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: widget.radioSize * 0.6,
                    height: widget.radioSize * 0.6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedValue == option.value
                          ? widget.activeColor ?? Theme.of(context).primaryColor
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class RadioOption<T> {
  final String label;
  final T value;

  RadioOption({
    required this.label,
    required this.value,
  });
}

