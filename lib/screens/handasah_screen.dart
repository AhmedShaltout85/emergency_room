// // ignore_for_file: use_build_context_synchronously

// import 'dart:async';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:go_router/go_router.dart';
// import 'package:emergency_room/custom_widget/custom_alert_dialog_create_handasah_users.dart';
// import 'package:emergency_room/custom_widget/custom_handasah_assign_user.dart';

// import 'package:emergency_room/utils/app_constants.dart';
// import 'package:emergency_room/custom_widget/custom_web_view_iframe.dart';
// import 'package:audioplayers/audioplayers.dart'; // Add this import

// import '../custom_widget/custom_bottom_sheet.dart';
// import '../custom_widget/custom_reusable_alert_dailog.dart';
// import '../custom_widget/cutom_texts_alert_dailog.dart';
// import '../network/remote/remote_network_repos.dart';

// class HandasahScreen extends StatefulWidget {
//   const HandasahScreen({super.key});

//   @override
//   State<HandasahScreen> createState() => _HandasahScreenState();
// }

// class _HandasahScreenState extends State<HandasahScreen> {
//   late Future getLocsByHandasahNameAndIsFinished;
//   late Future getLocByHandasahAndTechnician;
//   String handasahName = StaticVariables.handasahName;
//   String gisHandasahUrl = "";
//   late Future getHandasatUsersItemsDropdownMenu;
//   List<String> handasatUsersItemsDropdownMenu = [];
//   double fontSize = 12.0;
//   String storeName = "";
//   Timer? _timer;
//   int length = 0;
//   int previousLength = 0; // Track previous length for comparison
//   final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player for sound

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//     _startPeriodicFetch();
//     _loadSound(); // Preload the sound
//     _loadStoreQty(); //Load store qty
//   }

//   Future<void> _loadSound() async {
//     // You can use a local asset or a network URL for the sound
//     // For local asset: add the sound file to your assets and update pubspec.yaml
//     await _audioPlayer.setSource(
//         AssetSource('sounds/alarm.mp3')); // Replace with your sound file
//   }

//   void _initializeData() {
//     setState(() {
//       getLocsByHandasahNameAndIsFinished =
//           DioNetworkRepos().getLocByHandasahAndIsFinished(handasahName, 0);
//       getLocByHandasahAndTechnician =
//           DioNetworkRepos().getLocByHandasahAndTechnician(handasahName, 'free');
//     });

//     // Initialize previous length
//     getLocByHandasahAndTechnician.then((value) {
//       previousLength = value.length;
//     });

//     // Initialize handasat users dropdown
//     getHandasatUsersItemsDropdownMenu =
//         DioNetworkRepos().fetchHandasatUsersItemsDropdownMenu(handasahName);
//     getHandasatUsersItemsDropdownMenu.then((value) {
//       handasatUsersItemsDropdownMenu = List<String>.from(value);
//     });
//   }

//   void _startPeriodicFetch() {
//     const Duration fetchInterval = Duration(seconds: 10);
//     _timer = Timer.periodic(fetchInterval, (Timer timer) async {
//       final newData = await DioNetworkRepos()
//           .getLocByHandasahAndTechnician(handasahName, 'free');

//       // Check if new items were added
//       if (newData.length > previousLength) {
//         _playAlertSound(); // Play sound when new items are detected
//       }

//       setState(() {
//         previousLength = newData.length; // Update previous length
//         getLocsByHandasahNameAndIsFinished =
//             DioNetworkRepos().getLocByHandasahAndIsFinished(handasahName, 0);
//         getLocByHandasahAndTechnician = Future.value(newData);
//       });
//     });
//   }

//   Future<void> _playAlertSound() async {
//     try {
//       await _audioPlayer.stop(); // Stop any currently playing sound
//       await _audioPlayer.resume(); // Play the alert sound
//     } catch (e) {
//       log('Error playing sound: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _audioPlayer.dispose(); // Dispose the audio player
//     super.dispose();
//   }

//   //show bottom sheet Redirect to Handasat
//   void showCustomBottomSheet(
//       BuildContext context, String title, String message, String address) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: false, // Ensures it takes full width
//       builder: (context) {
//         return CustomBottomSheet(
//           title: title,
//           message: message,
//           hintText: "أختر فنى",
//           dropdownItems: handasatUsersItemsDropdownMenu,
//           onItemSelected: (value) {
//             log("Selected: $value");
//             setState(() {
//               DioNetworkRepos().updateLocAddTechnician(address, value);
//             });
//           },
//           onPressed: () async {
//             Navigator.of(context).pop();
//             // await DioNetworkRepos().updateLocAddTechnician(address, "free");
//           },
//         );
//       },
//     );
//   }

