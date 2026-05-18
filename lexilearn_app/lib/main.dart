import 'package:flutter/material.dart' hide NavigationDrawer;
import 'navigation_drawer.dart';
import 'clickable_username.dart';
import 'dashboard_screen.dart';
import 'my_studies_screen.dart';
import 'create_course_screen.dart';
import 'create_question_screen.dart';
import 'user_info_screen.dart';
import 'login_screen.dart';
import 'language_manager.dart';
import 'language_slider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LexiLearn',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  final String username;
  final String userRole;
  final int userId;

  const MainScreen({
    super.key,
    required this.username,
    required this.userRole,
    required this.userId,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

 @override
  Widget build(BuildContext context) {
    // Tüm ana iskeleti ValueListenableBuilder içine alıyoruz
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLang,
      builder: (context, lang, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('LexiLearn'),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            actions: [
              // Language Slider'ı her sayfada üst menüye yerleştiriyoruz
              const Center(child: LanguageSlider()),
              const SizedBox(width: 8),
              ClickableUsername(
                userId: widget.userId,
                username: widget.username,
                userRole: widget.userRole,
              ),
              const SizedBox(width: 8),
            ],
          ),
          drawer: NavigationDrawer(
            userId: widget.userId,
            username: widget.username,
            userRole: widget.userRole,
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          body: _getBody(),
        );
      }
    );
  }

  Widget _getBody() {
    if (widget.userRole == "Professor") {
      if (_selectedIndex == 1) {
        _selectedIndex = 0;
      }
      switch (_selectedIndex) {
        case 0:
          return DashboardScreen(
            userId: widget.userId,
            username: widget.username,
            userRole: widget.userRole,
          );
        case 2:
          return const CreateCourseScreen();
        case 3:
          return const CreateQuestionScreen();
        default:
          return Center(
            child: Text(
              LanguageManager.getText('coming_soon'),
              style: const TextStyle(fontSize: 24, color: Colors.grey),
            ),
          );
      }
    }

    switch (_selectedIndex) {
      case 0:
        return DashboardScreen(
          userId: widget.userId,
          username: widget.username,
          userRole: widget.userRole,
        );
      case 1:
        return MyStudiesScreen(userId: widget.userId);
      default:
        return Center(
          child: Text(
            LanguageManager.getText('coming_soon'),
            style: const TextStyle(fontSize: 24, color: Colors.grey),
          ),
        );
    }
  }
}
