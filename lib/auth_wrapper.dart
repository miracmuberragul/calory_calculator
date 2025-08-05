// lib/auth_wrapper.dart

import 'package:calori_app/login_screen.dart';
import 'package:calori_app/page_route.dart'; // KENDİ ANA SAYFA DOSYANIZ
import 'package:calori_app/login_screen.dart';
import 'package:calori_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide PageRoute;
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Auth servisini Provider üzerinden alıyoruz
    final authService = Provider.of<AuthService>(context, listen: false);

    // Kullanıcının oturum açma durumundaki değişiklikleri dinliyoruz
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Stream'den henüz bir veri gelmediyse, bekleme ekranı göster
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Stream'den veri geldiyse ve bu veri 'null' değilse,
        // yani bir kullanıcı oturumu aktifse...
        if (snapshot.hasData) {
          // Kullanıcıyı ana sayfanız olan RoutePage'e yönlendir.
          return const RoutePage();
        }

        // Stream'den gelen veri 'null' ise, yani aktif bir oturum yoksa...
        // Kullanıcıyı giriş ekranına yönlendir.
        return const LoginScreen();
      },
    );
  }
}
