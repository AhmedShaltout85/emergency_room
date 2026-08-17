// // // ignore_for_file: must_be_immutable, library_private_types_in_public_api

// // import 'dart:developer';

// // import 'package:flutter/material.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:emergency_room/custom_widget/custom_circle_avatar.dart';
// // import 'package:emergency_room/custom_widget/custom_dropdown_menu.dart';
// // import 'package:emergency_room/custom_widget/custom_elevated_button.dart';
// // // import 'package:emergency_room/custom_widget/custom_landing_body.dart';
// // import 'package:emergency_room/custom_widget/custom_login_drop_down_menu.dart';
// // import 'package:emergency_room/custom_widget/custom_radio_button.dart';
// // import 'package:emergency_room/custom_widget/custom_text_field.dart';
// // // import 'package:emergency_room/screens/handasah_screen.dart';
// // // import 'package:emergency_room/screens/mobile_emergency_room_screen.dart';
// // // import 'package:emergency_room/screens/system_admin_screen.dart';
// // // import 'package:emergency_room/screens/user_screen.dart';
// // import 'package:emergency_room/utils/app_constants.dart';
// // import 'package:flutter/foundation.dart' show kIsWeb;

// // import '../network/remote/remote_network_repos.dart';
// // // import '../screens/address_to_coordinates_web.dart';
// // // import '../screens/address_to_coordinates_web_other.dart';

// // class CustomizLoginScreenBody extends StatefulWidget {
// //   const CustomizLoginScreenBody({
// //     super.key,
// //   });

// //   @override
// //   State<CustomizLoginScreenBody> createState() =>
// //       _CustomizLoginScreenBodyState();
// // }

// // class _CustomizLoginScreenBodyState extends State<CustomizLoginScreenBody> {
// //   final TextEditingController usernameController = TextEditingController();
// //   final TextEditingController passwordController = TextEditingController();
// //   List<dynamic> userList = [];

// //   @override
// //   void dispose() {
// //     usernameController.dispose();
// //     passwordController.dispose();
// //     super.dispose();
// //   }

// //   String? selectedHandasah;
// //   String selectedOption = '3'; // Default to 'فنى هندسة' for mobile
// //   String? roleLabel = 'فنى هندسة';

// //   // Full options list
// //   final List<RadioOption<String>> _fullOptions = [
// //     RadioOption(label: 'فنى هندسة', value: '3'),
// //     RadioOption(label: 'مديرى الهندسة', value: '2'),
// //     RadioOption(label: 'الطوارئ المتحركة', value: '4'),
// //     RadioOption(label: 'غرفة الطوارىء', value: '1'),
// //     RadioOption(label: 'وزارة الإسكان', value: '0'),
// //   ];

// //   // Mobile-only options list
// //   final List<RadioOption<String>> _mobileOptions = [
// //     RadioOption(label: 'فنى هندسة', value: '3'),
// //   ];

// //   List<String> handasatItemsDropdownMenu = [];
// //   List<String> userItemsDropdownMenu = [];
// //   String? selectedUser;

// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchHandasatItems();
// //   }

// //   void fetchHandasatItems() async {
// //     try {
// //       final List<dynamic> items =
// //           await DioNetworkRepos().fetchHandasatItemsDropdownMenu();
// //       setState(() {
// //         handasatItemsDropdownMenu = items.map((e) => e.toString()).toList();
// //         if (handasatItemsDropdownMenu.isNotEmpty) {
// //           selectedHandasah = handasatItemsDropdownMenu.first;
// //         }
// //       });
// //     } catch (e) {
// //       log("Error fetching dropdown items: $e");
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Error loading engineering departments: $e')),
// //       );
// //     }
// //   }

// //   Future<void> fetchUsersForSelectedHandasah() async {
// //     if (selectedHandasah == null) return;

// //     try {
// //       List<dynamic> fetchedUsers = [];
// //       switch (selectedOption) {
// //         case '2':
// //           fetchedUsers = await DioNetworkRepos()
// //               .fetchLoginUsersItemsDropdownMenu(2, selectedHandasah!);
// //           break;
// //         case '3':
// //           fetchedUsers = await DioNetworkRepos()
// //               .fetchLoginUsersItemsDropdownMenu(3, selectedHandasah!);
// //           break;
// //       }

// //       if (!mounted) return;

// //       setState(() {
// //         userItemsDropdownMenu = fetchedUsers.map((e) => e.toString()).toList();
// //         selectedUser = userItemsDropdownMenu.isNotEmpty
// //             ? userItemsDropdownMenu.first
// //             : null;
// //       });
// //     } catch (e) {
// //       log('Error fetching users: $e');
// //       if (!mounted) return;
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Error loading users: $e')),
// //       );
// //     }
// //   }

// //   void handleLogin(BuildContext context) async {
// //     final username = usernameController.text;
// //     final password = passwordController.text;

// //     if (username.isEmpty || password.isEmpty) {
// //       showSnackBar('Please enter both username and password');
// //       return;
// //     }

// //     try {
// //       final response = await DioNetworkRepos().login(username, password);

// //       if (!context.mounted) return;

// //       if (response['success']) {
// //         handleSuccessfulLogin(context);
// //       } else {
// //         showSnackBar('Login failed: ${response['message']}');
// //       }
// //     } catch (e) {
// //       if (!context.mounted) return;
// //       showSnackBar('Login error: $e');
// //     }
// //   }

// //   void handleLoginWithDropDown(BuildContext context) async {
// //     final password = passwordController.text;

// //     if (selectedUser == null || password.isEmpty) {
// //       showSnackBar('Please select a user and enter password');
// //       return;
// //     }

