import 'package:flutter/material.dart';
import 'language_manager.dart';
import 'user_manager.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;
  final String username;
  final String userRole;

  const DashboardScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.userRole,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLang,
      builder: (context, lang, child) {
        return SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 80,
                  ), // İkonun ekranda tam ortalanması için boşluk
                  const Icon(
                    Icons.school,
                    size: 100,
                    color: Colors.blue,
                  ), // İkonu biraz daha büyüttük
                  const SizedBox(height: 24),

                  // Anında isim güncelleyen yapı
                  ValueListenableBuilder<String>(
                    valueListenable: UserManager.currentUsername,
                    builder: (context, currentName, child) {
                      String displayName = currentName.isEmpty
                          ? widget.username
                          : currentName;

                      return Text(
                        '${LanguageManager.getText('welcome_back')}, $displayName!',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),

                  const SizedBox(height: 12),
                  Text(
                    '${LanguageManager.getText('role')}: ${LanguageManager.getText(widget.userRole.toLowerCase())}',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
