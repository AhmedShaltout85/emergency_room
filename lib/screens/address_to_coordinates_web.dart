// // ignore_for_file: use_build_context_synchronously

// import 'dart:async';
// import 'dart:collection';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;

// // import 'package:pick_location/screens/agora_video_call.dart';
// // import 'package:pick_location/screens/caller_mobile_screen.dart';
// // import 'package:pick_location/screens/caller_screen.dart';
// // import 'package:pick_location/screens/dashboard_screen.dart';
// // import 'package:pick_location/screens/integration_with_stores_get_all_qty.dart';
// // import 'package:pick_location/screens/report_screen.dart';
// // import 'package:pick_location/screens/tracking.dart';

// // import '../common_services/video_call_service.dart';
// import '../custom_widget/custom_reusable_alert_dailog.dart';
// import '../custom_widget/custom_bottom_sheet.dart';
// import '../custom_widget/custom_browser_redirect.dart';
// import '../custom_widget/custom_drawer.dart';
// import '../custom_widget/custom_end_drawer.dart';
// import '../custom_widget/custom_reusable_alter_dialog_drop_down_textfield.dart';
// import '../custom_widget/custom_text_button_drop_down_menu.dart';
// import '../custom_widget/cutom_texts_alert_dailog.dart';
// import '../labs/widget/convert_handasah_to_lab_code.dart';
// import '../labs/widget/convert_lab_code_to_lab_name.dart';
// import '../network/remote/remote_network_repos.dart';
// import '../utils/app_constants.dart';
// /////////////
// // import '../labs/charts/rose_chart.dart';
// // import '../labs/charts/radial_chart.dart';
// // import '.../labs/charts/bar_chart.dart';
// // import '../labs/charts/line_chart.dart';
// // import '../labs/charts/pie_chart.dart';
// // import '../labs/charts/doughnut_chart.dart';

// class AddressToCoordinates extends StatefulWidget {
//   const AddressToCoordinates({super.key});

//   @override
//   AddressToCoordinatesState createState() => AddressToCoordinatesState();
// }

// class AddressToCoordinatesState extends State<AddressToCoordinates> {
//   String storeName = "";
//   final Completer<GoogleMapController> _controller = Completer();

//   String address = "";
//   String coordinates = "";
//   String getAddress = "";
//   LatLng alexandriaCoordinates = const LatLng(31.205753, 29.924526);
//   double latitude = 0.0, longitude = 0.0;
//   var pickMarkers = HashSet<Marker>();
//   late Future
//       getLocsAfterGetCoordinatesAndGis; //get addresses from db(after getting coordinates and gis link)
//   late Future getLocsByHandasahNameAndTechinicianName;
//   final TextEditingController addressController = TextEditingController();
//   late Future getHandasatItemsDropdownMenu;
//   List<String> handasatItemsDropdownMenu = [];
//   List<String> addHandasahToAddressList = [];
//   late Future<List<Map<String, dynamic>>> getAllHotLineAddresses;

//   // Replace with your actual Google Maps API key
//   String googleMapsApiKey = "AIzaSyDRaJJnyvmDSU8OgI8M20C5nmwHNc_AMvk";
//   double fontSize = 12.0;
//   Timer? _timer; // Timer for periodic fetching
//   // BitmapDescriptor? pinLocationIcon;
//   int numberOfAffectedPeople = 4;
//   double aproxTimeFixing = 1;
//   String pipDim = '4 mm';

//   @override
//   void dispose() {
//     _timer?.cancel(); // Cancel periodic fetch and location update timer
//     // Dispose the controller when the widget is disposed
//     addressController.dispose();
//     super.dispose();
//   }

//   //TODO:convert GIS-HANDASAH-NAME-TO-EMERGENCY-HANDASAH-NAME(inprogress-21-02-2026)
//   String convertGisHandasahNameToEmergencyHandasahName(
//       String emergencyHandasahPattern) {
//     const Map<String, String> patternToName = {
//       'ABUKEER/ابو قير': 'هندسة فرع أبو قير',
//       'MANDARA/المندرة': 'هندسة فرع المندرة',
//       'SIDIBISHR/سيدى بشر': 'هندسة فرع سيدى بشر',
//       'ELRAML/الرمل': 'هندسة فرع الرمل',
//       'ELBRAHEMIA/الابراهمية': 'هندسة فرع الابراهمية',
//       'ELNOZHA/النزهه': 'هندسة فرع النزهه',
//       'ELBALAD_MOHERMBK/البلد ومحرم بك': 'هندسة فرع البلد',
//       'ELQABBARI/القبارى': 'هندسة فرع القبارى',
//       'ELAGAMI/ العجمى': 'هندسة فرع العجمى',
//       'MADINET_NOUBARIA_ELGDIDA/مدينة النوباريه الجديدة': 'هندسة النوبارية',
//       'ELAMREYA/العامريه': 'هندسة فرع العامريه',
//       'ELBANGER/البنجر': 'هندسة بنجر السكر',
//       // '': 'هندسة ك 59',
//       'BORGELARAB/برج العرب': 'هندسة برج العرب الجديده',
//       '6OCTOBER/6 اكتوبر': 'هندسة فرع 6 اكتوبر',
//       'ELMINA/الميناء': 'هندسة فرع الميناء',
//       'MARIOUT1/مريوط 1': 'هندسة فرع مريوط 1',
//     };

//     for (final entry in patternToName.entries) {
//       if (emergencyHandasahPattern.contains(entry.key)) {
//         return entry.value;
//       }
//     }

//     return emergencyHandasahPattern;
//   }

//   //initialize app(hotline data)
//   Future<void> _initializeApp() async {
//     try {
//       setState(() {
//         getAllHotLineAddresses = _loadHotlineData();
//       });
//     } catch (e) {
//       log("Error initializing app: $e");
//       _showErrorSnackbar("Failed to initialize application");
//     }
//   }

//   Future<List<Map<String, dynamic>>> _loadHotlineData() async {
//     try {
//       final token = await DioNetworkRepos().getHotLineTokenByUserAndPassword();
//       return DioNetworkRepos().getHotLineData(token);
//     } catch (e) {
//       log("Error loading hotline data: $e");
//       _showErrorSnackbar("Failed to load hotline data");
//       return [];
//     }
//   }

//   void _showErrorSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           textAlign: TextAlign.center,
//         ),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   //update in periodic time
//   void _startPeriodicFetch() {
//     const Duration fetchInterval =
//         Duration(seconds: 10); // Fetch every 10 seconds
//     _timer = Timer.periodic(fetchInterval, (Timer timer) {
//       setState(() {
//         // getAllHotLineAddresses = DioNetworkRepos().getLoc();
//         getLocsAfterGetCoordinatesAndGis =
//             DioNetworkRepos().getAllComplaintsNotFinished();
//         getLocsByHandasahNameAndTechinicianName =
//             DioNetworkRepos().getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");
//       });
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     // BitmapDescriptor.asset(
//     //         const ImageConfiguration(
//     //           size: Size(40, 40),
//     //         ),
//     //         'assets/green_marker.png')
//     //     .then((onValue) {
//     //   pinLocationIcon = onValue;
//     // });
//     _initializeApp();

//     setState(() {
//       // getLocs = DioNetworkRepos().getLoc();
//       getLocsAfterGetCoordinatesAndGis =
//           DioNetworkRepos().getAllComplaintsNotFinished();
//       getLocsByHandasahNameAndTechinicianName =
//           DioNetworkRepos().getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");
//     });

//     // getLocs.then((value) => log("GET ALL HOTlINE LOCATIONS: $value"));

//     getLocsByHandasahNameAndTechinicianName.then(
//         (value) => log("NO HANDASAH AND TECHNICIAN ARE ASSIGNED: $value"));

//     //get handasat items dropdown menu from db
//     getHandasatItemsDropdownMenu =
//         DioNetworkRepos().fetchHandasatItemsDropdownMenu();

//     //load list
//     getHandasatItemsDropdownMenu.then((value) {
//       value.forEach((element) {
//         element = element.toString();
//         //add to list
//         handasatItemsDropdownMenu.add(element);
//       });
//       //debug print
//       log("handasatItemsDropdownMenu from UI: $handasatItemsDropdownMenu");
//       log(value.toString());
//     });
//     //start periodic fetch
//     _startPeriodicFetch();
//   }

//   // Function to get latitude and longitude from an address using Google Maps Geocoding API
//   // Future<void> _getCoordinatesFromAddress(String address) async {
//   //   final url = Uri.parse(
//   //       'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$googleMapsApiKey');

//   //   final GoogleMapController controller = await _controller.future;

//   //   try {
//   //     final response = await http.get(url);

//   //     if (response.statusCode == 200) {
//   //       final data = json.decode(response.body);

//   //       if (data['results'].isNotEmpty) {
//   //         var location = data['results'][0]['geometry']['location'];
//   //         setState(() {
//   //           coordinates =
//   //               "Latitude: ${location['lat']}, Longitude: ${location['lng']}";
//   //           latitude = location['lat']; // latitude
//   //           longitude = location['lng']; // longitude

//   //           //add marker
//   //           pickMarkers.add(
//   //             Marker(
//   //               markerId: MarkerId(address),
//   //               position: LatLng(latitude, longitude),
//   //               infoWindow: InfoWindow(
//   //                 title: address,
//   //                 snippet: coordinates,
//   //               ),
//   //               icon:
//   //                   // pinLocationIcon!,
//   //                   BitmapDescriptor.defaultMarkerWithHue(
//   //                       BitmapDescriptor.hueGreen),
//   //             ),
//   //           );
//   //           // Move camera to the new location
//   //           controller.animateCamera(
//   //             CameraUpdate.newCameraPosition(
//   //               CameraPosition(
//   //                 target: LatLng(latitude, longitude),
//   //                 zoom: 15.0, // You can adjust the zoom level as needed
//   //               ),
//   //             ),
//   //           );
//   //           //
//   //           log(address);
//   //           log(coordinates);
//   //           log(longitude.toString());
//   //           log(latitude.toString());

//   //           //update locations after getting coordinates
//   //           // getLocs = DioNetworkRepos().getLoc();
//   //           //update locations after getting coordinates and gis link
//   //           getLocsAfterGetCoordinatesAndGis =
//   //               DioNetworkRepos().getAllComplaintsNotFinished();
//   //           getLocsByHandasahNameAndTechinicianName =
//   //               DioNetworkRepos().getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");
//   //         });
//   //         log('START-GIS-INTEGRATIONS');
//   //         //get last gis record from GIS server
//   //         int lastRecordNumber = await DioNetworkRepos()
//   //             .getLastRecordNumberWeb(); //get last gis record from GIS serverWEB-NO-BODY

//   //         log("lastRecordNumber :>> $lastRecordNumber");
//   //         int newRecordNumber = lastRecordNumber + 1;
//   //         log("newRecordNumber :>> $newRecordNumber");
//   //         //

//   //         //TODO: UPDATE_GET_GIS_LINK_HANDASAT_NAME_FORM_GIS_SERVER(INPROGRESS-IN-10-02-2026)
//   //         //create new gis point
//   //         // String mapLink =
//   //         //     await DioNetworkRepos().createNewGisPointAndGetMapLink(
//   //         //   newRecordNumber,
//   //         //   longitude.toString(),
//   //         //   latitude.toString(),
//   //         // );
//   //         // log("gis_longitude :>> $longitude");
//   //         // log("gis_latitude :>> $latitude");
//   //         // log("GIS MAP LINK :>> $mapLink");

//   //         //TODO: UPDATE_GET_GIS_LINK_HANDASAT_NAME_FORM_GIS_SERVER(INPROGRESS-IN-10-02-2026)
//   //         final result = await DioNetworkRepos()
//   //             .createNewGisPointAndGetMapLinkAndHandasah(
//   //                 newRecordNumber, longitude.toString(), latitude.toString());
//   //         log("GIS-RESPONSE-DATA :>> $result");
//   //                 //
//   //         final gisUrl = result['url'];
//   //         final branch = result['engineering_branch'];
//   //         final service = result['wtp_service'];
//   //         log("GIS MAP LINK :>> $gisUrl");
//   //         log("GIS BRANCH :>> $branch");
//   //         log("GIS SERVICE :>> $service");

//   //         //TODO: UPDATE_GET_GIS_LINK_HANDASAT_NAME_FORM_GIS_SERVER(INPROGRESS-IN-16-03-2026)
//   //         String handasahBranch =
//   //             convertGisHandasahNameToEmergencyHandasahName(branch);
//   //         // check if address already exist(UPDATED-IN-29-01-2025)
//   //         var addressInList =
//   //             await DioNetworkRepos().checkAddressExists(address);
//   //         log("PRINTED DATA FROM UI:  ${await DioNetworkRepos().checkAddressExists(address)}");
//   //         log("PRINTED BY USING VAR: $addressInList");
//   //         // log("PRINTED BY USING STRING: $addressInListString");
//   //         //
//   //         //
//   //         if (addressInList == true) {
//   //           //  call the function to update locations in database
//   //           log("address already exist >>>>>> $addressInList");

//   //           //  call the function to update locations in database
//   //           //update Locations list after getting coordinates and gis link
//   //           //TODO: UPDATE_GET_GIS_LINK_HANDASAT_NAME_FORM_GIS_SERVER(ADD-HANDASAT-NAME-INPROGRESS-IN-21-02-2026)
//   //           // await DioNetworkRepos().updateLocations(
//   //           //   address,
//   //           //   longitude,
//   //           //   latitude,
//   //           //   url, //updated(28-02-2026)
//   //           // );
//   //           //TODO: UPDATE_GET_GIS_LINK_HANDASAT_NAME_FORM_GIS_SERVER(ADD-HANDASAT-NAME-INPROGRESS-IN-21-02-2026)
//   //           await DioNetworkRepos().updateLocations(
//   //             address,
//   //             longitude,
//   //             latitude,
//   //             gisUrl,
//   //             handasahBranch,
//   //           );
//   //           //
//   //           log("updated Locations list after getting coordinates and gis link");
//   //         } else {
//   //           //  call the function to post locations in database
//   //           log("address not exist >>>>>>>>> $addressInList");

//   //           //  call the function to post locations in database
//   //           // await DioNetworkRepos().createNewLocation(
//   //           //   address,
//   //           //   longitude,
//   //           //   latitude,
//   //           //   url, //updated(28-02-2026)
//   //           // );
//   //           //TODO: UPDATE_GET_GIS_LINK_HANDASAT_NAME_FORM_GIS_SERVER(ADD-HANDASAT-NAME-INPROGRESS-IN-21-02-2026)
//   //           await DioNetworkRepos().createNewLocation(
//   //             address,
//   //             longitude,
//   //             latitude,
//   //             gisUrl,
//   //             handasahBranch
//   //           );

//   //           log("POSTED new Location In Locations list after getting coordinates and gis link");
//   //         }

//   //         //update Locations list after getting coordinates

//   //         setState(() {
//   //           // getLocs = DioNetworkRepos().getLoc();
//   //           //update locations after getting coordinates and gis link
//   //           getLocsAfterGetCoordinatesAndGis =
//   //               DioNetworkRepos().getAllComplaintsNotFinished();
//   //           getLocsByHandasahNameAndTechinicianName =
//   //               DioNetworkRepos().getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");
//   //         });
//   //       } else {
//   //         setState(() {
//   //           coordinates = "Error: No results found";
//   //         });
//   //       }
//   //     } else {
//   //       setState(() {
//   //         coordinates = "Error: Failed to fetch data";
//   //       });
//   //     }
//   //   } catch (e) {
//   //     setState(() {
//   //       coordinates = "Error: Unable to get coordinates";
//   //     });
//   //   }
//   // }
//   // ==================== UI: _getCoordinatesFromAddress ====================

// // ==================== UI: _getCoordinatesFromAddress ====================

//   Future<void> _getCoordinatesFromAddress(String address) async {
//     final url = Uri.parse(
//       'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$googleMapsApiKey',
//     );

//     final GoogleMapController controller = await _controller.future;

//     try {
//       final response = await http.get(url);

//       // ── 1. HTTP error ──────────────────────────────────────────────────────
//       if (response.statusCode != 200) {
//         setState(() => coordinates = "Error: Failed to fetch data");
//         return;
//       }

//       final data = json.decode(response.body);

//       // ── 2. No geocode results ──────────────────────────────────────────────
//       if (data['results'] == null || data['results'].isEmpty) {
//         setState(() => coordinates = "Error: No results found");
//         return;
//       }

//       // ── 3. Extract coordinates ─────────────────────────────────────────────
//       final location = data['results'][0]['geometry']['location'];
//       latitude = location['lat'];
//       longitude = location['lng'];
//       coordinates = "Latitude: $latitude, Longitude: $longitude";

//       log("Address     :>> $address");
//       log("Coordinates :>> $coordinates");
//       log("Longitude   :>> $longitude");
//       log("Latitude    :>> $latitude");

//       // ── 4. Update map UI (marker + camera) ────────────────────────────────
//       setState(() {
//         pickMarkers.add(
//           Marker(
//             markerId: MarkerId(address),
//             position: LatLng(latitude, longitude),
//             infoWindow: InfoWindow(title: address, snippet: coordinates),
//             icon: BitmapDescriptor.defaultMarkerWithHue(
//               BitmapDescriptor.hueGreen,
//             ),
//           ),
//         );
//       });

//       await controller.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(target: LatLng(latitude, longitude), zoom: 15.0),
//         ),
//       );

//       // ── 5. GIS Integration ─────────────────────────────────────────────────
//       log('START-GIS-INTEGRATIONS');
//       await _runGisIntegration(address); // ✅ Separated into its own method

//       // ── 6. Refresh UI lists after everything is done ───────────────────────
//       setState(() {
//         getLocsAfterGetCoordinatesAndGis =
//             DioNetworkRepos().getAllComplaintsNotFinished();
//         getLocsByHandasahNameAndTechinicianName =
//             DioNetworkRepos().getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");
//       });
//     } catch (e) {
//       log("_getCoordinatesFromAddress error: $e");
//       setState(() => coordinates = "Error: Unable to get coordinates");
//     }
//   }

// // ── GIS Integration (separated so catch works correctly) ──────────────────
//   Future<void> _runGisIntegration(String address) async {
//     log("=== _runGisIntegration STARTED ===");
//     try {
//       log("=== CALLING getLastRecordNumberWeb ===");
//       final lastRecordNumber = await DioNetworkRepos().getLastRecordNumberWeb();
//       log("=== getLastRecordNumberWeb SUCCESS: $lastRecordNumber ===");

//       final newRecordNumber = lastRecordNumber + 1;

//       log("=== CALLING createNewGisPointAndGetMapLinkAndHandasah ===");
//       final result =
//           await DioNetworkRepos().createNewGisPointAndGetMapLinkAndHandasah(
//         newRecordNumber,
//         longitude.toString(),
//         latitude.toString(),
//       );
//       log("=== createNewGisPoint SUCCESS: $result ===");

//       final gisUrl = result['url'] as String? ?? 'لم يدرج';
//       final branch = result['engineering_branch'] as String? ?? 'لم يدرج';
//       final service = result['wtp_service'] as String? ?? 'لم يدرج';

//       log("GIS MAP LINK :>> $gisUrl");
//       log("GIS BRANCH   :>> $branch");
//       log("GIS SERVICE  :>> $service");

//       final handasahBranch =
//           convertGisHandasahNameToEmergencyHandasahName(branch);

//       log("=== CALLING _saveOrUpdateLocation WITH REAL DATA ===");
//       await _saveOrUpdateLocation(address, gisUrl, handasahBranch);
//       log("=== _saveOrUpdateLocation DONE ===");
//     } catch (gisError, stackTrace) {
//       log("=== GIS CATCH BLOCK REACHED ===");
//       log("=== gisError: $gisError ===");
//       log("=== stackTrace: $stackTrace ===");
//       log("=== CALLING _saveOrUpdateLocation WITH FALLBACK ===");
//       await _saveOrUpdateLocation(address, 'لم يدرج', 'لم يدرج');
//       log("=== FALLBACK _saveOrUpdateLocation DONE ===");
//     }

//     log("=== _runGisIntegration ENDED ===");
//   }

// // ── Helper: save new or update existing location ──────────────────────────

//   Future<void> _saveOrUpdateLocation(
//     String address,
//     String gisUrl,
//     String handasahBranch,
//   ) async {
//     try {
//       final addressExists = await DioNetworkRepos().checkAddressExists(address);
//       log("addressExists: $addressExists");

//       if (addressExists == true) {
//         log("Address already exists — updating...");
//         await DioNetworkRepos().updateLocations(
//           address,
//           longitude,
//           latitude,
//           gisUrl,
//           handasahBranch,
//         );
//         log("Location updated successfully.");
//       } else {
//         log("Address not found — creating new location...");
//         await DioNetworkRepos().createNewLocation(
//           address,
//           longitude,
//           latitude,
//           gisUrl,
//           handasahBranch,
//         );
//         log("New location created successfully.");
//       }
//     } catch (e) {
//       log("_saveOrUpdateLocation error: $e");
//     }
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
//           hintText: "اختر الهندسة",
//           dropdownItems: handasatItemsDropdownMenu,
//           onItemSelected: (value) {
//             log("Selected: $value");
//             setState(() {
//               DioNetworkRepos().updateLocAddHandasah(address, value);
//             });
//           },
//           onPressed: () async {
//             Navigator.of(context).pop();
//             await DioNetworkRepos().updateLocAddTechnician(address, "لم يدرج");
//             await DioNetworkRepos().updateLocAddIsApproved(address, 0);
//           },
//         );
//       },
//     );
//   }