// //     try {
// //       final response = await DioNetworkRepos().login(selectedUser!, password);

// //       if (!context.mounted) return;

// //       if (response['success']) {
// //         handleSuccessfulLogin(context);
// //       } else {
// //         showSnackBar('Login failed: ${response['message']}');
// //       }
// //     } catch (e) {
// //       if (!context.mounted) return;
// //       showSnackBar('Login error: $e');
// //     }
// //   }

// //   void handleSuccessfulLogin(BuildContext context) {
// //     showSnackBar('تم تسجيل الدخول بنجاح');

// //     switch (StaticVariables.userRole) {
// //       case 0:
// //         // Navigator.push(context,
// //         //     MaterialPageRoute(builder: (context) => const SystemAdminScreen()));
// //         context.go('/centeral-emergency');
// //         break;
// //       case 1:
// //         // Navigator.push(
// //         //     context,
// //         //     MaterialPageRoute(
// //         //         builder: (context) => const AddressToCoordinates()));
// //         context.go('/emergency');
// //         break;
// //       case 2:
// //         // Navigator.push(context,
// //         //     MaterialPageRoute(builder: (context) => const HandasahScreen()));
// //         context.go('/handasah');
// //         break;
// //       case 3:
// //         // Navigator.push(context,
// //         //     MaterialPageRoute(builder: (context) => const UserScreen()));
// //         context.go('/technician');
// //         break;
// //       case 4:
// //         // Navigator.push(
// //         //     context,
// //         //     MaterialPageRoute(
// //         //         builder: (context) => const MobileEmergencyRoomScreen()));
// //         // builder: (context) => const AddressToCoordinatesOther()));
// //         context.go('/mobile-emergency-room');
// //         break;
// //       default:
// //         showSnackBar('فضلا, أدخل البيانات الصحيحة');
// //     }
// //   }

// //   void showSnackBar(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(
// //           message,
// //           textDirection: TextDirection.rtl,
// //           textAlign: TextAlign.center,
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final screenWidth = MediaQuery.of(context).size.width;
// //     final isMobile = !kIsWeb && (screenWidth < 600);

