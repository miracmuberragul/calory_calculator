// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // ⭐ DÜZELTME: GoogleSignIn nesnesini bu şekilde alıyoruz.
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Kullanıcının oturum durumunu dinleyen stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Mevcut kullanıcıyı al
  User? get currentUser => _auth.currentUser;

  // Email & Şifre ile Kayıt Olma
  Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }

  // Email & Şifre ile Giriş Yapma
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }

  // Çıkış Yapma
  Future<void> signOut() async {
    try {
      // ⭐ DÜZELTME: Çıkış yaparken de aynı nesneyi kullanıyoruz.
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print("Çıkış yaparken hata: $e");
    }
  }
}
