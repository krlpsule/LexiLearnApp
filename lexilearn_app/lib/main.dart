import 'package:flutter/material.dart';
import 'user_info_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true; // Toggles between Login and Sign Up
  String selectedRole = 'Student'; // Default role for sign up

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  void _submitForm() {
    // Task 1.2 & 1.3 Integration Point:
    // Here is where you will send data to your backend/database.
    if (isLogin) {
      print("Logging in with: ${_emailController.text}");
      // Execute SQL SELECT to verify user and fetch role
    } else {
      print(
        "Signing up as $selectedRole with username: ${_usernameController.text}",
      );
      // Execute SQL INSERT to create user with selectedRole
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(
        title: const Text('LexiLearn'),
        leading: IconButton(
          icon: const Icon(Icons.account_circle),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserInfoScreen()),
            );
          },
        ),
      ),
      body: const Center(
        child: Text('Welcome to LexiLearn!'),
      ),
=======
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Username field (Only visible on Sign Up)
            if (!isLogin)
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
            SizedBox(height: 10),

            // Email field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),

            // Password field
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 10),

            // Role selection (Only visible on Sign Up)
            if (!isLogin)
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(labelText: 'Role'),
                items: ['Student', 'Professor'].map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedRole = newValue!;
                  });
                },
              ),
            SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(isLogin ? 'Login' : 'Sign Up'),
            ),

            // Toggle Button
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                });
              },
              child: Text(
                isLogin
                    ? 'Create an account'
                    : 'Already have an account? Login',
              ),
            ),
          ],
        ),
      ),
>>>>>>> 3e096292baa3113ee99eaaaac542940026070fe4
    );
  }
}