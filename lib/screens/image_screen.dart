import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:wallpaper_app/resource/download_service.dart';
import 'package:wallpaper_app/widgets/bottom_button.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({
    super.key,
    required this.imageUrl,
  });

  final String imageUrl;

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  bool _isSettingWallpaper = false;
  bool _isDownloadingWallpaper = false;

  Future<void> setWallpaper() async {
    setState(() {
      _isSettingWallpaper = true;
    });
    final location = WallpaperManager.HOME_SCREEN;
    final file = await DefaultCacheManager().getSingleFile(widget.imageUrl);
    final result =
        await WallpaperManager.setWallpaperFromFile(file.path, location);

    setState(() {
      _isSettingWallpaper = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    String message;
    if (result) {
      message = 'Wallpaper set successfully.';
    } else {
      message = 'Failed to set wallpaper, please try again.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  Future<void> downloadWallpaper() async {
    setState(() {
      _isDownloadingWallpaper = true;
    });
    await DownloadService().downloadImage(widget.imageUrl);
    setState(() {
      _isDownloadingWallpaper = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.contain,
            ),
          ),
          Row(
            children: [
              if (!kIsWeb)
                Expanded(
                  child: BottomButton(
                    onTap: setWallpaper,
                    text: 'Set Wallpaper',
                    isLoading: _isSettingWallpaper,
                  ),
                ),
              if (!kIsWeb)
                Container(
                  color: Colors.white,
                  width: 1,
                  height: 60,
                ),
              Expanded(
                  child: BottomButton(
                onTap: downloadWallpaper,
                text: 'Download',
                isLoading: _isDownloadingWallpaper,
              ))
            ],
          ),
        ],
      ),
    );
  }
}
