import 'package:flutter/material.dart';

class LanguageManager {
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
      
      // Dashboard Translations
      'welcome_back': 'Welcome back',
      'role': 'Role',
      'quizzes_created_part1': 'You have created',
      'quizzes_created_part2': 'quiz(zes).',
      'no_studies_created': 'You haven\'t created any studies yet.',
      'students_took_quiz': 'student(s) took your quiz.',
      'avg_success_rate': 'Average success rate:',
      'add_question_btn': 'Wanna add question to that quiz?',
      'student_stats_coming': 'Student statistics coming soon...',
      
      // My Studies Translations
      'my_studies': 'My Studies',
      'ongoing': 'Ongoing',
      'available': 'Available',
      'error': 'Error:',
      'retry': 'Retry',
      'no_ongoing_studies': 'No ongoing studies',
      'start_new_study': 'Start a new study from the Available tab',
      'no_available_studies': 'No available studies',
      'check_back_later': 'Check back later for new content!',
      'complete': 'complete',
      'start_btn': 'Start',
      'study_start_success': 'Study started successfully!',
      'study_start_fail': 'Failed to start study.'
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
      
      // Dashboard Translations
      'welcome_back': 'Tekrar hoş geldin',
      'role': 'Rol',
      'quizzes_created_part1': 'Toplam',
      'quizzes_created_part2': 'adet test oluşturdunuz.',
      'no_studies_created': 'Henüz hiç çalışma oluşturmadınız.',
      'students_took_quiz': 'öğrenci testinizi çözdü.',
      'avg_success_rate': 'Ortalama başarı oranı:',
      'add_question_btn': 'Bu teste soru eklemek ister misiniz?',
      'student_stats_coming': 'Öğrenci istatistikleri yakında eklenecek...',
      
      // My Studies Translations
      'my_studies': 'Çalışmalarım',
      'ongoing': 'Devam Eden',
      'available': 'Mevcut',
      'error': 'Hata:',
      'retry': 'Tekrar Dene',
      'no_ongoing_studies': 'Devam eden çalışma yok',
      'start_new_study': 'Mevcut sekmesinden yeni bir çalışmaya başla',
      'no_available_studies': 'Mevcut çalışma yok',
      'check_back_later': 'Yeni içerikler için daha sonra tekrar kontrol et!',
      'complete': 'tamamlandı',
      'start_btn': 'Başla',
      'study_start_success': 'Çalışma başarıyla başlatıldı!',
      'study_start_fail': 'Çalışma başlatılamadı.'
    }
  };

  static String getText(String key) {
    return _translations[currentLang.value]?[key] ?? key;
  }
}
