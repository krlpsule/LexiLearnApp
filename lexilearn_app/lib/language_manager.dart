import 'package:flutter/material.dart';

class LanguageManager {
  // Global state for the language. Defaults to English ('en')
  static final ValueNotifier<String> currentLang = ValueNotifier('en');

  static final Map<String, Map<String, String>> _translations = {
    'en': {
      'login': 'Login',
      'signup': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'username': 'Username',
      'student': 'Student',
      'professor': 'Professor',
      'login_success': 'Login Successful!',
      'register_success': 'Registration Successful!',
      'switch_to_signup': 'Don\'t have an account? Sign Up',
      'switch_to_login': 'Already have an account? Login',
    },
    'tr': {
      'login': 'Giriş Yap',
      'signup': 'Kayıt Ol',
      'email': 'E-posta',
      'password': 'Şifre',
      'username': 'Kullanıcı Adı',
      'student': 'Öğrenci',
      'professor': 'Profesör',
      'login_success': 'Giriş Başarılı!',
      'register_success': 'Kayıt Başarılı!',
      'switch_to_signup': 'Hesabınız yok mu? Kayıt Ol',
      'switch_to_login': 'Zaten hesabınız var mı? Giriş Yap',
    }
  };

  static String getText(String key) {
    return _translations[currentLang.value]?[key] ?? key;
  }
}