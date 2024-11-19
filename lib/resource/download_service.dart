import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;

class DownloadService {
  Future<void> downloadImage(String imageUrl) async {
    try {
      // Fetch image data
      final response = await http.get(Uri.parse(imageUrl));
      final Uint8List imageBytes = response.bodyBytes;

      if (kIsWeb) {
        // Web download implementation
        _downloadWeb(imageBytes, _extractFileName(imageUrl));
      } else if (Platform.isAndroid || Platform.isIOS) {
        // Mobile download implementation
        await _downloadMobile(imageBytes, _extractFileName(imageUrl));
      }
    } catch (e) {
      print('Download error: $e');
      // Handle download errors (show user-friendly message)
    }
  }

  void _downloadWeb(Uint8List bytes, String fileName) {
    // Create blob and trigger download for web
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<void> _downloadMobile(Uint8List bytes, String fileName) async {
    // Request storage permission
    if (await Permission.storage.request().isGranted) {
      // Get external storage directory
      final directory = await getExternalStorageDirectory();
      final file = File('${directory?.path}/$fileName');

      // Write bytes to file
      await file.writeAsBytes(bytes);

      // Optional: Show download complete notification
      // You might use a package like flutter_local_notifications

      print('Image downloaded at : ${directory?.path}');
    }
  }

  String _extractFileName(String url) {
    // Extract filename from URL or generate a unique name
    return url.split('/').last.contains('.')
        ? url.split('/').last
        : 'downloaded_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }
}