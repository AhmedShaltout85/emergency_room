// // ignore_for_file: library_private_types_in_public_api, unused_field

// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

// import '../utils/dio_http_constants.dart'; // Ensure this file contains your Agora App ID and Token

// class AudioCallScreen extends StatefulWidget {
//   const AudioCallScreen({super.key});

//   @override
//   _AudioCallScreenState createState() => _AudioCallScreenState();
// }

// class _AudioCallScreenState extends State<AudioCallScreen> {
//   int? _remoteUid; // UID of the remote user
//   late RtcEngine _engine; // Agora RTC Engine instance
//   bool _localUserJoined = false; // Track if the local user has joined the channel

//   @override
//   void initState() {
//     super.initState();
//     initAgora(); // Initialize Agora when the widget is created
//   }

//   @override
//   void dispose() {
//     _engine.leaveChannel(); // Leave the channel when the widget is disposed
//     _engine.release(); // Release the Agora engine resources
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background container
//           Container(
//             color: Colors.black87,
//             child: Center(
//               child: _remoteUid == null
//                   ? const Text(
//                       'Calling …',
//                       style: TextStyle(color: Colors.white),
//                     )
//                   : Text(
//                       'Calling with $_remoteUid',
//                       style: const TextStyle(color: Colors.white),
//                     ),
//             ),
//           ),
//           // End call button
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 25.0, right: 25),
//               child: Container(
//                 height: 50,
//                 color: Colors.black12,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     IconButton(
//                       onPressed: () {
//                         Navigator.of(context).pop(true); // End the call
//                       },
//                       icon: const Icon(
//                         Icons.call_end,
//                         size: 44,
//                         color: Colors.redAccent,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Initialize Agora RTC Engine
//   Future<void> initAgora() async {
//     // Request microphone permission
//     await [Permission.microphone].request();

//     // Create and initialize the Agora RTC Engine
//     _engine = createAgoraRtcEngine();
//     await _engine.initialize(
//       const RtcEngineContext(
//         appId: appId, // Replace with your Agora App ID
//         channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
//       ),
//     );

//     // Enable audio
//     await _engine.enableAudio();

//     // Register event handlers
//     _engine.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//           log("Local user ${connection.localUid} joined");
//           setState(() {
//             _localUserJoined = true;
//           });
//         },
//         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//           log("Remote user $remoteUid joined");
//           setState(() {
//             _remoteUid = remoteUid;
//           });
//         },
//         onUserOffline: (RtcConnection connection, int remoteUid,
//             UserOfflineReasonType reason) {
//           log("Remote user $remoteUid left the channel");
//           setState(() {
//             _remoteUid = null;
//           });
//         },
//         onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
//           log("Token privilege will expire: $token");
//         },
//       ),
//     );

//     // Set the client role to broadcaster
//     await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

//     // Join the channel
//     await _engine.joinChannel(
//       token: token, // Replace with your Agora Token
//       channelId: channel, // Replace with your channel name
//       uid: 0, // Use 0 to let Agora assign a UID
//       options: const ChannelMediaOptions(),
//     );
//   }
// }


// // // for the audio call it’s so similar :


// // // ignore_for_file: library_private_types_in_public_api

// // import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// // import 'package:flutter/material.dart';
// // import 'package:permission_handler/permission_handler.dart';

// // import '../utils/dio_http_constants.dart';

// // class AudioCallScreen extends StatefulWidget {
// //   const AudioCallScreen({super.key});

// //   @override
// //   _AudioCallScreenState createState() => _AudioCallScreenState();
// // }

// // class _AudioCallScreenState extends State<AudioCallScreen> {
// //   late int _remoteUid;
// //   late RtcEngine _engine;
// //   bool _localUserJoined = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     initAgora();
// //   }

// //   @override
// //   void dispose() {
// //     super.dispose();
// //     _engine.leaveChannel();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Stack(
// //         children: [
// //           Container(
// //             color: Colors.black87,
// //             child: Center(
// //               child: _remoteUid == 0
// //                   ? const Text(
// //                       'Calling …',
// //                       style: TextStyle(color: Colors.white),
// //                     )
// //                   : Text(
// //                       'Calling with $_remoteUid',
// //                     ),
// //             ),
// //           ),
// //           Align(
// //             alignment: Alignment.bottomCenter,
// //             child: Padding(
// //               padding: const EdgeInsets.only(bottom: 25.0, right: 25),
// //               child: Container(
// //                 height: 50,
// //                 color: Colors.black12,
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.end,
// //                   children: [
// //                     IconButton(
// //                         onPressed: () {
// //                           Navigator.of(context).pop(true);
// //                         },
// //                         icon: const Icon(
// //                           Icons.call_end,
// //                           size: 44,
// //                           color: Colors.redAccent,
// //                         )),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Future<void> initAgora() async {
// //     await [Permission.microphone, Permission.camera].request();
// //     //create the engine
// //     _engine = createAgoraRtcEngine();
// //     await _engine.initialize(const RtcEngineContext(
// //       appId: appId,
// //       channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
// //     ));
// //     _engine.enableAudio();
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
// //             _remoteUid = 0;
// //           });
// //         },
// //         onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
// //           log(
// //               '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
// //         },
// //       ),
// //     );

// //     await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
// //     await _engine.enableAudio();
// //     await _engine.startPreview();

// //     await _engine.joinChannel(
// //       token: token,
// //       channelId: channel,
// //       uid: 0,
// //       options: const ChannelMediaOptions(),
// //     );

// //     Widget _renderRemoteAudio() {
// //       if (_remoteUid != 0) {
// //         return Text(
// //           'Calling with $_remoteUid',
// //           style: const TextStyle(color: Colors.white),
// //         );
// //       } else {
// //         return const Text(
// //           'Calling …',
// //           style: TextStyle(color: Colors.white),
// //         );
// //       }


// //     }

// //   }
// // }
