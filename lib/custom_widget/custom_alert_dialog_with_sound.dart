import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../screens/receiver_mobile_screen.dart';
// import 'package:pick_location/common_services/webrtc_config/video_call_screen.dart';

// import '../screens/agora_video_call.dart';

class CustomAlertDialogWithSound extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final String soundPath;
  final String address;
  final VoidCallback onDismiss;

  const CustomAlertDialogWithSound({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    required this.soundPath,
    required this.address, required this.onDismiss,
  });

  @override
  State<CustomAlertDialogWithSound> createState() =>
      _CustomAlertDialogWithSoundState();
}

class _CustomAlertDialogWithSoundState
    extends State<CustomAlertDialogWithSound> {
  AudioPlayer audioPlayer = AudioPlayer();
  void _playSound() async {
    await audioPlayer.play(AssetSource(widget.soundPath));
  }

  @override
  Widget build(BuildContext context) {
    // Play sound when the dialog is shown
    WidgetsBinding.instance.addPostFrameCallback((_) => _playSound());

    return AlertDialog(
      title: Text(
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        widget.title,
        style: const TextStyle(
          color: Colors.indigo,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),

      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            widget.icon,
            color: Colors.red,
            size: 50,
          ),
          const SizedBox(width: 10),
          Text(
            widget.message,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              color: Colors.indigo,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ), // Add your custom sound asset path here (e.g., 'assets/sounds/alert_sound.mp3',),
      actions: [
        Align(
          alignment: Alignment.bottomCenter,
          child: IconButton(
            onPressed: () {
              //
              Navigator.of(context).pop();
              //
              audioPlayer.stop();
              //
              Navigator.push(
                context,
                MaterialPageRoute(
                  // builder: (context) => VideoCallScreen(roomId: widget.address,),
                  builder: (context) => ReceiverMobileScreen(addressTitle: widget.address,),
                  // AgoraVideoCall(
                  //   title: widget.address,
                  // ),
                ),
              );
            },
            icon: const CircleAvatar(
              radius: 25,
              backgroundColor: Colors.green,
              child: Icon(
                Icons.call,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}


//  showDialog(
//                 context: context,
//                 builder: (context) => CustomAlertDialogWithSound(
//                   title: 'Alert!',
//                   message: 'This is a custom alert dialog with sound.',
//                   icon: Icons.video_call,
//                   soundPath: 'sounds/alert_sound.mp3', // Add your sound file path
//                 ),
//               );




// import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';

// class CustomAlertDialogWithSound extends StatefulWidget {
//   final String title;
//   final String message;
//   final String soundAsset;
//   final VoidCallback? onOk;

//   const CustomAlertDialogWithSound({
//     super.key,
//     required this.title,
//     required this.message,
//     required this.soundAsset,
//     this.onOk,
//   });

//   @override
//   State<CustomAlertDialogWithSound> createState() => _CustomAlertDialogWithSoundState();
// }

// class _CustomAlertDialogWithSoundState extends State<CustomAlertDialogWithSound> {
//   final AudioPlayer _audioPlayer = AudioPlayer();

//   @override
//   void initState() {
//     super.initState();
//     _playSound();
//   }

//   Future<void> _playSound() async {
//     await _audioPlayer.play(AssetSource(widget.soundAsset));
//   }

//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       contentPadding: const EdgeInsets.all(20),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Icon(Icons.video_call, size: 80, color: Colors.blue),
//           const SizedBox(height: 20),
//           Text(
//             widget.title,
//             style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             widget.message,
//             textAlign: TextAlign.center,
//             style: const TextStyle(fontSize: 16),
//           ),
//         ],
//       ),
//       actionsAlignment: MainAxisAlignment.center,
//       actions: [
//         TextButton(
//           onPressed: () {
//             _audioPlayer.stop();
//             Navigator.of(context).pop();
//             if (widget.onOk != null) widget.onOk!();
//           },
//           child: const Text("OK"),
//         )
//       ],
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'custom_alert_dialog_with_sound.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Custom Dialog Demo',
//       home: const HomePage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   void _showDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => const CustomAlertDialogWithSound(
//         title: 'Incoming Video Call',
//         message: 'John Doe is calling you...',
//         soundAsset: 'sounds/ringtone.mp3',
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Video Call Alert Dialog')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () => _showDialog(context),
//           child: const Text('Show Alert'),
//         ),
//       ),
//     );
//   }
// }

