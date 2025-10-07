import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String textString;
  final VoidCallback onPressed;
  const CustomTextButton({
    super.key,
    required this.textString,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 11),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          textString,
          style: const TextStyle(
            color: Color.fromARGB(255, 150, 94, 74),
          ),
        ),
      ),
    );
  }
}
