// lib/services/firestore_service.dart

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:calori_app/services/daily_tracking_service.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcı ID'sini al
  static String? get _userId => _auth.currentUser?.uid;

  // Yemek verisini Firestore'a kaydet
  static Future<bool> saveFoodEntry(FoodEntry foodEntry) async {
    try {
      if (_userId == null) {
        print('Kullanıcı oturum açmamış');
        return false;
      }

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('food_entries')
          .add({
            'foodName': foodEntry.foodName,
            'calories': foodEntry.calories,
            'protein': foodEntry.protein,
            'fat': foodEntry.fat,
            'carbohydrates': foodEntry.carbohydrates,
            'timestamp': foodEntry.timestamp,
            'imageUrl': foodEntry.imageUrl,
            'date': _formatDate(foodEntry.timestamp), // Günlük filtreleme için
          });

      print('Yemek verisi Firestore\'a kaydedildi: ${foodEntry.foodName}');
      return true;
    } catch (e) {
      print('Firestore kaydetme hatası: $e');
      return false;
    }
  }

  // Belirli bir günün yemek verilerini getir
  static Future<List<FoodEntry>> getTodayFoodEntries() async {
    try {
      if (_userId == null) {
        print('Kullanıcı oturum açmamış');
        return [];
      }

      final today = _formatDate(DateTime.now());

      final querySnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('food_entries')
          .where('date', isEqualTo: today)
          .orderBy('timestamp', descending: false)
          .get();

      log('Bugünkü yemek verileri alındı: ${querySnapshot.docs.length} kayıt');

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return FoodEntry(
          id: doc.id, // Firestore'dan gelen benzersiz ID
          foodName: data['foodName'] ?? 'Bilinmiyor',
          calories: data['calories'] ?? 0,
          protein: (data['protein'] ?? 0.0).toDouble(),
          fat: (data['fat'] ?? 0.0).toDouble(),
          carbohydrates: (data['carbohydrates'] ?? 0.0).toDouble(),
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          imageUrl: data['imageUrl'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Firestore veri çekme hatası: $e');
      return [];
    }
  }

  // Belirli bir tarih aralığındaki verileri getir
  static Future<List<FoodEntry>> getFoodEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (_userId == null) {
        print('Kullanıcı oturum açmamış');
        return [];
      }

      final querySnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('food_entries')
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .where('timestamp', isLessThanOrEqualTo: endDate)
          .orderBy('timestamp', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return FoodEntry(
          id: doc.id, // Firestore'dan gelen benzersiz ID
          foodName: data['foodName'] ?? 'Bilinmiyor',
          calories: data['calories'] ?? 0,
          protein: (data['protein'] ?? 0.0).toDouble(),
          fat: (data['fat'] ?? 0.0).toDouble(),
          carbohydrates: (data['carbohydrates'] ?? 0.0).toDouble(),
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          imageUrl: data['imageUrl'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Firestore tarih aralığı veri çekme hatası: $e');
      return [];
    }
  }

  // Yemek verisini sil
  static Future<bool> deleteFoodEntry(String documentId) async {
    try {
      if (_userId == null) {
        print('Kullanıcı oturum açmamış');
        return false;
      }

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('food_entries')
          .doc(documentId)
          .delete();

      print('Yemek verisi silindi: $documentId');
      return true;
    } catch (e) {
      print('Firestore silme hatası: $e');
      return false;
    }
  }

  // Kullanıcının tüm yemek verilerini getir (sayfalama ile)
  static Future<List<FoodEntry>> getAllFoodEntries({
    int limit = 50,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      if (_userId == null) {
        print('Kullanıcı oturum açmamış');
        return [];
      }

      Query query = _firestore
          .collection('users')
          .doc(_userId)
          .collection('food_entries')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return FoodEntry(
          id: doc.id, // Firestore'dan gelen benzersiz ID
          foodName: data['foodName'] ?? 'Bilinmiyor',
          calories: data['calories'] ?? 0,
          protein: (data['protein'] ?? 0.0).toDouble(),
          fat: (data['fat'] ?? 0.0).toDouble(),
          carbohydrates: (data['carbohydrates'] ?? 0.0).toDouble(),
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          imageUrl: data['imageUrl'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Firestore tüm veriler çekme hatası: $e');
      return [];
    }
  }

  // Günlük istatistikleri getir
  static Future<Map<String, dynamic>> getDailyStats(DateTime date) async {
    try {
      if (_userId == null) {
        return {
          'totalCalories': 0,
          'totalProtein': 0.0,
          'totalFat': 0.0,
          'totalCarbohydrates': 0.0,
          'mealCount': 0,
        };
      }

      final dateString = _formatDate(date);

      final querySnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('food_entries')
          .where('date', isEqualTo: dateString)
          .get();

      int totalCalories = 0;
      double totalProtein = 0.0;
      double totalFat = 0.0;
      double totalCarbohydrates = 0.0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        totalCalories += (data['calories'] ?? 0) as int;
        totalProtein += (data['protein'] ?? 0.0).toDouble();
        totalFat += (data['fat'] ?? 0.0).toDouble();
        totalCarbohydrates += (data['carbohydrates'] ?? 0.0).toDouble();
      }

      return {
        'totalCalories': totalCalories,
        'totalProtein': totalProtein,
        'totalFat': totalFat,
        'totalCarbohydrates': totalCarbohydrates,
        'mealCount': querySnapshot.docs.length,
      };
    } catch (e) {
      print('Günlük istatistik hesaplama hatası: $e');
      return {
        'totalCalories': 0,
        'totalProtein': 0.0,
        'totalFat': 0.0,
        'totalCarbohydrates': 0.0,
        'mealCount': 0,
      };
    }
  }

  // Real-time dinleyici - bugünkü veriler için
  static Stream<List<FoodEntry>> getTodayFoodEntriesStream() {
    if (_userId == null) {
      return Stream.value([]);
    }

    final today = _formatDate(DateTime.now());

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('food_entries')
        .where('date', isEqualTo: today)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return FoodEntry(
              id: doc.id, // Firestore'dan gelen benzersiz ID
              foodName: data['foodName'] ?? 'Bilinmiyor',
              calories: data['calories'] ?? 0,
              protein: (data['protein'] ?? 0.0).toDouble(),
              fat: (data['fat'] ?? 0.0).toDouble(),
              carbohydrates: (data['carbohydrates'] ?? 0.0).toDouble(),
              timestamp: (data['timestamp'] as Timestamp).toDate(),
              imageUrl: data['imageUrl'] ?? '',
            );
          }).toList();
        });
  }

  // Yardımcı fonksiyon - tarihi string formatına çevir
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Kullanıcı profili oluştur/güncelle
  static Future<bool> createOrUpdateUserProfile({
    required String name,
    required String email,
    int? dailyCalorieGoal,
    double? dailyProteinGoal,
    double? dailyFatGoal,
    double? dailyCarbGoal,
  }) async {
    try {
      if (_userId == null) {
        print('Kullanıcı oturum açmamış');
        return false;
      }

      await _firestore.collection('users').doc(_userId).set({
        'name': name,
        'email': email,
        'dailyCalorieGoal': dailyCalorieGoal ?? 2000,
        'dailyProteinGoal': dailyProteinGoal ?? 150.0,
        'dailyFatGoal': dailyFatGoal ?? 65.0,
        'dailyCarbGoal': dailyCarbGoal ?? 250.0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('Kullanıcı profili kaydedildi/güncellendi');
      return true;
    } catch (e) {
      print('Kullanıcı profili kaydetme hatası: $e');
      return false;
    }
  }

  // Kullanıcı profilini getir
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (_userId == null) {
        print('Kullanıcı oturum açmamış');
        return null;
      }

      final doc = await _firestore.collection('users').doc(_userId).get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Kullanıcı profili getirme hatası: $e');
      return null;
    }
  }

  Future<void> updateUserProfileData({
    required String uid,
    required double height,
    required double weight,
    required double targetWeight,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'height': height,
        'weight': weight,
        'targetWeight': targetWeight,
      });
      print('Profil verileri güncellendi');
    } catch (e) {
      print('Profil verileri güncelleme hatası: $e');
      throw e; // Hata fırlat
    }
  }
}
