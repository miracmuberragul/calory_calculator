// lib/services/daily_tracking_service.dart
import 'package:calori_app/services/firebase_servise.dart';
import 'package:flutter/foundation.dart';

class FoodEntry {
  final String foodName;
  final int calories;
  final double protein;
  final double fat;
  final double carbohydrates;
  final DateTime timestamp;
  final String imageUrl;

  FoodEntry({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
    required this.timestamp,
    required this.imageUrl,
  });

  // JSON'dan FoodEntry oluştur
  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      foodName: json['foodName'] ?? 'Bilinmiyor',
      calories: json['calories'] ?? 0,
      protein: (json['protein'] ?? 0.0).toDouble(),
      fat: (json['fat'] ?? 0.0).toDouble(),
      carbohydrates: (json['carbohydrates'] ?? 0.0).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  // FoodEntry'yi JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbohydrates': carbohydrates,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}

class DailyNutrition {
  final int totalCalories;
  final double totalProtein;
  final double totalFat;
  final double totalCarbohydrates;
  final int mealCount;

  DailyNutrition({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalFat,
    required this.totalCarbohydrates,
    required this.mealCount,
  });
}

class DailyTrackingService extends ChangeNotifier {
  // Günlük hedefler (static değerler - daha sonra kullanıcı profili ile değiştirilebilir)
  static const int dailyCalorieGoal = 2000;
  static const double dailyProteinGoal = 150.0;
  static const double dailyFatGoal = 65.0;
  static const double dailyCarbGoal = 250.0;

  // Local cache için liste (performans için)
  List<FoodEntry> _todayEntries = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<FoodEntry> get todayEntries => _todayEntries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Günlük beslenme özetini hesapla
  DailyNutrition get dailyNutrition {
    int totalCalories = 0;
    double totalProtein = 0.0;
    double totalFat = 0.0;
    double totalCarbohydrates = 0.0;

    for (var entry in _todayEntries) {
      totalCalories += entry.calories;
      totalProtein += entry.protein;
      totalFat += entry.fat;
      totalCarbohydrates += entry.carbohydrates;
    }

    return DailyNutrition(
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalFat: totalFat,
      totalCarbohydrates: totalCarbohydrates,
      mealCount: _todayEntries.length,
    );
  }

  // Progress hesaplamaları
  double get calorieProgress {
    final progress = dailyNutrition.totalCalories / dailyCalorieGoal;
    return progress > 1.0 ? 1.0 : progress;
  }

  double get proteinProgress {
    final progress = dailyNutrition.totalProtein / dailyProteinGoal;
    return progress > 1.0 ? 1.0 : progress;
  }

  double get fatProgress {
    final progress = dailyNutrition.totalFat / dailyFatGoal;
    return progress > 1.0 ? 1.0 : progress;
  }

  double get carbProgress {
    final progress = dailyNutrition.totalCarbohydrates / dailyCarbGoal;
    return progress > 1.0 ? 1.0 : progress;
  }

  // Service başlatıldığında bugünkü verileri yükle
  Future<void> initializeService() async {
    await loadTodayEntries();
  }

  // Bugünkü yemek verilerini Firestore'dan yükle
  Future<void> loadTodayEntries() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final entries = await FirestoreService.getTodayFoodEntries();
      _todayEntries = entries;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Veriler yüklenirken hata oluştu: $e';
      debugPrint('loadTodayEntries error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Yeni yemek girişi ekle
  Future<bool> addFoodEntry(FoodEntry foodEntry) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // Önce Firestore'a kaydet
      final success = await FirestoreService.saveFoodEntry(foodEntry);

      if (success) {
        // Başarılıysa local cache'e ekle
        _todayEntries.add(foodEntry);
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Yemek kaydedilemedi';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Yemek eklerken hata oluştu: $e';
      debugPrint('addFoodEntry error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Yemek girişini sil (index ile - local cache için)
  Future<bool> removeFoodEntry(int index) async {
    try {
      if (index < 0 || index >= _todayEntries.length) {
        _errorMessage = 'Geçersiz yemek indeksi';
        return false;
      }

      _setLoading(true);
      _errorMessage = null;

      // Firestore'dan silmek için document ID'ye ihtiyacımız var
      // Bu durumda tüm listeyi yeniden yüklemek daha pratik olabilir
      final foodEntry = _todayEntries[index];

      // Local cache'den kaldır
      _todayEntries.removeAt(index);
      notifyListeners();

      // Not: Gerçek bir uygulamada document ID'yi de saklamamız gerekir
      // Şimdilik local cache'den siliyoruz, Firestore sync'i sonraki refresh'te olacak

      return true;
    } catch (e) {
      _errorMessage = 'Yemek silinirken hata oluştu: $e';
      debugPrint('removeFoodEntry error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Belirli bir tarih aralığındaki verileri getir
  Future<List<FoodEntry>> getFoodEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await FirestoreService.getFoodEntriesByDateRange(
        startDate,
        endDate,
      );
    } catch (e) {
      debugPrint('getFoodEntriesByDateRange error: $e');
      return [];
    }
  }

  // Günlük istatistikleri getir
  Future<DailyNutrition> getDailyNutitionForDate(DateTime date) async {
    try {
      final stats = await FirestoreService.getDailyStats(date);
      return DailyNutrition(
        totalCalories: stats['totalCalories'],
        totalProtein: stats['totalProtein'],
        totalFat: stats['totalFat'],
        totalCarbohydrates: stats['totalCarbohydrates'],
        mealCount: stats['mealCount'],
      );
    } catch (e) {
      debugPrint('getDailyNutitionForDate error: $e');
      return DailyNutrition(
        totalCalories: 0,
        totalProtein: 0.0,
        totalFat: 0.0,
        totalCarbohydrates: 0.0,
        mealCount: 0,
      );
    }
  }

  // Real-time dinleyici başlat (opsiyonel)
  void startRealtimeListener() {
    FirestoreService.getTodayFoodEntriesStream().listen(
      (entries) {
        _todayEntries = entries;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Real-time veri hatası: $error';
        debugPrint('Realtime listener error: $error');
        notifyListeners();
      },
    );
  }

  // Verileri yenile
  Future<void> refreshData() async {
    await loadTodayEntries();
  }

  // Tüm verileri temizle (çıkış yaparken vs.)
  void clearData() {
    _todayEntries.clear();
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  // Yardımcı fonksiyonlar
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Haftalık özet getir
  Future<Map<String, DailyNutrition>> getWeeklyNutrition() async {
    final Map<String, DailyNutrition> weeklyData = {};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month}-${date.day}';
      weeklyData[dateKey] = await getDailyNutitionForDate(date);
    }

    return weeklyData;
  }

  // Aylık özet getir
  Future<Map<String, DailyNutrition>> getMonthlyNutrition() async {
    final Map<String, DailyNutrition> monthlyData = {};
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(now.year, now.month, day);
      if (date.isBefore(now) || date.isAtSameMomentAs(now)) {
        final dateKey = '${date.year}-${date.month}-${date.day}';
        monthlyData[dateKey] = await getDailyNutitionForDate(date);
      }
    }

    return monthlyData;
  }
}
