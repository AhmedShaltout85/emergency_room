import 'dart:developer';

import 'package:emergency_room/custom_widget/custom_radio_button.dart';
import 'package:emergency_room/custom_widget/custom_text_field.dart';
import 'package:flutter/material.dart';

import '../network/remote/remote_network_repos.dart';
import '../utils/app_constants.dart';

class CustomAlertDialogCreateHandasahUsers extends StatefulWidget {
  final String title;
  const CustomAlertDialogCreateHandasahUsers({
    super.key,
    required this.title,
  });

  @override
  State<CustomAlertDialogCreateHandasahUsers> createState() =>
      _CustomAlertDailogCreateHandasahUsersState();
}

class _CustomAlertDailogCreateHandasahUsersState
    extends State<CustomAlertDialogCreateHandasahUsers> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Initialize with a default value
  String selectedOption = '2'; // Default to 'مديرى ومشرفى الهندسة'

  final List<RadioOption<String>> options = [
    RadioOption(label: 'فنى هندسة', value: '3'),
    RadioOption(label: 'مديرى ومشرفى الهندسة', value: '2'),
  ];

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        'إضافة مستخدم جديد',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 20),
          CustomTextField(
            controller: usernameController,
            keyboardType: TextInputType.text,
            lableText: 'إسم المستخدم',
            hintText: 'فضلا أدخل اسم المستخدم',
            prefixIcon: const Icon(Icons.verified_user_outlined),
            suffixIcon: const SizedBox(),
            obscureText: false,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: passwordController,
            keyboardType: TextInputType.text,
            lableText: 'كلمة المرور',
            hintText: 'فضلا أدخل كلمة المرور',
            prefixIcon: const Icon(Icons.password_rounded),
            suffixIcon: const SizedBox.shrink(),
            obscureText: false,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: confirmPasswordController,
            keyboardType: TextInputType.text,
            lableText: 'تاكيد كلمة المرور',
            hintText: 'فضلا قم بالتاكيد',
            prefixIcon: const Icon(Icons.password_rounded),
            suffixIcon: const SizedBox.shrink(),
            obscureText: false,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: CustomRadioButton<String>(
              options: options,
              initialValue: selectedOption, // Use the state variable
              onChanged: (value) {
                setState(() {
                  selectedOption = value ?? '2'; // Fallback to default if null
                });
                log("Selected: $selectedOption");
              },
              direction: Axis.horizontal,
              spacing: 7.0,
              activeColor: Colors.indigo,
              inactiveColor: Colors.grey[600],
              textStyle: const TextStyle(
                fontSize: 12,
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
              ),
              radioSize: 13.0,
            ),
          ),
          const SizedBox(height: 20),
        ]),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("إلغاء"),
        ),
        ElevatedButton(
          onPressed: () async {
            // Validate inputs
            if (usernameController.text.isEmpty ||
                passwordController.text.isEmpty ||
                confirmPasswordController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'فضلا أدخل اسم المستخدم, وكلمة المرور بشكل صحيح',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              );
              return;
            }

            if (passwordController.text.trim() !=
                confirmPasswordController.text.trim()) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'فضلا تاكد من تطابق كلمة المرور',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              );
              return;
            }

            try {
              // Call create new user
              await DioNetworkRepos().createNewUser(
                usernameController.text.trim(),
                passwordController.text.trim(),
                int.parse(selectedOption),
                StaticVariables.handasahName,
              );

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'تم انشاء المستخدم بنجاح',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                  ),
                ),
              );

              // Clear fields and close dialog
              usernameController.clear();
              passwordController.clear();
              confirmPasswordController.clear();
              Navigator.of(context).pop();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'حدث خطأ: ${e.toString()}',
                    textDirection: TextDirection.rtl,
                  ),
                ),
              );
            }
          },
          child: const Text("حفظ"),
        ),
      ],
    );
  }
}
