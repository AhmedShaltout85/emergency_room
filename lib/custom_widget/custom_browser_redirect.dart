// 1. Add Dependency
// Add the url_launcher package to your pubspec.yaml file:

// yaml
// Copy code
// dependencies:
//   url_launcher: ^6.1.8

// 2. Create a Custom Redirect Class
// Create a new Dart file (e.g., custom_browser_redirect.dart) and define the CustomBrowserRedirect class:

import 'package:url_launcher/url_launcher.dart';

class CustomBrowserRedirect {
  /// Opens the given URL in the default browser
  static Future<void> openInBrowser(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  }
}

// 3. Use the Custom Class
// Here’s how you can use the CustomBrowserRedirect class in your app:

// Example:

// import 'package:flutter/material.dart';
// import 'custom_browser_redirect.dart';

// class MainScreen extends StatelessWidget {
//   const MainScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Main Screen'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async {
//             const url = 'https://flutter.dev';
//             try {
//               await CustomBrowserRedirect.openInBrowser(url);
//             } catch (e) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text('Failed to open URL: $e')),
//               );
//             }
//           },
//           child: const Text('Open in Browser'),
//         ),
//       ),
//     );
//   }
// }


// 4. That’s it! You can now use the CustomBrowserRedirect class to open URLs in the default browser.
// using pub.dev site https://pub.dev/packages/url_launcher
// full example

// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// final Uri _url = Uri.parse('https://flutter.dev');

// void main() => runApp(
//       const MaterialApp(
//         home: Material(
//           child: Center(
//             child: ElevatedButton(
//               onPressed: _launchUrl,
//               child: Text('Show Flutter homepage'),
//             ),
//           ),
//         ),
//       ),
//     );

// Future<void> _launchUrl() async {
//   if (!await launchUrl(_url)) {
//     throw Exception('Could not launch $_url');
//   }
// }
