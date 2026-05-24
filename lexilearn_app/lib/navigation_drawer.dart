import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'manage_questions_screen.dart';
import 'language_manager.dart'; // Added Import

class NavigationDrawer extends StatelessWidget {
  final int userId;
  final String username;
  final String userRole;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const NavigationDrawer({
    super.key,
    required this.userId,
    required this.username,
    required this.userRole,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    // ADDED: ValueListenableBuilder watches for language changes
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLang,
      builder: (context, lang, child) {
        return Drawer(
          child: Column(
            children: [
              // Drawer Header
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.blue),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      // Dynamically translate the user role
                      LanguageManager.getText(userRole.toLowerCase()),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Menu Item 1: Dashboard
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: Text(LanguageManager.getText('dashboard')),
                tileColor: selectedIndex == 0 ? Colors.blue.shade50 : null,
                onTap: () {
                  onItemSelected(0);
                  Navigator.pop(context);
                },
              ),

              // Menu Item 2: My Studies (Student Only)
              if (userRole == "Student")
                ListTile(
                  leading: const Icon(Icons.book),
                  title: Text(LanguageManager.getText('my_studies')),
                  tileColor: selectedIndex == 1 ? Colors.blue.shade50 : null,
                  onTap: () {
                    onItemSelected(1);
                    Navigator.pop(context);
                  },
                ),

              // Menu Item 3: Create Study (Professor Only)
              if (userRole == "Professor")
                ListTile(
                  leading: const Icon(Icons.add_circle),
                  title: Text(LanguageManager.getText('create_study')),
                  tileColor: selectedIndex == 2 ? Colors.blue.shade50 : null,
                  onTap: () {
                    onItemSelected(2);
                    Navigator.pop(context);
                  },
                ),

              // Menu Item 4: Create Question (Professor Only)
              if (userRole == "Professor")
                ListTile(
                  leading: const Icon(Icons.quiz),
                  title: Text(LanguageManager.getText('create_question')),
                  tileColor: selectedIndex == 3 ? Colors.blue.shade50 : null,
                  onTap: () {
                    onItemSelected(3);
                    Navigator.pop(context);
                  },
                ),

              // Menu Item: Manage Questions (Professor Only)
              if (userRole == "Professor")
                ListTile(
                  leading: const Icon(Icons.edit_note, color: Colors.blue),
                  title: Text(
                    LanguageManager.getText('manage_questions'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ManageQuestionsScreen(userId: userId),
                      ),
                    );
                  },
                ),

              const Divider(),

              // Menu Item 5: Settings
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text(LanguageManager.getText('settings')),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              // Menu Item 6: Logout
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(LanguageManager.getText('logout')),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
