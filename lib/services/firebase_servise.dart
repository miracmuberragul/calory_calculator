// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calori_app/models/user_model.dart'; // Yeni modelimizi import ediyoruz

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // users koleksiyonuna referans
  late final CollectionReference<UserModel> _usersRef;

  FirestoreService() {
    // Firestore'a veri yazıp okurken UserModel'i otomatik dönüştürmek için
    // withConverter kullanıyoruz. Bu, kodu çok daha temiz hale getirir.
    _usersRef = _db
        .collection('users')
        .withConverter<UserModel>(
          fromFirestore: (snapshot, _) => UserModel.fromFirestore(snapshot),
          toFirestore: (user, _) => user.toFirestore(),
        );
  }

  // Yeni kullanıcı oluşturma veya mevcut kullanıcı verilerini güncelleme
  Future<void> setUserData(UserModel user) async {
    try {
      // .set() metodu, eğer doküman varsa üzerine yazar, yoksa oluşturur.
      // SetOptions(merge: true) sayesinde sadece gönderdiğimiz alanları günceller,
      // diğerlerini silmez.
      await _usersRef.doc(user.uid).set(user, SetOptions(merge: true));
    } catch (e) {
      print("Firestore kullanıcı verisi kaydetme hatası: $e");
      rethrow; // Hatanın UI katmanında da yakalanabilmesi için yeniden fırlat
    }
  }

  // Belirli bir kullanıcının verisini UserModel olarak çekme
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _usersRef.doc(uid).get();
      return doc.data(); // withConverter sayesinde bu direkt UserModel döner
    } catch (e) {
      print("Firestore kullanıcı verisi okuma hatası: $e");
      return null;
    }
  }

  Future<void> createUserDocument(String uid, String email) async {
    try {
      // Yeni kullanıcı için sadece email ve uid içeren bir doküman oluştur.
      // merge: false olmalı ki yanlışlıkla üzerine yazmasın.
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Kullanıcı dokümanı oluşturma hatası: $e");
      rethrow;
    }
  }

  // Kullanıcının profil bilgilerini (boy, kilo vb.) güncelleme
  Future<void> updateUserProfileData({
    required String uid,
    String? email, // email'i de eklemek iyi bir pratik
    required double height,
    required double weight,
    required double targetWeight,
  }) async {
    try {
      // .set() metodu, doküman yoksa oluşturur, varsa SetOptions(merge: true)
      // sayesinde sadece belirtilen alanları günceller.
      await _db.collection('users').doc(uid).set({
        'height_cm': height,
        'current_weight_kg': weight,
        'target_weight_kg': targetWeight,
        if (email != null)
          'email': email, // Eğer email gönderilmişse onu da ekle
      }, SetOptions(merge: true));
    } catch (e) {
      print("Profil güncelleme/kaydetme hatası: $e");
      rethrow;
    }
  }

  // Yemeği belirli bir kullanıcının altına kaydetme (mevcut fonksiyon)
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
      print("Yemek girdisi ekleme hatası: $e");
    }
  }
}
