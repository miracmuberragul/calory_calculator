// lib/main.dart

import 'package:calori_app/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calori_app/services/daily_tracking_service.dart';
import 'package:calori_app/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DailyTrackingService(),
      child: MaterialApp(
        title: 'Kalori Dedektifi',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF35738C),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'System',
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF35738C),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF033F40),
            foregroundColor: Colors.white,
            elevation: 2,
            centerTitle: true,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