// //     return Scaffold(
// //       body: Center(
// //         child: SingleChildScrollView(
// //           child: Container(
// //             width: screenWidth > 600 ? 600 : screenWidth * 0.9,
// //             padding: const EdgeInsets.all(20),
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 const CustomCircleAvatar(
// //                   imgString: 'assets/logo.png',
// //                   width: 100,
// //                   height: 100,
// //                   radius: 100,
// //                 ),
// //                 const SizedBox(height: 20),

// //                 // Role selection section
// //                 if (isMobile)
// //                   _buildMobileRoleSelection()
// //                 else
// //                   _buildWebRoleSelection(),

// //                 const SizedBox(height: 20),

// //                 // Login form
// //                 Card(
// //                   color: Colors.blueGrey.shade200,
// //                   elevation: 8,
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(20),
// //                   ),
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(20),
// //                     child: Column(
// //                       children: [
// //                         // Username field or user dropdown
// //                         selectedOption == '0' ||
// //                                 selectedOption == '1' ||
// //                                 selectedOption == '4'
// //                             ? _buildUsernameField()
// //                             : _buildUserDropdown(),

// //                         const SizedBox(height: 16),

// //                         // Password field
// //                         _buildPasswordField(),

// //                         const SizedBox(height: 24),

// //                         // Login button
// //                         _buildLoginButton(),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildMobileRoleSelection() {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 25.0),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           // Engineering dropdown for mobile
// //           if (selectedOption == '3' || selectedOption == '2')
// //             Expanded(
// //               flex: 3,
// //               child: Container(
// //                 decoration: BoxDecoration(
// //                   border: Border.all(color: Colors.indigo, width: 1.0),
// //                   borderRadius: BorderRadius.circular(10.0),
// //                 ),
// //                 child: CustomDropdown(
// //                   isExpanded: true,
// //                   items: handasatItemsDropdownMenu,
// //                   hintText: 'اختر الهندسة',
// //                   value: selectedHandasah,
// //                   onChanged: (value) async {
// //                     setState(() => selectedHandasah = value);
// //                     await fetchUsersForSelectedHandasah();
// //                   },
// //                 ),
// //               ),
// //             ),
// //           const SizedBox(width: 10),
// //           // Radio button for mobile (single option)
// //           Expanded(
// //             flex: 2,
// //             child: CustomRadioButton<String>(
// //               options: _mobileOptions,
// //               initialValue: '3',
// //               onChanged: (value) {
// //                 setState(() {
// //                   selectedOption = value!;
// //                   roleLabel = 'فنى هندسة';
// //                 });
// //               },
// //               direction: Axis.horizontal,
// //               spacing: 13.0,
// //               activeColor: Colors.indigo,
// //               inactiveColor: Colors.grey[600],
// //               textStyle: const TextStyle(fontSize: 11, color: Colors.indigo),
// //               radioSize: 15.0,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildWebRoleSelection() {
// //     return Column(
// //       children: [
// //         Padding(
// //           padding: const EdgeInsets.all(25.0),
// //           child: Align(
// //             alignment: Alignment.centerRight,
// //             child: CustomRadioButton<String>(
// //               options: _fullOptions,
// //               initialValue: '3',
// //               onChanged: (value) {
// //                 setState(() {
// //                   selectedOption = value!;
// //                   switch (selectedOption) {
// //                     case '0':
// //                       roleLabel = 'وزارة الإسكان';
// //                       break;
// //                     case '1':
// //                       roleLabel = 'غرفة الطوارىء';
// //                       break;
// //                     case '2':
// //                       roleLabel = 'مديرى الهندسة';
// //                       break;
// //                     case '3':
// //                       roleLabel = 'فنى هندسة';
// //                       break;
// //                     case '4':
// //                       roleLabel = 'الطوارئ المتحركة';
// //                       break;
// //                   }
// //                   // Reset selections when role changes
// //                   selectedHandasah = null;
// //                   selectedUser = null;
// //                   userItemsDropdownMenu = [];
// //                 });
// //                 if (selectedOption == '2' || selectedOption == '3') {
// //                   fetchHandasatItems();
// //                 }
// //               },
// //               direction: Axis.horizontal,
// //               spacing: 13.0,
// //               activeColor: Colors.indigo,
// //               inactiveColor: Colors.grey[600],
// //               textStyle: const TextStyle(fontSize: 11, color: Colors.indigo),
// //               radioSize: 15.0,
// //             ),
// //           ),
// //         ),
// //         // Engineering dropdown for web
// //         if (selectedOption == '3' || selectedOption == '2')
// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 150.0),
// //             child: Container(
// //               margin: const EdgeInsets.all(3.0),
// //               padding: const EdgeInsets.symmetric(horizontal: 1.0),
// //               decoration: BoxDecoration(
// //                 border: Border.all(color: Colors.indigo, width: 1.0),
// //                 borderRadius: BorderRadius.circular(10.0),
// //               ),
// //               child: CustomDropdown(
// //                 isExpanded: true,
// //                 items: handasatItemsDropdownMenu,
// //                 hintText: 'فضلا أختر الهندسة',
// //                 value: selectedHandasah,
// //                 onChanged: (value) async {
// //                   setState(() => selectedHandasah = value);
// //                   await fetchUsersForSelectedHandasah();
// //                 },
// //               ),
// //             ),
// //           ),
// //       ],
// //     );
// //   }

// //   Widget _buildUsernameField() {
// //     return CustomTextField(
// //       controller: usernameController,
// //       keyboardType: TextInputType.text,
// //       lableText: 'Username',
// //       hintText: 'Enter Username',
// //       prefixIcon: const Icon(Icons.verified_user_outlined),
// //       suffixIcon: const SizedBox(),
// //       obscureText: false,
// //       textInputAction: TextInputAction.next,
// //     );
// //   }

// //   Widget _buildUserDropdown() {
// //     return Container(
// //       margin: const EdgeInsets.symmetric(horizontal: 30.0),
// //       padding: const EdgeInsets.symmetric(horizontal: 30.0),
// //       decoration: BoxDecoration(
// //         border: Border.all(color: Colors.indigo, width: 1.0),
// //         borderRadius: BorderRadius.circular(10.0),
// //       ),
// //       child: CustomLoginDropdown(
// //         items: userItemsDropdownMenu,
// //         value: selectedUser,
// //         hintText: 'فضلا أختر إسم المستخدم',
// //         onChanged: (value) {
// //           setState(() => selectedUser = value);
// //         },
// //       ),
// //     );
// //   }

// //   Widget _buildPasswordField() {
// //     return CustomTextField(
// //       controller: passwordController,
// //       keyboardType: TextInputType.text,
// //       lableText: 'Password',
// //       hintText: 'Enter Password',
// //       prefixIcon: const Icon(Icons.password),
// //       suffixIcon: const Icon(Icons.visibility),
// //       obscureText: true,
// //       textInputAction: TextInputAction.done,
// //     );
// //   }

// //   Widget _buildLoginButton() {
// //     return selectedOption == '0' ||
// //             selectedOption == '1' ||
// //             selectedOption == '4'
// //         ? CustomElevatedButton(
// //             textString: 'Login',
// //             onPressed: () => handleLogin(context),
// //           )
// //         : CustomElevatedButton(
// //             textString: 'Login',
// //             onPressed: () => handleLoginWithDropDown(context),
// //           );
// //   }
// // }
// // ignore_for_file: must_be_immutable, library_private_types_in_public_api

// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:emergency_room/custom_widget/custom_circle_avatar.dart';
// import 'package:emergency_room/custom_widget/custom_dropdown_menu.dart';
// import 'package:emergency_room/custom_widget/custom_elevated_button.dart';
// import 'package:emergency_room/custom_widget/custom_login_drop_down_menu.dart';
// import 'package:emergency_room/custom_widget/custom_radio_button.dart';
// import 'package:emergency_room/custom_widget/custom_text_field.dart';
// import 'package:emergency_room/custom_widget/no_internet_widget.dart';
// import 'package:emergency_room/custom_widget/offline_banner.dart';
// import 'package:emergency_room/utils/app_constants.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;

// import '../network/remote/remote_network_repos.dart';
// import '../services/connectivity_service.dart';

// class CustomizLoginScreenBody extends StatefulWidget {
//   const CustomizLoginScreenBody({
//     super.key,
//   });

//   @override
//   State<CustomizLoginScreenBody> createState() =>
//       _CustomizLoginScreenBodyState();
// }

// class _CustomizLoginScreenBodyState extends State<CustomizLoginScreenBody> {
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   List<dynamic> userList = [];

//   // --- Internet connection state ---
//   bool _isLoading = true;
//   bool _isOnline = true;
//   bool _isOnlineChecked = false;
//   bool _hasInitialData = false;

//   @override
//   void dispose() {
//     usernameController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }

//   String? selectedHandasah;
//   String selectedOption = '3'; // Default to 'فنى هندسة' for mobile
//   String? roleLabel = 'فنى هندسة';

//   // Full options list
//   final List<RadioOption<String>> _fullOptions = [
//     RadioOption(label: 'فنى هندسة', value: '3'),
//     RadioOption(label: 'مديرى الهندسة', value: '2'),
//     RadioOption(label: 'الطوارئ المتحركة', value: '4'),
//     RadioOption(label: 'غرفة الطوارىء', value: '1'),
//     RadioOption(label: 'وزارة الإسكان', value: '0'),
//   ];

//   // Mobile-only options list
//   final List<RadioOption<String>> _mobileOptions = [
//     RadioOption(label: 'فنى هندسة', value: '3'),
//   ];

//   List<String> handasatItemsDropdownMenu = [];
//   List<String> userItemsDropdownMenu = [];
//   String? selectedUser;

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   Future<void> _initializeData() async {
//     // Check internet first
//     final online = await ConnectivityService.instance.hasConnection();
//     if (!mounted) return;
//     setState(() {
//       _isOnline = online;
//       _isOnlineChecked = true;
//     });

//     if (!online) {
//       setState(() {
//         _isLoading = false;
//       });
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });
//     await fetchHandasatItems();
//     if (!mounted) return;
//     setState(() {
//       _isLoading = false;
//       _hasInitialData = true;
//     });
//   }