//   Future<void> _loadStoreQty() async {
//     await DioNetworkRepos()
//         .getStoreNameByHandasahName(handasahName)
//         .then((value) {
//       storeName = value['storeName'];
//     });
//     DioNetworkRepos().excuteTempStoreQty(storeName);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         elevation: 7,
//         foregroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Colors.indigo, size: 17),
//         title: Text(
//           StaticVariables.handasahName,
//           style: const TextStyle(color: Colors.indigo),
//         ),
//         actions: [
//           IconButton(
//             tooltip: "إضافة مشرف, وفنى الهندسة",
//             hoverColor: Colors.yellow,
//             icon: const Icon(Icons.person_add_alt, color: Colors.indigo),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) =>
//                     const CustomAlertDialogCreateHandasahUsers(
//                   title: 'إضافة مستخدمين لمديرى ومشرفى وفنين الهندسة',
//                 ),
//               );
//             },
//           ),
//           IconButton(
//             tooltip: "إضافه المهمات الخاصة بالهندسة",
//             hoverColor: Colors.yellow,
//             icon: const Icon(Icons.note_add_outlined, color: Colors.indigo),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) {
//                   return CustomReusableAlertDialog(
//                     title: "إضافة مهمات الهندسة",
//                     fieldLabels: const ['المسمى', 'العدد'],
//                     onSubmit: (values) {
//                       try {
//                         DioNetworkRepos().createNewHandasahTools(
//                             handasahName, values[0], int.parse(values[1]));
//                       } catch (e) {
//                         log(e.toString());
//                       }
//                     },
//                   );
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       body: Row(
//         children: [
//           Expanded(
//             flex: 1,
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//               width: 220,
//               height: MediaQuery.of(context).size.height,
//               color: Colors.black38,
//               child: CustomHandasahAssignUser(
//                 getLocs: getLocByHandasahAndTechnician,
//                 stringListItems: handasatUsersItemsDropdownMenu,
//                 onPressed: () {
//                   setState(() {
//                     getLocsByHandasahNameAndIsFinished = DioNetworkRepos()
//                         .getLocByHandasahAndIsFinished(handasahName, 0);
//                     getLocByHandasahAndTechnician = DioNetworkRepos()
//                         .getLocByHandasahAndTechnician(handasahName, 'free');
//                   });
//                 },
//                 hintText: 'فضلا أختار الفنى',
//                 title: 'تخصيص شكوى لفنى',
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: gisHandasahUrl == ""
//                   ? const Center(
//                       child: Text(
//                         'عرض رابط GIS',
//                         style: TextStyle(fontSize: 20, color: Colors.indigo),
//                       ),
//                     )
//                   // : Container(),
//                   : IframeScreen(url: gisHandasahUrl),
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//               width: 220,
//               height: MediaQuery.of(context).size.height,
//               color: Colors.black38,
//               child: ListView(
//                 shrinkWrap: true,
//                 children: [
//                   const SizedBox(
//                     height: 50,
//                     child: DrawerHeader(
//                       decoration: BoxDecoration(color: Colors.indigo),
//                       child: Text(
//                         textDirection: TextDirection.rtl,
//                         textAlign: TextAlign.center,
//                         "الشكاوى غير مغلقة الخاصة بالهندسة",
//                         style: TextStyle(color: Colors.white, fontSize: 12),
//                       ),
//                     ),
//                   ),
//                   FutureBuilder(
//                     future: getLocsByHandasahNameAndIsFinished,
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(
//                           child: Text('لايوجد شكاوى'),
//                         );
//                       } else if (snapshot.connectionState ==
//                           ConnectionState.done) {
//                         if (snapshot.hasError) {
//                           return const Center(
//                               child: Text('لا يوجد شكاوى مفتوحة'));
//                         } else if (snapshot.hasData) {
//                           length = snapshot.data!.length;
//                           return ListView.builder(
//                             reverse: true,
//                             shrinkWrap: true,
//                             itemCount: snapshot.data!.length,
//                             itemBuilder: (context, index) {
//                               return InkWell(
//                                 onTap: () {
//                                   if (snapshot.data![index]['gis_url'] ==
//                                       'free') {
//                                     //TODO:MAKE-TOAST
//                                     Fluttertoast.showToast(
//                                         msg: "لا يوجد رابط GIS Map",
//                                         toastLength: Toast.LENGTH_SHORT,
//                                         gravity: ToastGravity.CENTER,
//                                         timeInSecForIosWeb: 1,
//                                         backgroundColor: Colors.red,
//                                         textColor: Colors.white,
//                                         fontSize: 16.0);
//                                   } else {
//                                     setState(() {
//                                       gisHandasahUrl =
//                                           snapshot.data![index]['gis_url'];
//                                     });
//                                   }
//                                 },
//                                 child: Card(
//                                   child: Column(
//                                     children: [
//                                       ListTile(
//                                         title: Row(
//                                           children: [
//                                             IconButton(
//                                               tooltip: 'إعادة تخصيص فنى',
//                                               hoverColor: Colors.yellow,
//                                               icon: const Icon(
//                                                 Icons.edit,
//                                                 color: Colors.indigo,
//                                               ),
//                                               onPressed: () {
//                                                 //
//                                                 //display bottom sheet
//                                                 showCustomBottomSheet(
//                                                   context,
//                                                   "إعادة تخصيص فنى",
//                                                   snapshot.data![index]
//                                                       ['handasah_name'],
//                                                   snapshot.data![index]
//                                                       ['address'],
//                                                 );
//                                               },
//                                             ),
//                                             Expanded(
//                                               child: Text(
//                                                 textAlign: TextAlign.center,
//                                                 snapshot.data![index]
//                                                     ['address'],
//                                                 style: const TextStyle(
//                                                   color: Colors.indigo,
//                                                   fontSize: 12,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         subtitle: Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                             vertical: 7.0,
//                                             horizontal: 3.0,
//                                           ),
//                                           child: Column(
//                                             children: [
//                                               Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   Expanded(
//                                                     child: Container(
//                                                       margin:
//                                                           const EdgeInsets.all(
//                                                               3.0),
//                                                       padding: const EdgeInsets
//                                                           .symmetric(
//                                                           horizontal: 1.0),
//                                                       decoration: BoxDecoration(
//                                                         border: Border.all(
//                                                             color: Colors.green,
//                                                             width: 1.0),
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(5.0),
//                                                         color: Colors.green,
//                                                       ),
//                                                       child: Text(
//                                                         textAlign:
//                                                             TextAlign.center,
//                                                         "${snapshot.data![index]['handasah_name']}",
//                                                         style: TextStyle(
//                                                           fontSize: fontSize,
//                                                           color: Colors.white,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   snapshot.data![index][
//                                                               'technical_name'] ==
//                                                           "free"
//                                                       ? Expanded(
//                                                           child: Container(
//                                                             margin:
//                                                                 const EdgeInsets
//                                                                     .all(3.0),
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .symmetric(
//                                                                     horizontal:
//                                                                         3.0),
//                                                             decoration:
//                                                                 BoxDecoration(
//                                                               border: Border.all(
//                                                                   color: Colors
//                                                                       .orange,
//                                                                   width: 1.0),
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           5.0),
//                                                               color:
//                                                                   Colors.orange,
//                                                             ),
//                                                             child: Text(
//                                                               "قيد تخصيص فنى",
//                                                               style: TextStyle(
//                                                                 overflow:
//                                                                     TextOverflow
//                                                                         .visible,
//                                                                 fontSize:
//                                                                     fontSize,
//                                                                 color: Colors
//                                                                     .white,
//                                                               ),
//                                                               textAlign:
//                                                                   TextAlign
//                                                                       .center,
//                                                             ),
//                                                           ),
//                                                         )
//                                                       : Expanded(
//                                                           child: Container(
//                                                             margin:
//                                                                 const EdgeInsets
//                                                                     .all(3.0),
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .symmetric(
//                                                                     horizontal:
//                                                                         3.0),
//                                                             decoration:
//                                                                 BoxDecoration(
//                                                               border: Border.all(
//                                                                   color: Colors
//                                                                       .green,
//                                                                   width: 1.0),
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           5.0),
//                                                               color:
//                                                                   Colors.green,
//                                                             ),
//                                                             child: Text(
//                                                               textAlign:
//                                                                   TextAlign
//                                                                       .center,
//                                                               "${snapshot.data![index]['technical_name']}",
//                                                               style: TextStyle(
//                                                                 fontSize:
//                                                                     fontSize,
//                                                                 color: Colors
//                                                                     .white,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                 ],
//                                               ),
//                                               Row(
//                                                 children: [
//                                                   Expanded(
//                                                     child: snapshot.data![index]
//                                                                 [
//                                                                 'is_approved'] ==
//                                                             1
//                                                         ? Container(
//                                                             margin:
//                                                                 const EdgeInsets
//                                                                     .all(3.0),
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .symmetric(
//                                                                     horizontal:
//                                                                         3.0),
//                                                             decoration:
//                                                                 BoxDecoration(
//                                                               border: Border.all(
//                                                                   color: Colors
//                                                                       .green,
//                                                                   width: 1.0),
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           5.0),
//                                                               color:
//                                                                   Colors.green,
//                                                             ),
//                                                             child: Text(
//                                                               textAlign:
//                                                                   TextAlign
//                                                                       .center,
//                                                               'تم قبول الشكوى',
//                                                               style: TextStyle(
//                                                                 fontSize:
//                                                                     fontSize,
//                                                                 color: Colors
//                                                                     .white,
//                                                               ),
//                                                             ),
//                                                           )
//                                                         : Container(
//                                                             margin:
//                                                                 const EdgeInsets
//                                                                     .all(3.0),
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .symmetric(
//                                                                     horizontal:
//                                                                         3.0),
//                                                             decoration:
//                                                                 BoxDecoration(
//                                                               border: Border.all(
//                                                                   color: Colors
//                                                                       .orange,
//                                                                   width: 1.0),
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           5.0),
//                                                               color:
//                                                                   Colors.orange,
//                                                             ),
//                                                             child: Text(
//                                                               textAlign:
//                                                                   TextAlign
//                                                                       .center,
//                                                               'قيد قبول الشكوى',
//                                                               style: TextStyle(
//                                                                 fontSize:
//                                                                     fontSize,
//                                                                 color: Colors
//                                                                     .white,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           IconButton(
//                                             tooltip: 'إبلاغ كسورات معامل',
//                                             hoverColor: Colors.yellow,
//                                             onPressed: () {},
//                                             icon: const Icon(
//                                                 Icons.report_gmailerrorred,
//                                                 color: Colors.purple),
//                                           ),
//                                           IconButton(
//                                             tooltip: 'مهمات مخازن مطلوبة',
//                                             hoverColor: Colors.yellow,
//                                             onPressed: () {
//                                               // Navigator.push(
//                                               //   context,
//                                               //   MaterialPageRoute(
//                                               //     builder: (context) =>
//                                               //         RequestToolForAddressScreen(
//                                               //       address:
//                                               //           snapshot.data![index]
//                                               //               ['address'],
//                                               //       handasahName:
//                                               //           snapshot.data![index]
//                                               //               ['handasah_name'],
//                                               //     ),
//                                               //   ),
//                                               // );
//                                               context.go(
//                                                   '/request-tool-address/${snapshot.data![index]['address']}/${snapshot.data![index]['handasah_name']}');
//                                             },
//                                             icon: const Icon(Icons.store_sharp,
//                                                 color: Colors.cyan),
//                                           ),
//                                           IconButton(
//                                             tooltip: 'جرد مخزن',
//                                             hoverColor: Colors.yellow,
//                                             onPressed: () async {
//                                               //  TODO://update store qty not tested

//                                               // await DioNetworkRepos()
//                                               //     .getStoreNameByHandasahName(
//                                               //         snapshot.data![index]
//                                               //             ['handasah_name'])
//                                               //     .then((value) {
//                                               //   storeName = value['storeName'];
//                                               // });
//                                               // DioNetworkRepos()
//                                               //     .excuteTempStoreQty(
//                                               //         storeName);
//                                               // Navigator.push(
//                                               //   context,
//                                               //   MaterialPageRoute(
//                                               //     builder: (context) =>
//                                               //         IntegrationWithStoresGetAllQty(
//                                               //       storeName: storeName,
//                                               //     ),
//                                               //   ),
//                                               // );
//                                               context.go(
//                                                   '/integrate-with-stores/$storeName');
//                                             },
//                                             icon: const Icon(
//                                                 Icons.store_outlined,
//                                                 color: Colors.indigo),
//                                           ),
//                                           IconButton(
//                                             tooltip: 'عرض بيانات الشكوى',
//                                             hoverColor: Colors.yellow,
//                                             onPressed: () {
//                                               showDialog(
//                                                 context: context,
//                                                 builder: (context) =>
//                                                     CustomReusableTextAlertDialog(
//                                                   title: 'بيانات العطل',
//                                                   messages: [
//                                                     'العنوان :  ${snapshot.data[index]['address']}',
//                                                     'الاحداثئات :  ${snapshot.data[index]['latitude']} , ${snapshot.data[index]['longitude']}',
//                                                     'الهندسة :  ${snapshot.data[index]['handasah_name']}',
//                                                     snapshot.data![index][
//                                                                 'technical_name'] ==
//                                                             "free"
//                                                         ? 'اسم فنى الهندسة: لم يتم تعيين فنى الهندسة'
//                                                         : 'إسم فنى الهندسة :  ${snapshot.data![index]['technical_name']}',
//                                                     'رابط :  ${snapshot.data[index]['gis_url']}',
//                                                     'إسم المبلغ :  ${snapshot.data[index]['caller_name']}',
//                                                     ' رقم هاتف المبلغ:  ${snapshot.data[index]['caller_phone']}',
//                                                     'نوع الكسر :  ${snapshot.data[index]['broker_type']}',
//                                                   ],
//                                                   actions: [
//                                                     Align(
//                                                       alignment:
//                                                           Alignment.bottomLeft,
//                                                       child: TextButton(
//                                                         onPressed: () =>
//                                                             Navigator.of(
//                                                                     context)
//                                                                 .pop(),
//                                                         child:
//                                                             const Text('Close'),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               );
//                                             },
//                                             icon: const Icon(Icons.info,
//                                                 color: Colors.blueAccent),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                             physics: const NeverScrollableScrollPhysics(),
//                           );
//                         } else {
//                           return const Center(
//                               child: Text('لايوجد شكاوى مفتوحة'));
//                         }
//                       } else {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// // ignore_for_file: use_build_context_synchronously

// import 'dart:async';
// import 'dart:developer';
// import 'package:emergency_room/screens/emeregency_room/controller/complaint_provider.dart';
// import 'package:emergency_room/screens/emeregency_room/model/complaint_model.dart';
// import 'package:emergency_room/screens/emeregency_room/repo/complaint_repo.dart';
// import 'package:emergency_room/screens/manage_system/control/handasah_provider.dart';
// import 'package:emergency_room/screens/manage_system/repo/handasah_repo.dart';
// import 'package:emergency_room/screens/manage_system/repo/users_repo.dart';
// import 'package:emergency_room/utils/center_toast.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import 'package:emergency_room/custom_widget/custom_alert_dialog_create_handasah_users.dart';

// import 'package:emergency_room/utils/app_constants.dart';
// import 'package:emergency_room/custom_widget/custom_web_view_iframe.dart';
// import 'package:audioplayers/audioplayers.dart'; // Add this import

// // ── manage_system data layer (model / repo / provider) ───────────────────

// import '../custom_widget/custom_bottom_sheet.dart';
// import '../custom_widget/custom_reusable_alert_dailog.dart';
// import '../custom_widget/cutom_texts_alert_dailog.dart';
// import '../network/remote/remote_network_repos.dart';

// class HandasahScreen extends StatefulWidget {
//   const HandasahScreen({super.key});

//   @override
//   State<HandasahScreen> createState() => _HandasahScreenState();
// }

// class _HandasahScreenState extends State<HandasahScreen> {
//   // ── Data layer ───────────────────────────────────────────────────────────
//   // Open complaints for ALL handasat are loaded into this provider; this
//   // screen shows the ones sent to [handasahName]. sortNewestFirst is false so
//   // the list keeps the server's order (the lists below use `reverse: true`,
//   // exactly like before).
//   final ComplaintProvider _complaints = ComplaintProvider(
//     ComplaintRepo(),
//     sortNewestFirst: false,
//   );
//   final HandasahRepo _handasahRepo = HandasahRepo();
//   final UsersRepo _usersRepo = UsersRepo();

//   String handasahName = StaticVariables.handasahName;
//   String gisHandasahUrl = "";
//   List<String> handasatUsersItemsDropdownMenu = [];
//   double fontSize = 12.0;
//   String storeName = "";
//   Timer? _timer;
//   int length = 0;
//   int previousLength = 0; // Track previous length for comparison
//   final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player for sound

//   /// Technician picked in each "unassigned complaint" card (by complaintId).
//   final Map<int, String> _selectedTechnician = {};

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//     _startPeriodicFetch();
//     _loadSound(); // Preload the sound
//     _loadStoreQty(); //Load store qty
//   }

//   Future<void> _loadSound() async {
//     // You can use a local asset or a network URL for the sound
//     // For local asset: add the sound file to your assets and update pubspec.yaml
//     await _audioPlayer.setSource(
//         AssetSource('sounds/alarm.mp3')); // Replace with your sound file
//   }

//   Future<void> _initializeData() async {
//     // Open complaints (all handasat) → ComplaintProvider
//     await _complaints.loadByFinished(false);
//     if (!mounted) return;

//     // Initialize previous length (unassigned complaints of this handasah)
//     previousLength = _complaints.unassignedComplaintsFor(handasahName).length;

//     // Initialize handasat users (technicians) dropdown:
//     // GET /users/role/3/control-unit/{handasahName}
//     try {
//       final names =
//           await _usersRepo.getNamesByRoleAndControlUnit(3, handasahName);
//       if (!mounted) return;
//       setState(() {
//         handasatUsersItemsDropdownMenu = List<String>.from(names);
//       });
//     } catch (e) {
//       log('Error loading technicians: $e');
//     }
//   }

//   void _startPeriodicFetch() {
//     const Duration fetchInterval = Duration(seconds: 10);
//     _timer = Timer.periodic(fetchInterval, (Timer timer) async {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }

//       await _complaints.loadByFinished(false);
//       if (!mounted) return;
//       // A failed refresh keeps the last good list; try again next tick.
//       if (_complaints.state == LoadState.error) return;

//       final newLength =
//           _complaints.unassignedComplaintsFor(handasahName).length;

//       // Check if new items were added
//       if (newLength > previousLength) {
//         _playAlertSound(); // Play sound when new items are detected
//       }
//       previousLength = newLength; // Update previous length
//     });
//   }

//   Future<void> _playAlertSound() async {
//     try {
//       await _audioPlayer.stop(); // Stop any currently playing sound
//       await _audioPlayer.resume(); // Play the alert sound
//     } catch (e) {
//       log('Error playing sound: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _audioPlayer.dispose(); // Dispose the audio player
//     _complaints.dispose();
//     super.dispose();
//   }

//   // ── Small helpers ────────────────────────────────────────────────────────

//   // void _toast(String msg, {Color color = Colors.red}) {
//   //   Fluttertoast.showToast(
//   //     msg: msg,
//   //     toastLength: Toast.LENGTH_SHORT,
//   //     gravity: ToastGravity.CENTER,
//   //     timeInSecForIosWeb: 1,
//   //     backgroundColor: color,
//   //     textColor: Colors.white,
//   //     fontSize: 16.0,
//   //   );
//   // }
//   void _toast(String msg, {Color color = Colors.red}) {
//     if (!mounted) return;
//     showCenterToast(context, msg, color: color);
//   }

//   /// Shows the provider's last failure message (Arabic) as a red toast.
//   void _showFailure() {
//     if (!mounted) return;
//     _toast(_complaints.failure?.message ?? 'تعذر تنفيذ العملية');
//   }

//   /// Assigns (or re-assigns) a technician through ComplaintProvider
//   /// (PUT /complaints/{id}/recipient). The technician is `recipientUser`.
//   Future<void> _assignTechnician(
//     ComplaintModel complaint,
//     String technician,
//   ) async {
//     final ok = await _complaints.setRecipient(
//       complaint,
//       recipientName: complaint.recipientName,
//       recipientUser: technician,
//     );
//     if (!mounted) return;
//     if (ok) {
//       _toast('تم تخصيص الفنى', color: Colors.green);
//     } else {
//       _showFailure();
//     }
//   }

//   //show bottom sheet Redirect to Handasat
//   void showCustomBottomSheet(
//     BuildContext context,
//     String title,
//     String message,
//     ComplaintModel complaint,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: false, // Ensures it takes full width
//       builder: (context) {
//         return CustomBottomSheet(
//           title: title,
//           message: message,
//           hintText: "أختر فنى",
//           dropdownItems: handasatUsersItemsDropdownMenu,
//           onItemSelected: (value) {
//             log("Selected: $value");
//             _assignTechnician(complaint, value!);
//           },
//           onPressed: () async {
//             Navigator.of(context).pop();
//           },
//         );
//       },
//     );
//   }

//   Future<void> _loadStoreQty() async {
//     try {
//       final handasah = await _handasahRepo.findByName(handasahName);
//       storeName = handasah.storeName;
//     } catch (e) {
//       log('Error loading store name: $e');
//     }
//     DioNetworkRepos().excuteTempStoreQty(storeName);
//   }

//   /// The small coloured status pill used on every card.
//   Widget _statusBadge(
//     String text,
//     Color color, {
//     double horizontalPadding = 3.0,
//     bool overflowVisible = false,
//   }) {
//     return Container(
//       margin: const EdgeInsets.all(3.0),
//       padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
//       decoration: BoxDecoration(
//         border: Border.all(color: color, width: 1.0),
//         borderRadius: BorderRadius.circular(5.0),
//         color: color,
//       ),
//       child: Text(
//         text,
//         textAlign: TextAlign.center,
//         style: TextStyle(
//           overflow: overflowVisible ? TextOverflow.visible : null,
//           fontSize: fontSize,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }

//   // ── Right panel: open complaints of this handasah ────────────────────────

//   Widget _buildComplaintCard(BuildContext context, ComplaintModel item) {
//     final bool hasTechnician =
//         !ComplaintProvider.isFreeTechnician(item.recipientUser);

//     return InkWell(
//       onTap: () {
//         final link = item.gisLink.trim();
//         if (link.isEmpty || link == 'لم يدرج' || link == 'free') {
//           //TODO:MAKE-TOAST
//           _toast("لا يوجد رابط GIS Map");
//         } else {
//           setState(() {
//             gisHandasahUrl = item.gisLink;
//           });
//         }
//       },
//       child: Card(
//         child: Column(
//           children: [
//             ListTile(
//               title: Row(
//                 children: [
//                   IconButton(
//                     tooltip: 'إعادة تخصيص فنى',
//                     hoverColor: Colors.yellow,
//                     icon: const Icon(
//                       Icons.edit,
//                       color: Colors.indigo,
//                     ),
//                     onPressed: () {
//                       //display bottom sheet
//                       showCustomBottomSheet(
//                         context,
//                         "إعادة تخصيص فنى",
//                         item.recipientDestination,
//                         item,
//                       );
//                     },
//                   ),
//                   Expanded(
//                     child: Text(
//                       textAlign: TextAlign.center,
//                       item.complaintAddress,
//                       style: const TextStyle(
//                         color: Colors.indigo,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               subtitle: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 7.0,
//                   horizontal: 3.0,
//                 ),
//                 child: Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: _statusBadge(
//                             item.recipientDestination,
//                             Colors.green,
//                             horizontalPadding: 1.0,
//                           ),
//                         ),
//                         Expanded(
//                           child: hasTechnician
//                               ? _statusBadge(item.recipientUser, Colors.green)
//                               : _statusBadge(
//                                   'قيد تخصيص فنى',
//                                   Colors.orange,
//                                   overflowVisible: true,
//                                 ),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: item.isTracked == 1
//                               ? _statusBadge('تم قبول الشكوى', Colors.green)
//                               : _statusBadge('قيد قبول الشكوى', Colors.orange),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 IconButton(
//                   tooltip: 'إبلاغ كسورات معامل',
//                   hoverColor: Colors.yellow,
//                   onPressed: () {},
//                   icon: const Icon(Icons.report_gmailerrorred,
//                       color: Colors.purple),
//                 ),
//                 IconButton(
//                   tooltip: 'مهمات مخازن مطلوبة',
//                   hoverColor: Colors.yellow,
//                   onPressed: () {
//                     context.go(
//                         '/request-tool-address/${item.complaintAddress}/${item.recipientDestination}');
//                   },
//                   icon: const Icon(Icons.store_sharp, color: Colors.cyan),
//                 ),
//                 IconButton(
//                   tooltip: 'جرد مخزن',
//                   hoverColor: Colors.yellow,
//                   onPressed: () async {
//                     //  TODO://update store qty not tested
//                     context.go('/integrate-with-stores/$storeName');
//                   },
//                   icon: const Icon(Icons.store_outlined, color: Colors.indigo),
//                 ),
//                 IconButton(
//                   tooltip: 'عرض بيانات الشكوى',
//                   hoverColor: Colors.yellow,
//                   onPressed: () {
//                     showDialog(
//                       context: context,
//                       builder: (context) => CustomReusableTextAlertDialog(
//                         title: 'بيانات العطل',
//                         messages: [
//                           'العنوان :  ${item.complaintAddress}',
//                           'الاحداثئات :  ${item.latitude} , ${item.longitude}',
//                           'الهندسة :  ${item.recipientDestination}',
//                           hasTechnician
//                               ? 'إسم فنى الهندسة :  ${item.recipientUser}'
//                               : 'اسم فنى الهندسة: لم يتم تعيين فنى الهندسة',
//                           'رابط :  ${item.gisLink}',
//                           'إسم المبلغ :  ${item.reporterName}',
//                           ' رقم هاتف المبلغ:  ${item.reporterPhone}',
//                           'نوع الكسر :  ${item.complaintType}',
//                         ],
//                         actions: [
//                           Align(
//                             alignment: Alignment.bottomLeft,
//                             child: TextButton(
//                               onPressed: () => Navigator.of(context).pop(),
//                               child: const Text('Close'),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                   icon: const Icon(Icons.info, color: Colors.blueAccent),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Left panel: assign a technician to complaints without one ────────────
//   // This replaces CustomHandasahAssignUser, which assigned through the old
//   // locations API. Assignment now goes through ComplaintProvider.setRecipient.

//   Widget _buildUnassignedCard(BuildContext context, ComplaintModel item) {
//     final id = item.complaintId;
//     final String? selected = id == null ? null : _selectedTechnician[id];
//     final bool canAssign =
//         id != null && selected != null && !_complaints.isBusy;

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(6.0),
//         child: Column(
//           children: [
//             Text(
//               item.complaintAddress,
//               textAlign: TextAlign.center,
//               textDirection: TextDirection.rtl,
//               style: const TextStyle(
//                 color: Colors.indigo,
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 4),
//             DropdownButton<String>(
//               isExpanded: true,
//               value: handasatUsersItemsDropdownMenu.contains(selected)
//                   ? selected
//                   : null,
//               hint: const Text(
//                 'فضلا أختار الفنى',
//                 textDirection: TextDirection.rtl,
//                 style: TextStyle(fontSize: 12),
//               ),
//               items: handasatUsersItemsDropdownMenu
//                   .map(
//                     (name) => DropdownMenuItem<String>(
//                       value: name,
//                       child: Text(
//                         name,
//                         textDirection: TextDirection.rtl,
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                     ),
//                   )
//                   .toList(),
//               onChanged: (value) {
//                 if (id == null || value == null) return;
//                 setState(() => _selectedTechnician[id] = value);
//               },
//             ),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: canAssign
//                     ? () async {
//                         await _assignTechnician(item, selected);
//                         if (mounted) {
//                           setState(() => _selectedTechnician.remove(id));
//                         }
//                       }
//                     : null,
//                 icon: const Icon(Icons.person_add_alt, size: 16),
//                 label: const Text('تخصيص', style: TextStyle(fontSize: 12)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider<ComplaintProvider>.value(
//       value: _complaints,
//       child: Scaffold(
//         appBar: AppBar(
//           centerTitle: true,
//           elevation: 7,
//           foregroundColor: Colors.white,
//           iconTheme: const IconThemeData(color: Colors.indigo, size: 17),
//           title: Text(
//             StaticVariables.handasahName,
//             style: const TextStyle(color: Colors.indigo),
//           ),
//           actions: [
//             IconButton(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               tooltip: "إضافة مشرف, وفنى الهندسة",
//               hoverColor: Colors.yellow,
//               icon: const Icon(Icons.person_add_alt, color: Colors.indigo, size: 20),
//               onPressed: () {
//                 showDialog(
//                   context: context,
//                   builder: (context) =>
//                       const CustomAlertDialogCreateHandasahUsers(
//                     title: 'إضافة مستخدمين لمديرى ومشرفى وفنين الهندسة',
//                   ),
//                 );
//               },
//             ),
//             IconButton(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               tooltip: "إضافه المهمات الخاصة بالهندسة",
//               hoverColor: Colors.yellow,
//               icon: const Icon(Icons.note_add_outlined, color: Colors.indigo, size: 20),
//               onPressed: () {
//                 showDialog(
//                   context: context,
//                   builder: (context) {
//                     return CustomReusableAlertDialog(
//                       title: "إضافة مهمات الهندسة",
//                       fieldLabels: const ['المسمى', 'العدد'],
//                       onSubmit: (values) {
//                         try {
//                           DioNetworkRepos().createNewHandasahTools(
//                               handasahName, values[0], int.parse(values[1]));
//                         } catch (e) {
//                           log(e.toString());
//                         }
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//             const SizedBox(width: 8),
//           ],
//         ),
//         body: Row(
//           children: [
//             // ── Left: complaints waiting for a technician ──────────────────
//             Expanded(
//               flex: 1,
//               child: Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                 width: 220,
//                 height: MediaQuery.of(context).size.height,
//                 color: Colors.black38,
//                 child: ListView(
//                   shrinkWrap: true,
//                   children: [
//                     const SizedBox(
//                       height: 50,
//                       child: DrawerHeader(
//                         decoration: BoxDecoration(color: Colors.indigo),
//                         child: Text(
//                           textDirection: TextDirection.rtl,
//                           textAlign: TextAlign.center,
//                           "تخصيص شكوى لفنى",
//                           style: TextStyle(color: Colors.white, fontSize: 12),
//                         ),
//                       ),
//                     ),
//                     Consumer<ComplaintProvider>(
//                       builder: (context, complaints, _) {
//                         final waiting =
//                             complaints.unassignedComplaintsFor(handasahName);
//                         if (waiting.isEmpty) {
//                           return const Padding(
//                             padding: EdgeInsets.all(8.0),
//                             child: Center(child: Text('لايوجد شكاوى')),
//                           );
//                         }
//                         return ListView.builder(
//                           reverse: true,
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: waiting.length,
//                           itemBuilder: (context, index) =>
//                               _buildUnassignedCard(context, waiting[index]),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             // ── Middle: GIS map ────────────────────────────────────────────
//             Expanded(
//               flex: 3,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: gisHandasahUrl == ""
//                     ? const Center(
//                         child: Text(
//                           'عرض رابط GIS',
//                           style: TextStyle(fontSize: 20, color: Colors.indigo),
//                         ),
//                       )
//                     // : Container(),
//                     : IframeScreen(url: gisHandasahUrl),
//               ),
//             ),
//             // ── Right: open complaints of this handasah ────────────────────
//             Expanded(
//               flex: 1,
//               child: Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                 width: 220,
//                 height: MediaQuery.of(context).size.height,
//                 color: Colors.black38,
//                 child: ListView(
//                   shrinkWrap: true,
//                   children: [
//                     const SizedBox(
//                       height: 50,
//                       child: DrawerHeader(
//                         decoration: BoxDecoration(color: Colors.indigo),
//                         child: Text(
//                           textDirection: TextDirection.rtl,
//                           textAlign: TextAlign.center,
//                           "الشكاوى غير مغلقة الخاصة بالهندسة",
//                           style: TextStyle(color: Colors.white, fontSize: 12),
//                         ),
//                       ),
//                     ),
//                     Consumer<ComplaintProvider>(
//                       builder: (context, complaints, _) {
//                         final open = complaints.openComplaintsFor(handasahName);
//                         length = open.length;

