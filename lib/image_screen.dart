import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';

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
  Future<void> setWallpaper() async {
    final location = WallpaperManager.HOME_SCREEN;
    final file = await DefaultCacheManager().getSingleFile(widget.imageUrl);
    final result = WallpaperManager.setWallpaperFromFile(file.path, location);
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
          Container(
            height: 60,
            width: double.infinity,
            color: Colors.black,
            child: Center(
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Set Wallpaper',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
