import 'package:flutter/material.dart';
import 'package:mobile_lelang/splash_screen/splash_screen.dart';
import 'package:mobile_lelang/view/profile/profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      
    );
  }
}
