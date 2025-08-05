// lib/page_route.dart

// Gerekli tüm ekranları import ediyoruz
import 'package:calori_app/main_dashboard_screen.dart'; // TAKİP EKRANI
import 'package:calori_app/home_screen.dart'; // TESPİT EKRANI
import 'package:calori_app/settings.dart'; // AYARLAR EKRANI
import 'package:flutter/material.dart';

// Bu, orijinal tasarımınızı içeren "Ana Sayfa" sekmesi
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF35738C), const Color(0xFFEEA2AF)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Kalori Dedektifi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF35738C),
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF35738C).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF35738C).withOpacity(0.2),
                  ),
                ),
                child: const Text(
                  'Yemeklerinizin kalori değerlerini AI ile tespit edin ve günlük beslenmenizi takip edin. Fotoğraf çekip anında sonuç alın!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF35738C),
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ANA İSKELET WIDGET'I (4 SEKMELİ) ---
class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  int _selectedIndex = 0; // Hangi sekmenin seçili olduğunu tutar

  static const List<String> _appBarTitles = <String>[
    'Kalori Dedektifi', // Ana Sayfa
    'Kalori Tespiti', // Tespit Et
    'Günlük Takip', // Takip
    'Profil ve Ayarlar', // Ayarlar
  ];

  // Her sekmede gösterilecek widget'ların listesi
  static const List<Widget> _pages = <Widget>[
    WelcomeScreen(), // Sekme 0: Sizin orijinal tasarımınız
    HomeScreen(), // Sekme 1: Kalori Tespit Ekranı
    MainDashboardScreen(), // Sekme 2: Takip Panosu (Dashboard)
    SettingsScreen(), // Sekme 3: Ayarlar Ekranı
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarTitles[_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF033F40),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            activeIcon: Icon(Icons.camera_alt),
            label: 'Tespit Et',
          ),
          // ⭐ YENİ SEKME EKLENDİ
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Takip',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFEEA2AF),
        unselectedItemColor: Colors.grey.shade600,
        onTap: _onItemTapped,
        type: BottomNavigationBarType
            .fixed, // 4 item olduğu için fixed kullanmak iyi bir pratik
        backgroundColor: Colors.white,
        elevation: 5,
      ),
    );
  }
}
