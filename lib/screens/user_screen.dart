//TODO:update code 4-5-2025

// ignore_for_file: no_leading_underscores_for_local_identifiers, use_build_context_synchronously, unused_field

import 'dart:async';
import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:go_router/go_router.dart';
import 'package:location/location.dart';
import 'package:audioplayers/audioplayers.dart';
// import 'package:emergency_room/common_services/webrtc_config/video_call_screen.dart';

import 'package:emergency_room/custom_widget/custom_browser_redirect.dart';
// import 'package:emergency_room/custom_widget/custom_landing_body.dart';
// import 'package:emergency_room/screens/agora_video_call.dart';
import 'package:emergency_room/screens/integration_with_stores_get_all_qty.dart';
// import 'package:emergency_room/screens/receiver_mobile_screen.dart';
import 'package:emergency_room/screens/user_request_tools.dart';
import 'package:emergency_room/utils/dio_http_constants.dart';
// import '../common_services/video_call_service.dart';
import '../custom_widget/custom_alert_dialog_with_sound.dart';
// import '../custom_widget/custom_web_view.dart';
import '../network/remote/dio_network_repos.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  Future<List<Map<String, dynamic>>> getUsersBrokenPointsList =
      Future.value([]);
  List<Map<String, dynamic>> _previousData = [];
  Timer? _timer, _timer2;
  int? isApproved;
  LocationData? currentLocation;
  String address = "";
  String storeName = "";
  int videoCall = 0;
  StreamSubscription<LocationData>? locationSubscription;
  bool _isDisposed = false;
  bool _isPlayingAlarm = false;
  bool _isPlayingRingtone = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
    _initializeData();
  }

  void _initializeData() async {
    await _getCurrentLocation();
    _fetchData();
    _startPeriodicFetch();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _timer2?.cancel();
    locationSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (_isDisposed) return;

    try {
      final data = await DioNetworkRepos().fetchHandasatUsersItemsBroken(
          DataStatic.handasahName, DataStatic.username, 0);

      if (_isDisposed) return;

      // Check for new items
      if (_hasNewItems(data)) {
        _playAlarmSound();
      }

      setState(() {
        getUsersBrokenPointsList = Future.value(data);
        _previousData = List.from(data);
      });

      if (data.isEmpty) {
        log("Data is empty, will retry in next cycle");
        return;
      }

      _handleVideoCallStatus(data);
    } catch (error) {
      log("Error fetching data: $error");
    }
  }

  bool _hasNewItems(List<Map<String, dynamic>> newData) {
    if (_previousData.isEmpty) return newData.isNotEmpty;
    return newData.length > _previousData.length;
  }

  Future<void> _playAlarmSound() async {
    if (_isPlayingAlarm) return;

    _isPlayingAlarm = true;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
    } catch (e) {
      log("Error playing alarm sound: $e");
    } finally {
      Future.delayed(const Duration(seconds: 5), () {
        _isPlayingAlarm = false;
      });
    }
  }

  Future<void> _playRingtoneSound() async {
    if (_isPlayingRingtone) return;

    _isPlayingRingtone = true;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/incoming_call.mp3'));
    } catch (e) {
      log("Error playing ringtone sound: $e");
    }
  }

  void _stopAllSounds() async {
    try {
      await _audioPlayer.stop();
      _isPlayingAlarm = false;
      _isPlayingRingtone = false;
    } catch (e) {
      log("Error stopping sounds: $e");
    }
  }

  void _handleVideoCallStatus(List<Map<String, dynamic>> data) {
    final firstItem = data.first;
    if (firstItem['video_call'] == 1) {
      if (!_isPlayingRingtone) {
        _playRingtoneSound();
        _showDialog(context, firstItem['address']);
      }
      _timer2?.cancel();
    } else if (firstItem['video_call'] == 0) {
      _stopAllSounds();
      _startUIUpdateTimer();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      var location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      final userLocation = await location.getLocation();
      if (_isDisposed) return;

      setState(() {
        currentLocation = userLocation;
      });

      locationSubscription = location.onLocationChanged.listen((newLocation) {
        if (_isDisposed) return;
        setState(() {
          currentLocation = newLocation;
        });
      });
    } catch (e) {
      log("Error getting location: $e");
    }
  }

  void _startPeriodicFetch() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      _fetchData();
    });
  }

  void _startUIUpdateTimer() {
    _timer2?.cancel();
    _timer2 = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      _fetchData();
    });
  }

  void _showDialog(BuildContext context, String address) {
    if (_isDisposed) return;

    showDialog(
      context: context,
      builder: (context) => CustomAlertDialogWithSound(
        title: 'مكالمة فيديو واردة من الطورائ',
        message: address,
        soundPath: 'sounds/incoming_call.mp3',
        icon: Icons.videocam,
        address: address,
        onDismiss: () {
          _stopAllSounds();
        },
      ),
    );
  }

  Future<void> _handleApproval(Map<String, dynamic> item) async {
    try {
      await DioNetworkRepos().updateLocAddIsApproved(item['address'], 1);

      if (_isDisposed) return;

      setState(() {
        isApproved = 1;
      });

      _fetchData();

      final addressInList =
          await DioNetworkRepos().checkAddressExistsInTracking(item['address']);
      //check if address exists in hotline table or not to update start time
      // TODO: add check if address exists in hotline table or not to update start time
      // final addressInList =
      //     await DioNetworkRepos().checkAddressExistsInTracking(item['address']);

      log("Address exists in tracking: $addressInList");

      if (addressInList == true) {
        await DioNetworkRepos().updateTrackingLocations(
          item['address'],
          double.parse(item['longitude']),
          double.parse(item['latitude']),
          currentLocation?.latitude ?? 0,
          currentLocation?.longitude ?? 0,
          currentLocation?.latitude,
          currentLocation?.longitude,
          item['technical_name'],
        );
      } else {
        await DioNetworkRepos().sendLocationToBackend(
          item['address'],
          item['technical_name'],
          double.parse(item['latitude']),
          double.parse(item['longitude']),
          currentLocation?.latitude,
          currentLocation?.longitude,
        );
      }

      _startLocationUpdates(item['address']);
    } catch (e) {
      log("Error in approval process: $e");
    }
  }

  void _startLocationUpdates(String address) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      if (currentLocation != null) {
        DioNetworkRepos().updateLocationToBackend(
            address, currentLocation!.latitude!, currentLocation!.longitude!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الاعطال المخصصة للمستخدم : ${DataStatic.username}',
            style: const TextStyle(color: Colors.indigo, fontSize: 15)),
        centerTitle: true,
        elevation: 7.0,
        // backgroundColor: Colors.white,
        // leading: IconButton(
        //   onPressed: () => Navigator.of(context).pop(true),
        //   icon: const Icon(Icons.arrow_back, color: Colors.white),
        // ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getUsersBrokenPointsList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text("عفوا لايوجد شكاوى جديدة"));
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              address = item['address'];
              isApproved = item['is_approved'];
              videoCall = item['video_call'];

              return Card(
                margin: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        item['address'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (item['handasah_name'] != null)
                      ListTile(
                        title: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(item['handasah_name'],
                                  style: const TextStyle(color: Colors.green)),
                              // Text(item['technical_name'],
                              //     style: const TextStyle(color: Colors.green)),
                              isApproved == 0
                                  ? TextButton(
                                      style: const ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                            Colors.orange),
                                      ),
                                      onPressed: () => _handleApproval(item),
                                      child: const Text(
                                        'قيد قبول الشكوى',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 7,
                                        ),
                                      ),
                                    )
                                  : TextButton(
                                      style: const ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                            Colors.green),
                                      ),
                                      onPressed: () {},
                                      child: const Text(
                                        'تم قبول الشكوى',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ListTile(
                      title: Text(
                        'الاحداثئات :  ${item['latitude']} , ${item['longitude']}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'إسم المبلغ :  ${item['caller_name']}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        ' رقم هاتف المبلغ:  ${item['caller_phone']}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'نوع الكسر :  ${item['broker_type']}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.indigo,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIconButton(
                          Icons.open_in_browser,
                          Colors.blue,
                          'اظهار الموقع على الخريطة GIS Map',
                          () => _openGisMap(item['gis_url'], item['address']),
                        ),
                        _buildIconButton(
                          Icons.phone,
                          Colors.green,
                          'إجراء مكالمة صوتية',
                          () => _handleSoundCall(item['address']),
                          // 'EmergencyRoom'),
                        ),
                        _buildIconButton(
                          Icons.video_call,
                          Colors.green,
                          'إجراء مكالمة فيديو',
                          () => _handleVideoCall(
                              item['video_call'], item['address']),
                        ),
                        _buildIconButton(
                          Icons.local_convenience_store_outlined,
                          Colors.cyan,
                          'طلب مهمات مخازن',
                          () => _navigateToRequestTools(item),
                        ),
                        _buildIconButton(
                          Icons.store_outlined,
                          Colors.indigo,
                          'جرد مخزن',
                          () => _handleInventory(item),
                        ),
                        _buildIconButton(
                          Icons.close_rounded,
                          Colors.red,
                          'إغلاق الشكوى',
                          () => _closeComplaint(item['address'], index),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildIconButton(
      IconData icon, Color color, String tooltip, VoidCallback onPressed) {
    return IconButton(
      tooltip: tooltip,
      hoverColor: Colors.yellow,
      onPressed: onPressed,
      icon: Icon(icon, color: color),
    );
  }

  void _openGisMap(String url, String title) {
    log("Start Gis Map $url");
    // if (kIsWeb) {
    CustomBrowserRedirect.openInBrowser(url);
    // } else if(Platform.isAndroid) {
    //    CustomBrowserRedirect.openInBrowser(url);
    // }else if (Platform.isWindows){
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => CustomWebView(title: title, url: url),
    //     ),
    //   );
    // }
  }

  void _handleSoundCall(String roomName) {
    _stopAllSounds();
    // VideoCallService.startVideoCall(
    //   context: context,
    //   userEmail: 'awcoah@example.com',
    //   isInitiator: true,
    //   userName: 'ahmed',
    //   customRoomName: roomName,
    // );
    CustomBrowserRedirect.openInBrowser("https://meet.jit.si/$roomName");
  }

  void _handleVideoCall(int videoCallStatus, String address) {
    log("Start Video Call");
    if (videoCallStatus == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لايمكن إجراء مكالمة فيديو قبل قبول تفعيل الاتصال من الطوارئ',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      _stopAllSounds();
      //Agora video call
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => AgoraVideoCall(title: address),
      //   ),
      // );
      //Video call using online server
      context.push('/mobile-receiver/$address');
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => ReceiverMobileScreen(addressTitle: address),
      //   ),
      // );
      ///////////11-06-2025
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => VideoCallScreen(
      //       roomId: address,
      //     ),
      //   ),
      // );
    }
  }

  void _navigateToRequestTools(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserRequestTools(
          handasahName: item['handasah_name'] ?? DataStatic.handasahName,
          address: item['address'],
          technicianName: item['technical_name'],
        ),
      ),
    );
    // context.push(
    //     '/user-request-tool/${item['handasah_name'] ?? DataStatic.handasahName}/${item['address']}/${item['technical_name']}');
  }

  Future<void> _handleInventory(Map<String, dynamic> item) async {
    try {
      log("Store Name before get: $storeName");
      log("Handasah Name before get: ${item['handasah_name']}");

      final value = await DioNetworkRepos()
          .getStoreNameByHandasahName(item['handasah_name']);

      storeName = value['storeName'];

      log("Store Name after get: $storeName");

      DioNetworkRepos().excuteTempStoreQty(storeName);
      // await DioNetworkRepos().excuteTempStoreQty(storeName);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IntegrationWithStoresGetAllQty(
            storeName: storeName,
          ),
        ),
      );

      // context.push('/integrate-with-stores/$storeName');
    } catch (e) {
      log("Error handling inventory: $e");
    }
  }

  void _closeComplaint(String address, int index) {
    // TODO: set actual locations x and y and final close
    setState(() {
      DioNetworkRepos().updateLocAddIsFinished(address, 1);
      getUsersBrokenPointsList = getUsersBrokenPointsList.then((list) {
        final newList = List<Map<String, dynamic>>.from(list);
        if (index < newList.length) {
          newList.removeAt(index);
        }
        return newList;
      });
    });
  }
}
