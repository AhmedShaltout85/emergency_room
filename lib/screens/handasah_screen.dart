// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:emergency_room/custom_widget/custom_alert_dialog_create_handasah_users.dart';
import 'package:emergency_room/custom_widget/custom_handasah_assign_user.dart';
// import 'package:emergency_room/custom_widget/custom_landing_body.dart';
// import 'package:emergency_room/screens/integration_with_stores_get_all_qty.dart';
// import 'package:emergency_room/screens/request_tool_for_address_screen.dart';
import 'package:emergency_room/utils/dio_http_constants.dart';
import 'package:emergency_room/custom_widget/custom_web_view_iframe.dart';
import 'package:audioplayers/audioplayers.dart'; // Add this import

import '../custom_widget/custom_bottom_sheet.dart';
import '../custom_widget/custom_reusable_alert_dailog.dart';
import '../custom_widget/cutom_texts_alert_dailog.dart';
import '../network/remote/dio_network_repos.dart';

class HandasahScreen extends StatefulWidget {
  const HandasahScreen({super.key});

  @override
  State<HandasahScreen> createState() => _HandasahScreenState();
}

class _HandasahScreenState extends State<HandasahScreen> {
  late Future getLocsByHandasahNameAndIsFinished;
  late Future getLocByHandasahAndTechnician;
  String handasahName = DataStatic.handasahName;
  String gisHandasahUrl = "";
  late Future getHandasatUsersItemsDropdownMenu;
  List<String> handasatUsersItemsDropdownMenu = [];
  double fontSize = 12.0;
  String storeName = "";
  Timer? _timer;
  int length = 0;
  int previousLength = 0; // Track previous length for comparison
  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player for sound

