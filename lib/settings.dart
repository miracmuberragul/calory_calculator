// lib/screens/settings_screen.dart

import 'package:calori_app/abaout_screen.dart';
import 'package:calori_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mevcut kullanıcıyı Auth Service'den alıyoruz.
    final User? user = Provider.of<AuthService>(
      context,
      listen: false,
    ).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil ve Ayarlar'),
        automaticallyImplyLeading: false, // Geri butonunu kaldırır
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (user != null) ...[
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFEEA2AF),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                user.displayName ??
                    'Kullanıcı Adı', // Google'dan gelirse adı yazar
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Center(
              child: Text(
                user.email ?? 'E-posta adresi bulunamadı',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
              ),
            ),
            const Divider(height: 40, thickness: 1),
          ],

          // Profil Bilgilerini Düzenleme Kartı
          Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.edit_outlined,
                color: Color(0xFF35738C),
              ),
              title: const Text('Profil Bilgilerimi Düzenle'),
              subtitle: const Text('Boy, kilo ve hedeflerinizi güncelleyin'),
              onTap: () {
                // TODO: Profil düzenleme ekranına yönlendirme eklenecek
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bu özellik yakında eklenecektir.'),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Uygulama Hakkında Kartı
          Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: Color(0xFF35738C)),
              title: const Text('Uygulama Hakkında'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 40),

          // Çıkış Yap Butonu
          ElevatedButton.icon(
            onPressed: () async {
              // AuthService üzerinden güvenli çıkış yap
              final authService = Provider.of<AuthService>(
                context,
                listen: false,
              );
              await authService.signOut();
              // AuthWrapper zaten bizi otomatik olarak LoginScreen'e yönlendirecek.
            },
            icon: const Icon(Icons.logout),
            label: const Text('Çıkış Yap'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
