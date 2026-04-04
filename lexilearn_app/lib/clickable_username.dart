import 'package:flutter/material.dart';

class ClickableUsername extends StatelessWidget {
  final String username;
  final String userRole;
  
  const ClickableUsername({
    super.key,
    required this.username,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to User Info Screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hello, $username!')),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Row(
          children: [
            const Icon(Icons.account_circle),
            const SizedBox(width: 8),
            Text(
              username,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}
