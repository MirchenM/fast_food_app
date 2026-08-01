import 'package:fast_food_app/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FastFood());
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