// //handle dropdown click
//   void handleOptionClick(String value) {
//     // You can handle button actions here
//     log("Clicked: $value");
//     if (value == 'عرض التقارير') {
//       // Navigator.push(
//       //   context,
//       //   MaterialPageRoute(
//       //     builder: (context) => const ReportScreen(),
//       // ),
//       // );
//       context.go('/report');
//     } else if (value == 'الربط مع الاسكادا') {
//       CustomBrowserRedirect.openInBrowser(
//         'http://41.33.226.211:8070/roundpoint',
//         // 'http://192.168.30.12:80/roundpoint',
//       );
//     } else if (value == 'عرض المناطق المزدحمة بالبلاغات') {
//       CustomBrowserRedirect.openInBrowser(
//         'http://196.219.231.3:8000/webmap/breaks-hot-spots',
//       );
//     } else if (value == 'عرض تقرير الاسكادا Dashboard') {
//       // Navigator.push(
//       //   context,
//       //   MaterialPageRoute(
//       //     builder: (context) => const StationsDashboard(),
//       //   ),
//       // );
//       context.go('/dashboard');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           " غرفة الطوارئ",
//           style: TextStyle(
//             color: Colors.indigo,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         centerTitle: true,
//         elevation: 7,
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(
//           color: Colors.indigo,
//           size: 17,
//         ),
//         actions: [
//           IconButton(
//             padding: const EdgeInsets.symmetric(horizontal: 5),
//             tooltip: "تحديث شكاوى الخط الساخن",
//             hoverColor: Colors.yellow,
//             onPressed: () {
//               _initializeApp();
//             },
//             icon: const Icon(
//               Icons.refresh,
//               color: Colors.indigo,
//             ),
//           ),
//           IconButton(
//             padding: const EdgeInsets.symmetric(horizontal: 5),
//             tooltip: "إضافة مستخدمين الطوارئ",
//             hoverColor: Colors.yellow,
//             icon: const Icon(
//               Icons.person_add_alt,
//               color: Colors.indigo,
//             ),
//             onPressed: () {
//               //
//               showDialog(
//                   context: context,
//                   builder: (context) {
//                     return CustomReusableAlertDialog(
//                         title: 'اضافة مستخدمين الطوارئ',
//                         fieldLabels: const [
//                           'اسم المستخدم',
//                           'كلمة المرور',
//                           'مطابقة كلمة المرور',
//                         ],
//                         onSubmit: (values) {
//                           DioNetworkRepos().createNewUser(
//                               values[0], values[1], 1, 'غرفة الطوارئ');
//                         });
//                   });
//               log("User Input: updated Caller Name, Phone, And Borken Number");
//             },
//           ),
//           TextButtonDropdown(
//             label: 'التقارير',
//             options: const [
//               'عرض التقارير',
//               'الربط مع الاسكادا',
//               'عرض المناطق المزدحمة بالبلاغات',
//               'عرض تقرير الاسكادا Dashboard',
//             ],
//             onSelected: handleOptionClick,
//           ),
//         ],
//       ),
//       body: Row(
//         children: [
//           //TODO:INTEGRATION_WITH_GIS_TO_GET_HANDASAT_AUTOMATICALLY(INPROGRESS-21-02-2026-comment it for now)
//           Expanded(
//             flex: 1,
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//               width: 220,
//               height: MediaQuery.of(context).size.height,
//               // color: Colors.black45,
//               child: CustomEndDrawer(
//                 title: 'تخصيص شكاوى الهندسة',
//                 getLocs: getLocsByHandasahNameAndTechinicianName,
//                 stringListItems: handasatItemsDropdownMenu,
//                 onPressed: () {
//                   //
//                   setState(() {
//                     getLocsByHandasahNameAndTechinicianName = DioNetworkRepos()
//                         .getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");
//                     //update locations after getting coordinates
//                     getLocsAfterGetCoordinatesAndGis =
//                         DioNetworkRepos().getAllComplaintsNotFinished();
//                   });
//                 },
//                 hintText: 'فضلا أختار الهندسة',
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Padding(
//               padding: const EdgeInsets.only(top: 8.0),
//               child: Stack(
//                 children: [
//                   GoogleMap(
//                     initialCameraPosition: CameraPosition(
//                       target: alexandriaCoordinates,
//                       zoom: 10.4746,
//                     ),
//                     onMapCreated: (GoogleMapController controller) {
//                       _controller.complete(controller);
//                     },
//                     markers: pickMarkers,
//                     zoomControlsEnabled: true,
//                     onCameraMoveStarted: () async {
//                       //
//                       final GoogleMapController controller =
//                           await _controller.future;
//                       CameraPosition cameraPosition = CameraPosition(
//                         target: LatLng(latitude, longitude),
//                         zoom: 14,
//                       );
//                       controller.animateCamera(
//                           CameraUpdate.newCameraPosition(cameraPosition));
//                     },
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: TextField(
//                             decoration: InputDecoration(
//                               constraints: const BoxConstraints(
//                                 maxHeight: 70,
//                                 minWidth: 200,
//                               ),
//                               filled: true,
//                               fillColor: Colors.white,
//                               border: const OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(10.0),
//                                 ),
//                               ),
//                               hintText: "فضلا أدخل العنوان",
//                               hintStyle: TextStyle(
//                                 color: Colors.indigo[200],
//                                 fontSize: 11,
//                               ),
//                               labelText: "61 طريق الحرية الاسكندرية",
//                             ),
//                             controller:
//                                 addressController, // set the controller to get address input
//                             style: const TextStyle(
//                               fontSize: 13,
//                               color: Colors.indigo,
//                             ),
//                             cursorColor: Colors.indigo,
//                             keyboardType: TextInputType.text,
//                             maxLength: 250, textAlign: TextAlign.right,
//                             textDirection: TextDirection.rtl,
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(bottom: 17.0),
//                           child: IconButton(
//                             alignment: Alignment.center,
//                             onPressed: () async {
//                               if (addressController.text.isEmpty) {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text(
//                                       " فضلا ادخل العنوان, ثم اضغط على البحث",
//                                       textDirection: TextDirection.rtl,
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   ),
//                                 );
//                               }
//                               setState(() {
//                                 pickMarkers.clear();
//                                 address = addressController.text;
//                                 _getCoordinatesFromAddress(address);
//                                 addressController.clear();
//                                 //update locations after getting coordinates
//                                 // getLocs = DioNetworkRepos().getLoc();
//                                 //update locations after getting coordinates and gis link
//                                 getLocsAfterGetCoordinatesAndGis =
//                                     DioNetworkRepos()
//                                         .getAllComplaintsNotFinished();
//                                 getLocsByHandasahNameAndTechinicianName =
//                                     DioNetworkRepos()
//                                         .getLocByHandasahAndTechnician(
//                                             "لم يدرج", "لم يدرج");
//                               });
//                             },
//                             icon: const CircleAvatar(
//                               backgroundColor: Colors.indigo,
//                               radius: 20,
//                               child: Icon(
//                                 Icons.search_outlined,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//               width: 220,
//               height: MediaQuery.of(context).size.height,
//               color: Colors.black45,
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     Container(
//                       height: 40,
//                       color: Colors.indigo,
//                       child: const Center(
//                         child: Text(
//                           textDirection: TextDirection.rtl,
//                           textAlign: TextAlign.center,
//                           'جميع الشكاوى غير المغلقة',
//                           style: TextStyle(
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                     FutureBuilder(
//                         //TODO: update locations after getting coordinates and gis link and getLocsByHandasahName
//                         future: getLocsAfterGetCoordinatesAndGis,
//                         builder: (context, snapshot) {
//                           if (snapshot.hasData) {
//                             return ListView.builder(
//                               reverse: true,
//                               shrinkWrap: true,
//                               itemCount: snapshot.data!.length,
//                               itemBuilder: (context, index) {
//                                 return InkWell(
//                                   onTap: () {
//                                     //display bottom sheet
//                                     showCustomBottomSheet(
//                                       context,
//                                       "إعادة التوجيه للهندسة",
//                                       snapshot.data![index]['address'],
//                                       snapshot.data![index]['address'],
//                                     );
//                                   },
//                                   child: Card(
//                                     child: Column(
//                                       children: [
//                                         ListTile(
//                                           title: Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 vertical: 7.0, horizontal: 3.0),
//                                             child: Row(
//                                               children: [
//                                                 IconButton(
//                                                   tooltip:
//                                                       "إضافة بيانات البلاغ",
//                                                   onPressed: () {
//                                                     //
//                                                     showDialog(
//                                                       context: context,
//                                                       builder: (context) =>
//                                                           CustomReusableAlertDialogWithDropdown(
//                                                               title:
//                                                                   "تحديث بيانات البلاغ",
//                                                               fieldConfigs: const [
//                                                                 FieldConfig(
//                                                                   label:
//                                                                       "إسم المبلغ",
//                                                                   type: FieldType
//                                                                       .textField,
//                                                                 ),
//                                                                 FieldConfig(
//                                                                   label:
//                                                                       "قطر الماسورة",
//                                                                   type: FieldType
//                                                                       .dropdown,
//                                                                   dropdownItems: [
//                                                                     "``4",
//                                                                     "``6",
//                                                                     "``8",
//                                                                     "``10",
//                                                                     "``12",
//                                                                     "``20",
//                                                                     "``28",
//                                                                     "``40",
//                                                                     "``60",
//                                                                   ],
//                                                                 ),
//                                                                 FieldConfig(
//                                                                   label:
//                                                                       "رقم الموبيل",
//                                                                   type: FieldType
//                                                                       .textField,
//                                                                 ),
//                                                               ],
//                                                               onSubmit:
//                                                                   (values) {
//                                                                 log("User Input: $values"); // values[0]=Name, values[1]=Email, etc.
//                                                                 if (values[0] == "" ||
//                                                                     values[1] ==
//                                                                         "" ||
//                                                                     values[2] ==
//                                                                         "") {
//                                                                   ScaffoldMessenger.of(
//                                                                           context)
//                                                                       .showSnackBar(
//                                                                     const SnackBar(
//                                                                       content:
//                                                                           Text(
//                                                                         "يرجى ملء جميع الحقول",
//                                                                         textDirection:
//                                                                             TextDirection.rtl,
//                                                                         textAlign:
//                                                                             TextAlign.center,
//                                                                       ),
//                                                                     ),
//                                                                   );
//                                                                 } else {
//                                                                   DioNetworkRepos().updateLocationBrokenByAddress(
//                                                                       snapshot.data![
//                                                                               index]
//                                                                           [
//                                                                           'address'],
//                                                                       values[0],
//                                                                       values[1],
//                                                                       values[
//                                                                           2]);
//                                                                   log("User Input: updated Caller Name, Phone, And Borken Number");

//                                                                   //add number of affected people
//                                                                   pipDim =
//                                                                       values[1];
//                                                                   if (values[
//                                                                           1] ==
//                                                                       "``4") {
//                                                                     numberOfAffectedPeople =
//                                                                         2000;
//                                                                     aproxTimeFixing =
//                                                                         2;
//                                                                   } else if (values[
//                                                                           1] ==
//                                                                       "``6") {
//                                                                     numberOfAffectedPeople =
//                                                                         2500;
//                                                                     aproxTimeFixing =
//                                                                         2;
//                                                                   } else if (values[
//                                                                           1] ==
//                                                                       "``8") {
//                                                                     numberOfAffectedPeople =
//                                                                         4000;
//                                                                     aproxTimeFixing =
//                                                                         3;
//                                                                   } else if (values[
//                                                                           1] ==
//                                                                       "``10") {
//                                                                     numberOfAffectedPeople =
//                                                                         4200;
//                                                                     aproxTimeFixing =
//                                                                         3;
//                                                                   } else if (values[
//                                                                           1] ==
//                                                                       "``12") {
//                                                                     numberOfAffectedPeople =
//                                                                         5000;
//                                                                     aproxTimeFixing =
//                                                                         4;
//                                                                   } else if (values[
//                                                                           1] ==
//                                                                       "``20") {
//                                                                     numberOfAffectedPeople =
//                                                                         10000;
//                                                                     aproxTimeFixing =
//                                                                         5;
//                                                                   } else if (values[
//                                                                           1] ==
//                                                                       "``28") {
//                                                                     numberOfAffectedPeople =
//                                                                         15000;
//                                                                     aproxTimeFixing =
//                                                                         6;
//                                                                   } else if (values[
//                                                                           1] ==
//                                                                       "``40") {
//                                                                     numberOfAffectedPeople =
//                                                                         50000;
//                                                                     aproxTimeFixing =
//                                                                         8;
//                                                                   } else if (values[
//                                                                           1] ==
//                                                                       "``60") {
//                                                                     numberOfAffectedPeople =
//                                                                         100000;
//                                                                     aproxTimeFixing =
//                                                                         24;
//                                                                   }
//                                                                 }
//                                                               }),
//                                                     );
//                                                   },
//                                                   icon: const Icon(
//                                                     Icons.add_circle_outlined,
//                                                     color: Colors.indigo,
//                                                   ),
//                                                 ),
//                                                 Expanded(
//                                                   child: Text(
//                                                     textAlign: TextAlign.right,
//                                                     textDirection:
//                                                         TextDirection.rtl,
//                                                     snapshot.data![index]
//                                                         ['address'],
//                                                     style: const TextStyle(
//                                                       color: Colors.indigo,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontSize: 13,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           subtitle: Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 vertical: 7.0, horizontal: 3.0),
//                                             child: Column(
//                                               children: [
//                                                 Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .spaceBetween,
//                                                   children: [
//                                                     snapshot.data![index][
//                                                                 'handasah_name'] ==
//                                                             'لم يدرج'
//                                                         ? Expanded(
//                                                             child: Container(
//                                                               margin:
//                                                                   const EdgeInsets
//                                                                       .all(3.0),
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .symmetric(
//                                                                       horizontal:
//                                                                           3.0),
//                                                               decoration: BoxDecoration(
//                                                                   border: Border.all(
//                                                                       color: Colors
//                                                                           .orange,
//                                                                       width:
//                                                                           1.0),
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               5.0),
//                                                                   color: Colors
//                                                                       .orange),
//                                                               child: Text(
//                                                                 textAlign:
//                                                                     TextAlign
//                                                                         .center,
//                                                                 "قيد تخصيص هندسة",
//                                                                 style:
//                                                                     TextStyle(
//                                                                   overflow:
//                                                                       TextOverflow
//                                                                           .visible,
//                                                                   fontSize:
//                                                                       fontSize,
//                                                                   color: Colors
//                                                                       .white,
//                                                                   // fontWeight:
//                                                                   //     FontWeight
//                                                                   //         .bold,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           )
//                                                         : Expanded(
//                                                             child: Container(
//                                                               margin:
//                                                                   const EdgeInsets
//                                                                       .all(3.0),
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .symmetric(
//                                                                       horizontal:
//                                                                           1.0),
//                                                               decoration: BoxDecoration(
//                                                                   border: Border.all(
//                                                                       color: Colors
//                                                                           .green,
//                                                                       width:
//                                                                           1.0),
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               5.0),
//                                                                   color: Colors
//                                                                       .green),
//                                                               child: Text(
//                                                                 textAlign:
//                                                                     TextAlign
//                                                                         .center,
//                                                                 "${snapshot.data![index]['handasah_name']}",
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize:
//                                                                       fontSize,
//                                                                   color: Colors
//                                                                       .white,
//                                                                   // fontWeight:
//                                                                   //     FontWeight
//                                                                   //         .bold,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                     snapshot.data![index][
//                                                                 'technical_name'] ==
//                                                             "لم يدرج"
//                                                         ? Expanded(
//                                                             child: Container(
//                                                               margin:
//                                                                   const EdgeInsets
//                                                                       .all(3.0),
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .symmetric(
//                                                                       horizontal:
//                                                                           3.0),
//                                                               decoration: BoxDecoration(
//                                                                   border: Border.all(
//                                                                       color: Colors
//                                                                           .orange,
//                                                                       width:
//                                                                           1.0),
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               5.0),
//                                                                   color: Colors
//                                                                       .orange),
//                                                               child: Text(
//                                                                 textAlign:
//                                                                     TextAlign
//                                                                         .center,
//                                                                 "قيد تخصيص فنى",
//                                                                 style:
//                                                                     TextStyle(
//                                                                   overflow:
//                                                                       TextOverflow
//                                                                           .visible,
//                                                                   fontSize:
//                                                                       fontSize,
//                                                                   color: Colors
//                                                                       .white,
//                                                                   // fontWeight:
//                                                                   //     FontWeight
//                                                                   //         .bold,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           )
//                                                         : Expanded(
//                                                             child: Container(
//                                                               margin:
//                                                                   const EdgeInsets
//                                                                       .all(3.0),
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .symmetric(
//                                                                       horizontal:
//                                                                           3.0),
//                                                               decoration: BoxDecoration(
//                                                                   border: Border.all(
//                                                                       color: Colors
//                                                                           .green,
//                                                                       width:
//                                                                           1.0),
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               5.0),
//                                                                   color: Colors
//                                                                       .green),
//                                                               child: Text(
//                                                                 textAlign:
//                                                                     TextAlign
//                                                                         .center,
//                                                                 "${snapshot.data![index]['technical_name']}",
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize:
//                                                                       fontSize,
//                                                                   color: Colors
//                                                                       .white,
//                                                                   // fontWeight:
//                                                                   //     FontWeight
//                                                                   //         .bold,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                   ],
//                                                 ),
//                                                 Row(
//                                                   children: [
//                                                     Expanded(
//                                                       child: snapshot.data![
//                                                                       index][
//                                                                   'is_approved'] ==
//                                                               1
//                                                           ? Container(
//                                                               margin:
//                                                                   const EdgeInsets
//                                                                       .all(3.0),
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .symmetric(
//                                                                       horizontal:
//                                                                           3.0),
//                                                               decoration: BoxDecoration(
//                                                                   border: Border.all(
//                                                                       color: Colors
//                                                                           .green,
//                                                                       width:
//                                                                           1.0),
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               5.0),
//                                                                   color: Colors
//                                                                       .green),
//                                                               child: Text(
//                                                                 textAlign:
//                                                                     TextAlign
//                                                                         .center,
//                                                                 'تم قبول البلاغ',
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize:
//                                                                       fontSize,
//                                                                   color: Colors
//                                                                       .white,
//                                                                   // fontWeight:
//                                                                   //     FontWeight
//                                                                   //         .bold,
//                                                                 ),
//                                                               ),
//                                                             )
//                                                           : Container(
//                                                               margin:
//                                                                   const EdgeInsets
//                                                                       .all(3.0),
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .symmetric(
//                                                                       horizontal:
//                                                                           3.0),
//                                                               decoration: BoxDecoration(
//                                                                   border: Border.all(
//                                                                       color: Colors
//                                                                           .orange,
//                                                                       width:
//                                                                           1.0),
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               5.0),
//                                                                   color: Colors
//                                                                       .orange),
//                                                               child: Text(
//                                                                 textAlign:
//                                                                     TextAlign
//                                                                         .center,
//                                                                 'قيد قبول البلاغ',
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize:
//                                                                       fontSize,
//                                                                   color: Colors
//                                                                       .white,
//                                                                   // fontWeight:
//                                                                   //     FontWeight
//                                                                   //         .bold,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                     ),
//                                                     Expanded(
//                                                       child: snapshot.data![
//                                                                       index][
//                                                                   'broker_type'] !=
//                                                               "لم يدرج نوع الكسر"
//                                                           ? Container(
//                                                               margin:
//                                                                   const EdgeInsets
//                                                                       .all(3.0),
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .symmetric(
//                                                                       horizontal:
//                                                                           3.0),
//                                                               decoration: BoxDecoration(
//                                                                   border: Border.all(
//                                                                       color: Colors
//                                                                           .green,
//                                                                       width:
//                                                                           1.0),
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               5.0),
//                                                                   color: Colors
//                                                                       .green),
//                                                               child: Text(
//                                                                 textAlign:
//                                                                     TextAlign
//                                                                         .center,
//                                                                 '${snapshot.data![index]['broker_type']}',
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize:
//                                                                       fontSize,
//                                                                   color: Colors
//                                                                       .white,
//                                                                   // fontWeight:
//                                                                   //     FontWeight
//                                                                   //         .bold,
//                                                                 ),
//                                                               ),
//                                                             )
//                                                           : Container(
//                                                               margin:
//                                                                   const EdgeInsets
//                                                                       .all(3.0),
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .symmetric(
//                                                                       horizontal:
//                                                                           3.0),
//                                                               decoration: BoxDecoration(
//                                                                   border: Border.all(
//                                                                       color: Colors
//                                                                           .orange,
//                                                                       width:
//                                                                           1.0),
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               5.0),
//                                                                   color: Colors
//                                                                       .orange),
//                                                               child: Text(
//                                                                 textAlign:
//                                                                     TextAlign
//                                                                         .center,
//                                                                 'لم يدرج نوع الكسر',
//                                                                 style:
//                                                                     TextStyle(
//                                                                   fontSize:
//                                                                       fontSize,
//                                                                   color: Colors
//                                                                       .white,
//                                                                   // fontWeight:
//                                                                   //     FontWeight
//                                                                   //         .bold,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                     ),
//                                                   ],
//                                                 )
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceAround,
//                                           children: [
//                                             Expanded(
//                                               child: IconButton(
//                                                 tooltip:
//                                                     'التوجهه للخريطة GIS Map',
//                                                 hoverColor: Colors.yellow,
//                                                 onPressed: () {
//                                                   log("Start Gis Map ${snapshot.data![index]['gis_url']}");
//                                                   //TODO:MAKE-TOAST
//                                                   if(snapshot.data![index]['gis_url'] == 'لم يدرج'){
//                                                     //TODO:MAKE-TOAST
//                                                     Fluttertoast.showToast(
//                                                         msg:
//                                                             "لا يوجد رابط GIS Map",
//                                                         toastLength:
//                                                             Toast.LENGTH_SHORT,
//                                                         gravity:
//                                                             ToastGravity.CENTER,
//                                                         timeInSecForIosWeb: 1,
//                                                         backgroundColor:
//                                                             Colors.red,
//                                                         textColor: Colors.white,
//                                                         fontSize: 16.0);
//                                                   }else{

//                                                   //open in browser
//                                                   CustomBrowserRedirect
//                                                       .openInBrowser(
//                                                     snapshot.data![index]
//                                                         ['gis_url'],
//                                                   );
//                                                   }
//                                                   //open in iframe webview in web app
//                                                   // Navigator.push(
//                                                   //   context,
//                                                   //   MaterialPageRoute(
//                                                   //     builder: (context) =>
//                                                   //         IframeScreen(
//                                                   //             url: snapshot
//                                                   //                     .data![index]
//                                                   //                 ['gis_url']),
//                                                   //   ),
//                                                   // );

//                                                   //open in webview
//                                                   //   Navigator.push(
//                                                   //     context,
//                                                   //     MaterialPageRoute(
//                                                   //       builder: (context) =>
//                                                   //           CustomWebView(
//                                                   //         title: 'GIS Map webview',
//                                                   //         url: snapshot.data![index]
//                                                   //             ['gis_url'],
//                                                   //       ),
//                                                   //     ),
//                                                   //   );
//                                                 },
//                                                 icon: const Icon(
//                                                   Icons.open_in_browser,
//                                                   color: Colors.blue,
//                                                 ),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: IconButton(
//                                                 tooltip: 'اجراء مكالمة صوتية',
//                                                 hoverColor: Colors.yellow,
//                                                 onPressed: () =>
//                                                     //     VideoCallService
//                                                     //         .startVideoCall(
//                                                     //   context: context,
//                                                     //   userEmail:
//                                                     //       'awcoah@example.com',
//                                                     //   isInitiator: true,
//                                                     //   userName: 'ahmed',
//                                                     //   customRoomName: snapshot
//                                                     //       .data![index]['address'],
//                                                     // ),

//                                                     // 'EmergencyRoom'),
//                                                     CustomBrowserRedirect
//                                                         .openInBrowser(
//                                                             "https://meet.jit.si/${snapshot.data![index]['address']}"),
//                                                 icon: const Icon(
//                                                   Icons.call,
//                                                   color: Colors.green,
//                                                 ),
//                                               ),
//                                             ),
//                                             //TODO: DISABLED-VIDEO-CALL
//                                             // Expanded(
//                                             //   child: IconButton(
//                                             //     tooltip: 'أجراء مكالمة فيديو',
//                                             //     hoverColor: Colors.yellow,
//                                             //     onPressed: () {
//                                             //       log("Start Video Call ${snapshot.data![index]['id']}");
//                                             //       if (snapshot.data![index]
//                                             //               ['is_approved'] ==
//                                             //           0) {
//                                             //         ScaffoldMessenger.of(
//                                             //                 context)
//                                             //             .showSnackBar(
//                                             //           const SnackBar(
//                                             //               content: Text(
//                                             //             'لايمكن إجراء مكالمة فيديو قبل قبول الفنى البلاغ',
//                                             //             textDirection:
//                                             //                 TextDirection.rtl,
//                                             //             textAlign:
//                                             //                 TextAlign.center,
//                                             //           )),
//                                             //         );
//                                             //       } else {
//                                             //         //update video call status(23-03-2025)
//                                             //         DioNetworkRepos()
//                                             //             .updateLocationBrokenByAddressUpdateVideoCall(
//                                             //                 snapshot.data![
//                                             //                         index]
//                                             //                     ['address'],
//                                             //                 1);
//                                             //         //open video call
//                                             //         // Navigator.push(
//                                             //         //   context,
//                                             //         //   MaterialPageRoute(
//                                             //         //     builder: (context) =>
//                                             //         //         AgoraVideoCall(
//                                             //         //       title:
//                                             //         //           '${snapshot.data![index]['address']}',
//                                             //         //     ),
//                                             //         //   ),
//                                             //         // );

//                                             //         //open Video Call from online server
//                                             //         context.go(
//                                             //             '/mobile-caller/${snapshot.data![index]['address']}');
//                                             //         // context.go(
//                                             //         //     '/webrtc-mob/${snapshot.data![index]['address']}');

//                                             //         // Navigator.push(
//                                             //         //   context,
//                                             //         //   MaterialPageRoute(
//                                             //         //     builder: (context) =>
//                                             //         //         CallerMobileScreen(
//                                             //         //             addressTitle:
//                                             //         //                 '${snapshot.data![index]['address']}'),
//                                             //         //   ),
//                                             //         // );
//                                             //       }
//                                             //     },
//                                             //     icon: const Icon(
//                                             //       Icons.video_call,
//                                             //       color: Colors.green,
//                                             //     ),
//                                             //   ),
//                                             // ),
//                                             Expanded(
//                                               child: IconButton(
//                                                 tooltip: 'بدء تتبع فنى الهندسة',
//                                                 hoverColor: Colors.yellow,
//                                                 onPressed: () {
//                                                   log("Start Traking ${snapshot.data![index]['id']}");
//                                                   if (snapshot.data![index]
//                                                           ['is_approved'] ==
//                                                       0) {
//                                                     ScaffoldMessenger.of(
//                                                             context)
//                                                         .showSnackBar(
//                                                       const SnackBar(
//                                                           content: Text(
//                                                         'البلاغ قيد القبول وجارى التفعيل',
//                                                         textDirection:
//                                                             TextDirection.rtl,
//                                                         textAlign:
//                                                             TextAlign.center,
//                                                       )),
//                                                     );
//                                                   } else {
//                                                     // Navigator.push(
//                                                     //   context,
//                                                     //   MaterialPageRoute(
//                                                     //     builder: (context) =>
//                                                     //         Tracking(
//                                                     //       address:
//                                                     //           '${snapshot.data![index]['address']}',
//                                                     //       latitude:
//                                                     //           "${snapshot.data![index]['latitude']}",
//                                                     //       longitude:
//                                                     //           '${snapshot.data![index]['longitude']}',
//                                                     //       technicianName:
//                                                     //           '${snapshot.data![index]['technical_name']}',
//                                                     //     ),
//                                                     //   ),
//                                                     // );
//                                                     context.go(
//                                                         '/tracking/${snapshot.data![index]['address']}/${snapshot.data![index]['latitude']}/${snapshot.data![index]['longitude']}/${snapshot.data![index]['technical_name']}');
//                                                   }
//                                                 },
//                                                 icon: const Icon(
//                                                   Icons.location_on,
//                                                   color: Colors.red,
//                                                 ),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: IconButton(
//                                                 tooltip: 'جرد مخزن',
//                                                 hoverColor: Colors.yellow,
//                                                 onPressed: () async {
//                                                   //if store name is empty
//                                                   if (snapshot.data![index]
//                                                           ['handasah_name'] ==
//                                                       'لم يدرج') {
//                                                     ScaffoldMessenger.of(
//                                                             context)
//                                                         .showSnackBar(
//                                                       const SnackBar(
//                                                           content: Text(
//                                                         'عفوا, لايمكن إظهار جرد المخزن قبل تخصيص الهندسه',
//                                                         textDirection:
//                                                             TextDirection.rtl,
//                                                         textAlign:
//                                                             TextAlign.center,
//                                                       )),
//                                                     );
//                                                   } else {
//                                                     //get store name by handasah
//                                                     log("Store Name before get: $storeName");
//                                                     log("Handasah Name before get: ${snapshot.data![index]['handasah_name']}");

//                                                     //navigate to IntegrationWithStoresGetAllQty
//                                                     await DioNetworkRepos()
//                                                         .getStoreNameByHandasahName(
//                                                             snapshot.data![
//                                                                     index][
//                                                                 'handasah_name'])
//                                                         .then((value) {
//                                                       // setState(() {
//                                                       log(value['storeName']);
//                                                       storeName =
//                                                           value['storeName'];
//                                                       // });
//                                                     });
//                                                     log("Store Name after get: $storeName");

//                                                     //excute tempStoredProcedure
//                                                     DioNetworkRepos()
//                                                         .excuteTempStoreQty(
//                                                             storeName);
//                                                     // navigate to IntegrationWithStoresGetAllQty
//                                                     // Navigator.push(
//                                                     //   context,
//                                                     //   MaterialPageRoute(
//                                                     //     builder: (context) =>
//                                                     //         IntegrationWithStoresGetAllQty(
//                                                     //       storeName: storeName,
//                                                     //     ),
//                                                     //   ),
//                                                     // );
//                                                     context.go(
//                                                         '/integrate-with-stores/$storeName');
//                                                   }
//                                                 },
//                                                 icon: const Icon(
//                                                   Icons.store_outlined,
//                                                   color: Colors.indigo,
//                                                 ),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: IconButton(
//                                                 tooltip: 'الربط مع المعامل',
//                                                 hoverColor: Colors.yellow,
//                                                 onPressed: () {
//                                                   //TODO: HANDLE-HANDASAH-NAME-TO-LAB-CODE(31-MAR-2026)
//                                                   StaticVariables.labCode =
//                                                       convertHandasahToLabCode(
//                                                           snapshot.data![index][
//                                                               'handasah_name']);
//                                                   //
//                                                   StaticVariables.labName =
//                                                       convertLabCodeToLabName(
//                                                           StaticVariables
//                                                               .labCode);
//                                                   //
//                                                   log(snapshot.data![index]
//                                                           ['handasah_name'] +
//                                                       " ==========> before charts");
//                                                   log(snapshot.data![index]
//                                                           ['handasah_name'] +
//                                                       " ==========> before charts");

//                                                   log("LAB_CODE: ${StaticVariables.labCode}");
//                                                   log("LAB_NAME: ${StaticVariables.labName}");
//                                                   //navigate to DashboardChartsList
//                                                   context.go(
//                                                       '/integration-with-labs');
//                                                   // Navigator.push(
//                                                   //     context,
//                                                   //     MaterialPageRoute(
//                                                   //         builder: (BuildContext
//                                                   //                 context) =>
//                                                   //             DashboardChartsList()));
//                                                 },
//                                                 icon: const Icon(
//                                                   Icons.report_gmailerrorred,
//                                                   color: Colors.cyan,
//                                                 ),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: IconButton(
//                                                 tooltip: 'تتبع سيارة GPS',
//                                                 hoverColor: Colors.yellow,
//                                                 onPressed: () {},
//                                                 icon: const Icon(
//                                                   Icons.car_rental,
//                                                   color: Colors.indigo,
//                                                 ),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: IconButton(
//                                                 tooltip:
//                                                     "غرفة الطوارئ المتحركة",
//                                                 hoverColor: Colors.yellow,
//                                                 onPressed: () {
//                                                   // Navigator.push(
//                                                   //   context,
//                                                   //   MaterialPageRoute(
//                                                   //     builder: (context) =>
//                                                   //         const CallerScreen(),
//                                                   //   ),
//                                                   // );
//                                                   // context.go('/caller');
//                                                   CustomBrowserRedirect
//                                                       .openInBrowser(
//                                                           "https://meet.jit.si/mobileEmergencyRoom");
//                                                 },
//                                                 icon: const Icon(
//                                                   Icons.car_crash,
//                                                   color: Colors.purple,
//                                                 ),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: IconButton(
//                                                 tooltip: 'نظام الكاميرات',
//                                                 hoverColor: Colors.yellow,
//                                                 onPressed: () {
//                                                   //
//                                                   //navigate to IPCameraViewer
//                                                   // Navigator.push(
//                                                   //   context,
//                                                   //   MaterialPageRoute(
//                                                   //     builder: (context) =>
//                                                   //         const IPCameraViewer(
//                                                   //       cameraUrl:
//                                                   //           'http://196.219.231.5', // replace with your actual stream URL
//                                                   //     ),
//                                                   //   ),
//                                                   // );
//                                                   //TODO://ADD_IP_CAMERA(INTEGRATION_INPROGRESS)
//                                                   //navigate to Browser
//                                                   const url =
//                                                       mobileCarIpCameratbaseUrlLocalHost;
//                                                   // 'http://196.219.231.5';
//                                                   CustomBrowserRedirect
//                                                       .openInBrowser(
//                                                           url); // Open in browser
//                                                 },
//                                                 icon: const Icon(
//                                                   Icons.video_camera_back,
//                                                   color: Colors.black,
//                                                 ),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: IconButton(
//                                                 tooltip: 'الربط مع الاسكادا',
//                                                 hoverColor: Colors.yellow,
//                                                 onPressed: () {
//                                                   //open in browser
//                                                   CustomBrowserRedirect
//                                                       .openInBrowser(
//                                                           'http://41.33.226.211:8070/roundpoint' // Open in browser
//                                                           );
//                                                 },
//                                                 icon: const Icon(
//                                                   Icons
//                                                       .dashboard_customize_outlined,
//                                                   color: Colors.orange,
//                                                 ),
//                                               ),
//                                             ),
//                                             Expanded(
//                                               child: IconButton(
//                                                 tooltip: 'عرض بيانات البلاغ',
//                                                 hoverColor: Colors.yellow,
//                                                 onPressed: () {
//                                                   showDialog(
//                                                     context: context,
//                                                     builder: (context) =>
//                                                         CustomReusableTextAlertDialog(
//                                                       title: 'بيانات البلاغ',
//                                                       messages: [
//                                                         'العنوان :  ${snapshot.data![index]['address']}',
//                                                         'قطر الماسورة: ${snapshot.data![index]['broker_type']} ',
//                                                         snapshot.data![index][
//                                                                     'broker_type'] ==
//                                                                 pipDim
//                                                             ? 'عدد السكان المتوقع تأثرهم بالكسر: $numberOfAffectedPeople نسمة'
//                                                             : 'عدد السكان المتوقع تأثرهم بالكسر: لم يتم تعيين قطر الماسورة',
//                                                         snapshot.data![index][
//                                                                     'broker_type'] ==
//                                                                 pipDim
//                                                             ? 'زمن الاصلاح المتوقع: $aproxTimeFixing ساعة'
//                                                             : 'زمن الاصلاح المتوقع: عفوا لم يتم تعيين قطر الماسورة',
//                                                         'الاحداثئات :  ${snapshot.data![index]['latitude']} , ${snapshot.data[index]['longitude']}',
//                                                         snapshot.data![index][
//                                                                     'handasah_name'] ==
//                                                                 "لم يدرج"
//                                                             ? 'الهندسة: لم يتم تعيين هندسة'
//                                                             : 'الهندسة :  ${snapshot.data![index]['handasah_name']}',
//                                                         snapshot.data![index][
//                                                                     'technical_name'] ==
//                                                                 "لم يدرج"
//                                                             ? 'اسم فنى الهندسة: لم يتم تعيين فنى الهندسة'
//                                                             : 'إسم فنى الهندسة :  ${snapshot.data![index]['technical_name']}',
//                                                         'Gis-Link :  ${snapshot.data![index]['gis_url']}',
//                                                         'إسم المبلغ :  ${snapshot.data![index]['caller_name']}',
//                                                         ' رقم هاتف المبلغ:  ${snapshot.data![index]['caller_phone']}',
//                                                       ],
//                                                       actions: [
//                                                         Align(
//                                                           alignment: Alignment
//                                                               .bottomLeft,
//                                                           child: TextButton(
//                                                             onPressed: () =>
//                                                                 Navigator.of(
//                                                                         context)
//                                                                     .pop(),
//                                                             child: const Text(
//                                                                 'إغلاق'),
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   );
//                                                 },
//                                                 icon: const Icon(
//                                                   Icons.info,
//                                                   color: Colors.blueAccent,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                               // physics: const NeverScrollableScrollPhysics(),
//                             );
//                           }
//                           return const Center(
//                             child: Text('لا يوجد شكاوى مفتوحة'),
//                           );
//                         }),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       drawer: CustomDrawer(
//         title: 'الاعطال الواردة من الخط الساخن',
//         getLocs: getAllHotLineAddresses,
//         onTap: (itemData) {
//           try {
//             // Set the static values here
//             StaticVariables.hotlineAddress = itemData['address'];
//             StaticVariables.hotlineId = itemData['id'];
//             StaticVariables.hotlineX = itemData['x'];
//             StaticVariables.hotlineY = itemData['y'];
//             StaticVariables.hotlinecaseReportDateTime =
//                 itemData['caseReportDateTime'];
//             StaticVariables.hotlinefinalClosed = itemData['finalClosed'];
//             StaticVariables.hotlinereporterName = itemData['reporterName'];
//             StaticVariables.hotlinemainStreet = itemData['mainStreet'];
//             StaticVariables.hotlineStreet = itemData['street'];
//             StaticVariables.hotlinecaseType = itemData['caseType'];
//             //
//             DioNetworkRepos().postHotLineDataList(
//               id: StaticVariables.hotlineId,
//               caseReportDateTime: StaticVariables.hotlinecaseReportDateTime,
//               caseType: StaticVariables.hotlinecaseType,
//               finalClosed: StaticVariables.hotlinefinalClosed,
//               mainStreet: StaticVariables.hotlinemainStreet,
//               reporterName: StaticVariables.hotlinereporterName,
//               street: StaticVariables.hotlineStreet,
//               x: StaticVariables.hotlineX,
//               y: StaticVariables.hotlineY,
//               address: StaticVariables.hotlineAddress,
//             );
//             _getCoordinatesFromAddress(StaticVariables.hotlineAddress);

//             //update locations after getting coordinates and gis link
//             getLocsAfterGetCoordinatesAndGis =
//                 DioNetworkRepos().getAllComplaintsNotFinished();
//             getLocsByHandasahNameAndTechinicianName =
//                 DioNetworkRepos().getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");
//           } catch (e) {
//             log(e.toString());
//           }

//           // Then perform any other actions needed
//           Navigator.of(context).pop(); // Close the drawer
//         },
//       ),
//     );
//   }
// }
// ignore_for_file: use_build_context_synchronously

// import 'dart:async';
// import 'dart:collection';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;

// import '../custom_widget/custom_reusable_alert_dailog.dart';
// import '../custom_widget/custom_bottom_sheet.dart';
// import '../custom_widget/custom_browser_redirect.dart';
// import '../custom_widget/custom_drawer.dart';
// import '../custom_widget/custom_end_drawer.dart';
// import '../custom_widget/custom_reusable_alter_dialog_drop_down_textfield.dart';
// import '../custom_widget/custom_text_button_drop_down_menu.dart';
// import '../custom_widget/cutom_texts_alert_dailog.dart';
// import '../custom_widget/no_internet_widget.dart';
// import '../custom_widget/offline_banner.dart';
// import '../labs/widget/convert_handasah_to_lab_code.dart';
// import '../labs/widget/convert_lab_code_to_lab_name.dart';
// import '../network/remote/remote_network_repos.dart';
// import '../services/connectivity_service.dart';
// import '../utils/app_constants.dart';

// class AddressToCoordinates extends StatefulWidget {
//   const AddressToCoordinates({super.key});

//   @override
//   AddressToCoordinatesState createState() => AddressToCoordinatesState();
// }

// class AddressToCoordinatesState extends State<AddressToCoordinates> {
//   String storeName = "";
//   final Completer<GoogleMapController> _controller = Completer();
//   bool _isMapControllerReady = false;

//   String address = "";
//   String coordinates = "";
//   String getAddress = "";
//   LatLng alexandriaCoordinates = const LatLng(31.205753, 29.924526);
//   double latitude = 0.0, longitude = 0.0;
//   var pickMarkers = HashSet<Marker>();

//   // Initialize with empty Future to avoid late initialization errors
//   Future getLocsAfterGetCoordinatesAndGis = Future.value([]);
//   Future getLocsByHandasahNameAndTechinicianName = Future.value([]);
//   final TextEditingController addressController = TextEditingController();
//   Future getHandasatItemsDropdownMenu = Future.value([]);
//   List<String> handasatItemsDropdownMenu = [];
//   List<String> addHandasahToAddressList = [];

//   // Initialize with empty Future
//   Future<List<Map<String, dynamic>>> getAllHotLineAddresses = Future.value([]);

//   // Replace with your actual Google Maps API key
//   String googleMapsApiKey = "AIzaSyDRaJJnyvmDSU8OgI8M20C5nmwHNc_AMvk";
//   double fontSize = 12.0;
//   Timer? _timer; // Timer for periodic fetching
//   int numberOfAffectedPeople = 4;
//   double aproxTimeFixing = 1;
//   String pipDim = '4 mm';

//   // --- Internet connection state ---
//   bool _isLoading = true;
//   bool _isOnline = true;
//   bool _isOnlineChecked = false;
//   bool _hasData = false;
//   List<Map<String, dynamic>> _hotlineData = [];

//   @override
//   void dispose() {
//     _timer?.cancel();
//     addressController.dispose();
//     // Complete the controller if not already completed
//     if (!_controller.isCompleted) {
//       _controller.completeError('Widget disposed');
//     }
//     super.dispose();
//   }

//   //TODO:convert GIS-HANDASAH-NAME-TO-EMERGENCY-HANDASAH-NAME(inprogress-21-02-2026)
//   String convertGisHandasahNameToEmergencyHandasahName(
//       String emergencyHandasahPattern) {
//     const Map<String, String> patternToName = {
//       'ABUKEER/ابو قير': 'هندسة فرع أبو قير',
//       'MANDARA/المندرة': 'هندسة فرع المندرة',
//       'SIDIBISHR/سيدى بشر': 'هندسة فرع سيدى بشر',
//       'ELRAML/الرمل': 'هندسة فرع الرمل',
//       'ELBRAHEMIA/الابراهمية': 'هندسة فرع الابراهمية',
//       'ELNOZHA/النزهه': 'هندسة فرع النزهه',
//       'ELBALAD_MOHERMBK/البلد ومحرم بك': 'هندسة فرع البلد',
//       'ELQABBARI/القبارى': 'هندسة فرع القبارى',
//       'ELAGAMI/ العجمى': 'هندسة فرع العجمى',
//       'MADINET_NOUBARIA_ELGDIDA/مدينة النوباريه الجديدة': 'هندسة النوبارية',
//       'ELAMREYA/العامريه': 'هندسة فرع العامريه',
//       'ELBANGER/البنجر': 'هندسة بنجر السكر',
//       'BORGELARAB/برج العرب': 'هندسة برج العرب الجديده',
//       '6OCTOBER/6 اكتوبر': 'هندسة فرع 6 اكتوبر',
//       'ELMINA/الميناء': 'هندسة فرع الميناء',
//       'MARIOUT1/مريوط 1': 'هندسة فرع مريوط 1',
//     };

//     for (final entry in patternToName.entries) {
//       if (emergencyHandasahPattern.contains(entry.key)) {
//         return entry.value;
//       }
//     }

//     return emergencyHandasahPattern;
//   }

//   //initialize app(hotline data)
//   Future<void> _initializeApp() async {
//     if (!mounted) return;

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

//     try {
//       setState(() {
//         _isLoading = true;
//       });
//       final token = await DioNetworkRepos().getHotLineTokenByUserAndPassword();
//       final data = await DioNetworkRepos().getHotLineData(token);

//       if (!mounted) return;
//       setState(() {
//         _hotlineData = data;
//         getAllHotLineAddresses = Future.value(data);
//         _hasData = data.isNotEmpty;
//         _isLoading = false;
//       });
//     } catch (e) {
//       log("Error initializing app: $e");
//       if (!mounted) return;
//       final onlineAgain = await ConnectivityService.instance.hasConnection();
//       if (!mounted) return;
//       setState(() {
//         _isOnline = onlineAgain;
//         _isLoading = false;
//       });
//     }
//   }

//   //update in periodic time
//   void _startPeriodicFetch() {
//     const Duration fetchInterval = Duration(seconds: 10);
//     _timer = Timer.periodic(fetchInterval, (Timer timer) async {
//       // Check if widget is still mounted
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }

//       final online = await ConnectivityService.instance.hasConnection();
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }

//       if (!online) {
//         setState(() {
//           _isOnline = false;
//           _isOnlineChecked = true;
//         });
//         return;
//       }

//       if (mounted) {
//         setState(() {
//           _isOnline = true;
//           _isOnlineChecked = true;
//           getLocsAfterGetCoordinatesAndGis =
//               DioNetworkRepos().getAllComplaintsNotFinished();
//           getLocsByHandasahNameAndTechinicianName =
//               DioNetworkRepos().getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");
//         });
//       }
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initializeApp();
//     _fetchInitialData();
//     _fetchHandasatItems();
//     _startPeriodicFetch();
//   }

//   Future<void> _fetchInitialData() async {
//     if (!mounted) return;

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
//       getLocsAfterGetCoordinatesAndGis =
//           DioNetworkRepos().getAllComplaintsNotFinished();
//       getLocsByHandasahNameAndTechinicianName =
//           DioNetworkRepos().getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");
//     });

//     try {
//       final data = await getLocsAfterGetCoordinatesAndGis;
//       await getLocsByHandasahNameAndTechinicianName;
//       if (!mounted) return;
//       setState(() {
//         _hasData = data != null && data.isNotEmpty;
//       });
//     } catch (e) {
//       log("Error fetching initial data: $e");
//       if (!mounted) return;
//       final onlineAgain = await ConnectivityService.instance.hasConnection();
//       if (!mounted) return;
//       setState(() {
//         _isOnline = onlineAgain;
//       });
//     } finally {
//       if (!mounted) return;
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _fetchHandasatItems() async {
//     if (!mounted) return;

//     final online = await ConnectivityService.instance.hasConnection();
//     if (!online) return;

//     try {
//       final value = await DioNetworkRepos().fetchHandasatItemsDropdownMenu();
//       if (!mounted) return;
//       // Fix: Ensure we're working with List<String>
//       List<String> stringItems = [];
//       for (var item in value) {
//         stringItems.add(item.toString());
//       }
//       setState(() {
//         handasatItemsDropdownMenu = stringItems;
//       });
//       log("handasatItemsDropdownMenu from UI: $handasatItemsDropdownMenu");
//     } catch (e) {
//       log("Error fetching handasat items: $e");
//     }
//   }

//   // ==================== UI: _getCoordinatesFromAddress ====================

//   Future<void> _getCoordinatesFromAddress(String address) async {
//     if (!mounted) return;

//     final online = await ConnectivityService.instance.hasConnection();
//     if (!online) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             "لا يوجد إتصال بالإنترنت. يرجى التحقق من الإتصال والمحاولة مرة أخرى.",
//             textDirection: TextDirection.rtl,
//             textAlign: TextAlign.center,
//           ),
//           backgroundColor: Colors.red,
//         ),
//       );
//       setState(() {
//         _isOnline = false;
//         _isOnlineChecked = true;
//       });
//       return;
//     }

//     setState(() {
//       _isOnline = true;
//       _isOnlineChecked = true;
//       _isLoading = true;
//     });

//     final url = Uri.parse(
//       'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$googleMapsApiKey',
//     );

//     try {
//       // Wait for map controller to be ready with timeout
//       GoogleMapController controller;
//       try {
//         controller = await _controller.future.timeout(
//           const Duration(seconds: 10),
//           onTimeout: () {
//             log("Map controller timeout");
//             throw Exception("Map controller timeout");
//           },
//         );
//       } catch (e) {
//         log("Error getting map controller: $e");
//         setState(() {
//           _isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               "خطأ في تحميل الخريطة، يرجى إعادة المحاولة",
//               textDirection: TextDirection.rtl,
//               textAlign: TextAlign.center,
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       final response = await http.get(url);

//       if (response.statusCode != 200) {
//         setState(() => coordinates = "Error: Failed to fetch data");
//         return;
//       }

//       final data = json.decode(response.body);

//       if (data['results'] == null || data['results'].isEmpty) {
//         setState(() => coordinates = "Error: No results found");
//         return;
//       }

//       final location = data['results'][0]['geometry']['location'];
//       latitude = location['lat'];
//       longitude = location['lng'];
//       coordinates = "Latitude: $latitude, Longitude: $longitude";

//       log("Address     :>> $address");
//       log("Coordinates :>> $coordinates");
//       log("Longitude   :>> $longitude");
//       log("Latitude    :>> $latitude");

//       setState(() {
//         pickMarkers.add(
//           Marker(
//             markerId: MarkerId(address),
//             position: LatLng(latitude, longitude),
//             infoWindow: InfoWindow(title: address, snippet: coordinates),
//             icon: BitmapDescriptor.defaultMarkerWithHue(
//               BitmapDescriptor.hueGreen,
//             ),
//           ),
//         );
//       });

//       // Only animate camera if controller is ready
//       if (mounted && !_controller.isCompleted) {
//         try {
//           await controller.animateCamera(
//             CameraUpdate.newCameraPosition(
//               CameraPosition(target: LatLng(latitude, longitude), zoom: 15.0),
//             ),
//           );
//         } catch (e) {
//           log("Error animating camera: $e");
//         }
//       }

//       log('START-GIS-INTEGRATIONS');
//       await _runGisIntegration(address);

//       if (!mounted) return;
//       setState(() {
//         getLocsAfterGetCoordinatesAndGis =
//             DioNetworkRepos().getAllComplaintsNotFinished();
//         getLocsByHandasahNameAndTechinicianName =
//             DioNetworkRepos().getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");
//         _isLoading = false;
//       });
//     } catch (e) {
//       log("_getCoordinatesFromAddress error: $e");
//       setState(() => coordinates = "Error: Unable to get coordinates");
//       if (!mounted) return;
//       final onlineAgain = await ConnectivityService.instance.hasConnection();
//       if (!mounted) return;
//       setState(() {
//         _isOnline = onlineAgain;
//         _isLoading = false;
//       });
//     }
//   }

// // ── GIS Integration ─────────────────────────────────────────────────────────
//   Future<void> _runGisIntegration(String address) async {
//     log("=== _runGisIntegration STARTED ===");
//     try {
//       log("=== CALLING getLastRecordNumberWeb ===");
//       final lastRecordNumber = await DioNetworkRepos().getLastRecordNumberWeb();
//       log("=== getLastRecordNumberWeb SUCCESS: $lastRecordNumber ===");

//       final newRecordNumber = lastRecordNumber + 1;

//       log("=== CALLING createNewGisPointAndGetMapLinkAndHandasah ===");
//       final result =
//           await DioNetworkRepos().createNewGisPointAndGetMapLinkAndHandasah(
//         newRecordNumber,
//         longitude.toString(),
//         latitude.toString(),
//       );
//       log("=== createNewGisPoint SUCCESS: $result ===");

//       final gisUrl = result['url'] as String? ?? 'لم يدرج';
//       final branch = result['engineering_branch'] as String? ?? 'لم يدرج';
//       final service = result['wtp_service'] as String? ?? 'لم يدرج';

//       log("GIS MAP LINK :>> $gisUrl");
//       log("GIS BRANCH   :>> $branch");
//       log("GIS SERVICE  :>> $service");

//       final handasahBranch =
//           convertGisHandasahNameToEmergencyHandasahName(branch);

//       log("=== CALLING _saveOrUpdateLocation WITH REAL DATA ===");
//       await _saveOrUpdateLocation(address, gisUrl, handasahBranch);
//       log("=== _saveOrUpdateLocation DONE ===");
//     } catch (gisError, stackTrace) {
//       log("=== GIS CATCH BLOCK REACHED ===");
//       log("=== gisError: $gisError ===");
//       log("=== stackTrace: $stackTrace ===");
//       log("=== CALLING _saveOrUpdateLocation WITH FALLBACK ===");
//       await _saveOrUpdateLocation(address, 'لم يدرج', 'لم يدرج');
//       log("=== FALLBACK _saveOrUpdateLocation DONE ===");
//     }

//     log("=== _runGisIntegration ENDED ===");
//   }

// // ── Helper: save new or update existing location ──────────────────────────

//   Future<void> _saveOrUpdateLocation(
//     String address,
//     String gisUrl,
//     String handasahBranch,
//   ) async {
//     try {
//       final addressExists = await DioNetworkRepos().checkAddressExists(address);
//       log("addressExists: $addressExists");

//       if (addressExists == true) {
//         log("Address already exists — updating...");
//         await DioNetworkRepos().updateLocations(
//           address,
//           longitude,
//           latitude,
//           gisUrl,
//           handasahBranch,
//         );
//         log("Location updated successfully.");
//       } else {
//         log("Address not found — creating new location...");
//         await DioNetworkRepos().createNewLocation(
//           address,
//           longitude,
//           latitude,
//           gisUrl,
//           handasahBranch,
//         );
//         log("New location created successfully.");
//       }
//     } catch (e) {
//       log("_saveOrUpdateLocation error: $e");
//     }
//   }

//   //show bottom sheet Redirect to Handasat
//   void showCustomBottomSheet(
//       BuildContext context, String title, String message, String address) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: false,
//       builder: (context) {
//         return CustomBottomSheet(
//           title: title,
//           message: message,
//           hintText: "اختر الهندسة",
//           dropdownItems: handasatItemsDropdownMenu,
//           onItemSelected: (value) {
//             log("Selected: $value");
//             setState(() {
//               DioNetworkRepos().updateLocAddHandasah(address, value);
//             });
//           },
//           onPressed: () async {
//             Navigator.of(context).pop();
//             await DioNetworkRepos().updateLocAddTechnician(address, "لم يدرج");
//             await DioNetworkRepos().updateLocAddIsApproved(address, 0);
//           },
//         );
//       },
//     );
//   }

// //handle dropdown click
//   void handleOptionClick(String value) {
//     log("Clicked: $value");
//     if (value == 'عرض التقارير') {
//       context.go('/report');
//     } else if (value == 'الربط مع الاسكادا') {
//       CustomBrowserRedirect.openInBrowser(
//         'http://41.33.226.211:8070/roundpoint',
//       );
//     } else if (value == 'عرض المناطق المزدحمة بالبلاغات') {
//       CustomBrowserRedirect.openInBrowser(
//         'http://196.219.231.3:8000/webmap/breaks-hot-spots',
//       );
//     } else if (value == 'عرض تقرير الاسكادا Dashboard') {
//       context.go('/dashboard');
//     }
//   }

//   // //TODO://add alexandria to the address(6-8-2026)

//   String _normalizeAlexandriaAddress(String input) {
//     const variants = [
//       'الاسكندرية',
//       'الإسكندرية',
//       'الاسكندريه',
//       'الإسكندريه', // fixed: was missing leading "ال"
//     ];
//     const correct = 'الإسكندرية';

//     var address = input.trim();

//     final hasVariant = variants.any((v) => address.contains(v));

//     if (hasVariant) {
//       for (final v in variants) {
//         address = address.replaceAll(v, correct);
//       }
//     } else {
//       address = address.isEmpty ? correct : '$address $correct';
//     }

//     return address;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Determine if we should show NoInternetWidget
//     final showNoInternet = !_isOnline && !_hasData && _isOnlineChecked;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           " غرفة الطوارئ",
//           style: TextStyle(
//             color: Colors.indigo,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         centerTitle: true,
//         elevation: 7,
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(
//           color: Colors.indigo,
//           size: 17,
//         ),
//         actions: [
//           IconButton(
//             padding: const EdgeInsets.symmetric(horizontal: 5),
//             tooltip: "تحديث شكاوى الخط الساخن",
//             hoverColor: Colors.yellow,
//             onPressed: () {
//               _initializeApp();
//             },
//             icon: const Icon(
//               Icons.refresh,
//               color: Colors.indigo,
//             ),
//           ),
//           IconButton(
//             padding: const EdgeInsets.symmetric(horizontal: 5),
//             tooltip: "إضافة مستخدمين الطوارئ",
//             hoverColor: Colors.yellow,
//             icon: const Icon(
//               Icons.person_add_alt,
//               color: Colors.indigo,
//             ),
//             onPressed: () {
//               showDialog(
//                   context: context,
//                   builder: (context) {
//                     return CustomReusableAlertDialog(
//                         title: 'اضافة مستخدمين الطوارئ',
//                         fieldLabels: const [
//                           'اسم المستخدم',
//                           'كلمة المرور',
//                           'مطابقة كلمة المرور',
//                         ],
//                         onSubmit: (values) {
//                           DioNetworkRepos().createNewUser(
//                               values[0], values[1], 1, 'غرفة الطوارئ');
//                         });
//                   });
//             },
//           ),
//           TextButtonDropdown(
//             label: 'التقارير',
//             options: const [
//               'عرض التقارير',
//               'الربط مع الاسكادا',
//               'عرض المناطق المزدحمة بالبلاغات',
//               'عرض تقرير الاسكادا Dashboard',
//             ],
//             onSelected: handleOptionClick,
//           ),
//         ],
//       ),
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
//                             _hasData = false;
//                           });
//                           _fetchInitialData();
//                           _initializeApp();
//                           _fetchHandasatItems();
//                         },
//                       )
//                     : Row(
//                         children: [
//                           Expanded(
//                             flex: 1,
//                             child: Container(
//                               margin: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 8),
//                               width: 220,
//                               height: MediaQuery.of(context).size.height,
//                               child: CustomEndDrawer(
//                                 title: 'تخصيص شكاوى الهندسة',
//                                 getLocs:
//                                     getLocsByHandasahNameAndTechinicianName,
//                                 stringListItems: handasatItemsDropdownMenu,
//                                 onPressed: () {
//                                   setState(() {
//                                     getLocsByHandasahNameAndTechinicianName =
//                                         DioNetworkRepos()
//                                             .getLocByHandasahAndTechnician(
//                                                 "لم يدرج", "لم يدرج");
//                                     getLocsAfterGetCoordinatesAndGis =
//                                         DioNetworkRepos()
//                                             .getAllComplaintsNotFinished();
//                                   });
//                                 },
//                                 hintText: 'فضلا أختار الهندسة',
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             flex: 3,
//                             child: Padding(
//                               padding: const EdgeInsets.only(top: 8.0),
//                               child: Stack(
//                                 children: [
//                                   GoogleMap(
//                                     initialCameraPosition: CameraPosition(
//                                       target: alexandriaCoordinates,
//                                       zoom: 10.4746,
//                                     ),
//                                     onMapCreated:
//                                         (GoogleMapController controller) {
//                                       if (!_controller.isCompleted) {
//                                         _controller.complete(controller);
//                                       }
//                                       setState(() {
//                                         _isMapControllerReady = true;
//                                       });
//                                     },
//                                     markers: pickMarkers,
//                                     zoomControlsEnabled: true,
//                                     onCameraMoveStarted: () async {
//                                       // Only try to animate if controller is ready
//                                       if (_controller.isCompleted && mounted) {
//                                         try {
//                                           final GoogleMapController controller =
//                                               await _controller.future;
//                                           CameraPosition cameraPosition =
//                                               CameraPosition(
//                                             target: LatLng(latitude, longitude),
//                                             zoom: 14,
//                                           );
//                                           await controller.animateCamera(
//                                               CameraUpdate.newCameraPosition(
//                                                   cameraPosition));
//                                         } catch (e) {
//                                           log("Camera move error: $e");
//                                         }
//                                       }
//                                     },
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Row(
//                                       children: [
//                                         Expanded(
//                                           child: TextField(
//                                             decoration: InputDecoration(
//                                               constraints: const BoxConstraints(
//                                                 maxHeight: 70,
//                                                 minWidth: 200,
//                                               ),
//                                               filled: true,
//                                               fillColor: Colors.white,
//                                               border: const OutlineInputBorder(
//                                                 borderRadius: BorderRadius.all(
//                                                   Radius.circular(10.0),
//                                                 ),
//                                               ),
//                                               hintText: "فضلا أدخل العنوان",
//                                               hintStyle: TextStyle(
//                                                 color: Colors.indigo[200],
//                                                 fontSize: 11,
//                                               ),
//                                               labelText:
//                                                   "61 طريق الحرية الاسكندرية",
//                                             ),
//                                             controller: addressController,
//                                             style: const TextStyle(
//                                               fontSize: 13,
//                                               color: Colors.indigo,
//                                             ),
//                                             cursorColor: Colors.indigo,
//                                             keyboardType: TextInputType.text,
//                                             maxLength: 250,
//                                             textAlign: TextAlign.right,
//                                             textDirection: TextDirection.rtl,
//                                           ),
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.only(
//                                               bottom: 17.0),
//                                           child: IconButton(
//                                             alignment: Alignment.center,
//                                             // onPressed: () async {
//                                             //   if (addressController
//                                             //       .text.isEmpty) {
//                                             //     ScaffoldMessenger.of(context)
//                                             //         .showSnackBar(
//                                             //       const SnackBar(
//                                             //         content: Text(
//                                             //           " فضلا ادخل العنوان, ثم اضغط على البحث",
//                                             //           textDirection:
//                                             //               TextDirection.rtl,
//                                             //           textAlign:
//                                             //               TextAlign.center,
//                                             //         ),
//                                             //       ),
//                                             //     );
//                                             //     return;
//                                             //   }
//                                             //   setState(() {
//                                             //     pickMarkers.clear();
//                                             //     address =
//                                             //         addressController.text;
//                                             //     //  ================
//                                             //     //TODO://add alexandria to the address(6-8-2026)
//                                             //     address =
//                                             //         _normalizeAlexandriaAddress(
//                                             //             addressController.text);

//                                             //     // final variants = [
//                                             //     //   'الاسكندرية',
//                                             //     //   'الإسكندرية',
//                                             //     //   'الاسكنرديه',
//                                             //     //   'لإسكندريه',
//                                             //     // ];

//                                             //     // const correct = 'الإسكندرية';

//                                             //     // bool hasVariant = variants.any(
//                                             //     //     (v) => address.contains(v));

//                                             //     // if (hasVariant) {
//                                             //     //   for (final v in variants) {
//                                             //     //     address = address
//                                             //     //         .replaceAll(v, correct);
//                                             //     //   }
//                                             //     // } else {
//                                             //     //   address = '$address $correct';
//                                             //     // }

//                                             //     //  ================
//                                             //     _getCoordinatesFromAddress(
//                                             //         address);
//                                             //     addressController.clear();
//                                             //     getLocsAfterGetCoordinatesAndGis =
//                                             //         DioNetworkRepos()
//                                             //             .getAllComplaintsNotFinished();
//                                             //     getLocsByHandasahNameAndTechinicianName =
//                                             //         DioNetworkRepos()
//                                             //             .getLocByHandasahAndTechnician(
//                                             //                 "لم يدرج", "لم يدرج");
//                                             //   });
//                                             // },
//                                             onPressed: () async {
//                                               if (addressController
//                                                   .text.isEmpty) {
//                                                 ScaffoldMessenger.of(context)
//                                                     .showSnackBar(
//                                                   const SnackBar(
//                                                     content: Text(
//                                                       " فضلا ادخل العنوان, ثم اضغط على البحث",
//                                                       textDirection:
//                                                           TextDirection.rtl,
//                                                       textAlign:
//                                                           TextAlign.center,
//                                                     ),
//                                                   ),
//                                                 );
//                                                 return;
//                                               }

//                                               // 1) Pure, synchronous normalization — no setState needed for this part
//                                               final normalizedAddress =
//                                                   _normalizeAlexandriaAddress(
//                                                       addressController.text);

//                                               // 2) Sync UI updates only
//                                               setState(() {
//                                                 pickMarkers.clear();
//                                                 address = normalizedAddress;
//                                               });

//                                               addressController.clear();

//                                               // 3) Await the async geocode/connectivity call BEFORE touching state again
//                                               await _getCoordinatesFromAddress(
//                                                   address);

//                                               // 4) Now safely refresh the futures, only after the above completes
//                                               if (!mounted) return;
//                                               setState(() {
//                                                 getLocsAfterGetCoordinatesAndGis =
//                                                     DioNetworkRepos()
//                                                         .getAllComplaintsNotFinished();
//                                                 getLocsByHandasahNameAndTechinicianName =
//                                                     DioNetworkRepos()
//                                                         .getLocByHandasahAndTechnician(
//                                                             "لم يدرج", "لم يدرج");
//                                               });
//                                             },
//                                             icon: const CircleAvatar(
//                                               backgroundColor: Colors.indigo,
//                                               radius: 20,
//                                               child: Icon(
//                                                 Icons.search_outlined,
//                                                 color: Colors.white,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             flex: 1,
//                             child: Container(
//                               margin: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 8),
//                               width: 220,
//                               height: MediaQuery.of(context).size.height,
//                               color: Colors.black45,
//                               child: SingleChildScrollView(
//                                 child: Column(
//                                   children: [
//                                     Container(
//                                       height: 40,
//                                       color: Colors.indigo,
//                                       child: const Center(
//                                         child: Text(
//                                           textDirection: TextDirection.rtl,
//                                           textAlign: TextAlign.center,
//                                           'جميع الشكاوى غير المغلقة',
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     FutureBuilder(
//                                         future:
//                                             getLocsAfterGetCoordinatesAndGis,
//                                         builder: (context, snapshot) {
//                                           if (snapshot.connectionState ==
//                                               ConnectionState.waiting) {
//                                             return const Center(
//                                                 child:
//                                                     CircularProgressIndicator());
//                                           }
//                                           if (snapshot.hasError) {
//                                             return Center(
//                                               child: Column(
//                                                 children: [
//                                                   const Text(
//                                                       'حدث خطأ في تحميل البيانات'),
//                                                   ElevatedButton(
//                                                     onPressed: () {
//                                                       setState(() {
//                                                         getLocsAfterGetCoordinatesAndGis =
//                                                             DioNetworkRepos()
//                                                                 .getAllComplaintsNotFinished();
//                                                       });
//                                                     },
//                                                     child: const Text(
//                                                         'إعادة المحاولة'),
//                                                   ),
//                                                 ],
//                                               ),
//                                             );
//                                           }
//                                           if (snapshot.hasData &&
//                                               snapshot.data!.isNotEmpty) {
//                                             return ListView.builder(
//                                               reverse: true,
//                                               shrinkWrap: true,
//                                               itemCount: snapshot.data!.length,
//                                               itemBuilder: (context, index) {
//                                                 final item =
//                                                     snapshot.data![index];
//                                                 return InkWell(
//                                                   onTap: () {
//                                                     showCustomBottomSheet(
//                                                       context,
//                                                       "إعادة التوجيه للهندسة",
//                                                       item['address'],
//                                                       item['address'],
//                                                     );
//                                                   },
//                                                   child: Card(
//                                                     child: Column(
//                                                       children: [
//                                                         ListTile(
//                                                           title: Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .symmetric(
//                                                                     vertical:
//                                                                         7.0,
//                                                                     horizontal:
//                                                                         3.0),
//                                                             child: Row(
//                                                               children: [
//                                                                 IconButton(
//                                                                   tooltip:
//                                                                       "إضافة بيانات البلاغ",
//                                                                   onPressed:
//                                                                       () {
//                                                                     showDialog(
//                                                                       context:
//                                                                           context,
//                                                                       builder: (context) => CustomReusableAlertDialogWithDropdown(
//                                                                           title: "تحديث بيانات البلاغ",
//                                                                           fieldConfigs: const [
//                                                                             FieldConfig(
//                                                                               label: "إسم المبلغ",
//                                                                               type: FieldType.textField,
//                                                                             ),
//                                                                             FieldConfig(
//                                                                               label: "قطر الماسورة",
//                                                                               type: FieldType.dropdown,
//                                                                               dropdownItems: [
//                                                                                 "``4",
//                                                                                 "``6",
//                                                                                 "``8",
//                                                                                 "``10",
//                                                                                 "``12",
//                                                                                 "``20",
//                                                                                 "``28",
//                                                                                 "``40",
//                                                                                 "``60"
//                                                                               ],
//                                                                             ),
//                                                                             FieldConfig(
//                                                                               label: "رقم الموبيل",
//                                                                               type: FieldType.textField,
//                                                                             ),
//                                                                           ],
//                                                                           onSubmit: (values) {
//                                                                             log("User Input: $values");
//                                                                             if (values[0] == "" ||
//                                                                                 values[1] == "" ||
//                                                                                 values[2] == "") {
//                                                                               ScaffoldMessenger.of(context).showSnackBar(
//                                                                                 const SnackBar(
//                                                                                   content: Text(
//                                                                                     "يرجى ملء جميع الحقول",
//                                                                                     textDirection: TextDirection.rtl,
//                                                                                     textAlign: TextAlign.center,
//                                                                                   ),
//                                                                                 ),
//                                                                               );
//                                                                             } else {
//                                                                               DioNetworkRepos().updateLocationBrokenByAddress(item['address'], values[0], values[1], values[2]);
//                                                                               log("User Input: updated Caller Name, Phone, And Borken Number");
//                                                                               pipDim = values[1];
//                                                                               // Update affected people based on pipe diameter
//                                                                               if (values[1] == "``4") {
//                                                                                 numberOfAffectedPeople = 2000;
//                                                                                 aproxTimeFixing = 2;
//                                                                               } else if (values[1] == "``6") {
//                                                                                 numberOfAffectedPeople = 2500;
//                                                                                 aproxTimeFixing = 2;
//                                                                               } else if (values[1] == "``8") {
//                                                                                 numberOfAffectedPeople = 4000;
//                                                                                 aproxTimeFixing = 3;
//                                                                               } else if (values[1] == "``10") {
//                                                                                 numberOfAffectedPeople = 4200;
//                                                                                 aproxTimeFixing = 3;
//                                                                               } else if (values[1] == "``12") {
//                                                                                 numberOfAffectedPeople = 5000;
//                                                                                 aproxTimeFixing = 4;
//                                                                               } else if (values[1] == "``20") {
//                                                                                 numberOfAffectedPeople = 10000;
//                                                                                 aproxTimeFixing = 5;
//                                                                               } else if (values[1] == "``28") {
//                                                                                 numberOfAffectedPeople = 15000;
//                                                                                 aproxTimeFixing = 6;
//                                                                               } else if (values[1] == "``40") {
//                                                                                 numberOfAffectedPeople = 50000;
//                                                                                 aproxTimeFixing = 8;
//                                                                               } else if (values[1] == "``60") {
//                                                                                 numberOfAffectedPeople = 100000;
//                                                                                 aproxTimeFixing = 24;
//                                                                               }
//                                                                             }
//                                                                           }),
//                                                                     );
//                                                                   },
//                                                                   icon:
//                                                                       const Icon(
//                                                                     Icons
//                                                                         .add_circle_outlined,
//                                                                     color: Colors
//                                                                         .indigo,
//                                                                   ),
//                                                                 ),
//                                                                 Expanded(
//                                                                   child: Text(
//                                                                     textAlign:
//                                                                         TextAlign
//                                                                             .right,
//                                                                     textDirection:
//                                                                         TextDirection
//                                                                             .rtl,
//                                                                     item[
//                                                                         'address'],
//                                                                     style:
//                                                                         const TextStyle(
//                                                                       color: Colors
//                                                                           .indigo,
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .bold,
//                                                                       fontSize:
//                                                                           13,
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                           subtitle: Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .symmetric(
//                                                                     vertical:
//                                                                         7.0,
//                                                                     horizontal:
//                                                                         3.0),
//                                                             child: Column(
//                                                               children: [
//                                                                 Row(
//                                                                   mainAxisAlignment:
//                                                                       MainAxisAlignment
//                                                                           .spaceBetween,
//                                                                   children: [
//                                                                     item['handasah_name'] ==
//                                                                             'لم يدرج'
//                                                                         ? Expanded(
//                                                                             child:
//                                                                                 Container(
//                                                                               margin: const EdgeInsets.all(3.0),
//                                                                               padding: const EdgeInsets.symmetric(horizontal: 3.0),
//                                                                               decoration: BoxDecoration(
//                                                                                 border: Border.all(color: Colors.orange, width: 1.0),
//                                                                                 borderRadius: BorderRadius.circular(5.0),
//                                                                                 color: Colors.orange,
//                                                                               ),
//                                                                               child: Text(
//                                                                                 textAlign: TextAlign.center,
//                                                                                 "قيد تخصيص هندسة",
//                                                                                 style: TextStyle(
//                                                                                   overflow: TextOverflow.visible,
//                                                                                   fontSize: fontSize,
//                                                                                   color: Colors.white,
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                           )
//                                                                         : Expanded(
//                                                                             child:
//                                                                                 Container(
//                                                                               margin: const EdgeInsets.all(3.0),
//                                                                               padding: const EdgeInsets.symmetric(horizontal: 1.0),
//                                                                               decoration: BoxDecoration(
//                                                                                 border: Border.all(color: Colors.green, width: 1.0),
//                                                                                 borderRadius: BorderRadius.circular(5.0),
//                                                                                 color: Colors.green,
//                                                                               ),
//                                                                               child: Text(
//                                                                                 textAlign: TextAlign.center,
//                                                                                 "${item['handasah_name']}",
//                                                                                 style: TextStyle(
//                                                                                   fontSize: fontSize,
//                                                                                   color: Colors.white,
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                     item['technical_name'] ==
//                                                                             "لم يدرج"
//                                                                         ? Expanded(
//                                                                             child:
//                                                                                 Container(
//                                                                               margin: const EdgeInsets.all(3.0),
//                                                                               padding: const EdgeInsets.symmetric(horizontal: 3.0),
//                                                                               decoration: BoxDecoration(
//                                                                                 border: Border.all(color: Colors.orange, width: 1.0),
//                                                                                 borderRadius: BorderRadius.circular(5.0),
//                                                                                 color: Colors.orange,
//                                                                               ),
//                                                                               child: Text(
//                                                                                 textAlign: TextAlign.center,
//                                                                                 "قيد تخصيص فنى",
//                                                                                 style: TextStyle(
//                                                                                   overflow: TextOverflow.visible,
//                                                                                   fontSize: fontSize,
//                                                                                   color: Colors.white,
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                           )
//                                                                         : Expanded(
//                                                                             child:
//                                                                                 Container(
//                                                                               margin: const EdgeInsets.all(3.0),
//                                                                               padding: const EdgeInsets.symmetric(horizontal: 3.0),
//                                                                               decoration: BoxDecoration(
//                                                                                 border: Border.all(color: Colors.green, width: 1.0),
//                                                                                 borderRadius: BorderRadius.circular(5.0),
//                                                                                 color: Colors.green,
//                                                                               ),
//                                                                               child: Text(
//                                                                                 textAlign: TextAlign.center,
//                                                                                 "${item['technical_name']}",
//                                                                                 style: TextStyle(
//                                                                                   fontSize: fontSize,
//                                                                                   color: Colors.white,
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                   ],
//                                                                 ),
//                                                                 Row(
//                                                                   children: [
//                                                                     Expanded(
//                                                                       child: item['is_approved'] ==
//                                                                               1
//                                                                           ? Container(
//                                                                               margin: const EdgeInsets.all(3.0),
//                                                                               padding: const EdgeInsets.symmetric(horizontal: 3.0),
//                                                                               decoration: BoxDecoration(
//                                                                                 border: Border.all(color: Colors.green, width: 1.0),
//                                                                                 borderRadius: BorderRadius.circular(5.0),
//                                                                                 color: Colors.green,
//                                                                               ),
//                                                                               child: Text(
//                                                                                 textAlign: TextAlign.center,
//                                                                                 'تم قبول البلاغ',
//                                                                                 style: TextStyle(
//                                                                                   fontSize: fontSize,
//                                                                                   color: Colors.white,
//                                                                                 ),
//                                                                               ),
//                                                                             )
//                                                                           : Container(
//                                                                               margin: const EdgeInsets.all(3.0),
//                                                                               padding: const EdgeInsets.symmetric(horizontal: 3.0),
//                                                                               decoration: BoxDecoration(
//                                                                                 border: Border.all(color: Colors.orange, width: 1.0),
//                                                                                 borderRadius: BorderRadius.circular(5.0),
//                                                                                 color: Colors.orange,
//                                                                               ),
//                                                                               child: Text(
//                                                                                 textAlign: TextAlign.center,
//                                                                                 'قيد قبول البلاغ',
//                                                                                 style: TextStyle(
//                                                                                   fontSize: fontSize,
//                                                                                   color: Colors.white,
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                     ),
//                                                                     Expanded(
//                                                                       child: item['broker_type'] !=
//                                                                               "لم يدرج نوع الكسر"
//                                                                           ? Container(
//                                                                               margin: const EdgeInsets.all(3.0),
//                                                                               padding: const EdgeInsets.symmetric(horizontal: 3.0),
//                                                                               decoration: BoxDecoration(
//                                                                                 border: Border.all(color: Colors.green, width: 1.0),
//                                                                                 borderRadius: BorderRadius.circular(5.0),
//                                                                                 color: Colors.green,
//                                                                               ),
//                                                                               child: Text(
//                                                                                 textAlign: TextAlign.center,
//                                                                                 '${item['broker_type']}',
//                                                                                 style: TextStyle(
//                                                                                   fontSize: fontSize,
//                                                                                   color: Colors.white,
//                                                                                 ),
//                                                                               ),
//                                                                             )
//                                                                           : Container(
//                                                                               margin: const EdgeInsets.all(3.0),
//                                                                               padding: const EdgeInsets.symmetric(horizontal: 3.0),
//                                                                               decoration: BoxDecoration(
//                                                                                 border: Border.all(color: Colors.orange, width: 1.0),
//                                                                                 borderRadius: BorderRadius.circular(5.0),
//                                                                                 color: Colors.orange,
//                                                                               ),
//                                                                               child: Text(
//                                                                                 textAlign: TextAlign.center,
//                                                                                 'لم يدرج نوع الكسر',
//                                                                                 style: TextStyle(
//                                                                                   fontSize: fontSize,
//                                                                                   color: Colors.white,
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                     ),
//                                                                   ],
//                                                                 )
//                                                               ],
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         // ALL ICON BUTTONS
//                                                         Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .spaceAround,
//                                                           children: [
//                                                             // GIS Map
//                                                             Expanded(
//                                                               child: IconButton(
//                                                                 tooltip:
//                                                                     'التوجهه للخريطة GIS Map',
//                                                                 hoverColor:
//                                                                     Colors
//                                                                         .yellow,
//                                                                 onPressed: () {
//                                                                   log("Start Gis Map ${item['gis_url']}");
//                                                                   if (item[
//                                                                           'gis_url'] ==
//                                                                       'لم يدرج') {
//                                                                     Fluttertoast.showToast(
//                                                                         msg:
//                                                                             "لا يوجد رابط GIS Map",
//                                                                         toastLength:
//                                                                             Toast
//                                                                                 .LENGTH_SHORT,
//                                                                         gravity:
//                                                                             ToastGravity
//                                                                                 .CENTER,
//                                                                         timeInSecForIosWeb:
//                                                                             1,
//                                                                         backgroundColor:
//                                                                             Colors
//                                                                                 .red,
//                                                                         textColor:
//                                                                             Colors
//                                                                                 .white,
//                                                                         fontSize:
//                                                                             16.0);
//                                                                   } else {
//                                                                     CustomBrowserRedirect
//                                                                         .openInBrowser(
//                                                                             item['gis_url']);
//                                                                   }
//                                                                 },
//                                                                 icon: const Icon(
//                                                                     Icons
//                                                                         .open_in_browser,
//                                                                     color: Colors
//                                                                         .blue),
//                                                               ),
//                                                             ),
//                                                             // Voice Call
//                                                             Expanded(
//                                                               child: IconButton(
//                                                                 tooltip:
//                                                                     'اجراء مكالمة صوتية',
//                                                                 hoverColor:
//                                                                     Colors
//                                                                         .yellow,
//                                                                 onPressed: () =>
//                                                                     CustomBrowserRedirect
//                                                                         .openInBrowser(
//                                                                             "https://meet.jit.si/${item['address']}"),
//                                                                 icon: const Icon(
//                                                                     Icons.call,
//                                                                     color: Colors
//                                                                         .green),
//                                                               ),
//                                                             ),
//                                                             // Tracking
//                                                             Expanded(
//                                                               child: IconButton(
//                                                                 tooltip:
//                                                                     'بدء تتبع فنى الهندسة',
//                                                                 hoverColor:
//                                                                     Colors
//                                                                         .yellow,
//                                                                 onPressed: () {
//                                                                   log("Start Traking ${item['id']}");
//                                                                   if (item[
//                                                                           'is_approved'] ==
//                                                                       0) {
//                                                                     ScaffoldMessenger.of(
//                                                                             context)
//                                                                         .showSnackBar(
//                                                                       const SnackBar(
//                                                                         content:
//                                                                             Text(
//                                                                           'البلاغ قيد القبول وجارى التفعيل',
//                                                                           textDirection:
//                                                                               TextDirection.rtl,
//                                                                           textAlign:
//                                                                               TextAlign.center,
//                                                                         ),
//                                                                       ),
//                                                                     );
//                                                                   } else {
//                                                                     context.go(
//                                                                         '/tracking/${item['address']}/${item['latitude']}/${item['longitude']}/${item['technical_name']}');
//                                                                   }
//                                                                 },
//                                                                 icon: const Icon(
//                                                                     Icons
//                                                                         .location_on,
//                                                                     color: Colors
//                                                                         .red),
//                                                               ),
//                                                             ),
//                                                             // Store Inventory
//                                                             Expanded(
//                                                               child: IconButton(
//                                                                 tooltip:
//                                                                     'جرد مخزن',
//                                                                 hoverColor:
//                                                                     Colors
//                                                                         .yellow,
//                                                                 onPressed:
//                                                                     () async {
//                                                                   if (item[
//                                                                           'handasah_name'] ==
//                                                                       'لم يدرج') {
//                                                                     ScaffoldMessenger.of(
//                                                                             context)
//                                                                         .showSnackBar(
//                                                                       const SnackBar(
//                                                                         content:
//                                                                             Text(
//                                                                           'عفوا, لايمكن إظهار جرد المخزن قبل تخصيص الهندسه',
//                                                                           textDirection:
//                                                                               TextDirection.rtl,
//                                                                           textAlign:
//                                                                               TextAlign.center,
//                                                                         ),
//                                                                       ),
//                                                                     );
//                                                                   } else {
//                                                                     await DioNetworkRepos()
//                                                                         .getStoreNameByHandasahName(item[
//                                                                             'handasah_name'])
//                                                                         .then(
//                                                                             (value) {
//                                                                       storeName =
//                                                                           value[
//                                                                               'storeName'];
//                                                                     });
//                                                                     DioNetworkRepos()
//                                                                         .excuteTempStoreQty(
//                                                                             storeName);
//                                                                     context.go(
//                                                                         '/integrate-with-stores/$storeName');
//                                                                   }
//                                                                 },
//                                                                 icon: const Icon(
//                                                                     Icons
//                                                                         .store_outlined,
//                                                                     color: Colors
//                                                                         .indigo),
//                                                               ),
//                                                             ),
//                                                             // Labs Integration
//                                                             Expanded(
//                                                               child: IconButton(
//                                                                 tooltip:
//                                                                     'الربط مع المعامل',
//                                                                 hoverColor:
//                                                                     Colors
//                                                                         .yellow,
//                                                                 onPressed: () {
//                                                                   StaticVariables
//                                                                           .labCode =
//                                                                       convertHandasahToLabCode(
//                                                                           item[
//                                                                               'handasah_name']);
//                                                                   StaticVariables
//                                                                           .labName =
//                                                                       convertLabCodeToLabName(
//                                                                           StaticVariables
//                                                                               .labCode);
//                                                                   log("LAB_CODE: ${StaticVariables.labCode}");
//                                                                   log("LAB_NAME: ${StaticVariables.labName}");
//                                                                   context.go(
//                                                                       '/integration-with-labs');
//                                                                 },
//                                                                 icon: const Icon(
//                                                                     Icons
//                                                                         .report_gmailerrorred,
//                                                                     color: Colors
//                                                                         .cyan),
//                                                               ),
//                                                             ),
//                                                             // GPS Car Tracking
//                                                             Expanded(
//                                                               child: IconButton(
//                                                                 tooltip:
//                                                                     'تتبع سيارة GPS',
//                                                                 hoverColor:
//                                                                     Colors
//                                                                         .yellow,
//                                                                 onPressed:
//                                                                     () {},
//                                                                 icon: const Icon(
//                                                                     Icons
//                                                                         .car_rental,
//                                                                     color: Colors
//                                                                         .indigo),
//                                                               ),
//                                                             ),
//                                                             // Mobile Emergency Room
//                                                             Expanded(
//                                                               child: IconButton(
//                                                                 tooltip:
//                                                                     "غرفة الطوارئ المتحركة",
//                                                                 hoverColor:
//                                                                     Colors
//                                                                         .yellow,
//                                                                 onPressed: () {
//                                                                   CustomBrowserRedirect
//                                                                       .openInBrowser(
//                                                                           "https://meet.jit.si/mobileEmergencyRoom");
//                                                                 },
//                                                                 icon: const Icon(
//                                                                     Icons
//                                                                         .car_crash,
//                                                                     color: Colors
//                                                                         .purple),
//                                                               ),
//                                                             ),
//                                                             // Camera System
//                                                             Expanded(
//                                                               child: IconButton(
//                                                                 tooltip:
//                                                                     'نظام الكاميرات',
//                                                                 hoverColor:
//                                                                     Colors
//                                                                         .yellow,
//                                                                 onPressed: () {
//                                                                   const url =
//                                                                       mobileCarIpCameratbaseUrlLocalHost;
//                                                                   CustomBrowserRedirect
//                                                                       .openInBrowser(
//                                                                           url);
//                                                                 },
//                                                                 icon: const Icon(
//                                                                     Icons
//                                                                         .video_camera_back,
//                                                                     color: Colors
//                                                                         .black),
//                                                               ),
//                                                             ),
//                                                             // SCADA Integration
//                                                             Expanded(
//                                                               child: IconButton(
//                                                                 tooltip:
//                                                                     'الربط مع الاسكادا',
//                                                                 hoverColor:
//                                                                     Colors
//                                                                         .yellow,
//                                                                 onPressed: () {
//                                                                   CustomBrowserRedirect
//                                                                       .openInBrowser(
//                                                                           'http://41.33.226.211:8070/roundpoint');
//                                                                 },
//                                                                 icon: const Icon(
//                                                                     Icons
//                                                                         .dashboard_customize_outlined,
//                                                                     color: Colors
//                                                                         .orange),
//                                                               ),
//                                                             ),
//                                                             // Complaint Info
//                                                             Expanded(
//                                                               child: IconButton(
//                                                                 tooltip:
//                                                                     'عرض بيانات البلاغ',
//                                                                 hoverColor:
//                                                                     Colors
//                                                                         .yellow,
//                                                                 onPressed: () {
//                                                                   showDialog(
//                                                                     context:
//                                                                         context,
//                                                                     builder:
//                                                                         (context) =>
//                                                                             CustomReusableTextAlertDialog(
//                                                                       title:
//                                                                           'بيانات البلاغ',
//                                                                       messages: [
//                                                                         'العنوان :  ${item['address']}',
//                                                                         'قطر الماسورة: ${item['broker_type']} ',
//                                                                         item['broker_type'] ==
//                                                                                 pipDim
//                                                                             ? 'عدد السكان المتوقع تأثرهم بالكسر: $numberOfAffectedPeople نسمة'
//                                                                             : 'عدد السكان المتوقع تأثرهم بالكسر: لم يتم تعيين قطر الماسورة',
//                                                                         item['broker_type'] ==
//                                                                                 pipDim
//                                                                             ? 'زمن الاصلاح المتوقع: $aproxTimeFixing ساعة'
//                                                                             : 'زمن الاصلاح المتوقع: عفوا لم يتم تعيين قطر الماسورة',
//                                                                         'الاحداثئات :  ${item['latitude']} , ${item['longitude']}',
//                                                                         item['handasah_name'] ==
//                                                                                 "لم يدرج"
//                                                                             ? 'الهندسة: لم يتم تعيين هندسة'
//                                                                             : 'الهندسة :  ${item['handasah_name']}',
//                                                                         item['technical_name'] ==
//                                                                                 "لم يدرج"
//                                                                             ? 'اسم فنى الهندسة: لم يتم تعيين فنى الهندسة'
//                                                                             : 'إسم فنى الهندسة :  ${item['technical_name']}',
//                                                                         'Gis-Link :  ${item['gis_url']}',
//                                                                         'إسم المبلغ :  ${item['caller_name']}',
//                                                                         ' رقم هاتف المبلغ:  ${item['caller_phone']}',
//                                                                       ],
//                                                                       actions: [
//                                                                         Align(
//                                                                           alignment:
//                                                                               Alignment.bottomLeft,
//                                                                           child:
//                                                                               TextButton(
//                                                                             onPressed: () =>
//                                                                                 Navigator.of(context).pop(),
//                                                                             child:
//                                                                                 const Text('إغلاق'),
//                                                                           ),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   );
//                                                                 },
//                                                                 icon: const Icon(
//                                                                     Icons.info,
//                                                                     color: Colors
//                                                                         .blueAccent),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 );
//                                               },
//                                             );
//                                           }
//                                           return const Center(
//                                             child: Text('لا يوجد شكاوى مفتوحة'),
//                                           );
//                                         }),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//           ),
//         ],
//       ),
//       drawer: CustomDrawer(
//         title: 'الاعطال الواردة من الخط الساخن',
//         getLocs: getAllHotLineAddresses,
//         onTap: (itemData) {
//           try {
//             StaticVariables.hotlineAddress = itemData['address'];
//             StaticVariables.hotlineId = itemData['id'];
//             StaticVariables.hotlineX = itemData['x'];
//             StaticVariables.hotlineY = itemData['y'];
//             StaticVariables.hotlinecaseReportDateTime =
//                 itemData['caseReportDateTime'];
//             StaticVariables.hotlinefinalClosed = itemData['finalClosed'];
//             StaticVariables.hotlinereporterName = itemData['reporterName'];
//             StaticVariables.hotlinemainStreet = itemData['mainStreet'];
//             StaticVariables.hotlineStreet = itemData['street'];
//             StaticVariables.hotlinecaseType = itemData['caseType'];

//             DioNetworkRepos().postHotLineDataList(
//               id: StaticVariables.hotlineId,
//               caseReportDateTime: StaticVariables.hotlinecaseReportDateTime,
//               caseType: StaticVariables.hotlinecaseType,
//               finalClosed: StaticVariables.hotlinefinalClosed,
//               mainStreet: StaticVariables.hotlinemainStreet,
//               reporterName: StaticVariables.hotlinereporterName,
//               street: StaticVariables.hotlineStreet,
//               x: StaticVariables.hotlineX,
//               y: StaticVariables.hotlineY,
//               address: StaticVariables.hotlineAddress,
//             );
//             _getCoordinatesFromAddress(StaticVariables.hotlineAddress);

//             getLocsAfterGetCoordinatesAndGis =
//                 DioNetworkRepos().getAllComplaintsNotFinished();
//             getLocsByHandasahNameAndTechinicianName =
//                 DioNetworkRepos().getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");
//           } catch (e) {
//             log(e.toString());
//           }
//           Navigator.of(context).pop();
//         },
//       ),
//     );
//   }
// }
// // ignore_for_file: use_build_context_synchronously

// import 'dart:async';
// import 'dart:collection';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:emergency_room/screens/widgets/update_close_complaint.dart';
// import 'package:emergency_room/screens/widgets/update_delete_complaint.dart';
// import 'package:emergency_room/screens/widgets/update_join_as_repeated_address.dart';
// import 'package:emergency_room/screens/widgets/update_obtain_approval.dart';
// import 'package:emergency_room/screens/widgets/update_recipient_destination.dart';
// import 'package:emergency_room/screens/widgets/update_urgency_number.dart';
// import 'package:emergency_room/utils/whatsapp/main_whatsapp_dialog.dart';
// import 'package:emergency_room/utils/whatsapp/main_whatsapp_service.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;

// import '../custom_widget/custom_reusable_alert_dailog.dart';
// import '../custom_widget/custom_bottom_sheet.dart';
// import '../custom_widget/custom_browser_redirect.dart';
// import '../custom_widget/custom_drawer.dart';
// import '../custom_widget/custom_end_drawer.dart';
// import '../custom_widget/custom_reusable_alter_dialog_drop_down_textfield.dart';
// import '../custom_widget/custom_text_button_drop_down_menu.dart';
// import '../custom_widget/cutom_texts_alert_dailog.dart';
// import '../custom_widget/no_internet_widget.dart';
// import '../custom_widget/offline_banner.dart';
// import '../labs/widget/convert_handasah_to_lab_code.dart';
// import '../labs/widget/convert_lab_code_to_lab_name.dart';
// import '../network/remote/remote_network_repos.dart';
// import '../services/connection_dialog_service.dart';
// import '../services/connectivity_service.dart';
// import '../utils/app_constants.dart';

// class AddressToCoordinates extends StatefulWidget {
//   const AddressToCoordinates({super.key});

//   @override
//   AddressToCoordinatesState createState() => AddressToCoordinatesState();
// }

// class AddressToCoordinatesState extends State<AddressToCoordinates> {
//   String storeName = "";
//   final Completer<GoogleMapController> _controller = Completer();
//   bool _isMapControllerReady = false;

//   String address = "";
//   String coordinates = "";
//   String getAddress = "";
//   LatLng alexandriaCoordinates = const LatLng(31.205753, 29.924526);
//   double latitude = 0.0, longitude = 0.0;
//   var pickMarkers = HashSet<Marker>();

//   // Data futures consumed by FutureBuilder / drawers.
//   // Initialized empty to avoid late-initialization errors before the
//   // first fetchData() completes.
//   Future getLocsAfterGetCoordinatesAndGis = Future.value([]);
//   Future getLocsByHandasahNameAndTechinicianName = Future.value([]);
//   final TextEditingController addressController = TextEditingController();
//   List<String> handasatItemsDropdownMenu = [];
//   List<String> addHandasahToAddressList = [];
//   Future<List<Map<String, dynamic>>> getAllHotLineAddresses = Future.value([]);

//   // Replace with your actual Google Maps API key
//   String googleMapsApiKey = "AIzaSyDRaJJnyvmDSU8OgI8M20C5nmwHNc_AMvk";
//   double fontSize = 12.0;
//   Timer? _timer; // Timer for periodic fetching
//   int numberOfAffectedPeople = 4;
//   double aproxTimeFixing = 1;
//   String pipDim = '4 mm';

//   // --- Internet connection state (mirrors ComplaintsReportsScreen) ---
//   bool _isLoading = true;
//   bool _isOnline = true;
//   bool _isOnlineChecked = false;
//   bool _hasData = false;
//   List<Map<String, dynamic>> _hotlineData = [];

//   @override
//   void dispose() {
//     _timer?.cancel();
//     addressController.dispose();
//     if (!_controller.isCompleted) {
//       _controller.completeError('Widget disposed');
//     }
//     super.dispose();
//   }

//   //TODO:convert GIS-HANDASAH-NAME-TO-EMERGENCY-HANDASAH-NAME(inprogress-21-02-2026)
//   String convertGisHandasahNameToEmergencyHandasahName(
//       String emergencyHandasahPattern) {
//     const Map<String, String> patternToName = {
//       'ABUKEER/ابو قير': 'هندسة فرع أبو قير',
//       'MANDARA/المندرة': 'هندسة فرع المندرة',
//       'SIDIBISHR/سيدى بشر': 'هندسة فرع سيدى بشر',
//       'ELRAML/الرمل': 'هندسة فرع الرمل',
//       'ELBRAHEMIA/الابراهمية': 'هندسة فرع الابراهمية',
//       'ELNOZHA/النزهه': 'هندسة فرع النزهه',
//       'ELBALAD_MOHERMBK/البلد ومحرم بك': 'هندسة فرع البلد',
//       'ELQABBARI/القبارى': 'هندسة فرع القبارى',
//       'ELAGAMI/ العجمى': 'هندسة فرع العجمى',
//       'MADINET_NOUBARIA_ELGDIDA/مدينة النوباريه الجديدة': 'هندسة النوبارية',
//       'ELAMREYA/العامريه': 'هندسة فرع العامريه',
//       'ELBANGER/البنجر': 'هندسة بنجر السكر',
//       'BORGELARAB/برج العرب': 'هندسة برج العرب الجديده',
//       '6OCTOBER/6 اكتوبر': 'هندسة فرع 6 اكتوبر',
//       'ELMINA/الميناء': 'هندسة فرع الميناء',
//       'MARIOUT1/مريوط 1': 'هندسة فرع مريوط 1',
//     };

//     for (final entry in patternToName.entries) {
//       if (emergencyHandasahPattern.contains(entry.key)) {
//         return entry.value;
//       }
//     }

//     return emergencyHandasahPattern;
//   }

//   // ==========================================================================
//   // Unified data fetch — single connectivity check + single fetch pass,
//   // matching ComplaintsReportsScreen.fetchData(). Replaces the old trio of
//   // _initializeApp / _fetchInitialData / _fetchHandasatItems, which each ran
//   // their own connectivity checks and could show duplicate dialogs.
//   // ==========================================================================
//   Future<void> fetchData() async {
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
//       // Only interrupt with a blocking dialog when there's truly nothing
//       // on screen yet. If we already have cached hotline/complaint data,
//       // the OfflineBanner alone is enough — showing the dialog on top of
//       // a populated screen is exactly the confusing behavior we want to
//       // avoid.
//       if (!_hasData) {
//         await ConnectionDialogService.showNoInternetDialog(
//           context,
//           onRetry: fetchData,
//         );
//       }
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final token = await DioNetworkRepos().getHotLineTokenByUserAndPassword();
//       final hotlineData = await DioNetworkRepos().getHotLineData(token);
//       //TODO:UPDATE_COMPLAINTS
//       final locsData = await DioNetworkRepos().getAllComplaintsNotFinished();
//       // final locsData = await DioNetworkRepos().getAllComplaintsNotFinished();
//       final locsByHandasah =
//           await DioNetworkRepos().getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");

//       final handasatItems =
//           await DioNetworkRepos().fetchHandasatItemsDropdownMenu();

//       if (!mounted) return;

//       final hotlineList = (hotlineData as List).cast<Map<String, dynamic>>();
//       final bool locsHasData = locsData is List && locsData.isNotEmpty;

//       setState(() {
//         _hotlineData = hotlineList;
//         getAllHotLineAddresses = Future.value(hotlineList);
//         getLocsAfterGetCoordinatesAndGis = Future.value(locsData);
//         getLocsByHandasahNameAndTechinicianName = Future.value(locsByHandasah);
//         handasatItemsDropdownMenu =
//             handasatItems.map<String>((e) => e.toString()).toList();
//         _hasData = hotlineList.isNotEmpty || locsHasData;
//         _isLoading = false;
//       });

//       log("handasatItemsDropdownMenu from UI: $handasatItemsDropdownMenu");
//       log("GET ALL HOTLINE LOCATIONS: $hotlineList");
//     } catch (e) {
//       log("Error fetching data: $e");
//       if (!mounted) return;
//       setState(() {
//         _isLoading = false;
//       });
//       final onlineAgain = await ConnectivityService.instance.hasConnection();
//       if (!mounted) return;
//       setState(() {
//         _isOnline = onlineAgain;
//       });
//       // Same rule here: only block with a dialog if there's no data to
//       // fall back on. Otherwise let the banner communicate it.
//       if (!onlineAgain && !_hasData) {
//         await ConnectionDialogService.showNoInternetDialog(
//           context,
//           onRetry: fetchData,
//         );
//       }
//     }
//   }

//   //update in periodic time — refreshes silently, defers to the banner
//   //instead of ever showing a blocking dialog on its own.
//   void _startPeriodicFetch() {
//     const Duration fetchInterval = Duration(seconds: 10);
//     _timer = Timer.periodic(fetchInterval, (Timer timer) async {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }

//       final online = await ConnectivityService.instance.hasConnection();
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }

//       setState(() {
//         _isOnline = online;
//         _isOnlineChecked = true;
//       });

//       if (online) {
//         setState(() {
//           getLocsAfterGetCoordinatesAndGis =
//               DioNetworkRepos().getAllComplaintsNotFinished();
//           getLocsByHandasahNameAndTechinicianName =
//               DioNetworkRepos().getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");
//         });
//       }
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//     _startPeriodicFetch();
//   }

//   // ==================== UI: _getCoordinatesFromAddress ====================

//   Future<void> _getCoordinatesFromAddress(String address) async {
//     if (!mounted) return;

//     final online = await ConnectivityService.instance.hasConnection();
//     if (!online) {
//       if (!mounted) return;
//       // Direct user action being blocked — an explicit notice is
//       // appropriate here regardless of what's already on screen.
//       ConnectionDialogService.showNoInternetDialog(context);
//       setState(() {
//         _isOnline = false;
//         _isOnlineChecked = true;
//       });
//       return;
//     }

//     setState(() {
//       _isOnline = true;
//       _isOnlineChecked = true;
//       _isLoading = true;
//     });

//     final url = Uri.parse(
//       'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$googleMapsApiKey',
//     );

//     try {
//       // Wait for map controller to be ready with timeout
//       GoogleMapController controller;
//       try {
//         controller = await _controller.future.timeout(
//           const Duration(seconds: 10),
//           onTimeout: () {
//             log("Map controller timeout");
//             throw Exception("Map controller timeout");
//           },
//         );
//       } catch (e) {
//         log("Error getting map controller: $e");
//         setState(() {
//           _isLoading = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               "خطأ في تحميل الخريطة، يرجى إعادة المحاولة",
//               textDirection: TextDirection.rtl,
//               textAlign: TextAlign.center,
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       final response = await http.get(url);

//       if (response.statusCode != 200) {
//         setState(() => coordinates = "Error: Failed to fetch data");
//         return;
//       }

//       final data = json.decode(response.body);

//       if (data['results'] == null || data['results'].isEmpty) {
//         setState(() => coordinates = "Error: No results found");
//         return;
//       }

//       final location = data['results'][0]['geometry']['location'];
//       latitude = location['lat'];
//       longitude = location['lng'];
//       coordinates = "Latitude: $latitude, Longitude: $longitude";

//       log("Address     :>> $address");
//       log("Coordinates :>> $coordinates");
//       log("Longitude   :>> $longitude");
//       log("Latitude    :>> $latitude");

//       setState(() {
//         pickMarkers.add(
//           Marker(
//             markerId: MarkerId(address),
//             position: LatLng(latitude, longitude),
//             infoWindow: InfoWindow(title: address, snippet: coordinates),
//             icon: BitmapDescriptor.defaultMarkerWithHue(
//               BitmapDescriptor.hueGreen,
//             ),
//           ),
//         );
//       });

//       // Only animate camera if controller is ready
//       if (mounted && !_controller.isCompleted) {
//         try {
//           await controller.animateCamera(
//             CameraUpdate.newCameraPosition(
//               CameraPosition(target: LatLng(latitude, longitude), zoom: 15.0),
//             ),
//           );
//         } catch (e) {
//           log("Error animating camera: $e");
//         }
//       }

//       log('START-GIS-INTEGRATIONS');
//       await _runGisIntegration(address);

//       if (!mounted) return;
//       setState(() {
//         getLocsAfterGetCoordinatesAndGis =
//             DioNetworkRepos().getAllComplaintsNotFinished();
//         getLocsByHandasahNameAndTechinicianName =
//             DioNetworkRepos().getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");
//         _isLoading = false;
//       });
//     } catch (e) {
//       log("_getCoordinatesFromAddress error: $e");
//       setState(() => coordinates = "Error: Unable to get coordinates");
//       if (!mounted) return;
//       final onlineAgain = await ConnectivityService.instance.hasConnection();
//       if (!mounted) return;
//       setState(() {
//         _isOnline = onlineAgain;
//         _isLoading = false;
//       });
//       if (!onlineAgain && !_hasData) {
//         await ConnectionDialogService.showNoInternetDialog(
//           context,
//           onRetry: fetchData,
//         );
//       }
//     }
//   }

// // ── GIS Integration ─────────────────────────────────────────────────────────
//   Future<void> _runGisIntegration(String address) async {
//     log("=== _runGisIntegration STARTED ===");
//     try {
//       log("=== CALLING getLastRecordNumberWeb ===");
//       final lastRecordNumber = await DioNetworkRepos().getLastRecordNumberWeb();
//       log("=== getLastRecordNumberWeb SUCCESS: $lastRecordNumber ===");

//       final newRecordNumber = lastRecordNumber + 1;

//       log("=== CALLING createNewGisPointAndGetMapLinkAndHandasah ===");
//       final result =
//           await DioNetworkRepos().createNewGisPointAndGetMapLinkAndHandasah(
//         newRecordNumber,
//         longitude.toString(),
//         latitude.toString(),
//       );
//       log("=== createNewGisPoint SUCCESS: $result ===");

//       final gisUrl = result['url'] as String? ?? 'لم يدرج';
//       final branch = result['engineering_branch'] as String? ?? 'لم يدرج';
//       final service = result['wtp_service'] as String? ?? 'لم يدرج';

//       log("GIS MAP LINK :>> $gisUrl");
//       log("GIS BRANCH   :>> $branch");
//       log("GIS SERVICE  :>> $service");

//       final handasahBranch =
//           convertGisHandasahNameToEmergencyHandasahName(branch);

//       log("=== CALLING _saveOrUpdateLocation WITH REAL DATA ===");
//       await _saveOrUpdateLocation(address, gisUrl, handasahBranch);
//       log("=== _saveOrUpdateLocation DONE ===");
//     } catch (gisError, stackTrace) {
//       log("=== GIS CATCH BLOCK REACHED ===");
//       log("=== gisError: $gisError ===");
//       log("=== stackTrace: $stackTrace ===");
//       log("=== CALLING _saveOrUpdateLocation WITH FALLBACK ===");
//       await _saveOrUpdateLocation(address, 'لم يدرج', 'لم يدرج');
//       log("=== FALLBACK _saveOrUpdateLocation DONE ===");
//     }

//     log("=== _runGisIntegration ENDED ===");
//   }

// // ── Helper: save new or update existing location ──────────────────────────

//   Future<void> _saveOrUpdateLocation(
//     String address,
//     String gisUrl,
//     String handasahBranch,
//   ) async {
//     try {
//       final addressExists = await DioNetworkRepos().checkAddressExists(address);
//       log("addressExists: $addressExists");

//       if (addressExists == true) {
//         log("Address already exists — updating...");
//         await DioNetworkRepos().updateLocations(
//           address,
//           longitude,
//           latitude,
//           gisUrl,
//           handasahBranch,
//         );
//         log("Location updated successfully.");
//       } else {
//         log("Address not found — creating new location...");
//         await DioNetworkRepos().createNewLocation(
//           address,
//           longitude,
//           latitude,
//           gisUrl,
//           handasahBranch,
//         );
//         log("New location created successfully.");
//       }
//     } catch (e) {
//       log("_saveOrUpdateLocation error: $e");
//     }
//   }

//   //show bottom sheet Redirect to Handasat
//   void showCustomBottomSheet(
//       BuildContext context, String title, String message, String address) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: false,
//       builder: (context) {
//         return CustomBottomSheet(
//           title: title,
//           message: message,
//           hintText: "اختر الهندسة",
//           dropdownItems: handasatItemsDropdownMenu,
//           onItemSelected: (value) {
//             log("Selected: $value");
//             setState(() {
//               DioNetworkRepos().updateLocAddHandasah(address, value);
//             });
//           },
//           onPressed: () async {
//             Navigator.of(context).pop();
//             await DioNetworkRepos().updateLocAddTechnician(address, "لم يدرج");
//             await DioNetworkRepos().updateLocAddIsApproved(address, 0);
//           },
//         );
//       },
//     );
//   }

// //handle dropdown click
//   void handleOptionClick(String value) {
//     log("Clicked: $value");
//     if (value == 'عرض التقارير') {
//       context.go('/report');
//     } else if (value == 'عرض البلاغات المفتوحة') {
//       context.go('/monitor-complaints');
//     } else if (value == 'عرض لوحة التحكم') {
//       context.go('/report-dashboard');
//     } else if (value == 'الربط مع الاسكادا') {
//       CustomBrowserRedirect.openInBrowser(
//         'http://41.33.226.211:8070/roundpoint',
//       );
//     } else if (value == 'عرض المناطق المزدحمة بالبلاغات') {
//       CustomBrowserRedirect.openInBrowser(
//         'http://196.219.231.3:8000/webmap/breaks-hot-spots',
//       );
//     } else if (value == 'عرض تقرير الاسكادا Dashboard') {
//       context.go('/dashboard');
//     }
//   }

//   // //TODO://add alexandria to the address(6-8-2026)

//   String _normalizeAlexandriaAddress(String input) {
//     const variants = [
//       'الاسكندرية',
//       'الإسكندرية',
//       'الاسكندريه',
//       'الإسكندريه', // fixed: was missing leading "ال"
//     ];
//     const correct = 'الإسكندرية';

//     var address = input.trim();

//     final hasVariant = variants.any((v) => address.contains(v));

//     if (hasVariant) {
//       for (final v in variants) {
//         address = address.replaceAll(v, correct);
//       }
//     } else {
//       address = address.isEmpty ? correct : '$address $correct';
//     }

//     return address;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Nothing useful is on screen only when we're offline AND we have no
//     // cached hotline/complaint data to fall back on.
//     final showNoInternet = !_isOnline && _isOnlineChecked && !_hasData;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           " غرفة الطوارئ",
//           style: TextStyle(
//             color: Colors.indigo,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         centerTitle: true,
//         elevation: 7,
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(
//           color: Colors.indigo,
//           size: 17,
//         ),
//         actions: [
//           IconButton(
//             padding: const EdgeInsets.symmetric(horizontal: 5),
//             tooltip: "تحديث شكاوى الخط الساخن",
//             hoverColor: Colors.yellow,
//             onPressed: () {
//               fetchData();
//             },
//             icon: const Icon(
//               Icons.refresh,
//               color: Colors.indigo,
//             ),
//           ),
//           IconButton(
//             padding: const EdgeInsets.symmetric(horizontal: 5),
//             tooltip: "إضافة مستخدمين الطوارئ",
//             hoverColor: Colors.yellow,
//             icon: const Icon(
//               Icons.person_add_alt,
//               color: Colors.indigo,
//             ),
//             onPressed: () {
//               showDialog(
//                   context: context,
//                   builder: (context) {
//                     return CustomReusableAlertDialog(
//                         title: 'اضافة مستخدمين الطوارئ',
//                         fieldLabels: const [
//                           'اسم المستخدم',
//                           'كلمة المرور',
//                           'مطابقة كلمة المرور',
//                         ],
//                         onSubmit: (values) {
//                           DioNetworkRepos().createNewUser(
//                               values[0], values[1], 1, 'غرفة الطوارئ');
//                         });
//                   });
//             },
//           ),
//           TextButtonDropdown(
//             label: 'متابعة البلاغات الواردة',
//             options: const [
//               'عرض البلاغات المفتوحة',
//               'عرض التقارير',
//               'عرض لوحة التحكم',
//               'عرض تقرير الاسكادا',
//               'الربط مع الاسكادا',
//               'عرض المناطق المزدحمة بالبلاغات',
//             ],
//             onSelected: handleOptionClick,
//           ),
//           IconButton(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             tooltip: "تسجيل الخروج",
//             hoverColor: Colors.yellow,
//             icon: const Icon(
//               Icons.logout,
//               color: Colors.red,
//             ),
//             onPressed: () {
//               context.go('/login');
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           OfflineBanner(visible: !_isOnline && _isOnlineChecked),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : showNoInternet
//                     ? NoInternetWidget(onRetry: fetchData)
//                     : Row(
//                         children: [
//                           Expanded(
//                             flex: 1,
//                             child: Container(
//                               margin: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 8),
//                               width: 220,
//                               height: MediaQuery.of(context).size.height,
//                               child: CustomEndDrawer(
//                                 title: 'تخصيص بلاغات الهندسة',
//                                 getLocs:
//                                     getLocsByHandasahNameAndTechinicianName,
//                                 stringListItems: handasatItemsDropdownMenu,
//                                 onPressed: () {
//                                   setState(() {
//                                     getLocsByHandasahNameAndTechinicianName =
//                                         DioNetworkRepos()
//                                             .getLocByHandasahAndTechnician(
//                                                 "لم يدرج", "لم يدرج");
//                                     getLocsAfterGetCoordinatesAndGis =
//                                         DioNetworkRepos()
//                                             .getAllComplaintsNotFinished();
//                                   });
//                                 },
//                                 hintText: 'فضلا أختار الهندسة',
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             flex: 3,
//                             child: Padding(
//                               padding: const EdgeInsets.only(top: 8.0),
//                               child: Stack(
//                                 children: [
//                                   GoogleMap(
//                                     initialCameraPosition: CameraPosition(
//                                       target: alexandriaCoordinates,
//                                       zoom: 10.4746,
//                                     ),
//                                     onMapCreated:
//                                         (GoogleMapController controller) {
//                                       if (!_controller.isCompleted) {
//                                         _controller.complete(controller);
//                                       }
//                                       setState(() {
//                                         _isMapControllerReady = true;
//                                       });
//                                     },
//                                     markers: pickMarkers,
//                                     zoomControlsEnabled: true,
//                                     onCameraMoveStarted: () async {
//                                       // Only try to animate if controller is ready
//                                       if (_controller.isCompleted && mounted) {
//                                         try {
//                                           final GoogleMapController controller =
//                                               await _controller.future;
//                                           CameraPosition cameraPosition =
//                                               CameraPosition(
//                                             target: LatLng(latitude, longitude),
//                                             zoom: 14,
//                                           );
//                                           await controller.animateCamera(
//                                               CameraUpdate.newCameraPosition(
//                                                   cameraPosition));
//                                         } catch (e) {
//                                           log("Camera move error: $e");
//                                         }
//                                       }
//                                     },
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Row(
//                                       children: [
//                                         Expanded(
//                                           child: TextField(
//                                             decoration: InputDecoration(
//                                               constraints: const BoxConstraints(
//                                                 maxHeight: 70,
//                                                 minWidth: 200,
//                                               ),
//                                               filled: true,
//                                               fillColor: Colors.white,
//                                               border: const OutlineInputBorder(
//                                                 borderRadius: BorderRadius.all(
//                                                   Radius.circular(10.0),
//                                                 ),
//                                               ),
//                                               hintText: "فضلا أدخل العنوان",
//                                               hintStyle: TextStyle(
//                                                 color: Colors.indigo[200],
//                                                 fontSize: 11,
//                                               ),
//                                               labelText:
//                                                   "61 طريق الحرية الاسكندرية",
//                                             ),
//                                             controller: addressController,
//                                             style: const TextStyle(
//                                               fontSize: 13,
//                                               color: Colors.indigo,
//                                             ),
//                                             cursorColor: Colors.indigo,
//                                             keyboardType: TextInputType.text,
//                                             maxLength: 250,
//                                             textAlign: TextAlign.right,
//                                             textDirection: TextDirection.rtl,
//                                           ),
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.only(
//                                               bottom: 17.0),
//                                           child: IconButton(
//                                             alignment: Alignment.center,
//                                             onPressed: () async {
//                                               if (addressController
//                                                   .text.isEmpty) {
//                                                 ScaffoldMessenger.of(context)
//                                                     .showSnackBar(
//                                                   const SnackBar(
//                                                     content: Text(
//                                                       " فضلا ادخل العنوان, ثم اضغط على البحث",
//                                                       textDirection:
//                                                           TextDirection.rtl,
//                                                       textAlign:
//                                                           TextAlign.center,
//                                                     ),
//                                                   ),
//                                                 );
//                                                 return;
//                                               }

//                                               // 1) Pure, synchronous normalization — no setState needed for this part
//                                               final normalizedAddress =
//                                                   _normalizeAlexandriaAddress(
//                                                       addressController.text);

//                                               // 2) Sync UI updates only
//                                               setState(() {
//                                                 pickMarkers.clear();
//                                                 address = normalizedAddress;
//                                               });

//                                               addressController.clear();

//                                               // 3) Await the async geocode/connectivity call BEFORE touching state again
//                                               await _getCoordinatesFromAddress(
//                                                   address);

//                                               // 4) Now safely refresh the futures, only after the above completes
//                                               if (!mounted) return;
//                                               setState(() {
//                                                 getLocsAfterGetCoordinatesAndGis =
//                                                     DioNetworkRepos()
//                                                         .getAllComplaintsNotFinished();
//                                                 getLocsByHandasahNameAndTechinicianName =
//                                                     DioNetworkRepos()
//                                                         .getLocByHandasahAndTechnician(
//                                                             "لم يدرج", "لم يدرج");
//                                               });
//                                             },
//                                             icon: const CircleAvatar(
//                                               backgroundColor: Colors.indigo,
//                                               radius: 20,
//                                               child: Icon(
//                                                 Icons.search_outlined,
//                                                 color: Colors.white,
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           Expanded(
//                             flex: 1,
//                             child: Container(
//                               margin: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 8),
//                               width: 220,
//                               height: MediaQuery.of(context).size.height,
//                               color: Colors.black45,
//                               child: SingleChildScrollView(
//                                 child: Column(
//                                   children: [
//                                     Container(
//                                       height: 40,
//                                       color: Colors.indigo,
//                                       child: const Center(
//                                         child: Text(
//                                           textDirection: TextDirection.rtl,
//                                           textAlign: TextAlign.center,
//                                           'جميع البلاغات غير المغلقة',
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     FutureBuilder(
//                                         future:
//                                             getLocsAfterGetCoordinatesAndGis,
//                                         builder: (context, snapshot) {
//                                           if (snapshot.connectionState ==
//                                               ConnectionState.waiting) {
//                                             return const Center(
//                                                 child:
//                                                     CircularProgressIndicator());
//                                           }
//                                           if (snapshot.hasError) {
//                                             return Center(
//                                               child: Column(
//                                                 children: [
//                                                   const Text(
//                                                       'حدث خطأ في تحميل البيانات'),
//                                                   ElevatedButton(
//                                                     onPressed: () {
//                                                       setState(() {
//                                                         getLocsAfterGetCoordinatesAndGis =
//                                                             DioNetworkRepos()
//                                                                 .getAllComplaintsNotFinished();
//                                                       });
//                                                     },
//                                                     child: const Text(
//                                                         'إعادة المحاولة'),
//                                                   ),
//                                                 ],
//                                               ),
//                                             );
//                                           }
//                                           if (snapshot.hasData &&
//                                               snapshot.data!.isNotEmpty) {
//                                             return ListView.builder(
//                                               reverse: true,
//                                               shrinkWrap: true,
//                                               itemCount: snapshot.data!.length,
//                                               itemBuilder: (context, index) {
//                                                 final item =
//                                                     snapshot.data![index];
//                                                 return InkWell(
//                                                   onTap: () {
//                                                     showCustomBottomSheet(
//                                                       context,
//                                                       "إعادة التوجيه للهندسة",
//                                                       item['address'],
//                                                       item['address'],
//                                                     );
//                                                   },
//                                                   child: Card(
//                                                     child: Column(
//                                                       children: [
//                                                         ListTile(
//                                                           title: Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .symmetric(
//                                                                     vertical:
//                                                                         7.0,
//                                                                     horizontal:
//                                                                         3.0),
//                                                             child: Row(
//                                                               children: [
//                                                                 IconButton(
//                                                                   tooltip:
//                                                                       "إضافة بيانات البلاغ",
//                                                                   onPressed:
//                                                                       () {
//                                                                     showDialog(
//                                                                       context:
//                                                                           context,
//                                                                       builder: (context) => CustomReusableAlertDialogWithDropdown(
//                                                                           title: "تحديث بيانات البلاغ",
//                                                                           fieldConfigs: const [
//                                                                             FieldConfig(
//                                                                               label: "إسم المبلغ",
//                                                                               type: FieldType.textField,
//                                                                             ),
//                                                                             FieldConfig(
//                                                                               label: "قطر الماسورة",
//                                                                               type: FieldType.dropdown,
//                                                                               dropdownItems: [
//                                                                                 "``4",
//                                                                                 "``6",
//                                                                                 "``8",
//                                                                                 "``10",
//                                                                                 "``12",
//                                                                                 "``20",
//                                                                                 "``28",
//                                                                                 "``40",
//                                                                                 "``60"
//                                                                               ],
//                                                                             ),
//                                                                             FieldConfig(
//                                                                               label: "رقم الموبيل",
//                                                                               type: FieldType.textField,
//                                                                             ),
//                                                                           ],
//                                                                           onSubmit: (values) {
//                                                                             log("User Input: $values");
//                                                                             if (values[0] == "" ||
//                                                                                 values[1] == "" ||
//                                                                                 values[2] == "") {
//                                                                               ScaffoldMessenger.of(context).showSnackBar(
//                                                                                 const SnackBar(
//                                                                                   content: Text(
//                                                                                     "يرجى ملء جميع الحقول",
//                                                                                     textDirection: TextDirection.rtl,
//                                                                                     textAlign: TextAlign.center,
//                                                                                   ),
//                                                                                 ),
//                                                                               );
//                                                                             } else {
//                                                                               DioNetworkRepos().updateLocationBrokenByAddress(item['address'], values[0], values[1], values[2]);
//                                                                               log("User Input: updated Caller Name, Phone, And Borken Number");
//                                                                               pipDim = values[1];
//                                                                               // Update affected people based on pipe diameter
//                                                                               if (values[1] == "``4") {
//                                                                                 numberOfAffectedPeople = 2000;
//                                                                                 aproxTimeFixing = 2;
//                                                                               } else if (values[1] == "``6") {
//                                                                                 numberOfAffectedPeople = 2500;
//                                                                                 aproxTimeFixing = 2;
//                                                                               } else if (values[1] == "``8") {
//                                                                                 numberOfAffectedPeople = 4000;
//                                                                                 aproxTimeFixing = 3;
//                                                                               } else if (values[1] == "``10") {
//                                                                                 numberOfAffectedPeople = 4200;
//                                                                                 aproxTimeFixing = 3;
//                                                                               } else if (values[1] == "``12") {
//                                                                                 numberOfAffectedPeople = 5000;
//                                                                                 aproxTimeFixing = 4;
//                                                                               } else if (values[1] == "``20") {
//                                                                                 numberOfAffectedPeople = 10000;
//                                                                                 aproxTimeFixing = 5;
//                                                                               } else if (values[1] == "``28") {
//                                                                                 numberOfAffectedPeople = 15000;
//                                                                                 aproxTimeFixing = 6;
//                                                                               } else if (values[1] == "``40") {
//                                                                                 numberOfAffectedPeople = 50000;
//                                                                                 aproxTimeFixing = 8;
//                                                                               } else if (values[1] == "``60") {
//                                                                                 numberOfAffectedPeople = 100000;
//                                                                                 aproxTimeFixing = 24;
//                                                                               }
//                                                                             }
//                                                                           }),
//                                                                     );
//                                                                   },
//                                                                   icon:
//                                                                       const Icon(
//                                                                     Icons
//                                                                         .add_circle_outlined,
//                                                                     color: Colors
//                                                                         .indigo,
//                                                                   ),
//                                                                 ),
//                                                                 Expanded(
//                                                                   child: Text(
//                                                                     textAlign:
//                                                                         TextAlign
//                                                                             .right,
//                                                                     textDirection:
//                                                                         TextDirection
//                                                                             .rtl,
//                                                                     item[
//                                                                         'complaintAddress'],
//                                                                     style:
//                                                                         const TextStyle(
//                                                                       color: Colors
//                                                                           .indigo,
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .bold,
//                                                                       fontSize:
//                                                                           13,
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                           subtitle: Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .symmetric(
//                                                                     vertical:
//                                                                         7.0,
//                                                                     horizontal:
//                                                                         3.0),
//                                                             child: Column(
//                                                               children: [
//                                                                 Row(
//                                                                   mainAxisAlignment:
//                                                                       MainAxisAlignment
//                                                                           .spaceBetween,
//                                                                   children: [
//                                                                     item['recipientDestination'] ==
//                                                                             'لم يدرج'
//                                                                         ? Expanded(
//                                                                             child:
//                                                                                 Container(
//                                                                               margin: const EdgeInsets.all(3.0),
//                                                                               padding: const EdgeInsets.symmetric(horizontal: 3.0),
//                                                                               decoration: BoxDecoration(
//                                                                                 border: Border.all(color: Colors.orange, width: 1.0),
//                                                                                 borderRadius: BorderRadius.circular(5.0),
//                                                                                 color: Colors.orange,
//                                                                               ),
//                                                                               child: Text(
//                                                                                 textAlign: TextAlign.center,
//                                                                                 "قيد تخصيص هندسة",
//                                                                                 style: TextStyle(
//                                                                                   overflow: TextOverflow.visible,
//                                                                                   fontSize: fontSize,
//                                                                                   color: Colors.white,
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                           )
//                                                                         : Expanded(
//                                                                             child:
//                                                                                 Container(
//                                                                               margin: const EdgeInsets.all(3.0),
//                                                                               padding: const EdgeInsets.symmetric(horizontal: 1.0),
//                                                                               decoration: BoxDecoration(
//                                                                                 border: Border.all(color: Colors.green, width: 1.0),
//                                                                                 borderRadius: BorderRadius.circular(5.0),
//                                                                                 color: Colors.green,
//                                                                               ),
//                                                                               child: Text(
//                                                                                 textAlign: TextAlign.center,
//                                                                                 "${item['recipientDestination']}",
//                                                                                 style: TextStyle(
//                                                                                   fontSize: fontSize,
//                                                                                   color: Colors.white,
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                     item['technical_name'] ==
//                                                                             "لم يدرج"
//                                                                         ? Expanded(
//                                                                             child:
//                                                                                 Container(
//                                                                               margin: const EdgeInsets.all(3.0),
//                                                                               padding: const EdgeInsets.symmetric(horizontal: 3.0),
//                                                                               decoration: BoxDecoration(
//                                                                                 border: Border.all(color: Colors.orange, width: 1.0),
//                                                                                 borderRadius: BorderRadius.circular(5.0),
//                                                                                 color: Colors.orange,
//                                                                               ),
//                                                                               child: Text(
//                                                                                 textAlign: TextAlign.center,
//                                                                                 "قيد تخصيص فنى",
//                                                                                 style: TextStyle(
//                                                                                   overflow: TextOverflow.visible,
//                                                                                   fontSize: fontSize,
//                                                                                   color: Colors.white,
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                           )
//                                                                         : Expanded(
//                                                                             child:
//                                                                                 Container(
//                                                                               margin: const EdgeInsets.all(3.0),
//                                                                               padding: const EdgeInsets.symmetric(horizontal: 3.0),
//                                                                               decoration: BoxDecoration(
//                                                                                 border: Border.all(color: Colors.green, width: 1.0),
//                                                                                 borderRadius: BorderRadius.circular(5.0),
//                                                                                 color: Colors.green,
//                                                                               ),
//                                                                               child: Text(
//                                                                                 textAlign: TextAlign.center,
//                                                                                 "${item['recipientUser']}",
//                                                                                 style: TextStyle(
//                                                                                   fontSize: fontSize,
//                                                                                   color: Colors.white,
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                   ],
//                                                                 ),
//                                                                 Row(
//                                                                   children: [
//                                                                     Expanded(
//                                                                       child: item['isTracked'] ==
//                                                                               1
//                                                                           ? Container(
//                                                                               margin: const EdgeInsets.all(3.0),
//                                                                               padding: const EdgeInsets.symmetric(horizontal: 3.0),
//                                                                               decoration: BoxDecoration(
//                                                                                 border: Border.all(color: Colors.green, width: 1.0),
//                                                                                 borderRadius: BorderRadius.circular(5.0),
//                                                                                 color: Colors.green,
//                                                                               ),
//                                                                               child: Text(
//                                                                                 textAlign: TextAlign.center,
//                                                                                 'تم قبول البلاغ',
//                                                                                 style: TextStyle(
//                                                                                   fontSize: fontSize,
//                                                                                   color: Colors.white,
//                                                                                 ),
//                                                                               ),
//                                                                             )
//                                                                           : Container(
//                                                                               margin: const EdgeInsets.all(3.0),
//                                                                               padding: const EdgeInsets.symmetric(horizontal: 3.0),
//                                                                               decoration: BoxDecoration(
//                                                                                 border: Border.all(color: Colors.orange, width: 1.0),
//                                                                                 borderRadius: BorderRadius.circular(5.0),
//                                                                                 color: Colors.orange,
//                                                                               ),
//                                                                               child: Text(
//                                                                                 textAlign: TextAlign.center,
//                                                                                 'قيد قبول البلاغ',
//                                                                                 style: TextStyle(
//                                                                                   fontSize: fontSize,
//                                                                                   color: Colors.white,
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                     ),
//                                                                     Expanded(
//                                                                       child: item['complaintType'] !=
//                                                                               "لم يدرج نوع الكسر"
//                                                                           ? Container(
//                                                                               margin: const EdgeInsets.all(3.0),
//                                                                               padding: const EdgeInsets.symmetric(horizontal: 3.0),
//                                                                               decoration: BoxDecoration(
//                                                                                 border: Border.all(color: Colors.green, width: 1.0),
//                                                                                 borderRadius: BorderRadius.circular(5.0),
//                                                                                 color: Colors.green,
//                                                                               ),
//                                                                               child: Text(
//                                                                                 textAlign: TextAlign.center,
//                                                                                 '${item['complaintType']}',
//                                                                                 style: TextStyle(
//                                                                                   fontSize: fontSize,
//                                                                                   color: Colors.white,
//                                                                                 ),
//                                                                               ),
//                                                                             )
//                                                                           : Container(
//                                                                               margin: const EdgeInsets.all(3.0),
//                                                                               padding: const EdgeInsets.symmetric(horizontal: 3.0),
//                                                                               decoration: BoxDecoration(
//                                                                                 border: Border.all(color: Colors.orange, width: 1.0),
//                                                                                 borderRadius: BorderRadius.circular(5.0),
//                                                                                 color: Colors.orange,
//                                                                               ),
//                                                                               child: Text(
//                                                                                 textAlign: TextAlign.center,
//                                                                                 'لم يدرج نوع الكسر',
//                                                                                 style: TextStyle(
//                                                                                   fontSize: fontSize,
//                                                                                   color: Colors.white,
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                     ),
//                                                                   ],
//                                                                 )
//                                                               ],
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         // ALL ICON BUTTONS
//                                                         Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .spaceAround,
//                                                           children: [
//                                                             // GIS Map
//                                                             Expanded(
//                                                               child: IconButton(
//                                                                 tooltip:
//                                                                     'التوجهه للخريطة GIS Map',
//                                                                 hoverColor:
//                                                                     Colors
//                                                                         .yellow,
//                                                                 onPressed: () {
//                                                                   log("Start Gis Map ${item['gisLink']}");
//                                                                   if (item[
//                                                                           'gisLink'] ==
//                                                                       'لم يدرج') {
//                                                                     //TODO:REDIRECT-TO-GOOGLE-MAP
//                                                                     CustomBrowserRedirect
//                                                                         .openInBrowser(
//                                                                             'https://www.google.com/maps/search/?api=1&query=${item['latitude']},${item['longitude']}');

//                                                                     // Fluttertoast.showToast(
//                                                                     //     msg:
//                                                                     //         "لا يوجد رابط GIS Map",
//                                                                     //     toastLength:
//                                                                     //         Toast
//                                                                     //             .LENGTH_SHORT,
//                                                                     //     gravity:
//                                                                     //         ToastGravity
//                                                                     //             .CENTER,
//                                                                     //     timeInSecForIosWeb:
//                                                                     //         1,
//                                                                     //     backgroundColor:
//                                                                     //         Colors
//                                                                     //             .red,
//                                                                     //     textColor:
//                                                                     //         Colors
//                                                                     //             .white,
//                                                                     //     fontSize:
//                                                                     //         16.0);
//                                                                   } else {
//                                                                     CustomBrowserRedirect
//                                                                         .openInBrowser(
//                                                                             item['gisLink']);
//                                                                   }
//                                                                 },
//                                                                 icon: const Icon(
//                                                                     Icons
//                                                                         .open_in_browser,
//                                                                     color: Colors
//                                                                         .blue),
//                                                               ),
//                                                             ),
//                                                             // Voice Call
//                                                             Expanded(
//                                                               child: IconButton(
//                                                                 tooltip:
//                                                                     'اجراء مكالمة صوتية',
//                                                                 hoverColor:
//                                                                     Colors
//                                                                         .yellow,
//                                                                 onPressed: () =>
//                                                                     CustomBrowserRedirect
//                                                                         .openInBrowser(
//                                                                             "https://meet.jit.si/${item['address']}"),
//                                                                 icon: const Icon(
//                                                                     Icons.call,
//                                                                     color: Colors
//                                                                         .green),
//                                                               ),
//                                                             ),
//                                                             // Tracking
//                                                             Expanded(
//                                                               child: IconButton(
//                                                                 tooltip:
//                                                                     'بدء تتبع فنى الهندسة',
//                                                                 hoverColor:
//                                                                     Colors
//                                                                         .yellow,
//                                                                 onPressed: () {
//                                                                   log("Start Traking ${item['complaintId']}");
//                                                                   if (item[
//                                                                           'isTracked'] ==
//                                                                       0) {
//                                                                     ScaffoldMessenger.of(
//                                                                             context)
//                                                                         .showSnackBar(
//                                                                       const SnackBar(
//                                                                         content:
//                                                                             Text(
//                                                                           'البلاغ قيد القبول وجارى التفعيل',
//                                                                           textDirection:
//                                                                               TextDirection.rtl,
//                                                                           textAlign:
//                                                                               TextAlign.center,
//                                                                         ),
//                                                                       ),
//                                                                     );
//                                                                   } else {
//                                                                     context.go(
//                                                                         '/tracking/${item['complaintAddress']}/${item['latitude']}/${item['longitude']}/${item['recipientUser']}');
//                                                                   }
//                                                                 },
//                                                                 icon: const Icon(
//                                                                     Icons
//                                                                         .location_on,
//                                                                     color: Colors
//                                                                         .red),
//                                                               ),
//                                                             ),
//                                                             // Store Inventory
//                                                             Expanded(
//                                                               child: IconButton(
//                                                                 tooltip:
//                                                                     'جرد مخزن',
//                                                                 hoverColor:
//                                                                     Colors
//                                                                         .yellow,
//                                                                 onPressed:
//                                                                     () async {
//                                                                   if (item[
//                                                                           'recipientDestination'] ==
//                                                                       'لم يدرج') {
//                                                                     ScaffoldMessenger.of(
//                                                                             context)
//                                                                         .showSnackBar(
//                                                                       const SnackBar(
//                                                                         content:
//                                                                             Text(
//                                                                           'عفوا, لايمكن إظهار جرد المخزن قبل تخصيص الهندسه',
//                                                                           textDirection:
//                                                                               TextDirection.rtl,
//                                                                           textAlign:
//                                                                               TextAlign.center,
//                                                                         ),
//                                                                       ),
//                                                                     );
//                                                                   } else {
//                                                                     await DioNetworkRepos()
//                                                                         .getStoreNameByHandasahName(item[
//                                                                             'recipientDestination'])
//                                                                         .then(
//                                                                             (value) {
//                                                                       storeName =
//                                                                           value[
//                                                                               'storeName'];
//                                                                     });
//                                                                     DioNetworkRepos()
//                                                                         .excuteTempStoreQty(
//                                                                             storeName);
//                                                                     context.go(
//                                                                         '/integrate-with-stores/$storeName');
//                                                                   }
//                                                                 },
//                                                                 icon: const Icon(
//                                                                     Icons
//                                                                         .store_outlined,
//                                                                     color: Colors
//                                                                         .indigo),
//                                                               ),
//                                                             ),
//                                                             // Labs Integration
//                                                             Expanded(
//                                                               child: IconButton(
//                                                                 tooltip:
//                                                                     'الربط مع المعامل',
//                                                                 hoverColor:
//                                                                     Colors
//                                                                         .yellow,
//                                                                 onPressed: () {
//                                                                   StaticVariables
//                                                                           .labCode =
//                                                                       convertHandasahToLabCode(
//                                                                           item[
//                                                                               'recipientUser']);
//                                                                   StaticVariables
//                                                                           .labName =
//                                                                       convertLabCodeToLabName(
//                                                                           StaticVariables
//                                                                               .labCode);
//                                                                   log("LAB_CODE: ${StaticVariables.labCode}");
//                                                                   log("LAB_NAME: ${StaticVariables.labName}");
//                                                                   context.go(
//                                                                       '/integration-with-labs');
//                                                                 },
//                                                                 icon: const Icon(
//                                                                     Icons
//                                                                         .report_gmailerrorred,
//                                                                     color: Colors
//                                                                         .cyan),
//                                                               ),
//                                                             ),
//                                                             // GPS Car Tracking
//                                                             Expanded(
//                                                               child: IconButton(
//                                                                 tooltip:
//                                                                     'تتبع سيارة GPS',
//                                                                 hoverColor:
//                                                                     Colors
//                                                                         .yellow,
//                                                                 onPressed:
//                                                                     () {},
//                                                                 icon: const Icon(
//                                                                     Icons
//                                                                         .car_rental,
//                                                                     color: Colors
//                                                                         .indigo),
//                                                               ),
//                                                             ),
//                                                             // Mobile Emergency Room
//                                                             Expanded(
//                                                               child: IconButton(
//                                                                 tooltip:
//                                                                     "غرفة الطوارئ المتحركة",
//                                                                 hoverColor:
//                                                                     Colors
//                                                                         .yellow,
//                                                                 onPressed: () {
//                                                                   CustomBrowserRedirect
//                                                                       .openInBrowser(
//                                                                           "https://meet.jit.si/mobileEmergencyRoom");
//                                                                 },
//                                                                 icon: const Icon(
//                                                                     Icons
//                                                                         .car_crash,
//                                                                     color: Colors
//                                                                         .purple),
//                                                               ),
//                                                             ),
//                                                             // Camera System
//                                                             Expanded(
//                                                               child: IconButton(
//                                                                 tooltip:
//                                                                     'نظام الكاميرات',
//                                                                 hoverColor:
//                                                                     Colors
//                                                                         .yellow,
//                                                                 onPressed: () {
//                                                                   const url =
//                                                                       mobileCarIpCameratbaseUrlLocalHost;
//                                                                   CustomBrowserRedirect
//                                                                       .openInBrowser(
//                                                                           url);
//                                                                 },
//                                                                 icon: const Icon(
//                                                                     Icons
//                                                                         .video_camera_back,
//                                                                     color: Colors
//                                                                         .black),
//                                                               ),
//                                                             ),
//                                                             // SCADA Integration
//                                                             Expanded(
//                                                               child: IconButton(
//                                                                 tooltip:
//                                                                     'الربط مع الاسكادا',
//                                                                 hoverColor:
//                                                                     Colors
//                                                                         .yellow,
//                                                                 onPressed: () {
//                                                                   CustomBrowserRedirect
//                                                                       .openInBrowser(
//                                                                           'http://41.33.226.211:8070/roundpoint');
//                                                                 },
//                                                                 icon: const Icon(
//                                                                     Icons
//                                                                         .dashboard_customize_outlined,
//                                                                     color: Colors
//                                                                         .orange),
//                                                               ),
//                                                             ),
//                                                             // Complaint Info
//                                                             Expanded(
//                                                               child: IconButton(
//                                                                 tooltip:
//                                                                     'عرض بيانات البلاغ',
//                                                                 hoverColor:
//                                                                     Colors
//                                                                         .yellow,
//                                                                          onPressed: () =>
//                                                                     _openActionsMenu(
//                                                                         context,
//                                                                         item),
//                                                                 // onPressed: () {
//                                                                 //   showDialog(
//                                                                 //     context:
//                                                                 //         context,
//                                                                 //     builder:
//                                                                 //         (context) =>
//                                                                 //             CustomReusableTextAlertDialog(
//                                                                 //       title:
//                                                                 //           'بيانات البلاغ',
//                                                                 //       messages: [
//                                                                 //         'العنوان :  ${item['complaintAddress']}',
//                                                                 //         'قطر الماسورة: ${item['complaintType']} ',
//                                                                 //         item['complaintType'] ==
//                                                                 //                 pipDim
//                                                                 //             ? 'عدد السكان المتوقع تأثرهم بالكسر: $numberOfAffectedPeople نسمة'
//                                                                 //             : 'عدد السكان المتوقع تأثرهم بالكسر: لم يتم تعيين قطر الماسورة',
//                                                                 //         item['complaintType'] ==
//                                                                 //                 pipDim
//                                                                 //             ? 'زمن الاصلاح المتوقع: $aproxTimeFixing ساعة'
//                                                                 //             : 'زمن الاصلاح المتوقع: عفوا لم يتم تعيين قطر الماسورة',
//                                                                 //         'الاحداثئات :  ${item['latitude']} , ${item['longitude']}',
//                                                                 //         item['recipientDestination'] ==
//                                                                 //                 "لم يدرج"
//                                                                 //             ? 'الهندسة: لم يتم تعيين هندسة'
//                                                                 //             : 'الهندسة :  ${item['recipientDestination']}',
//                                                                 //         item['recipientUser'] ==
//                                                                 //                 "لم يدرج"
//                                                                 //             ? 'اسم فنى الهندسة: لم يتم تعيين فنى الهندسة'
//                                                                 //             : 'إسم فنى الهندسة :  ${item['recipientUser']}',
//                                                                 //         'Gis-Link :  ${item['gisLink']}',
//                                                                 //         'إسم المبلغ :  ${item['reporterName']}',
//                                                                 //         ' رقم هاتف المبلغ:  ${item['reporterPhone']}',
//                                                                 //       ],
//                                                                 //       actions: [
//                                                                 //         Align(
//                                                                 //           alignment:
//                                                                 //               Alignment.bottomLeft,
//                                                                 //           child:
//                                                                 //               TextButton(
//                                                                 //             onPressed: () =>
//                                                                 //                 Navigator.of(context).pop(),
//                                                                 //             child:
//                                                                 //                 const Text('إغلاق'),
//                                                                 //           ),
//                                                                 //         ),
//                                                                 //       ],
//                                                                 //     ),
//                                                                 //   );
//                                                                 // },
//                                                                 icon: const Icon(
//                                                                     Icons.info,
//                                                                     color: Colors
//                                                                         .blueAccent),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 );
//                                               },
//                                             );
//                                           }
//                                           return const Center(
//                                             child:
//                                                 Text('لا يوجد بلاغات مفتوحة'),
//                                           );
//                                         }),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//           ),
//         ],
//       ),
//       drawer: CustomDrawer(
//         title: 'الاعطال الواردة من الخط الساخن',
//         getLocs: getAllHotLineAddresses,
//         onTap: (itemData) {
//           try {
//             StaticVariables.hotlineAddress = itemData['address'];
//             StaticVariables.hotlineId = itemData['id'];
//             StaticVariables.hotlineX = itemData['x'];
//             StaticVariables.hotlineY = itemData['y'];
//             StaticVariables.hotlinecaseReportDateTime =
//                 itemData['caseReportDateTime'];
//             StaticVariables.hotlinefinalClosed = itemData['finalClosed'];
//             StaticVariables.hotlinereporterName = itemData['reporterName'];
//             StaticVariables.hotlinemainStreet = itemData['mainStreet'];
//             StaticVariables.hotlineStreet = itemData['street'];
//             StaticVariables.hotlinecaseType = itemData['caseType'];

//             DioNetworkRepos().postHotLineDataList(
//               id: StaticVariables.hotlineId,
//               caseReportDateTime: StaticVariables.hotlinecaseReportDateTime,
//               caseType: StaticVariables.hotlinecaseType,
//               finalClosed: StaticVariables.hotlinefinalClosed,
//               mainStreet: StaticVariables.hotlinemainStreet,
//               reporterName: StaticVariables.hotlinereporterName,
//               street: StaticVariables.hotlineStreet,
//               x: StaticVariables.hotlineX,
//               y: StaticVariables.hotlineY,
//               address: StaticVariables.hotlineAddress,
//             );
//             _getCoordinatesFromAddress(StaticVariables.hotlineAddress);

//             getLocsAfterGetCoordinatesAndGis =
//                 DioNetworkRepos().getAllComplaintsNotFinished();
//             // DioNetworkRepos().getAllComplaintsNotFinished();
//             getLocsByHandasahNameAndTechinicianName =
//                 DioNetworkRepos().getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");
//           } catch (e) {
//             log(e.toString());
//           }
//           Navigator.of(context).pop();
//         },
//       ),
//     );
//   }

//   //TODO: add details to complaint
//   // ==========================================================================
//   // Actions menu (opened from the "عرض التفاصيل" row button)
//   // ==========================================================================

//   void _openActionsMenu(BuildContext buttonContext, Map<String, dynamic> item) {
//     final RenderBox button = buttonContext.findRenderObject() as RenderBox;
//     final RenderBox overlay =
//         Overlay.of(buttonContext).context.findRenderObject() as RenderBox;

//     final RelativeRect position = RelativeRect.fromRect(
//       Rect.fromPoints(
//         button.localToGlobal(Offset.zero, ancestor: overlay),
//         button.localToGlobal(
//           button.size.bottomRight(Offset.zero),
//           ancestor: overlay,
//         ),
//       ),
//       Offset.zero & overlay.size,
//     );

//     _showActionsMenu(position, item);
//   }

//   Future<void> _showActionsMenu(
//       RelativeRect position, Map<String, dynamic> item) async {
//     final selected = await showMenu<String>(
//       context: context,
//       position: position,
//       color: Colors.white,
//       elevation: 6,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(14),
//       ),
//       items: [
//         _buildActionMenuItem(
//           value: 'details',
//           icon: Icons.remove_red_eye_outlined,
//           iconColor: Colors.blue,
//           label: 'عرض التفاصيل',
//         ),
//         _buildActionMenuItem(
//           value: 'location',
//           icon: Icons.location_on_outlined,
//           iconColor: Colors.teal,
//           label: 'عرض الموقع',
//         ),
//         _buildActionMenuItem(
//           value: 'whatsapp',
//           icon: Icons.chat_outlined,
//           iconColor: Colors.green,
//           label: 'إرسال إلى واتساب',
//         ),
//         _buildActionMenuItem(
//           value: 'close',
//           icon: Icons.close_outlined,
//           iconColor: Colors.red.shade600,
//           label: 'غلق البلاغ',
//         ),
//         _buildActionMenuItem(
//           value: 'urgent',
//           icon: Icons.bolt_outlined,
//           iconColor: Colors.deepOrange,
//           label: 'استعجال',
//         ),
//         _buildActionMenuItem(
//           value: 'forward',
//           icon: Icons.forward_outlined,
//           iconColor: Colors.cyan.shade700,
//           label: 'إعادة توجيه',
//         ),
//         _buildActionMenuItem(
//           value: 'link_informant',
//           icon: Icons.link,
//           iconColor: Colors.purple,
//           label: 'ربط كمكرر',
//         ),
//         _buildActionMenuItem(
//           value: 'approval',
//           icon: Icons.check_circle_outline,
//           iconColor: Colors.green.shade700,
//           label: 'تم الحصول على الموافقة',
//         ),
//         const PopupMenuItem<String>(
//           enabled: false,
//           height: 1,
//           padding: EdgeInsets.zero,
//           child: Divider(height: 1),
//         ),
//         _buildActionMenuItem(
//           value: 'delete',
//           icon: Icons.delete_outline,
//           iconColor: Colors.red,
//           label: 'حذف',
//           labelColor: Colors.red,
//         ),
//       ],
//     );

//     if (selected == null || !mounted) return;

//     switch (selected) {
//       case 'details':
//         _showDetailsDialog(item);
//         break;
//       case 'location':
//         _handleShowLocation(item);
//         break;
//       case 'whatsapp':
//         _handleSendToWhatsapp(item);
//         break;
//       case 'close':
//         _handleCloseComplaint(item);
//         break;
//       case 'urgent':
//         _handleMarkUrgent(item);
//         break;
//       case 'forward':
//         _handleForwardComplaint(item);
//         break;
//       case 'link_informant':
//         _handleLinkAsInformant(item);
//         break;
//       case 'approval':
//         _handleApprovalObtained(item);
//         break;
//       case 'delete':
//         _handleDeleteComplaint(item);
//         break;
//     }
//   }

//   PopupMenuItem<String> _buildActionMenuItem({
//     required String value,
//     required IconData icon,
//     required Color iconColor,
//     required String label,
//     Color? labelColor,
//   }) {
//     return PopupMenuItem<String>(
//       value: value,
//       height: 42,
//       child: Directionality(
//         textDirection: TextDirection.rtl,
//         child: Row(
//           children: [
//             Container(
//               width: 28,
//               height: 28,
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: iconColor.withOpacity(0.12),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, size: 16, color: iconColor),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 label,
//                 textAlign: TextAlign.right,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontFamily: 'Cairo',
//                   fontWeight: FontWeight.w500,
//                   color: labelColor ?? Colors.black87,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- Action handlers ---------------------------------------------------
//   void _handleShowLocation(Map<String, dynamic> item) {
//     final lat = item['latitude']?.toString();
//     final lng = item['longitude']?.toString();
//     final gisUrl = item['gisLink']?.toString();
//     if (lat == null || lng == null || lat.isEmpty || lng.isEmpty) {
//       _showActionSnackbar('لا يوجد إحداثيات مسجلة لهذا البلاغ', isError: true);
//       return;
//     }
//     debugPrint('gisUrl:--> $gisUrl');

//     if (gisUrl != null &&
//         gisUrl.isNotEmpty &&
//         lng.isNotEmpty &&
//         lat.isNotEmpty) {
//       CustomBrowserRedirect.openInBrowser(gisUrl);
//     } else {
//       CustomBrowserRedirect.openInBrowser(
//           'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
//     }
//   }

// // In your screen file - Use this handler
//   Future<void> _handleSendToWhatsapp(Map<String, dynamic> item) async {
//     try {
//       // Check if WhatsApp is installed
//       final whatsAppInstalled = await MainWhatsAppService.isWhatsAppInstalled();
//       if (!whatsAppInstalled) {
//         // Show dialog with copy option
//         await MainWhatsAppDialog.showCopyDialog(
//           context: context,
//           complaint: item,
//         );
//         return;
//       }

//       // Get phone number from complaint data or use default
//       String phoneNumber = '00201032743609';

//       // Show dialog to get/confirm phone number
//       final userPhone = await MainWhatsAppDialog.showPhoneNumberDialog(
//         context: context,
//         initialPhoneNumber:
//             phoneNumber.isNotEmpty ? phoneNumber : '00201032743609',
//         complaint: item, // Pass complaint for preview
//       );

//       if (userPhone == null || userPhone.isEmpty) {
//         // User cancelled
//         _showActionSnackbar('تم إلغاء الإرسال');
//         return;
//       }

//       phoneNumber = userPhone;

//       // Send to WhatsApp
//       await MainWhatsAppService.sendToWhatsAppNumber(
//         complaint: item,
//         phoneNumber: phoneNumber,
//       );

//       _showActionSnackbar('تم فتح واتساب بنجاح');
//     } catch (e) {
//       debugPrint('WhatsApp error: $e');

//       // Fallback: Copy to clipboard
//       try {
//         await MainWhatsAppService.copyComplaintToClipboard(item);
//         _showActionSnackbar(
//           'حدث خطأ، تم نسخ البيانات إلى الحافظة',
//           isError: true,
//         );
//       } catch (copyError) {
//         _showActionSnackbar(
//           'حدث خطأ: ${e.toString()}',
//           isError: true,
//         );
//       }
//     }
//   }

//   //TODO: add close complaint

//   void _handleCloseComplaint(Map<String, dynamic> item) {
//     handleCloseComplaint(
//       context,
//       item,
//       fetchData,
//     );
//   }

// //TODO: add mark urgent
//   void _handleMarkUrgent(Map<String, dynamic> item) {
//     handleMarkUrgent(
//       context,
//       item,
//       fetchData,
//     );
//   }

// //TODO: add Reciept Destination
//   void _handleForwardComplaint(Map<String, dynamic> item) {
//     handleForwardComplaint(
//       context,
//       item,
//       fetchData,
//     );
//   }

// //TODO: add link as repeated
//   void _handleLinkAsInformant(Map<String, dynamic> item) {
//     handleLinkAsInformant(
//       context,
//       item,
//       fetchData,
//     );
//   }

// //TODO: add approval obtained
//   void _handleApprovalObtained(Map<String, dynamic> item) {
//     handleApprovalObtained(
//       context,
//       item,
//       fetchData,
//     );
//   }

// //TODO: add delete complaint
//   void _handleDeleteComplaint(Map<String, dynamic> item) {
//     handleDeleteComplaint(
//       context,
//       item,
//       fetchData,
//     );
//   }

//   void _showActionSnackbar(String message, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           textDirection: TextDirection.rtl,
//           textAlign: TextAlign.center,
//           style: const TextStyle(fontFamily: 'Cairo'),
//         ),
//         backgroundColor: isError ? Colors.red : Colors.indigo,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   void _showDetailsDialog(Map<String, dynamic> item) {
//     final entries = <MapEntry<String, String>>[
//       MapEntry('رقم البلاغ', item['complaintId']?.toString() ?? ''),
//       MapEntry('رقم البلاغ المرجعي', item['reportNumber']?.toString() ?? ''),
//       MapEntry('الحي', item['neighborhood']?.toString() ?? ''),
//       MapEntry('ربط مكرر', item['repeatComplaintNumber']?.toString() ?? ''),
//       MapEntry('مصدر البلاغ', item['complaintSource']?.toString() ?? ''),
//       MapEntry('إسم المبلغ', item['reporterName']?.toString() ?? ''),
//       MapEntry('موبيل المبلغ', item['reporterPhone']?.toString() ?? ''),
//       MapEntry('العنوان', item['complaintAddress']?.toString() ?? ''),
//       MapEntry('حالة الإصلاح', item['complaintRepairStatus']?.toString() ?? ''),
//       MapEntry('جهة الاعتماد', item['approvalAuthority']?.toString() ?? ''),
//       MapEntry('نوع الكسر', item['pumpDiameter']?.toString() ?? ''),
//       MapEntry('نوع البلاغ', item['complaintType']?.toString() ?? ''),
//       MapEntry('مدى الخطورة', item['seriousStatus']?.toString() ?? ''),
//       MapEntry('الحالة', item['complaintStatus']?.toString() ?? ''),
//       MapEntry('ملاحظات البلاغ', item['complaintNote']?.toString() ?? ''),
//       MapEntry('جهة الاستلام', item['recipientDestination']?.toString() ?? ''),
//       MapEntry('المستلم', item['recipientUser']?.toString() ?? ''),
//       MapEntry('إسم المستلم', item['recipientName']?.toString() ?? ''),
//       MapEntry(
//           'إسم المستخدم الحالي', item['currentUsername']?.toString() ?? ''),
//       MapEntry('رابط الخريطة (GIS)', item['gisLink']?.toString() ?? ''),
//       MapEntry('خط الطول', item['longitude']?.toString() ?? ''),
//       MapEntry('خط العرض', item['latitude']?.toString() ?? ''),
//       MapEntry('القطاع', item['sectorName']?.toString() ?? ''),
//       MapEntry('رقم الاستعجال', item['urgencyNumber']?.toString() ?? ''),
//       MapEntry('تاريخ الإنشاء', _formatDateOnly(item['createdAt'])),
//       MapEntry('آخر تحديث', _formatDateOnly(item['updatedAt'])),
//       MapEntry('تاريخ الانتهاء', _formatDateOnly(item['finishedAt'])),
//     ];

//     showDialog(
//       context: context,
//       builder: (dialogContext) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//           titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
//           title: Row(
//             children: [
//               const Icon(Icons.assignment_outlined, color: Colors.indigo),
//               const SizedBox(width: 8),
//               const Text(
//                 'تفاصيل البلاغ',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.indigo,
//                   fontSize: 18,
//                   fontFamily: 'Cairo',
//                 ),
//               ),
//               const Spacer(),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color:
//                       _statusColor(item['complaintStatus']).withOpacity(0.12),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: _statusColor(item['complaintStatus']),
//                   ),
//                 ),
//                 child: Text(
//                   item['complaintStatus']?.toString() ?? '',
//                   style: TextStyle(
//                     color: _statusColor(item['complaintStatus']),
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                     fontFamily: 'Cairo',
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           content: SizedBox(
//             width: 440,
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: entries
//                     .where((e) => e.value.isNotEmpty)
//                     .map(
//                       (e) => Container(
//                         margin: const EdgeInsets.only(bottom: 6),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(
//                               width: 130,
//                               child: Text(
//                                 e.key,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.indigo,
//                                   fontSize: 13,
//                                   fontFamily: 'Cairo',
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: SelectableText(
//                                 e.value,
//                                 textAlign: TextAlign.right,
//                                 style: const TextStyle(
//                                   fontSize: 13,
//                                   fontFamily: 'Cairo',
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     )
//                     .toList(),
//               ),
//             ),
//           ),
//           actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//           actions: [
//             TextButton.icon(
//               onPressed: () => Navigator.of(dialogContext).pop(),
//               icon: const Icon(Icons.close, size: 18),
//               label: const Text(
//                 'إغلاق',
//                 style: TextStyle(fontFamily: 'Cairo'),
//               ),
//               style: TextButton.styleFrom(foregroundColor: Colors.indigo),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// //
//   String _formatDateOnly(dynamic raw) {
//     if (raw == null) return '';
//     final parsed = DateTime.tryParse(raw.toString());
//     if (parsed == null) return raw.toString();
//     return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
//   }

//   //
//   Color _statusColor(String? status) {
//     switch (status) {
//       case 'مفتوح':
//       case 'عالى الأهمية':
//         return Colors.red;
//       case 'متوسط الأهمية':
//         return Colors.orange;
//       case 'مغلق':
//       case 'عادى':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }
// }
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'package:emergency_room/screens/widgets/update_close_complaint.dart';
import 'package:emergency_room/screens/widgets/update_delete_complaint.dart';
import 'package:emergency_room/screens/widgets/update_join_as_repeated_address.dart';
import 'package:emergency_room/screens/widgets/update_obtain_approval.dart';
import 'package:emergency_room/screens/widgets/update_recipient_destination.dart';
import 'package:emergency_room/screens/widgets/update_urgency_number.dart';
import 'package:emergency_room/utils/whatsapp/main_whatsapp_dialog.dart';
import 'package:emergency_room/utils/whatsapp/main_whatsapp_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../custom_widget/custom_reusable_alert_dailog.dart';
import '../custom_widget/custom_bottom_sheet.dart';
import '../custom_widget/custom_browser_redirect.dart';
import '../custom_widget/custom_drawer.dart';
import '../custom_widget/custom_end_drawer.dart';
import '../custom_widget/custom_text_button_drop_down_menu.dart';
import '../custom_widget/no_internet_widget.dart';
import '../custom_widget/offline_banner.dart';
import '../labs/widget/convert_handasah_to_lab_code.dart';
import '../labs/widget/convert_lab_code_to_lab_name.dart';
import '../network/remote/remote_network_repos.dart';
import '../services/connection_dialog_service.dart';
import '../services/connectivity_service.dart';
import '../utils/app_constants.dart';

class AddressToCoordinates extends StatefulWidget {
  const AddressToCoordinates({super.key});

  @override
  AddressToCoordinatesState createState() => AddressToCoordinatesState();
}

class AddressToCoordinatesState extends State<AddressToCoordinates> {
  String storeName = "";
  final Completer<GoogleMapController> _controller = Completer();
  bool _isMapControllerReady = false;

  String address = "";
  String coordinates = "";
  String getAddress = "";
  LatLng alexandriaCoordinates = const LatLng(31.205753, 29.924526);
  double latitude = 0.0, longitude = 0.0;
  var pickMarkers = HashSet<Marker>();

  // Data futures consumed by FutureBuilder / drawers.
  // Initialized empty to avoid late-initialization errors before the
  // first fetchData() completes.
  Future getLocsAfterGetCoordinatesAndGis = Future.value([]);
  Future getLocsByHandasahNameAndTechinicianName = Future.value([]);
  final TextEditingController addressController = TextEditingController();
  List<String> handasatItemsDropdownMenu = [];
  List<String> addHandasahToAddressList = [];
  Future<List<Map<String, dynamic>>> getAllHotLineAddresses = Future.value([]);

  // Replace with your actual Google Maps API key
  String googleMapsApiKey = "AIzaSyDRaJJnyvmDSU8OgI8M20C5nmwHNc_AMvk";
  double fontSize = 12.0;
  Timer? _timer; // Timer for periodic fetching
  int numberOfAffectedPeople = 4;
  double aproxTimeFixing = 1;
  String pipDim = '4 mm';

  // --- Internet connection state (mirrors ComplaintsReportsScreen) ---
  bool _isLoading = true;
  bool _isOnline = true;
  bool _isOnlineChecked = false;
  bool _hasData = false;
  List<Map<String, dynamic>> _hotlineData = [];

  @override
  void dispose() {
    _timer?.cancel();
    addressController.dispose();
    if (!_controller.isCompleted) {
      _controller.completeError('Widget disposed');
    }
    super.dispose();
  }

  //TODO:convert GIS-HANDASAH-NAME-TO-EMERGENCY-HANDASAH-NAME(inprogress-21-02-2026)
  String convertGisHandasahNameToEmergencyHandasahName(
      String emergencyHandasahPattern) {
    const Map<String, String> patternToName = {
      'ABUKEER/ابو قير': 'هندسة فرع أبو قير',
      'MANDARA/المندرة': 'هندسة فرع المندرة',
      'SIDIBISHR/سيدى بشر': 'هندسة فرع سيدى بشر',
      'ELRAML/الرمل': 'هندسة فرع الرمل',
      'ELBRAHEMIA/الابراهمية': 'هندسة فرع الابراهمية',
      'ELNOZHA/النزهه': 'هندسة فرع النزهه',
      'ELBALAD_MOHERMBK/البلد ومحرم بك': 'هندسة فرع البلد',
      'ELQABBARI/القبارى': 'هندسة فرع القبارى',
      'ELAGAMI/ العجمى': 'هندسة فرع العجمى',
      'MADINET_NOUBARIA_ELGDIDA/مدينة النوباريه الجديدة': 'هندسة النوبارية',
      'ELAMREYA/العامريه': 'هندسة فرع العامريه',
      'ELBANGER/البنجر': 'هندسة بنجر السكر',
      'BORGELARAB/برج العرب': 'هندسة برج العرب الجديده',
      '6OCTOBER/6 اكتوبر': 'هندسة فرع 6 اكتوبر',
      'ELMINA/الميناء': 'هندسة فرع الميناء',
      'MARIOUT1/مريوط 1': 'هندسة فرع مريوط 1',
    };

    for (final entry in patternToName.entries) {
      if (emergencyHandasahPattern.contains(entry.key)) {
        return entry.value;
      }
    }

    return emergencyHandasahPattern;
  }

  // ==========================================================================
  // Unified data fetch — single connectivity check + single fetch pass,
  // matching ComplaintsReportsScreen.fetchData(). Replaces the old trio of
  // _initializeApp / _fetchInitialData / _fetchHandasatItems, which each ran
  // their own connectivity checks and could show duplicate dialogs.
  // ==========================================================================
  Future<void> fetchData() async {
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
      // Only interrupt with a blocking dialog when there's truly nothing
      // on screen yet. If we already have cached hotline/complaint data,
      // the OfflineBanner alone is enough — showing the dialog on top of
      // a populated screen is exactly the confusing behavior we want to
      // avoid.
      if (!_hasData) {
        await ConnectionDialogService.showNoInternetDialog(
          context,
          onRetry: fetchData,
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await DioNetworkRepos().getHotLineTokenByUserAndPassword();
      final hotlineData = await DioNetworkRepos().getHotLineData(token);
      //TODO:UPDATE_COMPLAINTS
      final locsData = await DioNetworkRepos().getAllComplaintsNotFinished();
      // final locsData = await DioNetworkRepos().getAllComplaintsNotFinished();
      final locsByHandasah = await DioNetworkRepos()
          .getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");

      final handasatItems =
          await DioNetworkRepos().fetchHandasatItemsDropdownMenu();

      if (!mounted) return;

      final hotlineList = (hotlineData as List).cast<Map<String, dynamic>>();
      final bool locsHasData = locsData is List && locsData.isNotEmpty;

      setState(() {
        _hotlineData = hotlineList;
        getAllHotLineAddresses = Future.value(hotlineList);
        getLocsAfterGetCoordinatesAndGis = Future.value(locsData);
        getLocsByHandasahNameAndTechinicianName = Future.value(locsByHandasah);
        handasatItemsDropdownMenu =
            handasatItems.map<String>((e) => e.toString()).toList();
        _hasData = hotlineList.isNotEmpty || locsHasData;
        _isLoading = false;
      });

      log("handasatItemsDropdownMenu from UI: $handasatItemsDropdownMenu");
      log("GET ALL HOTLINE LOCATIONS: $hotlineList");
    } catch (e) {
      log("Error fetching data: $e");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      final onlineAgain = await ConnectivityService.instance.hasConnection();
      if (!mounted) return;
      setState(() {
        _isOnline = onlineAgain;
      });
      // Same rule here: only block with a dialog if there's no data to
      // fall back on. Otherwise let the banner communicate it.
      if (!onlineAgain && !_hasData) {
        await ConnectionDialogService.showNoInternetDialog(
          context,
          onRetry: fetchData,
        );
      }
    }
  }

  //update in periodic time — refreshes silently, defers to the banner
  //instead of ever showing a blocking dialog on its own.
  void _startPeriodicFetch() {
    const Duration fetchInterval = Duration(seconds: 10);
    _timer = Timer.periodic(fetchInterval, (Timer timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final online = await ConnectivityService.instance.hasConnection();
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _isOnline = online;
        _isOnlineChecked = true;
      });

      if (online) {
        setState(() {
          getLocsAfterGetCoordinatesAndGis =
              DioNetworkRepos().getAllComplaintsNotFinished();
          getLocsByHandasahNameAndTechinicianName = DioNetworkRepos()
              .getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    _startPeriodicFetch();
  }

  // ==================== UI: _getCoordinatesFromAddress ====================

  Future<void> _getCoordinatesFromAddress(String address) async {
    if (!mounted) return;

    final online = await ConnectivityService.instance.hasConnection();
    if (!online) {
      if (!mounted) return;
      // Direct user action being blocked — an explicit notice is
      // appropriate here regardless of what's already on screen.
      ConnectionDialogService.showNoInternetDialog(context);
      setState(() {
        _isOnline = false;
        _isOnlineChecked = true;
      });
      return;
    }

    setState(() {
      _isOnline = true;
      _isOnlineChecked = true;
      _isLoading = true;
    });

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$googleMapsApiKey',
    );

    try {
      // Wait for map controller to be ready with timeout
      GoogleMapController controller;
      try {
        controller = await _controller.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            log("Map controller timeout");
            throw Exception("Map controller timeout");
          },
        );
      } catch (e) {
        log("Error getting map controller: $e");
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "خطأ في تحميل الخريطة، يرجى إعادة المحاولة",
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await http.get(url);

      if (response.statusCode != 200) {
        setState(() => coordinates = "Error: Failed to fetch data");
        return;
      }

      final data = json.decode(response.body);

      if (data['results'] == null || data['results'].isEmpty) {
        setState(() => coordinates = "Error: No results found");
        return;
      }

      final location = data['results'][0]['geometry']['location'];
      latitude = location['lat'];
      longitude = location['lng'];
      coordinates = "Latitude: $latitude, Longitude: $longitude";

      log("Address     :>> $address");
      log("Coordinates :>> $coordinates");
      log("Longitude   :>> $longitude");
      log("Latitude    :>> $latitude");

      setState(() {
        pickMarkers.add(
          Marker(
            markerId: MarkerId(address),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(title: address, snippet: coordinates),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
        );
      });

      // Only animate camera if controller is ready
      if (mounted && !_controller.isCompleted) {
        try {
          await controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: LatLng(latitude, longitude), zoom: 15.0),
            ),
          );
        } catch (e) {
          log("Error animating camera: $e");
        }
      }

      log('START-GIS-INTEGRATIONS');
      await _runGisIntegration(address);

      if (!mounted) return;
      setState(() {
        getLocsAfterGetCoordinatesAndGis =
            DioNetworkRepos().getAllComplaintsNotFinished();
        getLocsByHandasahNameAndTechinicianName = DioNetworkRepos()
            .getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");
        _isLoading = false;
      });
    } catch (e) {
      log("_getCoordinatesFromAddress error: $e");
      setState(() => coordinates = "Error: Unable to get coordinates");
      if (!mounted) return;
      final onlineAgain = await ConnectivityService.instance.hasConnection();
      if (!mounted) return;
      setState(() {
        _isOnline = onlineAgain;
        _isLoading = false;
      });
      if (!onlineAgain && !_hasData) {
        await ConnectionDialogService.showNoInternetDialog(
          context,
          onRetry: fetchData,
        );
      }
    }
  }

  // ── GIS Integration ─────────────────────────────────────────────────────────
  Future<void> _runGisIntegration(String address) async {
    log("=== _runGisIntegration STARTED ===");
    try {
      log("=== CALLING getLastRecordNumberWeb ===");
      final lastRecordNumber = await DioNetworkRepos().getLastRecordNumberWeb();
      log("=== getLastRecordNumberWeb SUCCESS: $lastRecordNumber ===");

      final newRecordNumber = lastRecordNumber + 1;

      log("=== CALLING createNewGisPointAndGetMapLinkAndHandasah ===");
      final result =
          await DioNetworkRepos().createNewGisPointAndGetMapLinkAndHandasah(
        newRecordNumber,
        longitude.toString(),
        latitude.toString(),
      );
      log("=== createNewGisPoint SUCCESS: $result ===");

      final gisUrl = result['url'] as String? ?? 'لم يدرج';
      final branch = result['engineering_branch'] as String? ?? 'لم يدرج';
      final service = result['wtp_service'] as String? ?? 'لم يدرج';

      log("GIS MAP LINK :>> $gisUrl");
      log("GIS BRANCH   :>> $branch");
      log("GIS SERVICE  :>> $service");

      final handasahBranch =
          convertGisHandasahNameToEmergencyHandasahName(branch);

      log("=== CALLING _saveOrUpdateLocation WITH REAL DATA ===");
      await _saveOrUpdateLocation(address, gisUrl, handasahBranch);
      log("=== _saveOrUpdateLocation DONE ===");
    } catch (gisError, stackTrace) {
      log("=== GIS CATCH BLOCK REACHED ===");
      log("=== gisError: $gisError ===");
      log("=== stackTrace: $stackTrace ===");
      log("=== CALLING _saveOrUpdateLocation WITH FALLBACK ===");
      await _saveOrUpdateLocation(address, 'لم يدرج', 'لم يدرج');
      log("=== FALLBACK _saveOrUpdateLocation DONE ===");
    }

    log("=== _runGisIntegration ENDED ===");
  }

  // ── Helper: save new or update existing location ──────────────────────────

  Future<void> _saveOrUpdateLocation(
    String address,
    String gisUrl,
    String handasahBranch,
  ) async {
    try {
      // final addressExists = await DioNetworkRepos().checkAddressExists(address);
      // log("addressExists: $addressExists");

      // if (addressExists == true) {
      //   log("Address already exists — updating...");
      //   await DioNetworkRepos().updateLocations(
      //     address,
      //     longitude,
      //     latitude,
      //     gisUrl,
      //     handasahBranch,
      //   );
      //   log("Location updated successfully.");
      // } else {
      log("Address not found — creating new location...");
      await DioNetworkRepos().createNewComplaint(
        complaintAddress: address,
        gisLink: gisUrl,
        longitude: longitude.toString(),
        latitude: latitude.toString(),
        currentUsername: StaticVariables.username,
        recipientName: 'لم يدرج',
        recipientDestination: handasahBranch ?? 'لم يدرج',
        approvalAuthority: 'لم يدرج',
        neighborhood: 'لم يدرج',
        complaintSource: 'لم يدرج',
        reporterName: 'لم يدرج',
        reporterPhone: 'لم يدرج',
        complaintRepairStatus: 'لم يدرج',
        pumpDiameter: 'لم يدرج',
        seriousStatus: 'لم يدرج',
        complaintStatus: 'لم يدرج',
        recipientUser: 'لم يدرج',
        complaintType: 'لم يدرج',
        sectorName: 'لم يدرج',
      );
      log("Complaint created successfully.$address ===> $gisUrl ==>$handasahBranch ==>$longitude ===> $latitude ===> ${StaticVariables.username}");
      await DioNetworkRepos().createNewLocation(
        address,
        longitude,
        latitude,
        gisUrl,
        handasahBranch,
      );
      log("New location created successfully.");
      // }
    } catch (e) {
      log("_saveOrUpdateLocation error: $e");
    }
  }

  //show bottom sheet Redirect to Handasat
  void showCustomBottomSheet(
      BuildContext context, String title, String message, String address) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      builder: (context) {
        return CustomBottomSheet(
          title: title,
          message: message,
          hintText: "اختر الهندسة",
          dropdownItems: handasatItemsDropdownMenu,
          onItemSelected: (value) {
            log("Selected: $value");
            setState(() {
              DioNetworkRepos().updateLocAddHandasah(address, value);
            });
          },
          onPressed: () async {
            Navigator.of(context).pop();
            await DioNetworkRepos().updateLocAddTechnician(address, "لم يدرج");
            await DioNetworkRepos().updateLocAddIsApproved(address, 0);
          },
        );
      },
    );
  }

  //handle dropdown click
  void handleOptionClick(String value) {
    log("Clicked: $value");
    if (value == 'عرض التقارير') {
      context.go('/report');
    } else if (value == 'عرض البلاغات المفتوحة') {
      context.go('/monitor-complaints');
    } else if (value == 'عرض لوحة التحكم') {
      context.go('/report-dashboard');
    } else if (value == 'الربط مع الاسكادا') {
      CustomBrowserRedirect.openInBrowser(
        'http://41.33.226.211:8070/roundpoint',
      );
    } else if (value == 'عرض المناطق المزدحمة بالبلاغات') {
      CustomBrowserRedirect.openInBrowser(
        'http://196.219.231.3:8000/webmap/breaks-hot-spots',
      );
    } else if (value == 'عرض تقرير الاسكادا Dashboard') {
      context.go('/dashboard');
    }
  }

  // //TODO://add alexandria to the address(6-8-2026)

  String _normalizeAlexandriaAddress(String input) {
    const variants = [
      'الاسكندرية',
      'الإسكندرية',
      'الاسكندريه',
      'الإسكندريه', // fixed: was missing leading "ال"
    ];
    const correct = 'الإسكندرية';

    var address = input.trim();

    final hasVariant = variants.any((v) => address.contains(v));

    if (hasVariant) {
      for (final v in variants) {
        address = address.replaceAll(v, correct);
      }
    } else {
      address = address.isEmpty ? correct : '$address $correct';
    }

    return address;
  }

  @override
  Widget build(BuildContext context) {
    // Nothing useful is on screen only when we're offline AND we have no
    // cached hotline/complaint data to fall back on.
    final showNoInternet = !_isOnline && _isOnlineChecked && !_hasData;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          " غرفة الطوارئ",
          style: TextStyle(
            color: Colors.indigo,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 7,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.indigo,
          size: 17,
        ),
        actions: [
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            tooltip: "تحديث شكاوى الخط الساخن",
            hoverColor: Colors.yellow,
            onPressed: () {
              fetchData();
            },
            icon: const Icon(
              Icons.refresh,
              color: Colors.indigo,
            ),
          ),
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            tooltip: "إضافة مستخدمين الطوارئ",
            hoverColor: Colors.yellow,
            icon: const Icon(
              Icons.person_add_alt,
              color: Colors.indigo,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return CustomReusableAlertDialog(
                        title: 'اضافة مستخدمين الطوارئ',
                        fieldLabels: const [
                          'اسم المستخدم',
                          'كلمة المرور',
                          'مطابقة كلمة المرور',
                        ],
                        onSubmit: (values) {
                          DioNetworkRepos().createNewUser(
                              values[0], values[1], 1, 'غرفة الطوارئ');
                        });
                  });
            },
          ),
          TextButtonDropdown(
            label: 'متابعة البلاغات الواردة',
            options: const [
              'عرض البلاغات المفتوحة',
              'عرض التقارير',
              'عرض لوحة التحكم',
              'عرض تقرير الاسكادا',
              'الربط مع الاسكادا',
              'عرض المناطق المزدحمة بالبلاغات',
            ],
            onSelected: handleOptionClick,
          ),
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            tooltip: "تسجيل الخروج",
            hoverColor: Colors.yellow,
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            onPressed: () {
              context.go('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          OfflineBanner(visible: !_isOnline && _isOnlineChecked),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : showNoInternet
                    ? NoInternetWidget(onRetry: fetchData)
                    : Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              width: 220,
                              height: MediaQuery.of(context).size.height,
                              child: CustomEndDrawer(
                                title: 'تخصيص بلاغات الهندسة',
                                getLocs:
                                    getLocsByHandasahNameAndTechinicianName,
                                stringListItems: handasatItemsDropdownMenu,
                                onPressed: () {
                                  setState(() {
                                    getLocsByHandasahNameAndTechinicianName =
                                        DioNetworkRepos()
                                            .getLocByHandasahAndTechnician(
                                                "لم يدرج", "لم يدرج");
                                    getLocsAfterGetCoordinatesAndGis =
                                        DioNetworkRepos()
                                            .getAllComplaintsNotFinished();
                                  });
                                },
                                hintText: 'فضلا أختار الهندسة',
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Stack(
                                children: [
                                  GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: alexandriaCoordinates,
                                      zoom: 10.4746,
                                    ),
                                    onMapCreated:
                                        (GoogleMapController controller) {
                                      if (!_controller.isCompleted) {
                                        _controller.complete(controller);
                                      }
                                      setState(() {
                                        _isMapControllerReady = true;
                                      });
                                    },
                                    markers: pickMarkers,
                                    zoomControlsEnabled: true,
                                    onCameraMoveStarted: () async {
                                      // Only try to animate if controller is ready
                                      if (_controller.isCompleted && mounted) {
                                        try {
                                          final GoogleMapController controller =
                                              await _controller.future;
                                          CameraPosition cameraPosition =
                                              CameraPosition(
                                            target: LatLng(latitude, longitude),
                                            zoom: 14,
                                          );
                                          await controller.animateCamera(
                                              CameraUpdate.newCameraPosition(
                                                  cameraPosition));
                                        } catch (e) {
                                          log("Camera move error: $e");
                                        }
                                      }
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            decoration: InputDecoration(
                                              constraints: const BoxConstraints(
                                                maxHeight: 70,
                                                minWidth: 200,
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0),
                                                ),
                                              ),
                                              hintText: "فضلا أدخل العنوان",
                                              hintStyle: TextStyle(
                                                color: Colors.indigo[200],
                                                fontSize: 11,
                                              ),
                                              labelText:
                                                  "61 طريق الحرية الاسكندرية",
                                            ),
                                            controller: addressController,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.indigo,
                                            ),
                                            cursorColor: Colors.indigo,
                                            keyboardType: TextInputType.text,
                                            maxLength: 250,
                                            textAlign: TextAlign.right,
                                            textDirection: TextDirection.rtl,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 17.0),
                                          child: IconButton(
                                            alignment: Alignment.center,
                                            onPressed: () async {
                                              if (addressController
                                                  .text.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      " فضلا ادخل العنوان, ثم اضغط على البحث",
                                                      textDirection:
                                                          TextDirection.rtl,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }

                                              // 1) Pure, synchronous normalization — no setState needed for this part
                                              final normalizedAddress =
                                                  _normalizeAlexandriaAddress(
                                                      addressController.text);

                                              // 2) Sync UI updates only
                                              setState(() {
                                                pickMarkers.clear();
                                                address = normalizedAddress;
                                              });

                                              addressController.clear();

                                              // 3) Await the async geocode/connectivity call BEFORE touching state again
                                              await _getCoordinatesFromAddress(
                                                  address);

                                              // 4) Now safely refresh the futures, only after the above completes
                                              if (!mounted) return;
                                              setState(() {
                                                getLocsAfterGetCoordinatesAndGis =
                                                    DioNetworkRepos()
                                                        .getAllComplaintsNotFinished();
                                                getLocsByHandasahNameAndTechinicianName =
                                                    DioNetworkRepos()
                                                        .getLocByHandasahAndTechnician(
                                                            "لم يدرج",
                                                            "لم يدرج");
                                              });
                                            },
                                            icon: const CircleAvatar(
                                              backgroundColor: Colors.indigo,
                                              radius: 20,
                                              child: Icon(
                                                Icons.search_outlined,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              width: 220,
                              height: MediaQuery.of(context).size.height,
                              color: Colors.black45,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Container(
                                      height: 40,
                                      color: Colors.indigo,
                                      child: const Center(
                                        child: Text(
                                          textDirection: TextDirection.rtl,
                                          textAlign: TextAlign.center,
                                          'جميع البلاغات غير المغلقة',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    FutureBuilder(
                                        future:
                                            getLocsAfterGetCoordinatesAndGis,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                          if (snapshot.hasError) {
                                            return Center(
                                              child: Column(
                                                children: [
                                                  const Text(
                                                      'حدث خطأ في تحميل البيانات'),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        getLocsAfterGetCoordinatesAndGis =
                                                            DioNetworkRepos()
                                                                .getAllComplaintsNotFinished();
                                                      });
                                                    },
                                                    child: const Text(
                                                        'إعادة المحاولة'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          if (snapshot.hasData &&
                                              snapshot.data!.isNotEmpty) {
                                            return ListView.builder(
                                              reverse: true,
                                              shrinkWrap: true,
                                              itemCount: snapshot.data!.length,
                                              itemBuilder: (context, index) {
                                                final item =
                                                    snapshot.data![index];
                                                return Card(
                                                  child: Column(
                                                    children: [
                                                      ListTile(
                                                        title: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 7.0,
                                                                  horizontal:
                                                                      3.0),
                                                          child: Row(
                                                            children: [
                                                              // IconButton(
                                                              //   tooltip:
                                                              //       "إضافة بيانات البلاغ",
                                                              //   onPressed:
                                                              //       () {
                                                              //     showDialog(
                                                              //       context:
                                                              //           context,
                                                              //       builder: (context) => CustomReusableAlertDialogWithDropdown(
                                                              //           title: "تحديث بيانات البلاغ",
                                                              //           fieldConfigs: const [
                                                              //             FieldConfig(
                                                              //               label: "إسم المبلغ",
                                                              //               type: FieldType.textField,
                                                              //             ),
                                                              //             FieldConfig(
                                                              //               label: "قطر الماسورة",
                                                              //               type: FieldType.dropdown,
                                                              //               dropdownItems: [
                                                              //                 "``4",
                                                              //                 "``6",
                                                              //                 "``8",
                                                              //                 "``10",
                                                              //                 "``12",
                                                              //                 "``20",
                                                              //                 "``28",
                                                              //                 "``40",
                                                              //                 "``60"
                                                              //               ],
                                                              //             ),
                                                              //             FieldConfig(
                                                              //               label: "رقم الموبيل",
                                                              //               type: FieldType.textField,
                                                              //             ),
                                                              //           ],
                                                              //           onSubmit: (values) {
                                                              //             log("User Input: $values");
                                                              //             if (values[0] == "" ||
                                                              //                 values[1] == "" ||
                                                              //                 values[2] == "") {
                                                              //               ScaffoldMessenger.of(context).showSnackBar(
                                                              //                 const SnackBar(
                                                              //                   content: Text(
                                                              //                     "يرجى ملء جميع الحقول",
                                                              //                     textDirection: TextDirection.rtl,
                                                              //                     textAlign: TextAlign.center,
                                                              //                   ),
                                                              //                 ),
                                                              //               );
                                                              //             } else {
                                                              //               DioNetworkRepos().updateLocationBrokenByAddress(item['address'], values[0], values[1], values[2]);
                                                              //               log("User Input: updated Caller Name, Phone, And Borken Number");
                                                              //               pipDim = values[1];
                                                              //               // Update affected people based on pipe diameter
                                                              //               if (values[1] == "``4") {
                                                              //                 numberOfAffectedPeople = 2000;
                                                              //                 aproxTimeFixing = 2;
                                                              //               } else if (values[1] == "``6") {
                                                              //                 numberOfAffectedPeople = 2500;
                                                              //                 aproxTimeFixing = 2;
                                                              //               } else if (values[1] == "``8") {
                                                              //                 numberOfAffectedPeople = 4000;
                                                              //                 aproxTimeFixing = 3;
                                                              //               } else if (values[1] == "``10") {
                                                              //                 numberOfAffectedPeople = 4200;
                                                              //                 aproxTimeFixing = 3;
                                                              //               } else if (values[1] == "``12") {
                                                              //                 numberOfAffectedPeople = 5000;
                                                              //                 aproxTimeFixing = 4;
                                                              //               } else if (values[1] == "``20") {
                                                              //                 numberOfAffectedPeople = 10000;
                                                              //                 aproxTimeFixing = 5;
                                                              //               } else if (values[1] == "``28") {
                                                              //                 numberOfAffectedPeople = 15000;
                                                              //                 aproxTimeFixing = 6;
                                                              //               } else if (values[1] == "``40") {
                                                              //                 numberOfAffectedPeople = 50000;
                                                              //                 aproxTimeFixing = 8;
                                                              //               } else if (values[1] == "``60") {
                                                              //                 numberOfAffectedPeople = 100000;
                                                              //                 aproxTimeFixing = 24;
                                                              //               }
                                                              //             }
                                                              //           }),
                                                              //     );
                                                              //   },
                                                              //   icon:
                                                              //       const Icon(
                                                              //     Icons
                                                              //         .add_circle_outlined,
                                                              //     color: Colors
                                                              //         .indigo,
                                                              //   ),
                                                              // ),

                                                              Expanded(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              8.0),
                                                                  child: Text(
                                                                    textAlign:
                                                                        TextAlign
                                                                            .right,
                                                                    textDirection:
                                                                        TextDirection
                                                                            .rtl,
                                                                    item[
                                                                        'complaintAddress'],
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .indigo,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            13),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        subtitle: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 7.0,
                                                                  horizontal:
                                                                      3.0),
                                                          child: Column(
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  item['recipientDestination'] ==
                                                                          'لم يدرج'
                                                                      ? Expanded(
                                                                          child:
                                                                              Container(
                                                                            margin:
                                                                                const EdgeInsets.all(3.0),
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 3.0),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              border: Border.all(color: Colors.orange, width: 1.0),
                                                                              borderRadius: BorderRadius.circular(5.0),
                                                                              color: Colors.orange,
                                                                            ),
                                                                            child:
                                                                                Text(
                                                                              textAlign: TextAlign.center,
                                                                              "قيد تخصيص هندسة",
                                                                              style: TextStyle(
                                                                                overflow: TextOverflow.visible,
                                                                                fontSize: fontSize,
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : Expanded(
                                                                          child:
                                                                              Container(
                                                                            margin:
                                                                                const EdgeInsets.all(3.0),
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 1.0),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              border: Border.all(color: Colors.green, width: 1.0),
                                                                              borderRadius: BorderRadius.circular(5.0),
                                                                              color: Colors.green,
                                                                            ),
                                                                            child:
                                                                                Text(
                                                                              textAlign: TextAlign.center,
                                                                              "${item['recipientDestination']}",
                                                                              style: TextStyle(
                                                                                fontSize: fontSize,
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                  item['technical_name'] ==
                                                                          "لم يدرج"
                                                                      ? Expanded(
                                                                          child:
                                                                              Container(
                                                                            margin:
                                                                                const EdgeInsets.all(3.0),
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 3.0),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              border: Border.all(color: Colors.orange, width: 1.0),
                                                                              borderRadius: BorderRadius.circular(5.0),
                                                                              color: Colors.orange,
                                                                            ),
                                                                            child:
                                                                                Text(
                                                                              textAlign: TextAlign.center,
                                                                              "قيد تخصيص فنى",
                                                                              style: TextStyle(
                                                                                overflow: TextOverflow.visible,
                                                                                fontSize: fontSize,
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : Expanded(
                                                                          child:
                                                                              Container(
                                                                            margin:
                                                                                const EdgeInsets.all(3.0),
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 3.0),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              border: Border.all(color: Colors.green, width: 1.0),
                                                                              borderRadius: BorderRadius.circular(5.0),
                                                                              color: Colors.green,
                                                                            ),
                                                                            child:
                                                                                Text(
                                                                              textAlign: TextAlign.center,
                                                                              "${item['recipientUser']}",
                                                                              style: TextStyle(
                                                                                fontSize: fontSize,
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: item['isTracked'] ==
                                                                            1
                                                                        ? Container(
                                                                            margin:
                                                                                const EdgeInsets.all(3.0),
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 3.0),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              border: Border.all(color: Colors.green, width: 1.0),
                                                                              borderRadius: BorderRadius.circular(5.0),
                                                                              color: Colors.green,
                                                                            ),
                                                                            child:
                                                                                Text(
                                                                              textAlign: TextAlign.center,
                                                                              'تم قبول البلاغ',
                                                                              style: TextStyle(
                                                                                fontSize: fontSize,
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : Container(
                                                                            margin:
                                                                                const EdgeInsets.all(3.0),
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 3.0),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              border: Border.all(color: Colors.orange, width: 1.0),
                                                                              borderRadius: BorderRadius.circular(5.0),
                                                                              color: Colors.orange,
                                                                            ),
                                                                            child:
                                                                                Text(
                                                                              textAlign: TextAlign.center,
                                                                              'قيد قبول البلاغ',
                                                                              style: TextStyle(
                                                                                fontSize: fontSize,
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                  ),
                                                                  Expanded(
                                                                    child: item['complaintType'] !=
                                                                            "لم يدرج نوع الكسر"
                                                                        ? Container(
                                                                            margin:
                                                                                const EdgeInsets.all(3.0),
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 3.0),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              border: Border.all(color: Colors.green, width: 1.0),
                                                                              borderRadius: BorderRadius.circular(5.0),
                                                                              color: Colors.green,
                                                                            ),
                                                                            child:
                                                                                Text(
                                                                              textAlign: TextAlign.center,
                                                                              '${item['complaintType']}',
                                                                              style: TextStyle(
                                                                                fontSize: fontSize,
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : Container(
                                                                            margin:
                                                                                const EdgeInsets.all(3.0),
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 3.0),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              border: Border.all(color: Colors.orange, width: 1.0),
                                                                              borderRadius: BorderRadius.circular(5.0),
                                                                              color: Colors.orange,
                                                                            ),
                                                                            child:
                                                                                Text(
                                                                              textAlign: TextAlign.center,
                                                                              'لم يدرج نوع الكسر',
                                                                              style: TextStyle(
                                                                                fontSize: fontSize,
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      // ALL ICON BUTTONS
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          // GIS Map
                                                          Expanded(
                                                            child: IconButton(
                                                              tooltip:
                                                                  'التوجهه للخريطة GIS Map',
                                                              hoverColor:
                                                                  Colors.yellow,
                                                              onPressed: () {
                                                                log("Start Gis Map ${item['gisLink']}");
                                                                if (item[
                                                                        'gisLink'] ==
                                                                    'لم يدرج') {
                                                                  //TODO:REDIRECT-TO-GOOGLE-MAP
                                                                  CustomBrowserRedirect
                                                                      .openInBrowser(
                                                                          'https://www.google.com/maps/search/?api=1&query=${item['latitude']},${item['longitude']}');
                                                                } else {
                                                                  CustomBrowserRedirect
                                                                      .openInBrowser(
                                                                          item[
                                                                              'gisLink']);
                                                                }
                                                              },
                                                              icon: const Icon(
                                                                  Icons
                                                                      .open_in_browser,
                                                                  color: Colors
                                                                      .blue),
                                                            ),
                                                          ),
                                                          // Voice Call
                                                          Expanded(
                                                            child: IconButton(
                                                              tooltip:
                                                                  'اجراء مكالمة صوتية',
                                                              hoverColor:
                                                                  Colors.yellow,
                                                              onPressed: () =>
                                                                  CustomBrowserRedirect
                                                                      .openInBrowser(
                                                                          "https://meet.jit.si/${item['complaintAddress']}"),
                                                              icon: const Icon(
                                                                  Icons.call,
                                                                  color: Colors
                                                                      .green),
                                                            ),
                                                          ),
                                                          // Tracking
                                                          Expanded(
                                                            child: IconButton(
                                                              tooltip:
                                                                  'بدء تتبع فنى الهندسة',
                                                              hoverColor:
                                                                  Colors.yellow,
                                                              onPressed: () {
                                                                log("Start Traking ${item['complaintId']}");
                                                                if (item[
                                                                        'isTracked'] ==
                                                                    0) {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    const SnackBar(
                                                                      content:
                                                                          Text(
                                                                        'البلاغ قيد القبول وجارى التفعيل',
                                                                        textDirection:
                                                                            TextDirection.rtl,
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  );
                                                                } else {
                                                                  context.go(
                                                                      '/tracking/${item['complaintAddress']}/${item['latitude']}/${item['longitude']}/${item['recipientUser']}');
                                                                }
                                                              },
                                                              icon: const Icon(
                                                                  Icons
                                                                      .location_on,
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                          ),
                                                          // Store Inventory
                                                          Expanded(
                                                            child: IconButton(
                                                              tooltip:
                                                                  'جرد مخزن',
                                                              hoverColor:
                                                                  Colors.yellow,
                                                              onPressed:
                                                                  () async {
                                                                if (item[
                                                                        'recipientDestination'] ==
                                                                    'لم يدرج') {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    const SnackBar(
                                                                      content:
                                                                          Text(
                                                                        'عفوا, لايمكن إظهار جرد المخزن قبل تخصيص الهندسه',
                                                                        textDirection:
                                                                            TextDirection.rtl,
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                  );
                                                                } else {
                                                                  await DioNetworkRepos()
                                                                      .getStoreNameByHandasahName(
                                                                          item[
                                                                              'recipientDestination'])
                                                                      .then(
                                                                          (value) {
                                                                    storeName =
                                                                        value[
                                                                            'storeName'];
                                                                  });
                                                                  DioNetworkRepos()
                                                                      .excuteTempStoreQty(
                                                                          storeName);
                                                                  context.go(
                                                                      '/integrate-with-stores/$storeName');
                                                                }
                                                              },
                                                              icon: const Icon(
                                                                  Icons
                                                                      .store_outlined,
                                                                  color: Colors
                                                                      .indigo),
                                                            ),
                                                          ),
                                                          // Labs Integration
                                                          Expanded(
                                                            child: IconButton(
                                                              tooltip:
                                                                  'الربط مع المعامل',
                                                              hoverColor:
                                                                  Colors.yellow,
                                                              onPressed: () {
                                                                StaticVariables
                                                                        .labCode =
                                                                    convertHandasahToLabCode(
                                                                        item[
                                                                            'recipientUser']);
                                                                StaticVariables
                                                                        .labName =
                                                                    convertLabCodeToLabName(
                                                                        StaticVariables
                                                                            .labCode);
                                                                log("LAB_CODE: ${StaticVariables.labCode}");
                                                                log("LAB_NAME: ${StaticVariables.labName}");
                                                                context.go(
                                                                    '/integration-with-labs');
                                                              },
                                                              icon: const Icon(
                                                                  Icons
                                                                      .report_gmailerrorred,
                                                                  color: Colors
                                                                      .cyan),
                                                            ),
                                                          ),
                                                          // GPS Car Tracking
                                                          Expanded(
                                                            child: IconButton(
                                                              tooltip:
                                                                  'تتبع سيارة GPS',
                                                              hoverColor:
                                                                  Colors.yellow,
                                                              onPressed: () {},
                                                              icon: const Icon(
                                                                  Icons
                                                                      .car_rental,
                                                                  color: Colors
                                                                      .indigo),
                                                            ),
                                                          ),
                                                          // Mobile Emergency Room
                                                          Expanded(
                                                            child: IconButton(
                                                              tooltip:
                                                                  "غرفة الطوارئ المتحركة",
                                                              hoverColor:
                                                                  Colors.yellow,
                                                              onPressed: () {
                                                                CustomBrowserRedirect
                                                                    .openInBrowser(
                                                                        "https://meet.jit.si/mobileEmergencyRoom");
                                                              },
                                                              icon: const Icon(
                                                                  Icons
                                                                      .car_crash,
                                                                  color: Colors
                                                                      .purple),
                                                            ),
                                                          ),
                                                          // Camera System
                                                          Expanded(
                                                            child: IconButton(
                                                              tooltip:
                                                                  'نظام الكاميرات',
                                                              hoverColor:
                                                                  Colors.yellow,
                                                              onPressed: () {
                                                                const url =
                                                                    mobileCarIpCameratbaseUrlLocalHost;
                                                                CustomBrowserRedirect
                                                                    .openInBrowser(
                                                                        url);
                                                              },
                                                              icon: const Icon(
                                                                  Icons
                                                                      .video_camera_back,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                          // SCADA Integration
                                                          Expanded(
                                                            child: IconButton(
                                                              tooltip:
                                                                  'الربط مع الاسكادا',
                                                              hoverColor:
                                                                  Colors.yellow,
                                                              onPressed: () {
                                                                CustomBrowserRedirect
                                                                    .openInBrowser(
                                                                        'http://41.33.226.211:8070/roundpoint');
                                                              },
                                                              icon: const Icon(
                                                                  Icons
                                                                      .dashboard_customize_outlined,
                                                                  color: Colors
                                                                      .orange),
                                                            ),
                                                          ),
                                                          // Complaint Info - Using PopupMenuButton for reliable menu
                                                          Expanded(
                                                            child:
                                                                PopupMenuButton<
                                                                    String>(
                                                              tooltip:
                                                                  'عرض بيانات البلاغ',
                                                              offset:
                                                                  const Offset(
                                                                      0, -10),
                                                              color:
                                                                  Colors.white,
                                                              elevation: 6,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            14),
                                                              ),
                                                              onSelected: (value) =>
                                                                  _handleAction(
                                                                      value,
                                                                      item),
                                                              itemBuilder:
                                                                  (context) => [
                                                                _buildPopupMenuItem(
                                                                  value:
                                                                      'details',
                                                                  icon: Icons
                                                                      .remove_red_eye_outlined,
                                                                  iconColor:
                                                                      Colors
                                                                          .blue,
                                                                  label:
                                                                      'عرض التفاصيل',
                                                                ),
                                                                _buildPopupMenuItem(
                                                                  value:
                                                                      'location',
                                                                  icon: Icons
                                                                      .location_on_outlined,
                                                                  iconColor:
                                                                      Colors
                                                                          .teal,
                                                                  label:
                                                                      'عرض الموقع',
                                                                ),
                                                                _buildPopupMenuItem(
                                                                  value:
                                                                      'whatsapp',
                                                                  icon: Icons
                                                                      .chat_outlined,
                                                                  iconColor:
                                                                      Colors
                                                                          .green,
                                                                  label:
                                                                      'إرسال إلى واتساب',
                                                                ),
                                                                _buildPopupMenuItem(
                                                                  value:
                                                                      'close',
                                                                  icon: Icons
                                                                      .close_outlined,
                                                                  iconColor: Colors
                                                                      .red
                                                                      .shade600,
                                                                  label:
                                                                      'غلق البلاغ',
                                                                ),
                                                                _buildPopupMenuItem(
                                                                  value:
                                                                      'urgent',
                                                                  icon: Icons
                                                                      .bolt_outlined,
                                                                  iconColor: Colors
                                                                      .deepOrange,
                                                                  label:
                                                                      'استعجال',
                                                                ),
                                                                _buildPopupMenuItem(
                                                                  value:
                                                                      'forward',
                                                                  icon: Icons
                                                                      .forward_outlined,
                                                                  iconColor: Colors
                                                                      .cyan
                                                                      .shade700,
                                                                  label:
                                                                      'إعادة توجيه',
                                                                ),
                                                                _buildPopupMenuItem(
                                                                  value:
                                                                      'link_informant',
                                                                  icon: Icons
                                                                      .link,
                                                                  iconColor:
                                                                      Colors
                                                                          .purple,
                                                                  label:
                                                                      'ربط كمكرر',
                                                                ),
                                                                _buildPopupMenuItem(
                                                                  value:
                                                                      'approval',
                                                                  icon: Icons
                                                                      .check_circle_outline,
                                                                  iconColor: Colors
                                                                      .green
                                                                      .shade700,
                                                                  label:
                                                                      'تم الحصول على الموافقة',
                                                                ),
                                                                const PopupMenuItem<
                                                                    String>(
                                                                  enabled:
                                                                      false,
                                                                  height: 1,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  child: Divider(
                                                                      height:
                                                                          1),
                                                                ),
                                                                _buildPopupMenuItem(
                                                                  value:
                                                                      'delete',
                                                                  icon: Icons
                                                                      .delete_outline,
                                                                  iconColor:
                                                                      Colors
                                                                          .red,
                                                                  label: 'حذف',
                                                                  labelColor:
                                                                      Colors
                                                                          .red,
                                                                ),
                                                              ],
                                                              child: const Icon(
                                                                Icons.info,
                                                                color: Colors
                                                                    .blueAccent,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                          return const Center(
                                            child:
                                                Text('لا يوجد بلاغات مفتوحة'),
                                          );
                                        }),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
      drawer: CustomDrawer(
        title: 'الاعطال الواردة من الخط الساخن',
        getLocs: getAllHotLineAddresses,
        onTap: (itemData) {
          try {
            StaticVariables.hotlineAddress = itemData['address'];
            StaticVariables.hotlineId = itemData['id'];
            StaticVariables.hotlineX = itemData['x'];
            StaticVariables.hotlineY = itemData['y'];
            StaticVariables.hotlinecaseReportDateTime =
                itemData['caseReportDateTime'];
            StaticVariables.hotlinefinalClosed = itemData['finalClosed'];
            StaticVariables.hotlinereporterName = itemData['reporterName'];
            StaticVariables.hotlinemainStreet = itemData['mainStreet'];
            StaticVariables.hotlineStreet = itemData['street'];
            StaticVariables.hotlinecaseType = itemData['caseType'];

            DioNetworkRepos().postHotLineDataList(
              id: StaticVariables.hotlineId,
              caseReportDateTime: StaticVariables.hotlinecaseReportDateTime,
              caseType: StaticVariables.hotlinecaseType,
              finalClosed: StaticVariables.hotlinefinalClosed,
              mainStreet: StaticVariables.hotlinemainStreet,
              reporterName: StaticVariables.hotlinereporterName,
              street: StaticVariables.hotlineStreet,
              x: StaticVariables.hotlineX,
              y: StaticVariables.hotlineY,
              address: StaticVariables.hotlineAddress,
            );
            _getCoordinatesFromAddress(StaticVariables.hotlineAddress);

            getLocsAfterGetCoordinatesAndGis =
                DioNetworkRepos().getAllComplaintsNotFinished();
            // DioNetworkRepos().getAllComplaintsNotFinished();
            getLocsByHandasahNameAndTechinicianName = DioNetworkRepos()
                .getLocByHandasahAndTechnician("لم يدرج", "لم يدرج");
          } catch (e) {
            log(e.toString());
          }
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // ==========================================================================
  // Action handlers
  // ==========================================================================

  void _handleAction(String selected, Map<String, dynamic> item) {
    switch (selected) {
      case 'details':
        _showDetailsDialog(item);
        break;
      case 'location':
        _handleShowLocation(item);
        break;
      case 'whatsapp':
        _handleSendToWhatsapp(item);
        break;
      case 'close':
        _handleCloseComplaint(item);
        break;
      case 'urgent':
        _handleMarkUrgent(item);
        break;
      case 'forward':
        _handleForwardComplaint(item);
        break;
      case 'link_informant':
        _handleLinkAsInformant(item);
        break;
      case 'approval':
        _handleApprovalObtained(item);
        break;
      case 'delete':
        _handleDeleteComplaint(item);
        break;
    }
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required Color iconColor,
    required String label,
    Color? labelColor,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 42,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w500,
                  color: labelColor ?? Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Action handlers ---------------------------------------------------
  void _handleShowLocation(Map<String, dynamic> item) {
    final lat = item['latitude']?.toString();
    final lng = item['longitude']?.toString();
    final gisUrl = item['gisLink']?.toString();
    if (lat == null || lng == null || lat.isEmpty || lng.isEmpty) {
      _showActionSnackbar('لا يوجد إحداثيات مسجلة لهذا البلاغ', isError: true);
      return;
    }
    debugPrint('gisUrl:--> $gisUrl');

    if (gisUrl != null &&
        gisUrl.isNotEmpty &&
        lng.isNotEmpty &&
        lat.isNotEmpty) {
      CustomBrowserRedirect.openInBrowser(gisUrl);
    } else {
      CustomBrowserRedirect.openInBrowser(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    }
  }

  Future<void> _handleSendToWhatsapp(Map<String, dynamic> item) async {
    try {
      final whatsAppInstalled = await MainWhatsAppService.isWhatsAppInstalled();
      if (!whatsAppInstalled) {
        await MainWhatsAppDialog.showCopyDialog(
          context: context,
          complaint: item,
        );
        return;
      }

      String phoneNumber = '00201032743609';

      final userPhone = await MainWhatsAppDialog.showPhoneNumberDialog(
        context: context,
        initialPhoneNumber:
            phoneNumber.isNotEmpty ? phoneNumber : '00201032743609',
        complaint: item,
      );

      if (userPhone == null || userPhone.isEmpty) {
        _showActionSnackbar('تم إلغاء الإرسال');
        return;
      }

      phoneNumber = userPhone;

      await MainWhatsAppService.sendToWhatsAppNumber(
        complaint: item,
        phoneNumber: phoneNumber,
      );

      _showActionSnackbar('تم فتح واتساب بنجاح');
    } catch (e) {
      debugPrint('WhatsApp error: $e');

      try {
        await MainWhatsAppService.copyComplaintToClipboard(item);
        _showActionSnackbar(
          'حدث خطأ، تم نسخ البيانات إلى الحافظة',
          isError: true,
        );
      } catch (copyError) {
        _showActionSnackbar(
          'حدث خطأ: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  void _handleCloseComplaint(Map<String, dynamic> item) {
    handleCloseComplaint(
      context,
      item,
      fetchData,
    );
  }

  void _handleMarkUrgent(Map<String, dynamic> item) {
    handleMarkUrgent(
      context,
      item,
      fetchData,
    );
  }

  void _handleForwardComplaint(Map<String, dynamic> item) {
    handleForwardComplaint(
      context,
      item,
      fetchData,
    );
  }

  void _handleLinkAsInformant(Map<String, dynamic> item) {
    handleLinkAsInformant(
      context,
      item,
      fetchData,
    );
  }

  void _handleApprovalObtained(Map<String, dynamic> item) {
    handleApprovalObtained(
      context,
      item,
      fetchData,
    );
  }

  void _handleDeleteComplaint(Map<String, dynamic> item) {
    handleDeleteComplaint(
      context,
      item,
      fetchData,
    );
  }

  void _showActionSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: isError ? Colors.red : Colors.indigo,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDetailsDialog(Map<String, dynamic> item) {
    final entries = <MapEntry<String, String>>[
      MapEntry('رقم البلاغ', item['complaintId']?.toString() ?? ''),
      MapEntry('رقم البلاغ المرجعي', item['reportNumber']?.toString() ?? ''),
      MapEntry('الحي', item['neighborhood']?.toString() ?? ''),
      MapEntry('ربط مكرر', item['repeatComplaintNumber']?.toString() ?? ''),
      MapEntry('مصدر البلاغ', item['complaintSource']?.toString() ?? ''),
      MapEntry('إسم المبلغ', item['reporterName']?.toString() ?? ''),
      MapEntry('موبيل المبلغ', item['reporterPhone']?.toString() ?? ''),
      MapEntry('العنوان', item['complaintAddress']?.toString() ?? ''),
      MapEntry('حالة الإصلاح', item['complaintRepairStatus']?.toString() ?? ''),
      MapEntry('جهة الاعتماد', item['approvalAuthority']?.toString() ?? ''),
      MapEntry('نوع الكسر', item['pumpDiameter']?.toString() ?? ''),
      MapEntry('نوع البلاغ', item['complaintType']?.toString() ?? ''),
      MapEntry('مدى الخطورة', item['seriousStatus']?.toString() ?? ''),
      MapEntry('الحالة', item['complaintStatus']?.toString() ?? ''),
      MapEntry('ملاحظات البلاغ', item['complaintNote']?.toString() ?? ''),
      MapEntry('جهة الاستلام', item['recipientDestination']?.toString() ?? ''),
      MapEntry('المستلم', item['recipientUser']?.toString() ?? ''),
      MapEntry('إسم المستلم', item['recipientName']?.toString() ?? ''),
      MapEntry(
          'إسم المستخدم الحالي', item['currentUsername']?.toString() ?? ''),
      MapEntry('رابط الخريطة (GIS)', item['gisLink']?.toString() ?? ''),
      MapEntry('خط الطول', item['longitude']?.toString() ?? ''),
      MapEntry('خط العرض', item['latitude']?.toString() ?? ''),
      MapEntry('القطاع', item['sectorName']?.toString() ?? ''),
      MapEntry('رقم الاستعجال', item['urgencyNumber']?.toString() ?? ''),
      MapEntry('تاريخ الإنشاء', _formatDateOnly(item['createdAt'])),
      MapEntry('آخر تحديث', _formatDateOnly(item['updatedAt'])),
      MapEntry('تاريخ الانتهاء', _formatDateOnly(item['finishedAt'])),
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          title: Row(
            children: [
              const Icon(Icons.assignment_outlined, color: Colors.indigo),
              const SizedBox(width: 8),
              const Text(
                'تفاصيل البلاغ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                  fontSize: 18,
                  fontFamily: 'Cairo',
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      _statusColor(item['complaintStatus']).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _statusColor(item['complaintStatus']),
                  ),
                ),
                child: Text(
                  item['complaintStatus']?.toString() ?? '',
                  style: TextStyle(
                    color: _statusColor(item['complaintStatus']),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: entries
                    .where((e) => e.value.isNotEmpty)
                    .map(
                      (e) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 130,
                              child: Text(
                                e.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                  fontSize: 13,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                            Expanded(
                              child: SelectableText(
                                e.value,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(),
              icon: const Icon(Icons.close, size: 18),
              label: const Text(
                'إغلاق',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              style: TextButton.styleFrom(foregroundColor: Colors.indigo),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateOnly(dynamic raw) {
    if (raw == null) return '';
    final parsed = DateTime.tryParse(raw.toString());
    if (parsed == null) return raw.toString();
    return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'مفتوح':
      case 'عالى الأهمية':
        return Colors.red;
      case 'متوسط الأهمية':
        return Colors.orange;
      case 'مغلق':
      case 'عادى':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
