// lib/screens/login_screen.dart

import 'package:calori_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// TODO: Eğer profil oluşturma ekranınız varsa, import edin.
// import 'package:calori_app/screens/profile_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Sadece kayıt modunda görünecek şifre tekrar alanı için controller
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  // true: Giriş modu, false: Kayıt modu
  bool _isLoginMode = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Email/Şifre ile giriş veya kayıt işlemini yöneten fonksiyon
  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isLoginMode) {
        // --- Giriş Yapma Mantığı ---
        await authService.signInWithEmailAndPassword(email, password);
      } else {
        // --- Kayıt Olma Mantığı ---
        final userCredential = await authService.createUserWithEmailAndPassword(
          email,
          password,
        );

        // Kayıt başarılıysa, kullanıcıyı profil oluşturma ekranına yönlendir.
        if (mounted && userCredential != null) {
          // TODO: Kullanıcıyı profil bilgilerini (boy, kilo vb.) girmesi için
          // bir sonraki ekrana yönlendirin. Şimdilik AuthWrapper bu geçişi halledecek.
          // Navigator.of(context).pushReplacement(
          //   MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
          // );
        }
      }
    } on FirebaseAuthException catch (e) {
      // Firebase'den gelen özel hata mesajlarını kullanıcıya göster
      _showErrorSnackBar(
        e.message ?? 'Bilinmeyen bir kimlik doğrulama hatası oluştu.',
      );
    } catch (e) {
      _showErrorSnackBar('Beklenmedik bir hata oluştu: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: mediaQuery.size.height - mediaQuery.padding.top,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.food_bank_outlined,
                          size: 80,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Kalori Dedektifi',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLoginMode
                              ? 'Hesabınıza Giriş Yapın'
                              : 'Yeni Hesap Oluşturun',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 48),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'E-posta Adresi',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Lütfen geçerli bir e-posta adresi girin.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Şifre',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return 'Şifre en az 6 karakter olmalıdır.';
                            }
                            return null;
                          },
                        ),

                        // --- Sadece Kayıt Modunda Görünen Alan ---
                        if (!_isLoginMode)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: TextFormField(
                              controller: _confirmPasswordController,
                              decoration: const InputDecoration(
                                labelText: 'Şifreyi Onayla',
                                prefixIcon: Icon(Icons.lock_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return 'Şifreler eşleşmiyor.';
                                }
                                return null;
                              },
                            ),
                          ),

                        // ------------------------------------------
                        const SizedBox(height: 24),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _submit,
                                style: theme.elevatedButtonTheme.style
                                    ?.copyWith(
                                      padding: MaterialStateProperty.all(
                                        const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                      ),
                                    ),
                                child: Text(
                                  _isLoginMode ? 'Giriş Yap' : 'Kayıt Ol',
                                ),
                              ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            if (_isLoading) return;
                            setState(() {
                              _isLoginMode = !_isLoginMode;
                            });
                          },
                          child: Text(
                            _isLoginMode
                                ? 'Hesabınız yok mu? Kayıt Olun'
                                : 'Zaten bir hesabınız var mı? Giriş Yapın',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
