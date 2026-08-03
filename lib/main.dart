import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:fast_food_app/data/repositories/firebase_auth_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'presentation/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const FastFoodApp(),
    ),
  );
}

class FastFoodApp extends StatelessWidget {
  const FastFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sabor Rápido',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: AppTheme.light,
      home: LoginScreen(authRepository: FirebaseAuthRepository()),
    );
  }
}