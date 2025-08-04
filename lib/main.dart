// lib/main.dart

import 'package:calori_app/home_screen.dart';
import 'package:flutter/material.dart'; // Yeni dosyamızı import ediyoruz

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Uygulama başlığı
      title: 'Yemek Tanıma',

      // Hata ayıklama banner'ını kaldır
      debugShowCheckedModeBanner: false,

      // Uygulama teması
      theme: ThemeData(
        // Ana renk paleti
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),

        // Tema öğelerinin daha modern görünmesini sağlar
        useMaterial3: true,

        // AppBar teması
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF033F40), // AppBar arka plan rengi
          foregroundColor: Colors.white, // Başlık ve ikon renkleri
          elevation: 4,
        ),

        // Buton teması
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFEEA2AF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),

      // Uygulamanın başlangıç ekranı
      home: const HomeScreen(),
    );
  }
}
