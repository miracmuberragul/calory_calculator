import 'package:calori_app/home_screen.dart';
import 'package:flutter/material.dart';

class AbaoutScreen extends StatefulWidget {
  const AbaoutScreen({super.key});

  @override
  State<AbaoutScreen> createState() => _AbaoutScreenState();
}

class _AbaoutScreenState extends State<AbaoutScreen> {
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
