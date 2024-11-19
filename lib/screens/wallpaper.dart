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
  int _searchPage = 1;
  final List _searchedImages = [];
  bool _isSearchScreen = false;
  late TextEditingController _searchController;
  bool _isLoading = false;
  bool _isLoadingMoreImages = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fetchApi();
  }

  void _fetchApi() async {
    setState(() {
      _isLoading = true;
    });
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
    setState(() {
      _isLoading = false;
    });
  }

  void _fetchSearchApi(String query) async {
    setState(() {
      _isSearchScreen = true;
      _isLoading = true;
    });
    query = query.trim().toLowerCase();

    try {
      await http.get(
          Uri.parse(
              'https://api.pexels.com/v1/search?query=$query&per_page=80'),
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
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadMore() async {
    _page++;
    setState(() {
      _isLoadingMoreImages = true;
    });

    try {
      String url = 'https://api.pexels.com/v1/curated?per_page=80&page=$_page';
      await http.get(Uri.parse(url), headers: {
        'Authorization': dotenv.env['PEXEL_API_KEY']!,
      }).then((value) {
        Map result = jsonDecode(value.body);
        setState(() {
          List photos = result['photos'];
          _images.addAll(photos);
        });
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    setState(() {
      _isLoadingMoreImages = false;
    });
  }

  void _loadSearchMore(String query) {
    _searchPage++;
    setState(() {
      _isLoadingMoreImages = true;
    });

    try {
      String url =
          'https://api.pexels.com/v1/search?query=$query&per_page=80&page=$_searchPage';
      http.get(Uri.parse(url), headers: {
        'Authorization': dotenv.env['PEXEL_API_KEY']!,
      }).then(
        (value) {
          Map result = jsonDecode(value.body);
          setState(() {
            List photos = result['photos'];
            _searchedImages.addAll(photos);
          });
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    setState(() {
      _isLoadingMoreImages = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                if (_isSearchScreen)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearchScreen = false;

                        _searchedImages.clear();
                        _searchController.clear();
                      });
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      onSubmitted: _fetchSearchApi,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[800],
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey[300]),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
                                !_isSearchScreen
                                    ? _images[index]['src']['tiny']
                                    : _searchedImages[index]['src']['tiny'],
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                        childCount: !_isSearchScreen
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
                          if (_isSearchScreen) {
                            _loadSearchMore(_searchController.text);
                          } else {
                            _loadMore();
                          }
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
            if (_isLoadingMoreImages)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(
                  color: Colors.blueGrey,
                  minHeight: 6,
                ),
              )
          ],
        ),
      ),
    );
  }
}
