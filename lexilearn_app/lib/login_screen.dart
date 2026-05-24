import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart'; // Added to access MainScreen
import 'language_manager.dart'; // Import the manager
import 'language_slider.dart';  // Import the slider

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  String selectedRole = 'Student';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  // If using an Android Emulator, use 10.0.2.2 instead of localhost
  final String backendUrl = 'http://10.0.2.2:8080';

  Future<void> _submitForm() async {
    final String endpoint = isLogin ? '/login' : '/register';
    final Uri url = Uri.parse('$backendUrl$endpoint');

    Map<String, dynamic> requestBody = isLogin
        ? {
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
          }
        : {
            'username': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
            'role': selectedRole, // Captures 'Student' or 'Professor'
          };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${isLogin ? "Login" : "Registration"} Successful!',
              ),
            ),
          );

          if (isLogin) {
            int dynamicUserId = responseData['userId'];
            String dynamicUsername = responseData['username'];
            String dynamicRole = responseData['role'];

            // Success: Handle navigation to the main application page here
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainScreen(
                  userId: dynamicUserId,
                  username: dynamicUsername,
                  userRole: dynamicRole,
                ),
              ),
            );
          } else {
            // Registration successful, return to login mode
            setState(() {
              isLogin = true;
            });
          }
        } else {
          // Failure: Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${responseData['error'] ?? 'Invalid credentials'}',
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to the server: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the Scaffold in a ValueListenableBuilder so it updates instantly
    return ValueListenableBuilder<String>(
      valueListenable: LanguageManager.currentLang,
      builder: (context, lang, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(isLogin 
                ? LanguageManager.getText('login') 
                : LanguageManager.getText('signup')),
            centerTitle: true,
            actions: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(child: LanguageSlider()), // Place the slider here
              )
            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isLogin)
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: LanguageManager.getText('username'), // Translated text
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  if (!isLogin) const SizedBox(height: 16),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: LanguageManager.getText('email'), // Translated text
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: LanguageManager.getText('password'), // Translated text
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (!isLogin)
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: ['Student', 'Professor']
                          .map((role) => DropdownMenuItem(
                                value: role,
                                // Translate the role dropdown values visually
                                child: Text(LanguageManager.getText(role.toLowerCase())),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                    ),
                  if (!isLogin) const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(isLogin 
                        ? LanguageManager.getText('login') 
                        : LanguageManager.getText('signup')),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                      });
                    },
                    child: Text(isLogin
                        ? LanguageManager.getText('switch_to_signup')
                        : LanguageManager.getText('switch_to_login')),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
  

