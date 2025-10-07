// 🔧 Option 1: MJPEG Stream (most common for IP cams)
// 1. 📦 Add required dependencies (if needed)
// For MJPEG streams, you can use a simple HTML <img> tag in Flutter Web.

// No need for extra packages in this approach.

// 2. ✨ Create a reusable IP camera viewer widget using HtmlElementView:
import 'dart:ui' as ui;
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class IPCameraViewer extends StatelessWidget {
  final String cameraUrl;
  final double width;
  final double height;

  const IPCameraViewer({
    super.key,
    required this.cameraUrl,
    this.width = 640,
    this.height = 480,
  });

  @override
  Widget build(BuildContext context) {
    final String viewType = 'ip-camera-${cameraUrl.hashCode}';

    if (kIsWeb) {
      // Register the view type only once per url
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(
        viewType,
        (int viewId) {
          final imgElement = html.ImageElement()
            ..src = cameraUrl
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.objectFit = 'cover';
          return imgElement;
        },
      );

      return SizedBox(
        width: width,
        height: height,
        child: HtmlElementView(viewType: viewType),
      );
    } else {
      return const Center(
          child: Text('IP Camera not supported on this platform'));
    }
  }
}


// // Usage:
// import 'package:flutter/material.dart';
// import 'package:your_project/widgets/ip_camera_viewer.dart'; // Adjust import

// class CameraScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('IP Camera Stream')),
//       body: Center(
//         child: IPCameraViewer(
//           cameraUrl: 'http://192.168.1.100:8080/video', // replace with your actual stream URL
//         ),
//       ),
//     );
//   }
// }


// Creating a custom reusable class for opening an IP camera in a Flutter web app involves using the webview_flutter package to display the camera stream. Below is a step-by-step guide to create a reusable widget for this purpose.

// Steps:
// Add Dependencies:
// Add the webview_flutter package to your pubspec.yaml file:

// yaml
// Copy
// dependencies:
//   flutter:
//     sdk: flutter
//   webview_flutter: ^4.4.0
// Create the Reusable Widget:
// Create a custom widget that accepts the IP camera URL and displays the stream in a WebView.

// Code Implementation:
// Custom IP Camera Widget
// dart
// Copy
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class IpCameraViewer extends StatefulWidget {
//   final String cameraUrl; // URL of the IP camera stream
//   final double aspectRatio; // Aspect ratio of the camera view

//   const IpCameraViewer({
//     Key? key,
//     required this.cameraUrl,
//     this.aspectRatio = 16 / 9, // Default aspect ratio (16:9)
//   }) : super(key: key);

//   @override
//   _IpCameraViewerState createState() => _IpCameraViewerState();
// }

// class _IpCameraViewerState extends State<IpCameraViewer> {
//   late WebViewController _webViewController;

//   @override
//   void initState() {
//     super.initState();
//     _webViewController = WebViewController();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AspectRatio(
//       aspectRatio: widget.aspectRatio,
//       child: WebView(
//         initialUrl: widget.cameraUrl,
//         javascriptMode: JavascriptMode.unrestricted,
//         onWebViewCreated: (WebViewController webViewController) {
//           _webViewController = webViewController;
//         },
//         onPageStarted: (String url) {
//           log('Page started loading: $url');
//         },
//         onPageFinished: (String url) {
//           log('Page finished loading: $url');
//         },
//         gestureNavigationEnabled: true,
//       ),
//     );
//   }
// }
// Usage Example
// Here’s how you can use the IpCameraViewer widget in your app:

// dart
// Copy
// import 'package:flutter/material.dart';
// import 'ip_camera_viewer.dart'; // Import the custom widget

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'IP Camera Viewer',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const IpCameraScreen(),
//     );
//   }
// }

// class IpCameraScreen extends StatelessWidget {
//   const IpCameraScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('IP Camera Viewer'),
//       ),
//       body: const Center(
//         child: IpCameraViewer(
//           cameraUrl: 'http://your-ip-camera-url/stream', // Replace with your IP camera URL
//           aspectRatio: 16 / 9, // Adjust aspect ratio if needed
//         ),
//       ),
//     );
//   }
// }
// Key Features:
// Reusable Widget:

// The IpCameraViewer widget is reusable and can be used anywhere in your app by passing the IP camera URL.

// Aspect Ratio:

// The widget allows you to specify the aspect ratio of the camera view (default is 16:9).

// WebView Integration:

// The webview_flutter package is used to display the IP camera stream.

// Error Handling:

// You can extend the widget to include error handling (e.g., display an error message if the stream fails to load).

// Extending the Widget (Optional)
// You can add more features to the widget, such as:

// Loading Indicator: Show a loading indicator while the stream is loading.

// Error Handling: Display an error message if the stream fails to load.

// Full-Screen Mode: Add a button to toggle full-screen mode.

// Example: Adding a Loading Indicator
// dart
// Copy
// class IpCameraViewer extends StatefulWidget {
//   final String cameraUrl;
//   final double aspectRatio;

//   const IpCameraViewer({
//     Key? key,
//     required this.cameraUrl,
//     this.aspectRatio = 16 / 9,
//   }) : super(key: key);

//   @override
//   _IpCameraViewerState createState() => _IpCameraViewerState();
// }

// class _IpCameraViewerState extends State<IpCameraViewer> {
//   late WebViewController _webViewController;
//   bool _isLoading = true;

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         AspectRatio(
//           aspectRatio: widget.aspectRatio,
//           child: WebView(
//             initialUrl: widget.cameraUrl,
//             javascriptMode: JavascriptMode.unrestricted,
//             onWebViewCreated: (WebViewController webViewController) {
//               _webViewController = webViewController;
//             },
//             onPageStarted: (String url) {
//               setState(() {
//                 _isLoading = true;
//               });
//             },
//             onPageFinished: (String url) {
//               setState(() {
//                 _isLoading = false;
//               });
//             },
//             gestureNavigationEnabled: true,
//           ),
//         ),
//         if (_isLoading)
//           const Center(
//             child: CircularProgressIndicator(),
//           ),
//       ],
//     );
//   }
// }
// Notes:
// Ensure the IP camera URL is accessible from the web browser.

// For local IP cameras, you may need to configure your network to allow external access.

// Test the widget with different IP camera streams to ensure compatibility.

// This reusable widget provides a clean and modular way to integrate IP camera streams into your Flutter web app. Let me know if you need further assistance!
