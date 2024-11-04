import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:wallpaper_app/screens/wallpaper.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallpaper App',
      locale: DevicePreview.locale(context), // add this line
      builder: DevicePreview.appBuilder, // add this line
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      home: const Wallpaper(),
    );
  }
}