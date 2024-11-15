import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaper_app/screens/image_screen.dart';

class Wallpaper extends StatefulWidget {
  const Wallpaper({super.key});

  @override
  State<Wallpaper> createState() => _WallpaperState();
}

class _WallpaperState extends State<Wallpaper> {
  final List _images = [];
  int _page = 1;
  final List _searchedImages = [];

  @override
  void initState() {
    super.initState();
    _fetchApi();
  }

  void _fetchApi() async {
    try {
      await http.get(Uri.parse('https://api.pexels.com/v1/curated?per_page=80'),
          headers: {
            'Authorization': dotenv.env['PEXEL_API_KEY']!,
          }).then(
        (value) {
          Map result = jsonDecode(value.body);
          setState(() {
            final List photos = result['photos'];
            _images.addAll(photos);
          });
        },
      );
    } catch (e) {

      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void _fetchSearchApi(String query) async {
    query = query.trim().toLowerCase();
    http.get(
        Uri.parse('https://api.pexels.com/v1/search?query=$query&per_page=80'),
        headers: {
          'Authorization': dotenv.env['PEXEL_API_KEY']!,
        }).then(
      (value) {
        Map result = jsonDecode(value.body);
        _searchedImages.clear();
        setState(() {
          final List photos = result['photos'];
          _searchedImages.addAll(photos);
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
      body: SafeArea(
        child: Column(
          children: [
            SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 5,
                  ),
                  child: SearchBar(
                    leading: const Icon(Icons.search),
                    hintText: 'Search',
                    textStyle: const WidgetStatePropertyAll(
                      TextStyle(fontSize: 21),
                    ),
                    onSubmitted: _fetchSearchApi,
                  ),
                );
              },
              suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
                return [];
              },
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(5),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ImageScreen(
                                  imageUrl: _searchedImages.isEmpty
                                      ? _images[index]['src']['large2x']
                                      : _searchedImages[index]['src']
                                          ['large2x'],
                                ),
                              ));
                            },
                            child: Container(
                              color: Colors.grey,
                              child: Image.network(
                                _searchedImages.isEmpty
                                    ? _images[index]['src']['tiny']
                                    : _searchedImages[index]['src']['tiny'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                        childCount: _searchedImages.isEmpty
                            ? _images.length
                            : _searchedImages.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        childAspectRatio: 2 / 3,
                        mainAxisSpacing: 2,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
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
            ),
          ],
        ),
      ),
    );
  }
}
