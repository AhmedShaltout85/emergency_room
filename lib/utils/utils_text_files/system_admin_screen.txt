import 'dart:developer';

import 'package:flutter/material.dart';
import '../custom_widget/custom_dropdown_menu.dart';
import '../custom_widget/custom_elevated_button.dart';
import '../custom_widget/custom_radio_button.dart';
import '../custom_widget/custom_text_field.dart';
import '../network/remote/remote_network_repos.dart';

class SystemAdminScreen extends StatefulWidget {
  const SystemAdminScreen({super.key});

  @override
  State<SystemAdminScreen> createState() => _SystemAdminScreenState();
}

class _SystemAdminScreenState extends State<SystemAdminScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Default role selection
  String selectedOption = '0'; // Default role: مدير النظام
  String? roleValue = 'مدير النظام';

  final List<RadioOption<String>> options = [
    RadioOption(label: 'فنى هندسة', value: '3'),
    RadioOption(label: 'مديرى ومشرفى الهندسة', value: '2'),
    RadioOption(label: 'غرفة الطوارىء', value: '1'),
    RadioOption(label: 'مدير النظام', value: '0'),
  ];

  List<String> handasatItemsDropdownMenu = [];

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchHandasatItems();
  }

  void fetchHandasatItems() async {
    try {
      final List<dynamic> items =
          await DioNetworkRepos().fetchHandasatItemsDropdownMenu();
      setState(() {
        handasatItemsDropdownMenu = items.map((e) => e.toString()).toList();
      });
      log("handasatItemsDropdownMenu from UI: $handasatItemsDropdownMenu");
    } catch (e) {
      log("Error fetching dropdown items: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 7,
        // foregroundColor: Colors.white,
        // iconTheme: const IconThemeData(color: Colors.indigo, size: 17),
        title: const Text(
          'مدير النظام',
          style: TextStyle(color: Colors.indigo),
        ),
      ),
      body: Row(
        children: [
          const Expanded(
              flex: 1, child: SizedBox(width: 200, height: double.infinity)),
          Expanded(
            flex: 2,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'إضافة مستخدم جديد',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo),
                    ),
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
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: CustomRadioButton<String>(
                          options: options,
                          initialValue: '0',
                          onChanged: (value) {
                            setState(() {
                              selectedOption = value!;
                              switch (selectedOption) {
                                case '0':
                                  roleValue = 'مدير النظام';
                                  break;
                                case '1':
                                  roleValue = 'غرفة الطوارىء';
                                  break;
                                case '2':
                                  roleValue = 'مديرى ومشرفى الهندسة';
                                  break;
                                case '3':
                                  roleValue = 'فنى هندسة';
                                  break;
                              }
                            });
                            log("Selected: $selectedOption");
                          },
                          direction: Axis.horizontal,
                          spacing: 16.0,
                          activeColor: Colors.indigo,
                          inactiveColor: Colors.grey[600],
                          textStyle: const TextStyle(
                              fontSize: 13, color: Colors.indigo),
                          radioSize: 20.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (selectedOption == '3' || selectedOption == '2')
                      Container(
                        margin: const EdgeInsets.all(3.0),
                        padding: const EdgeInsets.symmetric(horizontal: 1.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.indigo, width: 1.0),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: CustomDropdown(
                          isExpanded: false,
                          items: handasatItemsDropdownMenu,
                          hintText: 'فضلا أختر الهندسة',
                          onChanged: (value) {
                            setState(() {
                              roleValue = value;
                            });
                            log('Selected Handasat item: $roleValue');
                          },
                        ),
                      ),
                    const SizedBox(height: 20),
                    CustomElevatedButton(
                      textString: 'حفظ',
                      onPressed: () async {
                        if (usernameController.text.isEmpty ||
                            passwordController.text.isEmpty ||
                            confirmPasswordController.text.isEmpty) {
                          _showSnackbar(context,
                              'فضلا أدخل اسم المستخدم, وكلمة المرور بشكل صحيح');
                        } else if (passwordController.text.trim() !=
                            confirmPasswordController.text.trim()) {
                          _showSnackbar(
                              context, 'فضلا تاكد من تطابق كلمة المرور');
                        } else {
                          try {
                            await DioNetworkRepos().createNewUser(
                              usernameController.text.trim(),
                              passwordController.text.trim(),
                              int.parse(selectedOption),
                              roleValue!,
                            );
                            _showSnackbar(context, 'تم انشاء المستخدم بنجاح');
                            usernameController.clear();
                            passwordController.clear();
                            confirmPasswordController.clear();
                          } catch (e) {
                            _showSnackbar(context, 'حدث خطأ: ${e.toString()}');
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Expanded(
              flex: 1, child: SizedBox(width: 200, height: double.infinity)),
        ],
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            textAlign: TextAlign.center, textDirection: TextDirection.rtl),
      ),
    );
  }
}