//                         if (open.isEmpty) {
//                           // Nothing loaded yet → "waiting" text; otherwise
//                           // the list really is empty (or the request failed).
//                           return Center(
//                             child: Text(
//                               complaints.state == LoadState.loading ||
//                                       complaints.state == LoadState.idle
//                                   ? 'لايوجد شكاوى'
//                                   : 'لا يوجد شكاوى مفتوحة',
//                             ),
//                           );
//                         }
//                         return ListView.builder(
//                           reverse: true,
//                           shrinkWrap: true,
//                           itemCount: open.length,
//                           itemBuilder: (context, index) =>
//                               _buildComplaintCard(context, open[index]),
//                           physics: const NeverScrollableScrollPhysics(),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'package:emergency_room/screens/emeregency_room/controller/complaint_provider.dart';
import 'package:emergency_room/screens/emeregency_room/model/complaint_model.dart';
import 'package:emergency_room/screens/emeregency_room/repo/complaint_repo.dart';
import 'package:emergency_room/screens/manage_system/control/handasah_provider.dart';
import 'package:emergency_room/screens/manage_system/repo/handasah_repo.dart';
import 'package:emergency_room/screens/manage_system/repo/users_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:emergency_room/custom_widget/custom_alert_dialog_create_handasah_users.dart';

