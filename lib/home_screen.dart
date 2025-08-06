// lib/screens/home_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:calori_app/services/daily_tracking_service.dart';

const String apiUrl = "http://127.0.0.1:5000/predict";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- Durum Değişkenleri ---
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  Map<String, dynamic>? _predictionResult;
  bool _isLoading = false;
  bool _isSaving = false; // Firestore'a kaydetme durumu
  String? _errorMessage;

  // --- Mantıksal Fonksiyonlar ---
  /// Galeriden veya kameradan bir resim seçer ve tahmin sürecini başlatır.
  Future<void> _processImage(ImageSource source) async {
    setState(() {
      _isLoading = true;
      _predictionResult = null;
      _errorMessage = null;
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
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Resim seçme hatası: $e";
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
            'image',
            imageFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _predictionResult = json.decode(utf8.decode(response.bodyBytes));
            _errorMessage = null;
          });
        }
      } else {
        final errorBody = json.decode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(
            () => _errorMessage =
                "Sunucu Hatası (${response.statusCode}): ${errorBody['error'] ?? response.reasonPhrase}",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _errorMessage =
              "Bağlantı Hatası: Sunucu çalışıyor mu? IP adresi doğru mu?\n($e)",
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// ⭐ GÜNCELLENDİ: Firestore'a kaydetme işlemi eklendi
  Future<void> _addToTracking() async {
    if (_predictionResult == null) return;

    setState(() => _isSaving = true);

    try {
      final trackingService = Provider.of<DailyTrackingService>(
        context,
        listen: false,
      );

      String foodName;
      int calories;
      double protein;
      double fat;
      double carbohydrates;

      // Gelen yanıtta 'items' anahtarı var mı diye kontrol et (çoklu yemek durumu)
      if (_predictionResult!.containsKey('items') &&
          _predictionResult!.containsKey('total_nutrition')) {
        // --- ÇOKLU YEMEK MANTIĞI ---
        final items = List<Map<String, dynamic>>.from(
          _predictionResult!['items'],
        );
        foodName = items
            .map((item) => item['food_name'] as String? ?? 'Öğe')
            .join(', ');

        final totalNutritions =
            _predictionResult!['total_nutrition'] as Map<String, dynamic>? ??
            {};
        calories = totalNutritions['calories'] as int? ?? 0;
        protein = (totalNutritions['protein'] as num? ?? 0.0).toDouble();
        fat = (totalNutritions['fat'] as num? ?? 0.0).toDouble();
        carbohydrates = (totalNutritions['carbohydrates'] as num? ?? 0.0)
            .toDouble();
      } else {
        // --- TEKLİ YEMEK MANTIĞI (Eski mantık) ---
        foodName = _predictionResult!['food_name'] as String? ?? 'Bilinmiyor';
        final nutritions =
            _predictionResult!['nutritions'] as Map<String, dynamic>? ?? {};
        calories = nutritions['calories'] as int? ?? 0;
        protein = (nutritions['protein_g'] as num? ?? 0.0).toDouble();
        fat = (nutritions['fat_g'] as num? ?? 0.0).toDouble();
        carbohydrates = (nutritions['carbohydrate_g'] as num? ?? 0.0)
            .toDouble();
      }

      final foodEntry = FoodEntry(
        id: '', // Firestore ID otomatik olarak atanacak
        foodName: foodName,
        calories: calories,
        protein: protein,
        fat: fat,
        carbohydrates: carbohydrates,
        timestamp: DateTime.now(),
        imageUrl: _imageFile?.path ?? '',
      );

      // Firestore'a kaydet
      final success = await trackingService.addFoodEntry(foodEntry);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${foodEntry.foodName} başarıyla kaydedildi!',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 3),
            ),
          );

          // Başarılı kaydetme sonrası formu temizle
          setState(() {
            _imageFile = null;
            _predictionResult = null;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Kaydetme işlemi başarısız oldu. Tekrar deneyin.',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_outlined, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Beklenmeyen hata: $e',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // --- Arayüz Bileşenleri ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

  Widget _buildActionButtons() {
    final bool isProcessing = _isLoading || _isSaving;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: isProcessing
              ? null
              : () => _processImage(ImageSource.camera),
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.camera_alt_outlined),
          label: Text(_isLoading ? 'İşleniyor...' : 'Fotoğraf Çek'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEEA2AF),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: isProcessing
              ? null
              : () => _processImage(ImageSource.gallery),
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Galeriden Seç'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultDisplay() {
    if (_isLoading) {
      return Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Yemek analiz ediliyor...',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      );
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
              ),
            ),
          ],
        ),
      );
    }

    if (_predictionResult != null) {
      return Column(
        children: [
          _PredictionResultCard(result: _predictionResult!),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _addToTracking,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.cloud_upload_outlined),
              label: Text(
                _isSaving ? 'Kaydediliyor...' : 'Firestore\'a Kaydet',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox(height: 50);
  }
}

/// Tahmin sonuçlarını gösteren kart widget'ı
class _PredictionResultCard extends StatelessWidget {
  final Map<String, dynamic> result;

  const _PredictionResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Görüntülenecek veriler için değişkenler
    String foodNameToDisplay;
    int calories;
    double protein;
    double fat;
    double carbohydrates;

    // Gelen yanıtta 'items' anahtarı var mı diye kontrol et (çoklu yemek durumu)
    if (result.containsKey('items') && result.containsKey('total_nutrition')) {
      // --- ÇOKLU YEMEK MANTIĞI ---
      final items = List<Map<String, dynamic>>.from(result['items']);
      foodNameToDisplay = items
          .map((item) => item['food_name'] as String? ?? 'Öğe')
          .join(', ');

      final totalNutritions =
          result['total_nutrition'] as Map<String, dynamic>? ?? {};
      calories = totalNutritions['calories'] as int? ?? 0;
      protein = (totalNutritions['protein'] as num? ?? 0.0).toDouble();
      fat = (totalNutritions['fat'] as num? ?? 0.0).toDouble();
      carbohydrates = (totalNutritions['carbohydrates'] as num? ?? 0.0)
          .toDouble();
    } else {
      // --- TEKLİ YEMEK MANTIĞI (Eski mantık) ---
      foodNameToDisplay = result['food_name'] as String? ?? 'Bilinmiyor';
      final nutritions = result['nutritions'] as Map<String, dynamic>? ?? {};
      calories = nutritions['calories'] as int? ?? 0;
      protein = (nutritions['protein_g'] as num? ?? 0.0).toDouble();
      fat = (nutritions['fat_g'] as num? ?? 0.0).toDouble();
      carbohydrates = (nutritions['carbohydrate_g'] as num? ?? 0.0).toDouble();
    }

    // Ortak verileri (kaynak, güven) al
    final source = result['source'] as String? ?? 'Bilinmiyor';
    final confidence = result['confidence'] as String? ?? 'N/A';
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
            Text(
              foodNameToDisplay.toUpperCase(),
              style: textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF033F40),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 30, thickness: 1, indent: 20, endIndent: 20),
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
                _NutrientInfo(
                  value: carbohydrates.toStringAsFixed(1),
                  label: 'Karbonhidrat',
                  unit: 'g',
                ),
              ],
            ),
            const SizedBox(height: 24),
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

/// Besin değeri bilgilerini gösteren widget
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
            color: const Color(0xFF033F40),
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
