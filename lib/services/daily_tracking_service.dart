// lib/services/daily_tracking_service.dart

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FoodEntry {
  final String? id;
  final String foodName;
  final int calories;
  final double protein;
  final double fat;
  final double carbohydrates;
  final DateTime timestamp;
  final String imageUrl;

  FoodEntry({
    this.id,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrates,
    required this.timestamp,
    this.imageUrl = '',
  });

  Map<String, dynamic> toJson() => {
    'foodName': foodName,
    'calories': calories,
    'protein': protein,
    'fat': fat,
    'carbohydrates': carbohydrates,
    'timestamp': timestamp.toIso8601String(),
    'imageUrl': imageUrl,
  };

  factory FoodEntry.fromMap(Map<String, dynamic> map, String documentId) {
    return FoodEntry(
      id: documentId,
      foodName: map['foodName'] ?? 'Bilinmiyor',
      calories: map['calories'] ?? 0,
      protein: (map['protein'] as num? ?? 0.0).toDouble(),
      fat: (map['fat'] as num? ?? 0.0).toDouble(),
      carbohydrates: (map['carbohydrates'] as num? ?? 0.0).toDouble(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}

class DailyNutrition {
  final int totalCalories;
  final double totalProtein;
  final double totalFat;
  final double totalCarbohydrates;
  final int mealCount;

  DailyNutrition({
    this.totalCalories = 0,
    this.totalProtein = 0.0,
    this.totalFat = 0.0,
    this.totalCarbohydrates = 0.0,
    this.mealCount = 0,
  });
}

class DailyTrackingService extends ChangeNotifier {
  final List<FoodEntry> _todayEntries = [];

  // Günlük hedefler
  static const int dailyCalorieGoal = 2000;
  static const double dailyProteinGoal = 150.0;
  static const double dailyFatGoal = 65.0;
  static const double dailyCarbGoal = 250.0;

  List<FoodEntry> get todayEntries => List.unmodifiable(_todayEntries);

  DailyNutrition get dailyNutrition {
    if (_todayEntries.isEmpty) return DailyNutrition();

    final today = DateTime.now();
    final todayEntries = _todayEntries
        .where(
          (entry) =>
              entry.timestamp.year == today.year &&
              entry.timestamp.month == today.month &&
              entry.timestamp.day == today.day,
        )
        .toList();

    int totalCalories = 0;
    double totalProtein = 0.0;
    double totalFat = 0.0;
    double totalCarbohydrates = 0.0;

    for (final entry in todayEntries) {
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
      mealCount: todayEntries.length,
    );
  }

  void addFoodEntry(FoodEntry entry) {
    _todayEntries.add(entry);
    notifyListeners();
  }

  void removeFoodEntry(int index) {
    if (index >= 0 && index < _todayEntries.length) {
      _todayEntries.removeAt(index);
      notifyListeners();
    }
  }

  void clearTodayEntries() {
    _todayEntries.clear();
    notifyListeners();
  }

  // Kalori hedefine ulaşma yüzdesi
  double get calorieProgress =>
      (dailyNutrition.totalCalories / dailyCalorieGoal).clamp(0.0, 1.0);

  // Protein hedefine ulaşma yüzdesi
  double get proteinProgress =>
      (dailyNutrition.totalProtein / dailyProteinGoal).clamp(0.0, 1.0);

  // Yağ hedefine ulaşma yüzdesi
  double get fatProgress =>
      (dailyNutrition.totalFat / dailyFatGoal).clamp(0.0, 1.0);

  // Karbonhidrat hedefine ulaşma yüzdesi
  double get carbProgress =>
      (dailyNutrition.totalCarbohydrates / dailyCarbGoal).clamp(0.0, 1.0);
}
