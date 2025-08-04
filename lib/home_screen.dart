// lib/screens/home_screen.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

// ❗ DİKKAT: BURAYI KENDİ BİLGİSAYARINIZIN IP ADRESİ İLE DEĞİŞTİRİN
// Bilgisayarınızın IP adresini öğrenmek için terminal/cmd'ye 'ipconfig' (Windows) veya 'ifconfig' (macOS/Linux) yazın.
// Örnek: "http://192.168.1.10:5000/predict"
const String apiUrl =
    "http://127.0.0.1:5000/predict"; // ⭐ Örnek IP ile güncellendi

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- Durum Değişkenleri (State Variables) ---
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  Map<String, dynamic>? _predictionResult;
  bool _isLoading = false;
  String? _errorMessage;

  // --- Mantıksal Fonksiyonlar (Logic Functions) ---

  /// Galeriden veya kameradan bir resim seçer ve tahmin sürecini başlatır.
  Future<void> _processImage(ImageSource source) async {
    setState(() {
      _isLoading = true;
      _predictionResult = null;
      _errorMessage = null;
      _imageFile = null;
    });

    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
        await _uploadAndPredict(File(pickedFile.path));
      } else {
        // Kullanıcı resim seçmekten vazgeçerse yüklemeyi durdur
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Resim seçilemedi: $e";
          _isLoading = false;
        });
      }
    }
  }

  /// Seçilen resmi Flask backend'ine yükler ve tahmin sonucunu alır.
  Future<void> _uploadAndPredict(File imageFile) async {
    try {
      var uri = Uri.parse(apiUrl);
      var request = http.MultipartRequest('POST', uri)
        ..files.add(
          await http.MultipartFile.fromPath(
            // ⭐ Python tarafında beklenen anahtar 'image' olmalı
            'image',
            imageFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        setState(() {
          // Gelen cevabı UTF-8 olarak decode ederek Türkçe karakter sorunlarını önle
          _predictionResult = json.decode(utf8.decode(response.bodyBytes));
          _errorMessage = null; // Başarılı olunca eski hatayı temizle
        });
      } else {
        final errorBody = json.decode(utf8.decode(response.bodyBytes));
        setState(
          () => _errorMessage =
              "Sunucu Hatası (${response.statusCode}): ${errorBody['error'] ?? response.reasonPhrase}",
        );
      }
    } catch (e) {
      setState(
        () => _errorMessage =
            "Bağlantı Hatası: Sunucu çalışıyor mu? IP adresi doğru mu?",
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Arayüz Bileşenleri (UI Widgets) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yemek Kalori Tespiti')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImagePreview(),
                const SizedBox(height: 32),
                _buildActionButtons(),
                const SizedBox(height: 32),
                _buildResultDisplay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Seçilen resmi veya bir yer tutucu ikonu gösteren widget.
  Widget _buildImagePreview() {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: _imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.file(_imageFile!, fit: BoxFit.cover),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fastfood_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Yemeğinizin fotoğrafını ekleyin",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /// Galeri ve Kamera butonlarını içeren widget.
  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _isLoading
              ? null
              : () => _processImage(ImageSource.camera),
          icon: const Icon(Icons.camera_alt_outlined),
          label: const Text('Fotoğraf Çek'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isLoading
              ? null
              : () => _processImage(ImageSource.gallery),
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Galeriden Seç'),
        ),
      ],
    );
  }

  /// Yükleme animasyonunu, hata mesajını veya tahmin sonucunu gösteren widget.
  Widget _buildResultDisplay() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.error.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
    if (_predictionResult != null) {
      // ⭐ GÜNCELLENDİ: Yeni sonuç kartı widget'ı çağrılıyor.
      return _PredictionResultCard(result: _predictionResult!);
    }
    return const SizedBox(height: 50);
  }
}

// --- ⭐ GÜNCELLENDİ: Sonuç Kartı Widget'ı ---
// Bu widget, yeni JSON formatını ayrıştırmak ve göstermek için tamamen yeniden yazıldı.

class _PredictionResultCard extends StatelessWidget {
  final Map<String, dynamic> result;

  const _PredictionResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // 1. Yeni JSON formatından verileri güvenli bir şekilde al
    final foodName = result['food_name'] as String? ?? 'Bilinmiyor';
    final source = result['source'] as String? ?? 'Bilinmiyor';
    final confidence = result['confidence'] as String? ?? 'N/A';

    // 2. İç içe geçmiş 'nutritions' nesnesini al
    final nutritions = result['nutritions'] as Map<String, dynamic>? ?? {};
    final calories = nutritions['calories'] as int? ?? 0;
    final protein = nutritions['protein_g'] as num? ?? 0.0;
    final fat = nutritions['fat_g'] as num? ?? 0.0;

    // 3. Kaynağa göre ikon ve metin belirle
    final bool isGemini = source.toLowerCase().contains('gemini');
    final IconData sourceIcon = isGemini
        ? Icons.cloud_outlined
        : Icons.dns_outlined;
    final String sourceText = isGemini
        ? 'Kaynak: Gemini API'
        : 'Kaynak: Yerel Model';
    final String confidenceText = isGemini ? 'Doğrulama' : 'Güven: $confidence';

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          children: [
            // YEMEK ADI
            Text(
              foodName.toUpperCase(),
              style: textTheme.headlineSmall?.copyWith(
                color: Color(0xFF033F40), // Yemek adı için özel renk
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 30, thickness: 1, indent: 20, endIndent: 20),

            // BESİN DEĞERLERİ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NutrientInfo(
                  value: calories.toString(),
                  label: 'Kalori',
                  unit: 'kcal',
                  color: colorScheme.secondary,
                ),
                _NutrientInfo(
                  value: protein.toStringAsFixed(1),
                  label: 'Protein',
                  unit: 'g',
                ),
                _NutrientInfo(
                  value: fat.toStringAsFixed(1),
                  label: 'Yağ',
                  unit: 'g',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ⭐ YENİ: Kaynak ve Güven Bilgisi için Chip
            Chip(
              avatar: Icon(sourceIcon, color: colorScheme.primary, size: 20),
              label: Text('$sourceText | $confidenceText'),
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              labelStyle: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Besin Değeri Gösterim Widget'ı (Değişiklik yok) ---
class _NutrientInfo extends StatelessWidget {
  final String value;
  final String label;
  final String unit;
  final Color? color;

  const _NutrientInfo({
    required this.value,
    required this.label,
    required this.unit,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final defaultColor = Theme.of(context).textTheme.headlineSmall?.color;

    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Color(0xFF033F40), // Özel renk
          ),
        ),
        Text(
          unit,
          style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
