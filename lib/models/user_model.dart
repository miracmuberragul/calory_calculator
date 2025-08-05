// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName; // Google'dan gelebilir, o yüzden nullable
  final double? height; // Boy (cm)
  final double? weight; // Kilo (kg)
  final double? targetWeight; // Hedef Kilo (kg)

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.height,
    this.weight,
    this.targetWeight,
  });

  // Firestore'dan gelen DocumentSnapshot'ı UserModel nesnesine dönüştüren factory metodu
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      height: (data['height_cm'] as num?)?.toDouble(),
      weight: (data['current_weight_kg'] as num?)?.toDouble(),
      targetWeight: (data['target_weight_kg'] as num?)?.toDouble(),
    );
  }

  // UserModel nesnesini Firestore'a yazmak için Map'e dönüştüren metot
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      if (displayName != null) 'displayName': displayName,
      if (height != null) 'height_cm': height,
      if (weight != null) 'current_weight_kg': weight,
      if (targetWeight != null) 'target_weight_kg': targetWeight,
    };
  }
}
