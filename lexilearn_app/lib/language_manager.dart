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

      'dashboard': 'Dashboard',
      'create_study': 'Create Study',
      'create_question': 'Create Question',
      'manage_questions': 'Manage My Questions',
      'settings': 'Settings',
      'logout': 'Logout',

      // Create Question Screen
      'create_question_title': 'Create Question',
      'select_category_domain': 'Select Category (Domain)',
      'select_category_hint': 'Select a Category',
      'which_study_add': 'Which Study to Add To?',
      'first_select_category': 'First select a category above',
      'select_study_hint': 'Select a Study',
      'question_type': 'Question Type',
      'multiple_choice': 'Multiple Choice',
      'true_false': 'True / False',
      'fill_in_blank': 'Fill in the Blank',
      'question_text_label': 'Question',
      'enter_question_text': 'Enter question text',
      'difficulty_level': 'Difficulty Level',
      'select_level': 'Select Level',
      'beginner': 'Beginner',
      'intermediate': 'Intermediate',
      'advanced': 'Advanced',
      'options': 'Options',
      'click_circle_correct': 'Click the circle next to the correct answer',
      'add_another_option': 'Add Another Option',
      'select_correct_answer': 'Select the Correct Answer:',
      'true_option': 'True',
      'false_option': 'False',
      'correct_answer_word': 'Correct Answer (Word/Phrase)',
      'students_type_exact': 'Students will need to type this exact word to pass.',
      'save_question': 'Save Question',
      'option_prefix': 'Option',
      
      // Study Quiz Screen
      'correct_exclamation': 'Correct! 🎉',
      'incorrect_answer': 'Incorrect. The right answer was: ',
      'study_complete': 'Study Complete! 🎓',
      'successfully_finished': 'You have successfully finished',
      'back_to_my_studies': 'Back to My Studies',
      'type_answer_here': 'Type your answer here...',
      'submit_answer': 'Submit Answer',
      'please_enter_answer': 'Please enter an answer first.',
      'no_questions_added': 'No questions added for this study yet.',
      'question_word': 'Question',
      'of_word': 'of',
      'coming_soon': 'Coming Soon',
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

      'dashboard': 'Kontrol Paneli',
      'create_study': 'Çalışma Oluştur',
      'create_question': 'Soru Oluştur',
      'manage_questions': 'Sorularımı Yönet',
      'settings': 'Ayarlar',
      'logout': 'Çıkış Yap',
    }
  };

  static String getText(String key) {
    return _translations[currentLang.value]?[key] ?? key;
  }
}
