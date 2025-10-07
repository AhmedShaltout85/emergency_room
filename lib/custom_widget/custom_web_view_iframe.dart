

import 'dart:html';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class IframeScreen extends StatefulWidget {
  final String url;

  const IframeScreen({super.key, required this.url});

  @override
  State<IframeScreen> createState() => _IframeScreenState();
}

class _IframeScreenState extends State<IframeScreen> {
  late IFrameElement _iFrameElement;
  late Widget _iframeWidget;

  @override
  void initState() {
    super.initState();
    _initializeIframe();
  }

  void _initializeIframe() {
    _iFrameElement = IFrameElement();
    _iFrameElement.style.height = '90%';
    _iFrameElement.style.width = '100%';
    _iFrameElement.style.border = 'none';
    _iFrameElement.src = widget.url; // Set initial URL

    // Register the iframe
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'iframeElement',
      (int viewId) => _iFrameElement,
    );

    // Create the HtmlElementView
    _iframeWidget = HtmlElementView(
      viewType: 'iframeElement',
      key: UniqueKey(), // Ensure re-rendering
    );
  }

  @override
  void didUpdateWidget(covariant IframeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.url != widget.url) {
      _iFrameElement.src = widget.url; // Update the iframe URL
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: _iframeWidget,
            ),
          ],
        ),
      ),
    );
  }
}
