// import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:pick_location/custom_widget/custom_web_view_web.dart';

import '../custom_widget/custom_browser_redirect.dart';
import '../custom_widget/custom_web_view.dart';
// import '../custom_widget/custom_web_view_all.dart';

class GisMap extends StatelessWidget {
  const GisMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GIS Map View'),
         centerTitle: true,
        elevation: 7,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.indigo, size: 17),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton(
            child: const Text('Open GIS Map IN Browser'),
            onPressed: () {
              const url = 'http://196.219.231.3:8000/lab-api/lab-marker/24';
              CustomBrowserRedirect.openInBrowser(url); // Open in browser
            },
          ),
          ElevatedButton(
            child: const Text('Open GIS Map IN WebView'),
            onPressed: () {
              const url = 'http://196.219.231.3:8000/lab-api/lab-marker/24';
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CustomWebView(
                            title: 'GIS Map webview', url: url)));
                //  Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => const CustomWebViewWeb(
                //             url: url)));
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => const CustomWebViewAll(
              //             title: 'GIS Map web-view all', url: url)));
              
            },
          ),
        ]),
      ),
    );
  }
}
