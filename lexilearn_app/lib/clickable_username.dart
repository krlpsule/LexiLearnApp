import 'package:flutter/material.dart';
import 'user_info_screen.dart';
import 'user_manager.dart'; 

class ClickableUsername extends StatelessWidget {
  final int userId;
  final String username; 
  final String userRole;

  const ClickableUsername({
    super.key,
    required this.userId,
    required this.username,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
   
    if (UserManager.currentUsername.value.isEmpty) {
      UserManager.currentUsername.value = username;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserInfoScreen(userId: userId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Row(
          children: [
            const Icon(Icons.account_circle),
            const SizedBox(width: 8),
          
            ValueListenableBuilder<String>(
              valueListenable: UserManager.currentUsername,
              builder: (context, currentName, child) {
                return Text(
                  currentName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}