import 'package:emergency_room/utils/app_constants.dart';
import 'package:emergency_room/utils/cache_helper.dart';
import 'package:emergency_room/utils/center_toast.dart';
import 'package:emergency_room/custom_widget/custom_web_view_iframe.dart';
import 'package:audioplayers/audioplayers.dart'; // Add this import

// ── manage_system data layer (model / repo / provider) ───────────────────

import '../custom_widget/custom_bottom_sheet.dart';
import '../custom_widget/custom_reusable_alert_dailog.dart';
import '../custom_widget/cutom_texts_alert_dailog.dart';
import '../network/remote/remote_network_repos.dart';

class HandasahScreen extends StatefulWidget {
  const HandasahScreen({super.key});

  @override
  State<HandasahScreen> createState() => _HandasahScreenState();
}

class _HandasahScreenState extends State<HandasahScreen> {
  // ── Data layer ───────────────────────────────────────────────────────────
  // Open complaints for ALL handasat are loaded into this provider; this
  // screen shows the ones sent to [handasahName]. sortNewestFirst is false so
  // the list keeps the server's order (the lists below use `reverse: true`,
  // exactly like before).
  final ComplaintProvider _complaints = ComplaintProvider(
    ComplaintRepo(),
    sortNewestFirst: false,
  );
  final HandasahRepo _handasahRepo = HandasahRepo();
  final UsersRepo _usersRepo = UsersRepo();

