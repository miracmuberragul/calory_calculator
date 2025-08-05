import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Kullanıcı verilerini (boy, kilo vb.) kaydet veya güncelle
  Future<void> saveUserData({
    required String uid,
    required String email,
    required double height,
    required double weight,
    required double targetWeight,
  }) async {
    try {
      await _db.collection('users').doc(uid).set(
        {
          'email': email,
          'height_cm': height,
          'current_weight_kg': weight,
          'target_weight_kg': targetWeight,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      ); // merge:true, var olan veriyi silmeden üzerine yazar.
    } catch (e) {
      print(e.toString());
    }
  }

  // Kullanıcı verilerini çek
  Future<DocumentSnapshot?> getUserData(String uid) async {
    try {
      return await _db.collection('users').doc(uid).get();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // ⭐ YEMEK GİRDİSİNİ KULLANICIYA ÖZEL KAYDETME
  // Bu fonksiyonu home_screen.dart içindeki _addToTracking'de kullanacağız.
  Future<void> addFoodEntryForUser(
    String uid,
    Map<String, dynamic> foodData,
  ) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('food_entries')
          .add(foodData);
    } catch (e) {
      print(e.toString());
    }
  }
}
