import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:fast_food_app/presentation/screens/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
      DevicePreview(
        enabled: !kReleaseMode,
        defaultDevice: Devices.ios.iPhone13,
        builder: (context) => const FastFood(),
      ),
  );
}

class FastFood extends StatelessWidget {
  const FastFood({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sabor Viciante',
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