  /// StaticVariables is in-memory only, so a hot restart / page refresh wipes
  /// it. Fall back to the value cached at login (key 'handasahName').
  static String _resolveHandasahName() {
    final fromStatic = StaticVariables.handasahName;
    if (fromStatic.trim().isNotEmpty) return fromStatic;
    return (CacheHelper.getData(key: 'handasahName') ?? '').toString();
  }

  String handasahName = _resolveHandasahName();
  bool get _hasHandasah => handasahName.trim().isNotEmpty;
  String gisHandasahUrl = "";
  List<String> handasatUsersItemsDropdownMenu = [];
  double fontSize = 12.0;
  String storeName = "";
  Timer? _timer;
  int length = 0;
  int previousLength = 0; // Track previous length for comparison
  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player for sound

  /// Technician picked in each "unassigned complaint" card (by complaintId).
  final Map<int, String> _selectedTechnician = {};

  @override
  void initState() {
    super.initState();

    if (!_hasHandasah) {
      // No handasah selected (e.g. after a hot restart the login step didn't
      // run again) → don't send requests with an empty name; go back to login.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/login');
      });
      return;
    }

    _initializeData();
    _startPeriodicFetch();
    _loadSound(); // Preload the sound
    _loadStoreQty(); //Load store qty
  }

  Future<void> _loadSound() async {
    // You can use a local asset or a network URL for the sound
    // For local asset: add the sound file to your assets and update pubspec.yaml
    await _audioPlayer.setSource(
        AssetSource('sounds/alarm.mp3')); // Replace with your sound file
  }

  Future<void> _initializeData() async {
    // Open complaints (all handasat) → ComplaintProvider
    await _complaints.loadByFinished(false);
    if (!mounted) return;

    // Initialize previous length (unassigned complaints of this handasah)
    previousLength = _complaints.unassignedComplaintsFor(handasahName).length;

    // Initialize handasat users (technicians) dropdown:
    // GET /users/role/3/control-unit/{handasahName}
    try {
      final names =
          await _usersRepo.getNamesByRoleAndControlUnit(3, handasahName);
      if (!mounted) return;
      setState(() {
        handasatUsersItemsDropdownMenu = List<String>.from(names);
      });
    } catch (e) {
      log('Error loading technicians: $e');
    }
  }

  void _startPeriodicFetch() {
    const Duration fetchInterval = Duration(seconds: 10);
    _timer = Timer.periodic(fetchInterval, (Timer timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      await _complaints.loadByFinished(false);
      if (!mounted) return;
      // A failed refresh keeps the last good list; try again next tick.
      if (_complaints.state == LoadState.error) return;

      final newLength =
          _complaints.unassignedComplaintsFor(handasahName).length;

      // Check if new items were added
      if (newLength > previousLength) {
        _playAlertSound(); // Play sound when new items are detected
      }
      previousLength = newLength; // Update previous length
    });
  }

  Future<void> _playAlertSound() async {
    try {
      await _audioPlayer.stop(); // Stop any currently playing sound
      await _audioPlayer.resume(); // Play the alert sound
    } catch (e) {
      log('Error playing sound: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose(); // Dispose the audio player
    _complaints.dispose();
    super.dispose();
  }

  // ── Small helpers ────────────────────────────────────────────────────────

  void _toast(String msg, {Color color = Colors.red}) {
    if (!mounted) return;
    showCenterToast(context, msg, color: color);
  }

  /// Shows the provider's last failure message (Arabic) as a red toast.
  void _showFailure() {
    if (!mounted) return;
    _toast(_complaints.failure?.message ?? 'تعذر تنفيذ العملية');
  }

  /// Assigns (or re-assigns) a technician through ComplaintProvider
  /// (PUT /complaints/{id}/recipient). The technician is `recipientUser`.
  Future<void> _assignTechnician(
    ComplaintModel complaint,
    String technician,
  ) async {
    final ok = await _complaints.setRecipient(
      complaint,
      recipientName: complaint.recipientName,
      recipientUser: technician,
    );
    if (!mounted) return;
    if (ok) {
      _toast('تم تخصيص الفنى', color: Colors.green);
    } else {
      _showFailure();
    }
  }

  //show bottom sheet Redirect to Handasat
  void showCustomBottomSheet(
    BuildContext context,
    String title,
    String message,
    ComplaintModel complaint,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false, // Ensures it takes full width
      builder: (context) {
        return CustomBottomSheet(
          title: title,
          message: message,
          hintText: "أختر فنى",
          dropdownItems: handasatUsersItemsDropdownMenu,
          onItemSelected: (value) {
            log("Selected: $value");
            _assignTechnician(complaint, value!);
          },
          onPressed: () async {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> _loadStoreQty() async {
    try {
      final handasah = await _handasahRepo.findByName(handasahName);
      storeName = handasah.storeName;
    } catch (e) {
      log('Error loading store name: $e');
    }
    DioNetworkRepos().excuteTempStoreQty(storeName);
  }

  /// The small coloured status pill used on every card.
  Widget _statusBadge(
    String text,
    Color color, {
    double horizontalPadding = 3.0,
    bool overflowVisible = false,
  }) {
    return Container(
      margin: const EdgeInsets.all(3.0),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.0),
        borderRadius: BorderRadius.circular(5.0),
        color: color,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          overflow: overflowVisible ? TextOverflow.visible : null,
          fontSize: fontSize,
          color: Colors.white,
        ),
      ),
    );
  }

  // ── Right panel: open complaints of this handasah ────────────────────────

  Widget _buildComplaintCard(BuildContext context, ComplaintModel item) {
    final bool hasTechnician =
        !ComplaintProvider.isFreeTechnician(item.recipientUser);

    return InkWell(
      onTap: () {
        final link = item.gisLink.trim();
        if (link.isEmpty || link == 'لم يدرج' || link == 'free') {
          //TODO:MAKE-TOAST
          _toast("لا يوجد رابط GIS Map");
        } else {
          setState(() {
            gisHandasahUrl = item.gisLink;
          });
        }
      },
      child: Card(
        child: Column(
          children: [
            ListTile(
              title: Row(
                children: [
                  IconButton(
                    tooltip: 'إعادة تخصيص فنى',
                    hoverColor: Colors.yellow,
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.indigo,
                    ),
                    onPressed: () {
                      //display bottom sheet
                      showCustomBottomSheet(
                        context,
                        "إعادة تخصيص فنى",
                        item.recipientDestination,
                        item,
                      );
                    },
                  ),
                  Expanded(
                    child: Text(
                      textAlign: TextAlign.center,
                      item.complaintAddress,
                      style: const TextStyle(
                        color: Colors.indigo,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 7.0,
                  horizontal: 3.0,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _statusBadge(
                            item.recipientDestination,
                            Colors.green,
                            horizontalPadding: 1.0,
                          ),
                        ),
                        Expanded(
                          child: hasTechnician
                              ? _statusBadge(item.recipientUser, Colors.green)
                              : _statusBadge(
                                  'قيد تخصيص فنى',
                                  Colors.orange,
                                  overflowVisible: true,
                                ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: item.isTracked == 1
                              ? _statusBadge('تم قبول الشكوى', Colors.green)
                              : _statusBadge('قيد قبول الشكوى', Colors.orange),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'إبلاغ كسورات معامل',
                  hoverColor: Colors.yellow,
                  onPressed: () {},
                  icon: const Icon(Icons.report_gmailerrorred,
                      color: Colors.purple),
                ),
                IconButton(
                  tooltip: 'مهمات مخازن مطلوبة',
                  hoverColor: Colors.yellow,
                  onPressed: () {
                    context.go(
                        '/request-tool-address/${item.complaintAddress}/${item.recipientDestination}');
                  },
                  icon: const Icon(Icons.store_sharp, color: Colors.cyan),
                ),
                IconButton(
                  tooltip: 'جرد مخزن',
                  hoverColor: Colors.yellow,
                  onPressed: () async {
                    //  TODO://update store qty not tested
                    context.go('/integrate-with-stores/$storeName');
                  },
                  icon: const Icon(Icons.store_outlined, color: Colors.indigo),
                ),
                IconButton(
                  tooltip: 'عرض بيانات الشكوى',
                  hoverColor: Colors.yellow,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => CustomReusableTextAlertDialog(
                        title: 'بيانات العطل',
                        messages: [
                          'العنوان :  ${item.complaintAddress}',
                          'الاحداثئات :  ${item.latitude} , ${item.longitude}',
                          'الهندسة :  ${item.recipientDestination}',
                          hasTechnician
                              ? 'إسم فنى الهندسة :  ${item.recipientUser}'
                              : 'اسم فنى الهندسة: لم يتم تعيين فنى الهندسة',
                          'رابط :  ${item.gisLink}',
                          'إسم المبلغ :  ${item.reporterName}',
                          ' رقم هاتف المبلغ:  ${item.reporterPhone}',
                          'نوع الكسر :  ${item.complaintType}',
                        ],
                        actions: [
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.info, color: Colors.blueAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Left panel: assign a technician to complaints without one ────────────
  // This replaces CustomHandasahAssignUser, which assigned through the old
  // locations API. Assignment now goes through ComplaintProvider.setRecipient.

  Widget _buildUnassignedCard(BuildContext context, ComplaintModel item) {
    final id = item.complaintId;
    final String? selected = id == null ? null : _selectedTechnician[id];
    final bool canAssign =
        id != null && selected != null && !_complaints.isBusy;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          children: [
            Text(
              item.complaintAddress,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: Colors.indigo,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            DropdownButton<String>(
              isExpanded: true,
              value: handasatUsersItemsDropdownMenu.contains(selected)
                  ? selected
                  : null,
              hint: const Text(
                'فضلا أختار الفنى',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 12),
              ),
              items: handasatUsersItemsDropdownMenu
                  .map(
                    (name) => DropdownMenuItem<String>(
                      value: name,
                      child: Text(
                        name,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (id == null || value == null) return;
                setState(() => _selectedTechnician[id] = value);
              },
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canAssign
                    ? () async {
                        await _assignTechnician(item, selected);
                        if (mounted) {
                          setState(() => _selectedTechnician.remove(id));
                        }
                      }
                    : null,
                icon: const Icon(Icons.person_add_alt, size: 16),
                label: const Text('تخصيص', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ComplaintProvider>.value(
      value: _complaints,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 7,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.indigo, size: 17),
          title: Text(
            handasahName,
            style: const TextStyle(color: Colors.indigo),
          ),
          actions: [
            IconButton(
              tooltip: "إضافة مشرف, وفنى الهندسة",
              hoverColor: Colors.yellow,
              icon: const Icon(Icons.person_add_alt, color: Colors.indigo, size: 20),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      const CustomAlertDialogCreateHandasahUsers(
                    title: 'إضافة مستخدمين لمديرى ومشرفى وفنين الهندسة',
                  ),
                );
              },
            ),
            IconButton(
              tooltip: "إضافه المهمات الخاصة بالهندسة",
              hoverColor: Colors.yellow,
              icon: const Icon(Icons.note_add_outlined, color: Colors.indigo, size: 20),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return CustomReusableAlertDialog(
                      title: "إضافة مهمات الهندسة",
                      fieldLabels: const ['المسمى', 'العدد'],
                      onSubmit: (values) {
                        try {
                          DioNetworkRepos().createNewHandasahTools(
                              handasahName, values[0], int.parse(values[1]));
                        } catch (e) {
                          log(e.toString());
                        }
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Row(
          children: [
            // ── Left: complaints waiting for a technician ──────────────────
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                width: 220,
                height: MediaQuery.of(context).size.height,
                color: Colors.black38,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const SizedBox(
                      height: 50,
                      child: DrawerHeader(
                        decoration: BoxDecoration(color: Colors.indigo),
                        child: Text(
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          "تخصيص شكوى لفنى",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                    Consumer<ComplaintProvider>(
                      builder: (context, complaints, _) {
                        final waiting =
                            complaints.unassignedComplaintsFor(handasahName);
                        if (waiting.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: Text('لايوجد شكاوى')),
                          );
                        }
                        return ListView.builder(
                          reverse: true,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: waiting.length,
                          itemBuilder: (context, index) =>
                              _buildUnassignedCard(context, waiting[index]),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // ── Middle: GIS map ────────────────────────────────────────────
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: gisHandasahUrl == ""
                    ? const Center(
                        child: Text(
                          'عرض رابط GIS',
                          style: TextStyle(fontSize: 20, color: Colors.indigo),
                        ),
                      )
                    // : Container(),
                    : IframeScreen(url: gisHandasahUrl),
              ),
            ),
            // ── Right: open complaints of this handasah ────────────────────
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                width: 220,
                height: MediaQuery.of(context).size.height,
                color: Colors.black38,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const SizedBox(
                      height: 50,
                      child: DrawerHeader(
                        decoration: BoxDecoration(color: Colors.indigo),
                        child: Text(
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          "الشكاوى غير مغلقة الخاصة بالهندسة",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                    Consumer<ComplaintProvider>(
                      builder: (context, complaints, _) {
                        final open = complaints.openComplaintsFor(handasahName);
                        length = open.length;

                        if (open.isEmpty) {
                          // Nothing loaded yet → "waiting" text; otherwise
                          // the list really is empty (or the request failed).
                          return Center(
                            child: Text(
                              complaints.state == LoadState.loading ||
                                      complaints.state == LoadState.idle
                                  ? 'لايوجد شكاوى'
                                  : 'لا يوجد شكاوى مفتوحة',
                            ),
                          );
                        }
                        return ListView.builder(
                          reverse: true,
                          shrinkWrap: true,
                          itemCount: open.length,
                          itemBuilder: (context, index) =>
                              _buildComplaintCard(context, open[index]),
                          physics: const NeverScrollableScrollPhysics(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
