// // ignore_for_file: use_build_context_synchronously

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'dart:async';
// // ignore: avoid_web_libraries_in_flutter
// // import 'dart:html';

// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:pick_location/screens/address_to_coordinates_web.dart';
// import 'package:pick_location/screens/user_screen.dart';

// import '../network/remote/dio_network_repos.dart';
// import '../utils/dio_http_constants.dart';

// class AgoraVideoCall extends StatefulWidget {
//   final String title;
//   const AgoraVideoCall({super.key, required this.title});

//   @override
//   State<AgoraVideoCall> createState() => _AgoraVideoCallState();
// }

// class _AgoraVideoCallState extends State<AgoraVideoCall> {
//   int? _remoteUid;
//   bool _localUserJoined = false;
//   late RtcEngine _engine;

//   @override
//   void initState() {
//     super.initState();
//     initAgora();
//   }

//   Future<void> initAgora() async {
//     // retrieve permissions
//     try {
//       // not tested

//       await [Permission.microphone, Permission.camera].request();
//       //create the engine
//       _engine = createAgoraRtcEngine();
//       await _engine.initialize(const RtcEngineContext(
//         appId: appId,
//         channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
//       ));

//       _engine.registerEventHandler(
//         RtcEngineEventHandler(
//           onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//             log("local user ${connection.localUid} joined");
//             setState(() {
//               _localUserJoined = true;
//             });
//           },
//           onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//             log("remote user $remoteUid joined");
//             setState(() {
//               _remoteUid = remoteUid;
//             });
//           },
//           onUserOffline: (RtcConnection connection, int remoteUid,
//               UserOfflineReasonType reason) {
//             log("remote user $remoteUid left channel");
//             setState(() {
//               _remoteUid = null;
//             });
//           },
//           onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
//             log(
//                 '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
//           },
//         ),
//       );

//       await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
//       await _engine.enableVideo();
//       await _engine.startPreview();

//       await _engine.joinChannel(
//         token: token,
//         channelId: channel,
//         uid: 0,
//         options: const ChannelMediaOptions(),
//       );
//     } catch (e) {
//       // not tested
//       log(e.toString());
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'فضلا قم بتوصيل ,وتفعيل صلاحيات الكاميرا والميكروفون',
//             textDirection: TextDirection.rtl,
//             textAlign: TextAlign.center,
//           ),
//         ),
//       );
//     }
//     // }
//     // await window.navigator.getUserMedia(audio: true, video: true);
//   }

//   @override
//   void dispose() {
//     super.dispose();

//     _dispose();
//   }

//   Future<void> _dispose() async {
//     await _engine.leaveChannel();
//     await _engine.release();
//   }

//   // Create UI with local view and remote view
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.indigo,
//         title: Text(
//           widget.title,
//           style: const TextStyle(color: Colors.white, fontSize: 12),
//         ),
//         centerTitle: true,
//         foregroundColor: Colors.white,
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pop(true); //back to previous screen
//             if (kIsWeb) {
//               //update video call
//               DioNetworkRepos().updateLocationBrokenByAddressUpdateVideoCall(
//                   widget.title, 0);
//             }

//             // _dispose();
//           },
//           icon: const Icon(Icons.arrow_back),
//         ),
//       ),
//       body: Stack(
//         children: [
//           Center(
//             child: _remoteVideo(),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Align(
//               alignment: Alignment.topLeft,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: SizedBox(
//                   width: 100,
//                   height: 150,
//                   child: Center(
//                     child: _localUserJoined
//                         ? AgoraVideoView(
//                             controller: VideoViewController(
//                               rtcEngine: _engine,
//                               canvas: const VideoCanvas(uid: 0),
//                             ),
//                           )
//                         : const CircularProgressIndicator(),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 25.0, right: 25),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   IconButton(
//                     onPressed: () {
//                       setState(() {
//                         //update video call
//                         DioNetworkRepos()
//                             .updateLocationBrokenByAddressUpdateVideoCall(
//                                 widget.title, 0);
//                       });
//                       //
//                       kIsWeb
//                           ? Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     const AddressToCoordinates(),
//                               ),
//                             )
//                           : Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => const UserScreen(),
//                               ),
//                             );
//                     },
//                     icon: const CircleAvatar(
//                       radius: 25,
//                       backgroundColor: Colors.red,
//                       child: Icon(
//                         Icons.call_end,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Display remote user's video
//   Widget _remoteVideo() {
//     if (_remoteUid != null) {
//       return AgoraVideoView(
//         controller: VideoViewController.remote(
//           rtcEngine: _engine,
//           canvas: VideoCanvas(uid: _remoteUid),
//           connection: const RtcConnection(channelId: channel),
//         ),
//       );
//     } else {
//       return const Text(
//         'Please wait for remote user to join',
//         textAlign: TextAlign.center,
//       );
//     }
//   }
// }

// // // ignore_for_file: library_private_types_in_public_api

// // import 'dart:async';

// // import 'package:flutter/material.dart';
// // import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// // import 'package:permission_handler/permission_handler.dart';

// // import '../utils/dio_http_constants.dart';
// // // ignore: avoid_web_libraries_in_flutter
// // // import 'dart:html';

