import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoCallService {
  static const String staticRoomName = "EmergencyRoom";

  // Optional: Make room name configurable
  static String getRoomName({String? customRoom}) {
    return customRoom ?? staticRoomName;
  }

  static Future<void> startVideoCall({
    required BuildContext context,
    required String userEmail,
    required String userName,
    String? customRoomName,
    bool isInitiator = false,
    bool startWithAudioMuted = false,
    bool startWithVideoMuted = false,
  }) async {
    final roomName = getRoomName(customRoom: customRoomName);

    try {
      // For web, we'll use URL launching
      if (kIsWeb) {
        final url = "https://meet.jit.si/$roomName#userEmail=$userEmail";
        final uri = Uri.parse(url);

        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication, // Open in new tab/window
          );
        } else {
          throw "Could not launch $url";
        }
        return;
      }

      // For mobile (Android/iOS) - with user details
      var options = JitsiMeetingOptions(
        room: roomName,
        // userDisplayName: userName,
        // userEmail: userEmail,
        // userAvatarURL: "", // You can add avatar URL if available
        // audioMuted: startWithAudioMuted,
        // videoMuted: startWithVideoMuted,
      );

      await JitsiMeet.joinMeeting(options);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error starting call: ${error.toString()}"),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => startVideoCall(
                context: context,
                userEmail: userEmail,
                userName: userName,
                customRoomName: customRoomName,
                isInitiator: isInitiator,
                startWithAudioMuted: startWithAudioMuted,
                startWithVideoMuted: startWithVideoMuted,
              ),
            ),
          ),
        );
      }
    }
  }

  static Future<void> showCallInvitationDialog({
    required BuildContext context,
    required String userEmail,
    required String userName,
    String? customRoomName,
    String? inviterName,
  }) async {
    if (!context.mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.video_call, color: Colors.blue),
            SizedBox(width: 8),
            Text("Video Call Invitation"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              inviterName != null
                  ? "$inviterName has invited you to join a video call."
                  : "You've been invited to join a video call.",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.meeting_room, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Room: ${getRoomName(customRoom: customRoomName)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Decline"),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              startVideoCall(
                context: context,
                userEmail: userEmail,
                userName: userName,
                customRoomName: customRoomName,
              );
            },
            icon: const Icon(Icons.video_call),
            label: const Text("Join Call"),
          ),
        ],
      ),
    );
  }

  static String getRoomLink({String? customRoomName}) {
    final roomName = getRoomName(customRoom: customRoomName);
    return "https://meet.jit.si/$roomName";
  }

  static Future<void> leaveMeeting() async {
    try {
      if (!kIsWeb) {
        log("Leave meeting called - implement based on your package version");
      }
    } catch (e) {
      log("Error leaving meeting: $e");
    }
  }

  static Future<bool> isInMeeting() async {
    try {
      if (!kIsWeb) {
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static String generateUniqueRoomName({String prefix = "Room"}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return "${prefix}_$random";
  }
}