//   Future<void> fetchHandasatItems() async {
//     try {
//       final List<dynamic> items =
//           await DioNetworkRepos().fetchHandasatItemsDropdownMenu();
//       if (!mounted) return;
//       setState(() {
//         handasatItemsDropdownMenu = items.map((e) => e.toString()).toList();
//         if (handasatItemsDropdownMenu.isNotEmpty) {
//           selectedHandasah = handasatItemsDropdownMenu.first;
//         }
//       });
//     } catch (e) {
//       log("Error fetching dropdown items: $e");
//       // Check if internet is still available
//       final online = await ConnectivityService.instance.hasConnection();
//       if (!mounted) return;
//       setState(() {
//         _isOnline = online;
//       });
//       if (!online) {
//         // Don't show error for no internet, banner will handle it
//         return;
//       }
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading engineering departments: $e')),
//       );
//     }
//   }

//   Future<void> fetchUsersForSelectedHandasah() async {
//     if (selectedHandasah == null) return;

//     // Check internet before API call
//     final online = await ConnectivityService.instance.hasConnection();
//     if (!online) {
//       setState(() {
//         _isOnline = false;
//         _isOnlineChecked = true;
//       });
//       return;
//     }

//     try {
//       List<dynamic> fetchedUsers = [];
//       switch (selectedOption) {
//         case '2':
//           fetchedUsers = await DioNetworkRepos()
//               .fetchLoginUsersItemsDropdownMenu(2, selectedHandasah!);
//           break;
//         case '3':
//           fetchedUsers = await DioNetworkRepos()
//               .fetchLoginUsersItemsDropdownMenu(3, selectedHandasah!);
//           break;
//       }

//       if (!mounted) return;

//       setState(() {
//         userItemsDropdownMenu = fetchedUsers.map((e) => e.toString()).toList();
//         selectedUser = userItemsDropdownMenu.isNotEmpty
//             ? userItemsDropdownMenu.first
//             : null;
//       });
//     } catch (e) {
//       log('Error fetching users: $e');
//       final onlineAgain = await ConnectivityService.instance.hasConnection();
//       if (!mounted) return;
//       setState(() {
//         _isOnline = onlineAgain;
//       });
//       if (!onlineAgain) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading users: $e')),
//       );
//     }
//   }

//   void handleLogin(BuildContext context) async {
//     // Check internet before login
//     final online = await ConnectivityService.instance.hasConnection();
//     if (!online) {
//       setState(() {
//         _isOnline = false;
//         _isOnlineChecked = true;
//       });
//       showSnackBar('لا يوجد إتصال بالإنترنت');
//       return;
//     }

//     final username = usernameController.text;
//     final password = passwordController.text;

//     if (username.isEmpty || password.isEmpty) {
//       showSnackBar('Please enter both username and password');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await DioNetworkRepos().login(username, password);

//       if (!context.mounted) return;

//       setState(() {
//         _isLoading = false;
//       });

//       if (response['success']) {
//         handleSuccessfulLogin(context);
//       } else {
//         showSnackBar('Login failed: ${response['message']}');
//       }
//     } catch (e) {
//       if (!context.mounted) return;
//       setState(() {
//         _isLoading = false;
//       });
//       // Check if internet was lost during login
//       final onlineAgain = await ConnectivityService.instance.hasConnection();
//       setState(() {
//         _isOnline = onlineAgain;
//       });
//       if (!onlineAgain) {
//         showSnackBar('لا يوجد إتصال بالإنترنت');
//         return;
//       }
//       showSnackBar('Login error: $e');
//     }
//   }

//   void handleLoginWithDropDown(BuildContext context) async {
//     // Check internet before login
//     final online = await ConnectivityService.instance.hasConnection();
//     if (!online) {
//       setState(() {
//         _isOnline = false;
//         _isOnlineChecked = true;
//       });
//       showSnackBar('لا يوجد إتصال بالإنترنت');
//       return;
//     }

//     final password = passwordController.text;

//     if (selectedUser == null || password.isEmpty) {
//       showSnackBar('Please select a user and enter password');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response = await DioNetworkRepos().login(selectedUser!, password);

//       if (!context.mounted) return;

//       setState(() {
//         _isLoading = false;
//       });

