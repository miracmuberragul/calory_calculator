// lib/screens/page_route.dart

import 'package:calori_app/main_dashboard_screen.dart';
import 'package:calori_app/abaout_screen.dart';
import 'package:flutter/material.dart';

class PageRoute extends StatefulWidget {
  const PageRoute({super.key});

  @override
  State<PageRoute> createState() => _PageRouteState();
}

class _PageRouteState extends State<PageRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kalori Dedektifi',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: const Color(0xFF033F40),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 24.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo ve başlık
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF35738C),
                        const Color(0xFFEEA2AF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF35738C).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Ana başlık
                const Text(
                  'Kalori Dedektifi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF35738C),
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 24),

                // Açıklama metni - daha modern tipografi
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF35738C).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF35738C).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Yemeklerinizin kalori değerlerini AI ile tespit edin ve günlük beslenmenizi takip edin. '
                    'Fotoğraf çekip anında sonuç alın!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF35738C),
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Ana buton - Dashboard'a git
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainDashboardScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.dashboard_outlined),
                    label: const Text('Ana Sayfa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEEA2AF),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: const Color(0xFFEEA2AF).withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // İkincil buton - Hakkında
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Uygulama Hakkında'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFEEA2AF),
                      elevation: 2,
                      side: BorderSide(
                        color: const Color(0xFFEEA2AF).withOpacity(0.3),
                        width: 1.5,
                      ),
                      shadowColor: const Color(0xFF35738C).withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
