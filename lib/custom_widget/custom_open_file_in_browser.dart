import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:universal_html/html.dart' as html;

class FileOpener {
  static Future<void> openFile(BuildContext context, String filePath) async {
    try {
      // Check if it's a web environment
      if (html.window.location.href.startsWith('http')) {
        // For web, we can't directly open local files - need to handle differently
        await _handleWebFileOpening(context, filePath);
      } else {
        // For mobile/desktop using url_launcher
        final uri = Uri.file(filePath);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          _showError(context,
              'Could not open the file. No application found to handle this file type.');
        }
      }
    } catch (e) {
      _showError(context, 'Error opening file: ${e.toString()}');
    }
  }

  static Future<void> _handleWebFileOpening(
      BuildContext context, String filePath) async {
    // Check if it's a network URL
    if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
      // Open external URLs normally
      final uri = Uri.parse(filePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showError(context, 'Could not launch the URL.');
      }
    } else if (filePath.startsWith('file://')) {
      // For local files in web, we need to either:
      // 1. Host them on a server
      // 2. Use download approach
      _showLocalFileWarning(context, filePath);
    } else {
      // Assume it's a local path without file:// prefix
      _showLocalFileWarning(context, filePath);
    }
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  static void _showLocalFileWarning(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Access Restricted'),
        content: const Text(
          'Web browsers restrict access to local files for security reasons. '
          'Please upload the file to cloud storage or a server and use the http:// URL instead.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              // Offer to download the file if it's in the web assets
              _attemptFileDownload(context, filePath);
              Navigator.pop(context);
            },
            child: const Text('Try Download'),
          ),
        ],
      ),
    );
  }

  static void _attemptFileDownload(BuildContext context, String filePath) {
    try {
      // Extract filename
      final filename = filePath.split('/').last;

      // Create an anchor element to trigger download
      final anchor = html.AnchorElement()
        ..href = filePath
        ..download = filename
        ..style.display = 'none';

      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download initiated if file is available'),
        ),
      );
    } catch (e) {
      _showError(context, 'Failed to download file: ${e.toString()}');
    }
  }
}
