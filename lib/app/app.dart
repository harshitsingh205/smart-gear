import 'package:flutter/material.dart';
import 'theme.dart';
import '../screens/auth/splash_screen.dart';

class SmartGearApp extends StatelessWidget {
  const SmartGearApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartGear - Motorcycle Gear Rental & AI Demand Prediction',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