  @override
  void initState() {
    super.initState();
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

  void _initializeData() {
    setState(() {
      getLocsByHandasahNameAndIsFinished =
          DioNetworkRepos().getLocByHandasahAndIsFinished(handasahName, 0);
      getLocByHandasahAndTechnician =
          DioNetworkRepos().getLocByHandasahAndTechnician(handasahName, 'free');
    });

    // Initialize previous length
    getLocByHandasahAndTechnician.then((value) {
      previousLength = value.length;
    });

    // Initialize handasat users dropdown
    getHandasatUsersItemsDropdownMenu =
        DioNetworkRepos().fetchHandasatUsersItemsDropdownMenu(handasahName);
    getHandasatUsersItemsDropdownMenu.then((value) {
      handasatUsersItemsDropdownMenu = List<String>.from(value);
    });
  }

  void _startPeriodicFetch() {
    const Duration fetchInterval = Duration(seconds: 10);
    _timer = Timer.periodic(fetchInterval, (Timer timer) async {
      final newData = await DioNetworkRepos()
          .getLocByHandasahAndTechnician(handasahName, 'free');

      // Check if new items were added
      if (newData.length > previousLength) {
        _playAlertSound(); // Play sound when new items are detected
      }

      setState(() {
        previousLength = newData.length; // Update previous length
        getLocsByHandasahNameAndIsFinished =
            DioNetworkRepos().getLocByHandasahAndIsFinished(handasahName, 0);
        getLocByHandasahAndTechnician = Future.value(newData);
      });
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
    super.dispose();
  }

  //show bottom sheet Redirect to Handasat
  void showCustomBottomSheet(
      BuildContext context, String title, String message, String address) {
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
            setState(() {
              DioNetworkRepos().updateLocAddTechnician(address, value);
            });
          },
          onPressed: () async {
            Navigator.of(context).pop();
            // await DioNetworkRepos().updateLocAddTechnician(address, "free");
          },
        );
      },
    );
  }

  Future<void> _loadStoreQty() async {
    await DioNetworkRepos()
        .getStoreNameByHandasahName(handasahName)
        .then((value) {
      storeName = value['storeName'];
    });
    DioNetworkRepos().excuteTempStoreQty(storeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 7,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.indigo, size: 17),
        title: Text(
          DataStatic.handasahName,
          style: const TextStyle(color: Colors.indigo),
        ),
        actions: [
          IconButton(
            tooltip: "إضافة مشرف, وفنى الهندسة",
            hoverColor: Colors.yellow,
            icon: const Icon(Icons.person_add_alt, color: Colors.indigo),
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
            icon: const Icon(Icons.note_add_outlined, color: Colors.indigo),
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
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              width: 220,
              height: MediaQuery.of(context).size.height,
              color: Colors.black38,
              child: CustomHandasahAssignUser(
                getLocs: getLocByHandasahAndTechnician,
                stringListItems: handasatUsersItemsDropdownMenu,
                onPressed: () {
                  setState(() {
                    getLocsByHandasahNameAndIsFinished = DioNetworkRepos()
                        .getLocByHandasahAndIsFinished(handasahName, 0);
                    getLocByHandasahAndTechnician = DioNetworkRepos()
                        .getLocByHandasahAndTechnician(handasahName, 'free');
                  });
                },
                hintText: 'فضلا أختار الفنى',
                title: 'تخصيص شكوى لفنى',
              ),
            ),
          ),
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
                  FutureBuilder(
                    future: getLocsByHandasahNameAndIsFinished,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Text('لايوجد شكاوى'),
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.done) {
                        if (snapshot.hasError) {
                          return const Center(
                              child: Text('لا يوجد شكاوى مفتوحة'));
                        } else if (snapshot.hasData) {
                          length = snapshot.data!.length;
                          return ListView.builder(
                            reverse: true,
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    gisHandasahUrl =
                                        snapshot.data![index]['gis_url'];
                                  });
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
                                                //
                                                //display bottom sheet
                                                showCustomBottomSheet(
                                                  context,
                                                  "إعادة تخصيص فنى",
                                                  snapshot.data![index]
                                                      ['handasah_name'],
                                                  snapshot.data![index]
                                                      ['address'],
                                                );
                                              },
                                            ),
                                            Expanded(
                                              child: Text(
                                                textAlign: TextAlign.center,
                                                snapshot.data![index]
                                                    ['address'],
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              3.0),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 1.0),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.green,
                                                            width: 1.0),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                        color: Colors.green,
                                                      ),
                                                      child: Text(
                                                        textAlign:
                                                            TextAlign.center,
                                                        "${snapshot.data![index]['handasah_name']}",
                                                        style: TextStyle(
                                                          fontSize: fontSize,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  snapshot.data![index][
                                                              'technical_name'] ==
                                                          "free"
                                                      ? Expanded(
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(3.0),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        3.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .orange,
                                                                  width: 1.0),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0),
                                                              color:
                                                                  Colors.orange,
                                                            ),
                                                            child: Text(
                                                              "قيد تخصيص فنى",
                                                              style: TextStyle(
                                                                overflow:
                                                                    TextOverflow
                                                                        .visible,
                                                                fontSize:
                                                                    fontSize,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        )
                                                      : Expanded(
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(3.0),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        3.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .green,
                                                                  width: 1.0),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0),
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                            child: Text(
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              "${snapshot.data![index]['technical_name']}",
                                                              style: TextStyle(
                                                                fontSize:
                                                                    fontSize,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: snapshot.data![index]
                                                                [
                                                                'is_approved'] ==
                                                            1
                                                        ? Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(3.0),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        3.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .green,
                                                                  width: 1.0),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0),
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                            child: Text(
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              'تم قبول الشكوى',
                                                              style: TextStyle(
                                                                fontSize:
                                                                    fontSize,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          )
                                                        : Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(3.0),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        3.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .orange,
                                                                  width: 1.0),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0),
                                                              color:
                                                                  Colors.orange,
                                                            ),
                                                            child: Text(
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              'قيد قبول الشكوى',
                                                              style: TextStyle(
                                                                fontSize:
                                                                    fontSize,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            tooltip: 'إبلاغ كسورات معامل',
                                            hoverColor: Colors.yellow,
                                            onPressed: () {},
                                            icon: const Icon(
                                                Icons.report_gmailerrorred,
                                                color: Colors.purple),
                                          ),
                                          IconButton(
                                            tooltip: 'مهمات مخازن مطلوبة',
                                            hoverColor: Colors.yellow,
                                            onPressed: () {
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) =>
                                              //         RequestToolForAddressScreen(
                                              //       address:
                                              //           snapshot.data![index]
                                              //               ['address'],
                                              //       handasahName:
                                              //           snapshot.data![index]
                                              //               ['handasah_name'],
                                              //     ),
                                              //   ),
                                              // );
                                              context.go(
                                                  '/request-tool-address/${snapshot.data![index]['address']}/${snapshot.data![index]['handasah_name']}');
                                            },
                                            icon: const Icon(Icons.store_sharp,
                                                color: Colors.cyan),
                                          ),
                                          IconButton(
                                            tooltip: 'جرد مخزن',
                                            hoverColor: Colors.yellow,
                                            onPressed: () async {
                                              //  TODO://update store qty not tested

                                              // await DioNetworkRepos()
                                              //     .getStoreNameByHandasahName(
                                              //         snapshot.data![index]
                                              //             ['handasah_name'])
                                              //     .then((value) {
                                              //   storeName = value['storeName'];
                                              // });
                                              // DioNetworkRepos()
                                              //     .excuteTempStoreQty(
                                              //         storeName);
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) =>
                                              //         IntegrationWithStoresGetAllQty(
                                              //       storeName: storeName,
                                              //     ),
                                              //   ),
                                              // );
                                              context.go(
                                                  '/integrate-with-stores/$storeName');
                                            },
                                            icon: const Icon(
                                                Icons.store_outlined,
                                                color: Colors.indigo),
                                          ),
                                          IconButton(
                                            tooltip: 'عرض بيانات الشكوى',
                                            hoverColor: Colors.yellow,
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    CustomReusableTextAlertDialog(
                                                  title: 'بيانات العطل',
                                                  messages: [
                                                    'العنوان :  ${snapshot.data[index]['address']}',
                                                    'الاحداثئات :  ${snapshot.data[index]['latitude']} , ${snapshot.data[index]['longitude']}',
                                                    'الهندسة :  ${snapshot.data[index]['handasah_name']}',
                                                    snapshot.data![index][
                                                                'technical_name'] ==
                                                            "free"
                                                        ? 'اسم فنى الهندسة: لم يتم تعيين فنى الهندسة'
                                                        : 'إسم فنى الهندسة :  ${snapshot.data![index]['technical_name']}',
                                                    'رابط :  ${snapshot.data[index]['gis_url']}',
                                                    'إسم المبلغ :  ${snapshot.data[index]['caller_name']}',
                                                    ' رقم هاتف المبلغ:  ${snapshot.data[index]['caller_phone']}',
                                                    'نوع الكسر :  ${snapshot.data[index]['broker_type']}',
                                                  ],
                                                  actions: [
                                                    Align(
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      child: TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(),
                                                        child:
                                                            const Text('Close'),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.info,
                                                color: Colors.blueAccent),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            physics: const NeverScrollableScrollPhysics(),
                          );
                        } else {
                          return const Center(
                              child: Text('لايوجد شكاوى مفتوحة'));
                        }
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
