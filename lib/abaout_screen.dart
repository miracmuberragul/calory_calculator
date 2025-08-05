// lib/screens/about_screen.dart

import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uygulama Hakkında'),
        backgroundColor: const Color(0xFF033F40),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo ve başlık
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF35738C),
                          const Color(0xFFEEA2AF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
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
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Kalori Dedektifi',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF35738C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Versiyon 1.0.0',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Özellikler
            _buildSectionCard('Uygulama Özellikleri', Icons.star_border, [
              '🤖 AI destekli yemek tanıma',
              '📊 Günlük kalori takibi',
              '🍎 Besin değeri analizi',
              '📸 Kamera ile anında tarama',
              '📱 Kullanıcı dostu arayüz',
              '📈 İlerleme takibi',
            ]),

            const SizedBox(height: 24),

            // Nasıl Çalışır
            _buildSectionCard('Nasıl Çalışır?', Icons.help_outline, [
              '1. Yemeğinizin fotoğrafını çekin',
              '2. AI modeli yemeği analiz eder',
              '3. Kalori ve besin değerleri hesaplanır',
              '4. Sonuçları günlük takibinize ekleyin',
              '5. İlerlemenizi takip edin',
            ]),

            const SizedBox(height: 24),

            // Teknoloji
            _buildSectionCard('Kullanılan Teknolojiler', Icons.computer, [
              '🧠 Machine Learning & AI',
              '📱 Flutter Framework',
              '🐍 Python Flask Backend',
              '🔗 REST API',
              '💾 Yerel Veri Depolama',
            ]),

            const SizedBox(height: 24),

            // İletişim
            _buildContactCard(),

            const SizedBox(height: 24),

            // Yasal Bilgiler
            _buildLegalCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<String> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF35738C), size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF35738C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF35738C).withOpacity(0.1),
            const Color(0xFFEEA2AF).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF35738C).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.contact_support,
                color: Color(0xFF35738C),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'İletişim & Destek',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF35738C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Sorularınız, önerileriniz veya geri bildirimleriniz için:',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          const Text(
            '📧 info@kaloridedektifi.com',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF35738C),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '🌐 www.kaloridedektifi.com',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF35738C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel, color: Colors.grey.shade600, size: 24),
              const SizedBox(width: 12),
              Text(
                'Yasal Bilgiler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '• Bu uygulama eğitim amaçlı geliştirilmiştir.\n'
            '• Kalori hesaplamaları yaklaşık değerlerdir.\n'
            '• Tıbbi karar verme için kullanmayınız.\n'
            '• Gizlilik politikamız kapsamında verileriniz korunmaktadır.\n'
            '• © 2024 Kalori Dedektifi. Tüm hakları saklıdır.',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