//       if (response['success']) {
//         handleSuccessfulLogin(context);
//       } else {
//         showSnackBar('Login failed: ${response['message']}');
//       }
//     } catch (e) {
//       if (!context.mounted) return;
//       setState(() {
//         _isLoading = false;
//       });
//       final onlineAgain = await ConnectivityService.instance.hasConnection();
//       setState(() {
//         _isOnline = onlineAgain;
//       });
//       if (!onlineAgain) {
//         showSnackBar('لا يوجد إتصال بالإنترنت');
//         return;
//       }
//       showSnackBar('Login error: $e');
//     }
//   }

//   void handleSuccessfulLogin(BuildContext context) {
//     showSnackBar('تم تسجيل الدخول بنجاح');

//     switch (StaticVariables.userRole) {
//       case 0:
//         context.go('/centeral-emergency');
//         break;
//       case 1:
//         context.go('/emergency');
//         break;
//       case 2:
//         context.go('/handasah');
//         break;
//       case 3:
//         context.go('/technician');
//         break;
//       case 4:
//         context.go('/mobile-emergency-room');
//         break;
//       default:
//         showSnackBar('فضلا, أدخل البيانات الصحيحة');
//     }
//   }

//   void showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           textDirection: TextDirection.rtl,
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isMobile = !kIsWeb && (screenWidth < 600);

//     // Determine if we should show NoInternetWidget
//     final showNoInternet = !_isOnline && !_hasInitialData && _isOnlineChecked;

//     return Scaffold(
//       body: Column(
//         children: [
//           OfflineBanner(visible: !_isOnline && _isOnlineChecked),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : showNoInternet
//                     ? NoInternetWidget(
//                         onRetry: () {
//                           setState(() {
//                             _isLoading = true;
//                             _hasInitialData = false;
//                           });
//                           _initializeData();
//                         },
//                       )
//                     : Center(
//                         child: SingleChildScrollView(
//                           child: Container(
//                             width: screenWidth > 600 ? 600 : screenWidth * 0.9,
//                             padding: const EdgeInsets.all(20),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const CustomCircleAvatar(
//                                   imgString: 'assets/logo.png',
//                                   width: 100,
//                                   height: 100,
//                                   radius: 100,
//                                 ),
//                                 const SizedBox(height: 20),

//                                 // Role selection section
//                                 if (isMobile)
//                                   _buildMobileRoleSelection()
//                                 else
//                                   _buildWebRoleSelection(),

//                                 const SizedBox(height: 20),

//                                 // Login form
//                                 Card(
//                                   color: Colors.blueGrey.shade200,
//                                   elevation: 8,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(20),
//                                     child: Column(
//                                       children: [
//                                         // Username field or user dropdown
//                                         selectedOption == '0' ||
//                                                 selectedOption == '1' ||
//                                                 selectedOption == '4'
//                                             ? _buildUsernameField()
//                                             : _buildUserDropdown(),

//                                         const SizedBox(height: 16),

//                                         // Password field
//                                         _buildPasswordField(),

//                                         const SizedBox(height: 24),

