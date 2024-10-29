import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaper_app/image_screen.dart';

class Wallpaper extends StatefulWidget {
  const Wallpaper({super.key});

  @override
  State<Wallpaper> createState() => _WallpaperState();
}

class _WallpaperState extends State<Wallpaper> {
  final List _images = [];
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _fetchApi();
  }

  void _fetchApi() async {
    await http.get(Uri.parse('https://api.pexels.com/v1/curated?per_page=80'),
        headers: {
          'Authorization': dotenv.env['PEXEL_API_KEY']!,
        }).then(
      (value) {
        Map result = jsonDecode(value.body);
        setState(() {
          List photos = result['photos'];
          _images.addAll(photos);
        });
      },
    );
  }

  void _loadMore() {
    _page++;

    String url = 'https://api.pexels.com/v1/curated?per_page=80&page=$_page';
    http.get(Uri.parse(url), headers: {
      'Authorization': dotenv.env['PEXEL_API_KEY']!,
    }).then((value) {
      Map result = jsonDecode(value.body);
      setState(() {
        List photos = result['photos'];
        _images.addAll(photos);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: _images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                childAspectRatio: 2 / 3,
                mainAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ImageScreen(
                        imageUrl: _images[index]['src']['large2x'],
                      ),
                    ));
                  },
                  child: Container(
                    color: Colors.grey,
                    child: Image.network(
                      _images[index]['src']['tiny'],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            height: 60,
            width: double.infinity,
            color: Colors.black,
            child: Center(
              child: TextButton(
                onPressed: () {
                  _loadMore();
                },
                child: const Text(
                  'Load more',
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
