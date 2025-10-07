// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
// import 'package:webview_flutter_web/webview_flutter_web.dart';

class CustomWebViewWeb extends StatefulWidget {
  final String url;

  const CustomWebViewWeb({
    super.key,
    required this.url,
  });

  @override
  State<CustomWebViewWeb> createState() => _CustomWebViewWebState();
}

class _CustomWebViewWebState extends State<CustomWebViewWeb> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web View'),
        actions: <Widget>[
          _SampleMenu(
            PlatformWebViewController(
              const PlatformWebViewControllerCreationParams(),
            )..loadRequest(
                LoadRequestParams(
                  uri: Uri.parse(widget.url),
                ),
              ),
          ),
        ],
      ),
      body: PlatformWebViewWidget(
        PlatformWebViewWidgetCreationParams(
          controller: PlatformWebViewController(
            const PlatformWebViewControllerCreationParams(),
          )..loadRequest(
              LoadRequestParams(
                uri: Uri.parse(widget.url),
              ),
            ),
        ),
      ).build(context),
    );
  }
}

enum _MenuOptions {
  doPostRequest,
}

class _SampleMenu extends StatelessWidget {
  const _SampleMenu(this.controller);

  final PlatformWebViewController controller;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuOptions>(
      onSelected: (_MenuOptions value) {
        switch (value) {
          case _MenuOptions.doPostRequest:
            _onDoPostRequest(controller);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuItem<_MenuOptions>>[
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.doPostRequest,
          child: Text('Post Request'),
        ),
      ],
    );
  }

  Future<void> _onDoPostRequest(PlatformWebViewController controller) async {
    final LoadRequestParams params = LoadRequestParams(
      uri: Uri.parse('https://httpbin.org/post'),
      method: LoadRequestMethod.post,
      headers: const <String, String>{
        'foo': 'bar',
        'Content-Type': 'text/plain'
      },
      body: Uint8List.fromList('Test Body'.codeUnits),
    );
    await controller.loadRequest(params);
  }
}

