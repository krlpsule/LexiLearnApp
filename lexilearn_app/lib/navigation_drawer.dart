import 'package:flutter/material.dart';
import 'login_screen.dart';

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
                  userRole,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Menu Item 1: Dashboard 
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            tileColor: selectedIndex == 0 ? Colors.blue.shade50 : null,
            onTap: () {
              onItemSelected(0);
              Navigator.pop(context);
            },
          ),

          // Menu Item 2: My Studies 
          if (userRole == "Student")
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('My Studies'),
              tileColor: selectedIndex == 1 ? Colors.blue.shade50 : null,
              onTap: () {
                onItemSelected(1);
                Navigator.pop(context);
              },
            ),

          // Menu Item 3: Create Study 
          if (userRole == "Professor")
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text('Create Study'),
              tileColor: selectedIndex == 2 ? Colors.blue.shade50 : null,
              onTap: () {
                onItemSelected(2);
                Navigator.pop(context);
              },
            ),
            
          // Menu Item 4: Create Question 
          if (userRole == "Professor")
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('Create Question'),
              tileColor: selectedIndex == 3 ? Colors.blue.shade50 : null,
              onTap: () {
                onItemSelected(3);
                Navigator.pop(context);
              },
            ),
          const Divider(),

          // Menu Item 5: Settings 
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          // Menu Item 6: Logout 
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
