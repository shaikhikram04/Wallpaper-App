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
        await _downloadMobile(response, _extractFileName(imageUrl));
      }
    } catch (e) {
      print('Download error: $e');
      // Handle download errors (show user-friendly message)
    }
  }

  void _downloadWeb(Uint8List bytes, String fileName) {
    // Ensure filename ends with .jpg
    if (!fileName.toLowerCase().endsWith('.jpg') &&
        !fileName.toLowerCase().endsWith('.jpeg')) {
      fileName = '$fileName.jpg';
    }

    // Create blob with JPEG MIME type
    final blob = html.Blob(
      [bytes],
      'image/jpeg', // Specify MIME type as JPEG
    );

    _downloadBlob(blob, fileName);
  }

  Future<void> _downloadMobile(http.Response response, String fileName) async {
    try {
      // Request storage permission
      if (!await _requestPermission()) {
        throw Exception('Storage permission denied');
      }

      // Get the root directory path
      Directory? root;
      if (Platform.isAndroid) {
        // This will give us /storage/emulated/0/
        root = Directory('/storage/emulated/0/');
      } else {
        // For iOS, we'll use the documents directory
        final appDir = await getApplicationDocumentsDirectory();
        root = Directory(appDir.path);
      }

      // Create your custom directory at root level
      final String customDirPath = '${root.path}/MyImages';
      final Directory customDir = Directory(customDirPath);

      // Create directory if it doesn't exist
      if (!await customDir.exists()) {
        await customDir.create(recursive: true);
      }

      // Download image
      if (response.statusCode != 200) {
        throw Exception('Failed to download image');
      }

      // Ensure file name has .jpg extension
      final String fileNameWithExt =
          fileName.toLowerCase().endsWith('.jpg') ? fileName : '$fileName.jpg';

      // Create file path
      final String filePath = '${customDir.path}/$fileNameWithExt';

      // Save file
      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
    } catch (e) {
      print(e.toString());
    }
  }

  void _downloadBlob(html.Blob blob, String fileName) {
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement()
      ..href = url
      ..style.display = 'none'
      ..download = fileName;

    html.document.body?.children.add(anchor);
    anchor.click();

    // Cleanup
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }
    } else if (Platform.isIOS) {
      // iOS doesn't need explicit permission for saving to app directory
      return true;
    }
    return false;
  }

  String _extractFileName(String url) {
    // Extract filename from URL or generate a unique name
    return url.split('/').last.contains('.')
        ? url.split('/').last
        : 'downloaded_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }
}
