import 'package:flutter/material.dart';
import 'package:calori_app/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalori Dedektifi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF35738C),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'System', // Sistem fontunu kullan
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
        // AppBar teması eklendi
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF033F40), // AppBar arka plan rengi
          foregroundColor: Colors.white, // Başlık ve ikon renkleri
          elevation: 4,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
