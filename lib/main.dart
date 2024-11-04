import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wallpaper_app/app.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    DevicePreview(
      backgroundColor: Colors.white,
      enabled: true,
      defaultDevice: Devices.ios.iPhone13ProMax,
      isToolbarVisible: true,
      availableLocales: const [Locale('en', 'US')],
      tools: const [
        DeviceSection(
          model: true,
          orientation: false,
          frameVisibility: false,
          virtualKeyboard: false,
        ),
      ],
      devices: [
        Devices.android.samsungGalaxyA50,
        Devices.android.samsungGalaxyNote20,
        Devices.android.samsungGalaxyS20,
        Devices.android.samsungGalaxyNote20Ultra,
        Devices.android.onePlus8Pro,
        Devices.android.sonyXperia1II,
        Devices.ios.iPhoneSE,
        Devices.ios.iPhone12,
        Devices.ios.iPhone12Mini,
        Devices.ios.iPhone12ProMax,
        Devices.ios.iPhone13,
        Devices.ios.iPhone13ProMax,
        Devices.ios.iPhone13Mini,
        Devices.ios.iPhoneSE,
      ],
      builder: (context) => const MyApp(),
    ),
  );
}
