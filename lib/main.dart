// lib/main.dart

import 'package:calori_app/auth_wrapper.dart'; // Bu dosyayı birazdan oluşturacağız
import 'package:calori_app/firebase_options.dart';
import 'package:calori_app/services/auth_service.dart'; // Oluşturduğumuz servis
import 'package:calori_app/services/firebase_servise.dart';
import 'package:calori_app/splash_screen.dart';
// Oluşturduğumuz servis
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calori_app/services/daily_tracking_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider kullanarak birden fazla servis sağlayalım
    return MultiProvider(
      providers: [
        // Bu servis, günlük kalori takibini yönetir (zaten vardı)
        ChangeNotifierProvider(create: (context) => DailyTrackingService()),
        // Bu servis, Firebase kimlik doğrulama işlemlerini yönetir
        Provider<AuthService>(create: (_) => AuthService()),
        // Bu servis, Firestore veritabanı işlemlerini yönetir
        Provider<FirestoreService>(create: (_) => FirestoreService()),
      ],
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
        // ⭐ Uygulamanın başlangıç noktası artık AuthWrapper olacak
        // SplashScreen'den sonra bu ekrana yönlendireceğiz.
        // Şimdilik test için doğrudan AuthWrapper'ı koyalım.
        // home: const SplashScreen(), // Orijinal hali
        home: const SplashScreen(), // Yeni hali
      ),
    );
  }
}