// // class VideoCallScreen extends StatefulWidget {
// //   const VideoCallScreen({super.key});

// //   @override
// //   _VideoCallScreenState createState() => _VideoCallScreenState();
// // }

// // class _VideoCallScreenState extends State<VideoCallScreen> {
// //   late final RtcEngine _engine;
// //   bool _localUserJoined = false;
// //   int? _remoteUid;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeAgora();
// //   }

// //   Future<void> _initializeAgora() async {
// //     // Request permissions (for mobile platforms)
// //     await [Permission.microphone, Permission.camera].request();

// //     // await window.navigator.getUserMedia(audio: true, video: true);

// //     // Create RtcEngine instance
// //     _engine = createAgoraRtcEngine();
// //     await _engine.initialize(const RtcEngineContext(appId: appId));

// //     // Set up event handlers
// //     _engine.registerEventHandler(
// //       RtcEngineEventHandler(
// //         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
// //           log("local user ${connection.localUid} joined");
// //           setState(() {
// //             _localUserJoined = true;
// //           });
// //         },
// //         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
// //           log("remote user $remoteUid joined");
// //           setState(() {
// //             _remoteUid = remoteUid;
// //           });
// //         },
// //         onUserOffline: (RtcConnection connection, int remoteUid,
// //             UserOfflineReasonType reason) {
// //           log("remote user $remoteUid left channel");
// //           setState(() {
// //             _remoteUid = null;
// //           });
// //         },
// //         onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
// //           log(
// //               '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
// //         },
// //       ),
// //     );

// //     // Join channel
// //     await _engine.enableVideo();
// //     await _engine.startPreview();
// //     await _engine.joinChannel(
// //       token: token,
// //       channelId: channel,
// //       uid: 0, // 0 means the Agora server assigns UID
// //       options: const ChannelMediaOptions(),
// //     );
// //   }

// //   // Widget to render the local video
// //   Widget _renderLocalPreview() {
// //     if (_localUserJoined) {
// //       return AgoraVideoView(
// //         controller: VideoViewController(
// //           rtcEngine: _engine,
// //           canvas: const VideoCanvas(uid: 0),
// //         ),
// //       );
// //     } else {
// //       return const Text(
// //         'Joining channel...',
// //         textAlign: TextAlign.center,
// //       );
// //     }
// //   }

// //   // Widget to render the remote video
// //   Widget _renderRemoteVideo() {
// //     if (_remoteUid != null) {
// //       return AgoraVideoView(
// //         controller: VideoViewController.remote(
// //           rtcEngine: _engine,
// //           canvas: VideoCanvas(uid: _remoteUid),
// //           connection: const RtcConnection(channelId: channel),
// //         ),
// //       );
// //     } else {
// //       return const Text(
// //         'Waiting for remote user to Join...',
// //         textAlign: TextAlign.center,
// //       );
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _engine.leaveChannel();
// //     _engine.release();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Video Call')),
// //       body: Stack(
// //         children: [
// //           Center(child: _renderRemoteVideo()),
// //           Align(
// //             alignment: Alignment.topLeft,
// //             child: SizedBox(
// //               width: 100,
// //               height: 150,
// //               child: _renderLocalPreview(),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }


// // To use a specific uid in the Agora video call code, you need to pass it when joining the channel using the joinChannel() method. In the code provided, the uid is currently set to 0, which allows Agora to assign a unique ID automatically.

// // To use a specific uid, follow these steps:

// // 1. Define the UID
// // Declare the UID as a constant or pass it as a parameter to the widget:


// // // Define a specific UID
// // const int myUid = 12345;
// // 2. Pass the UID to joinChannel()
// // Replace the uid parameter in joinChannel() with your specific UID:


// // await _engine.joinChannel(
// //   token: token,
// //   channelId: channel,
// //   uid: myUid,  // Use your specific UID here
// //   options: const ChannelMediaOptions(),
// // );
// // 3. Update the Local Video View
// // Ensure the local video view uses the same UID:


// // child: _localUserJoined
// //     ? AgoraVideoView(
// //         controller: VideoViewController(
// //           rtcEngine: _engine,
// //           canvas: VideoCanvas(uid: myUid),  // Use the same UID here
// //         ),
// //       )
// //     : const CircularProgressIndicator(),
// // 4. Update the Remote Video View
// // No changes are needed for the remote video view because it listens for the onUserJoined event and uses the remoteUid value automatically.

// // Example Changes
// // Here is a modified snippet of the relevant sections:


// // const int myUid = 12345;

// // await _engine.joinChannel(
// //   token: token,
// //   channelId: channel,
// //   uid: myUid,  // Use specific UID
// //   options: const ChannelMediaOptions(),
// // );

// // child: _localUserJoined
// //     ? AgoraVideoView(
// //         controller: VideoViewController(
// //           rtcEngine: _engine,
// //           canvas: VideoCanvas(uid: myUid),  // Match the specific UID
// //         ),
// //       )
// //     : const CircularProgressIndicator(),
// // Note:
// // Ensure the uid is unique in the channel; otherwise, there will be conflicts.
// // If you are using tokens for authentication, make sure the token is generated with the same uid.
// // This change ensures you are using a predefined uid instead of letting Agora auto-assign one.