//                                         // Login button
//                                         _buildLoginButton(),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMobileRoleSelection() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 25.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Engineering dropdown for mobile
//           if (selectedOption == '3' || selectedOption == '2')
//             Expanded(
//               flex: 3,
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.indigo, width: 1.0),
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 child: CustomDropdown(
//                   isExpanded: true,
//                   items: handasatItemsDropdownMenu,
//                   hintText: 'اختر الهندسة',
//                   value: selectedHandasah,
//                   onChanged: (value) async {
//                     setState(() => selectedHandasah = value);
//                     await fetchUsersForSelectedHandasah();
//                   },
//                 ),
//               ),
//             ),
//           const SizedBox(width: 10),
//           // Radio button for mobile (single option)
//           Expanded(
//             flex: 2,
//             child: CustomRadioButton<String>(
//               options: _mobileOptions,
//               initialValue: '3',
//               onChanged: (value) {
//                 setState(() {
//                   selectedOption = value!;
//                   roleLabel = 'فنى هندسة';
//                 });
//               },
//               direction: Axis.horizontal,
//               spacing: 13.0,
//               activeColor: Colors.indigo,
//               inactiveColor: Colors.grey[600],
//               textStyle: const TextStyle(fontSize: 11, color: Colors.indigo),
//               radioSize: 15.0,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWebRoleSelection() {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(25.0),
//           child: Align(
//             alignment: Alignment.centerRight,
//             child: CustomRadioButton<String>(
//               options: _fullOptions,
//               initialValue: '3',
//               onChanged: (value) {
//                 setState(() {
//                   selectedOption = value!;
//                   switch (selectedOption) {
//                     case '0':
//                       roleLabel = 'وزارة الإسكان';
//                       break;
//                     case '1':
//                       roleLabel = 'غرفة الطوارىء';
//                       break;
//                     case '2':
//                       roleLabel = 'مديرى الهندسة';
//                       break;
//                     case '3':
//                       roleLabel = 'فنى هندسة';
//                       break;
//                     case '4':
//                       roleLabel = 'الطوارئ المتحركة';
//                       break;
//                   }
//                   // Reset selections when role changes
//                   selectedHandasah = null;
//                   selectedUser = null;
//                   userItemsDropdownMenu = [];
//                 });
//                 // Call fetchHandasatItems without expecting a return value
//                 if (selectedOption == '2' || selectedOption == '3') {
//                   fetchHandasatItems();
//                 }
//               },
//               direction: Axis.horizontal,
//               spacing: 13.0,
//               activeColor: Colors.indigo,
//               inactiveColor: Colors.grey[600],
//               textStyle: const TextStyle(fontSize: 11, color: Colors.indigo),
//               radioSize: 15.0,
//             ),
//           ),
//         ),
//         // Engineering dropdown for web
//         if (selectedOption == '3' || selectedOption == '2')
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 150.0),
//             child: Container(
//               margin: const EdgeInsets.all(3.0),
//               padding: const EdgeInsets.symmetric(horizontal: 1.0),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.indigo, width: 1.0),
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//               child: CustomDropdown(
//                 isExpanded: true,
//                 items: handasatItemsDropdownMenu,
//                 hintText: 'فضلا أختر الهندسة',
//                 value: selectedHandasah,
//                 onChanged: (value) async {
//                   setState(() => selectedHandasah = value);
//                   await fetchUsersForSelectedHandasah();
//                 },
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildUsernameField() {
//     return CustomTextField(
//       controller: usernameController,
//       keyboardType: TextInputType.text,
//       lableText: 'Username',
//       hintText: 'Enter Username',
//       prefixIcon: const Icon(Icons.verified_user_outlined),
//       suffixIcon: const SizedBox(),
//       obscureText: false,
//       textInputAction: TextInputAction.next,
//     );
//   }

//   Widget _buildUserDropdown() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 30.0),
//       padding: const EdgeInsets.symmetric(horizontal: 30.0),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.indigo, width: 1.0),
//         borderRadius: BorderRadius.circular(10.0),
//       ),
//       child: CustomLoginDropdown(
//         items: userItemsDropdownMenu,
//         value: selectedUser,
//         hintText: 'فضلا أختر إسم المستخدم',
//         onChanged: (value) {
//           setState(() => selectedUser = value);
//         },
//       ),
//     );
//   }

//   Widget _buildPasswordField() {
//     return CustomTextField(
//       controller: passwordController,
//       keyboardType: TextInputType.text,
//       lableText: 'Password',
//       hintText: 'Enter Password',
//       prefixIcon: const Icon(Icons.password),
//       suffixIcon: const Icon(Icons.visibility),
//       obscureText: true,
//       textInputAction: TextInputAction.done,
//     );
//   }

//   Widget _buildLoginButton() {
//     return selectedOption == '0' ||
//             selectedOption == '1' ||
//             selectedOption == '4'
//         ? CustomElevatedButton(
//             textString: 'Login',
//             onPressed: () => handleLogin(context),
//           )
//         : CustomElevatedButton(
//             textString: 'Login',
//             onPressed: () => handleLoginWithDropDown(context),
//           );
//   }
// }
// ignore_for_file: must_be_immutable, library_private_types_in_public_api

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:emergency_room/custom_widget/custom_circle_avatar.dart';
import 'package:emergency_room/custom_widget/custom_dropdown_menu.dart';
import 'package:emergency_room/custom_widget/custom_elevated_button.dart';
import 'package:emergency_room/custom_widget/custom_login_drop_down_menu.dart';
import 'package:emergency_room/custom_widget/custom_radio_button.dart';
import 'package:emergency_room/custom_widget/custom_text_field.dart';
import 'package:emergency_room/custom_widget/no_internet_widget.dart';
import 'package:emergency_room/custom_widget/offline_banner.dart';
import 'package:emergency_room/utils/app_constants.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../network/remote/remote_network_repos.dart';
import '../services/connectivity_service.dart';

class CustomizLoginScreenBody extends StatefulWidget {
  const CustomizLoginScreenBody({
    super.key,
  });

  @override
  State<CustomizLoginScreenBody> createState() =>
      _CustomizLoginScreenBodyState();
}

class _CustomizLoginScreenBodyState extends State<CustomizLoginScreenBody> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  List<dynamic> userList = [];

  // --- Internet connection state ---
  bool _isLoading = true;
  bool _isOnline = true;
  bool _isOnlineChecked = false;
  bool _hasInitialData = false;

  // --- Login state ---
  bool _isLoggingIn = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? selectedHandasah;
  String selectedOption = '3'; // Default to 'فنى هندسة' for mobile
  String? roleLabel = 'فنى هندسة';

  // Full options list
  final List<RadioOption<String>> _fullOptions = [
    RadioOption(label: 'فنى هندسة', value: '3'),
    RadioOption(label: 'مديرى الهندسة', value: '2'),
    RadioOption(label: 'الطوارئ المتحركة', value: '4'),
    RadioOption(label: 'غرفة الطوارىء', value: '1'),
    RadioOption(label: 'وزارة الإسكان', value: '0'),
  ];

  // Mobile-only options list
  final List<RadioOption<String>> _mobileOptions = [
    RadioOption(label: 'فنى هندسة', value: '3'),
  ];

  List<String> handasatItemsDropdownMenu = [];
  List<String> userItemsDropdownMenu = [];
  String? selectedUser;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Check internet first
    final online = await ConnectivityService.instance.hasConnection();
    if (!mounted) return;
    setState(() {
      _isOnline = online;
      _isOnlineChecked = true;
    });

    if (!online) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });
    await fetchHandasatItems();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _hasInitialData = true;
    });
  }

  Future<void> fetchHandasatItems() async {
    try {
      final List<dynamic> items =
          await DioNetworkRepos().fetchHandasatItemsDropdownMenu();
      if (!mounted) return;
      setState(() {
        handasatItemsDropdownMenu = items.map((e) => e.toString()).toList();
        if (handasatItemsDropdownMenu.isNotEmpty) {
          selectedHandasah = handasatItemsDropdownMenu.first;
        }
      });
    } catch (e) {
      log("Error fetching dropdown items: $e");
      // Check if internet is still available
      final online = await ConnectivityService.instance.hasConnection();
      if (!mounted) return;
      setState(() {
        _isOnline = online;
      });
      if (!online) {
        // Don't show error for no internet, banner will handle it
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ في تحميل البيانات: $e',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchUsersForSelectedHandasah() async {
    if (selectedHandasah == null) return;

    // Check internet before API call
    final online = await ConnectivityService.instance.hasConnection();
    if (!online) {
      setState(() {
        _isOnline = false;
        _isOnlineChecked = true;
      });
      return;
    }

    try {
      List<dynamic> fetchedUsers = [];
      switch (selectedOption) {
        case '2':
          fetchedUsers = await DioNetworkRepos()
              .fetchLoginUsersItemsDropdownMenu(2, selectedHandasah!);
          break;
        case '3':
          fetchedUsers = await DioNetworkRepos()
              .fetchLoginUsersItemsDropdownMenu(3, selectedHandasah!);
          break;
      }

      if (!mounted) return;

      setState(() {
        userItemsDropdownMenu = fetchedUsers.map((e) => e.toString()).toList();
        selectedUser = userItemsDropdownMenu.isNotEmpty
            ? userItemsDropdownMenu.first
            : null;
      });
    } catch (e) {
      log('Error fetching users: $e');
      final onlineAgain = await ConnectivityService.instance.hasConnection();
      if (!mounted) return;
      setState(() {
        _isOnline = onlineAgain;
      });
      if (!onlineAgain) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ في تحميل المستخدمين: $e',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _performLogin() {
    if (selectedOption == '0' ||
        selectedOption == '1' ||
        selectedOption == '4') {
      handleLogin(context);
    } else {
      handleLoginWithDropDown(context);
    }
  }

  void handleLogin(BuildContext context) async {
    // Check internet before login
    final online = await ConnectivityService.instance.hasConnection();
    if (!online) {
      setState(() {
        _isOnline = false;
        _isOnlineChecked = true;
      });
      showSnackBar('لا يوجد إتصال بالإنترنت');
      return;
    }

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      showSnackBar('يرجى إدخال اسم المستخدم وكلمة المرور');
      return;
    }

    if (_isLoggingIn) return;

    setState(() {
      _isLoggingIn = true;
      _isLoading = true;
    });

    try {
      final response = await DioNetworkRepos().login(username, password);

      if (!context.mounted) return;

      setState(() {
        _isLoggingIn = false;
        _isLoading = false;
      });

      if (response['success'] == true) {
        handleSuccessfulLogin(context);
      } else {
        showSnackBar(
            'فشل تسجيل الدخول: ${response['message'] ?? 'بيانات غير صحيحة'}');
      }
    } catch (e) {
      log("Login error: $e");
      if (!context.mounted) return;
      setState(() {
        _isLoggingIn = false;
        _isLoading = false;
      });
      // Check if internet was lost during login
      final onlineAgain = await ConnectivityService.instance.hasConnection();
      setState(() {
        _isOnline = onlineAgain;
      });
      if (!onlineAgain) {
        showSnackBar('لا يوجد إتصال بالإنترنت');
        return;
      }
      showSnackBar('حدث خطأ أثناء تسجيل الدخول: $e');
    }
  }

  void handleLoginWithDropDown(BuildContext context) async {
    // Check internet before login
    final online = await ConnectivityService.instance.hasConnection();
    if (!online) {
      setState(() {
        _isOnline = false;
        _isOnlineChecked = true;
      });
      showSnackBar('لا يوجد إتصال بالإنترنت');
      return;
    }

    final password = passwordController.text.trim();

    if (selectedUser == null || password.isEmpty) {
      showSnackBar('يرجى اختيار المستخدم وإدخال كلمة المرور');
      return;
    }

    if (_isLoggingIn) return;

    setState(() {
      _isLoggingIn = true;
      _isLoading = true;
    });

    try {
      final response = await DioNetworkRepos().login(selectedUser!, password);

      if (!context.mounted) return;

      setState(() {
        _isLoggingIn = false;
        _isLoading = false;
      });

      if (response['success'] == true) {
        handleSuccessfulLogin(context);
      } else {
        showSnackBar(
            'فشل تسجيل الدخول: ${response['message'] ?? 'بيانات غير صحيحة'}');
      }
    } catch (e) {
      log("Login error: $e");
      if (!context.mounted) return;
      setState(() {
        _isLoggingIn = false;
        _isLoading = false;
      });
      final onlineAgain = await ConnectivityService.instance.hasConnection();
      setState(() {
        _isOnline = onlineAgain;
      });
      if (!onlineAgain) {
        showSnackBar('لا يوجد إتصال بالإنترنت');
        return;
      }
      showSnackBar('حدث خطأ أثناء تسجيل الدخول: $e');
    }
  }

  void handleSuccessfulLogin(BuildContext context) {
    showSnackBar('تم تسجيل الدخول بنجاح');

    // Small delay to show the success message before navigation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!context.mounted) return;

      switch (StaticVariables.userRole) {
        case 0:
          context.go('/centeral-emergency');
          break;
        case 1:
          context.go('/emergency');
          break;
        case 2:
          context.go('/handasah');
          break;
        case 3:
          context.go('/technician');
          break;
        case 4:
          context.go('/mobile-emergency-room');
          break;
        default:
          showSnackBar('فضلا, أدخل البيانات الصحيحة');
      }
    });
  }

  void showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
        ),
        backgroundColor: message.contains('نجاح') ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = !kIsWeb && (screenWidth < 600);

    // Determine if we should show NoInternetWidget
    final showNoInternet = !_isOnline && !_hasInitialData && _isOnlineChecked;

    return Scaffold(
      body: Column(
        children: [
          OfflineBanner(visible: !_isOnline && _isOnlineChecked),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.indigo),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'جاري تحميل البيانات...',
                          style: TextStyle(
                            color: Colors.indigo,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : showNoInternet
                    ? NoInternetWidget(
                        onRetry: () {
                          setState(() {
                            _isLoading = true;
                            _hasInitialData = false;
                          });
                          _initializeData();
                        },
                      )
                    : Center(
                        child: SingleChildScrollView(
                          child: Container(
                            width: screenWidth > 600 ? 600 : screenWidth * 0.9,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CustomCircleAvatar(
                                  imgString: 'assets/logo.png',
                                  width: 100,
                                  height: 100,
                                  radius: 100,
                                ),
                                const SizedBox(height: 20),

                                // Role selection section
                                if (isMobile)
                                  _buildMobileRoleSelection()
                                else
                                  _buildWebRoleSelection(),

                                const SizedBox(height: 20),

                                // Login form
                                Card(
                                  color: Colors.blueGrey.shade50,
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      children: [
                                        // Username field or user dropdown
                                        selectedOption == '0' ||
                                                selectedOption == '1' ||
                                                selectedOption == '4'
                                            ? _buildUsernameField()
                                            : _buildUserDropdown(),

                                        const SizedBox(height: 16),

                                        // Password field
                                        _buildPasswordField(),

                                        const SizedBox(height: 24),

                                        // Login button
                                        _buildLoginButton(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileRoleSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Engineering dropdown for mobile
          if (selectedOption == '3' || selectedOption == '2')
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.indigo, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: CustomDropdown(
                  isExpanded: true,
                  items: handasatItemsDropdownMenu,
                  hintText: 'اختر الهندسة',
                  value: selectedHandasah,
                  onChanged: (value) async {
                    setState(() => selectedHandasah = value);
                    await fetchUsersForSelectedHandasah();
                  },
                ),
              ),
            ),
          const SizedBox(width: 10),
          // Radio button for mobile (single option)
          Expanded(
            flex: 2,
            child: CustomRadioButton<String>(
              options: _mobileOptions,
              initialValue: '3',
              onChanged: (value) {
                setState(() {
                  selectedOption = value!;
                  roleLabel = 'فنى هندسة';
                });
              },
              direction: Axis.horizontal,
              spacing: 13.0,
              activeColor: Colors.indigo,
              inactiveColor: Colors.grey[600],
              textStyle: const TextStyle(fontSize: 11, color: Colors.indigo),
              radioSize: 15.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebRoleSelection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: CustomRadioButton<String>(
              options: _fullOptions,
              initialValue: '3',
              onChanged: (value) {
                setState(() {
                  selectedOption = value!;
                  switch (selectedOption) {
                    case '0':
                      roleLabel = 'وزارة الإسكان';
                      break;
                    case '1':
                      roleLabel = 'غرفة الطوارىء';
                      break;
                    case '2':
                      roleLabel = 'مديرى الهندسة';
                      break;
                    case '3':
                      roleLabel = 'فنى هندسة';
                      break;
                    case '4':
                      roleLabel = 'الطوارئ المتحركة';
                      break;
                  }
                  // Reset selections when role changes
                  selectedHandasah = null;
                  selectedUser = null;
                  userItemsDropdownMenu = [];
                });
                // Call fetchHandasatItems without expecting a return value
                if (selectedOption == '2' || selectedOption == '3') {
                  fetchHandasatItems();
                }
              },
              direction: Axis.horizontal,
              spacing: 13.0,
              activeColor: Colors.indigo,
              inactiveColor: Colors.grey[600],
              textStyle: const TextStyle(fontSize: 11, color: Colors.indigo),
              radioSize: 15.0,
            ),
          ),
        ),
        // Engineering dropdown for web
        if (selectedOption == '3' || selectedOption == '2')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 150.0),
            child: Container(
              margin: const EdgeInsets.all(3.0),
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.indigo, width: 1.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: CustomDropdown(
                isExpanded: true,
                items: handasatItemsDropdownMenu,
                hintText: 'فضلا أختر الهندسة',
                value: selectedHandasah,
                onChanged: (value) async {
                  setState(() => selectedHandasah = value);
                  await fetchUsersForSelectedHandasah();
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return CustomTextField(
      controller: usernameController,
      keyboardType: TextInputType.text,
      lableText: 'اسم المستخدم',
      hintText: 'أدخل اسم المستخدم',
      prefixIcon: const Icon(Icons.verified_user_outlined),
      suffixIcon: const SizedBox(),
      obscureText: false,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildUserDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30.0),
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.indigo, width: 1.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: CustomLoginDropdown(
        items: userItemsDropdownMenu,
        value: selectedUser,
        hintText: 'فضلا أختر إسم المستخدم',
        onChanged: (value) {
          setState(() => selectedUser = value);
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return CustomTextField(
      controller: passwordController,
      keyboardType: TextInputType.text,
      lableText: 'كلمة المرور',
      hintText: 'أدخل كلمة المرور',
      prefixIcon: const Icon(Icons.password),
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility : Icons.visibility_off,
          color: Colors.grey,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildLoginButton() {
    // Determine which login method to use
    final isDirectLogin =
        selectedOption == '0' || selectedOption == '1' || selectedOption == '4';

    // Create the onPressed callback - always provide a function
    // If logging in, provide an empty function to disable the button
    VoidCallback onPressed;
    if (_isLoggingIn) {
      // Button is disabled during login - provide empty function
      onPressed = () {};
    } else {
      onPressed = isDirectLogin
          ? () => handleLogin(context)
          : () => handleLoginWithDropDown(context);
    }

    return CustomElevatedButton(
      textString: _isLoggingIn ? 'جاري تسجيل الدخول...' : 'تسجيل الدخول',
      onPressed: onPressed,
    );
  }
}
