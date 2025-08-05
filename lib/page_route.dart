import 'package:calori_app/abaout_screen.dart';
import 'package:calori_app/home_screen.dart';
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
          'Yemek Kalori Tespiti ',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        centerTitle: true,
        elevation: 2,
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
                // Ana başlık
                const Text(
                  ' Yemek Kalori Tespiti ',
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
                    'Bu uygulama, yemeklerin kalori değerlerini tahmin etmek için makine öğrenimi modelleri kullanır. '
                    'Kameranızı kullanarak bir yemek fotoğrafı çekebilir ve modelin tahmin ettiği kalori değerini görebilirsiniz.',
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

                // Ana buton - daha büyük ve merkezi
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEEA2AF),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: const Color(0xFFEEA2AF).withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Kalori Tahmini Yap',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // İkincil buton - aynı boyut ve stil
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AbaoutScreen(),
                        ),
                      );
                    },
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
                    child: const Text(
                      'Uygulama Hakkında',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
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
