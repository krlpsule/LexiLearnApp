import 'package:flutter/material.dart';
import 'navigation_drawer.dart';
import 'clickable_username.dart';
import 'dashboard_screen.dart';
import 'my_studies_screen.dart';
import 'create_course_screen.dart';
import 'create_question_screen.dart';
import 'user_info_screen.dart';

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
      home: const MainScreen(
        username: 'John Doe',
        userRole: 'Student',
        userId: 1,
      ),
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
    return Scaffold(
      // App Bar with clickable username (Task 3.2)
      appBar: AppBar(
        title: const Text('LexiLearn'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          ClickableUsername(
            username: widget.username,
            userRole: widget.userRole,
          ),
        ],
      ),
      
      // Sidebar drawer (Task 3.1)
      drawer: NavigationDrawer(
        username: widget.username,
        userRole: widget.userRole,
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      
      // Body changes based on selected menu
      body: _selectedIndex == 0
          ? DashboardScreen(
              username: widget.username,
              userRole: widget.userRole,
            )
          : _selectedIndex == 1
              ? MyStudiesScreen(userId: widget.userId)
              : _selectedIndex == 2 && widget.userRole == "Professor"
                  ? const CreateCourseScreen()
                  : _selectedIndex == 3 && widget.userRole == "Professor"
                      ? const CreateQuestionScreen()
                      : const Center(
                          child: Text(
                            'Coming Soon',
                            style: TextStyle(fontSize: 24, color: Colors.grey),
                          ),
                        ),
    );
  }
}
