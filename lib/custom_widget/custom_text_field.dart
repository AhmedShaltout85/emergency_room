import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String lableText;
  final String hintText;
  final Widget prefixIcon;
  final Widget suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextEditingController controller;
  const CustomTextField({
    super.key,
    required this.lableText,
    required this.hintText,
    required this.prefixIcon,
    required this.suffixIcon,
    required this.obscureText,
    this.keyboardType = TextInputType.none,
    required this.textInputAction,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25),
      child: TextField(
        controller: controller,
        textInputAction: textInputAction,
        style: const TextStyle(fontSize: 10),
        obscureText: obscureText,
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: const Color.fromARGB(255, 218, 214, 214),
          labelText: lableText,
          hintText: hintText,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
