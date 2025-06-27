import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/my_button.dart';
import 'package:flutter_application_1/widgets/my_textfiled.dart';
import 'package:flutter_application_1/widgets/square_tile.dart';
import 'dart:async';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final upm_idController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String userType = 'Recipient';

  final List<String> userTypes = ['Certificate Authority (CA)', 'Recipient'];

  // Placeholder for checking username existence
  Future<bool> usernameExists(String username) async {
    // TODO: Replace with Firebase check later
    await Future.delayed(const Duration(milliseconds: 200));
    return false;
  }

  // Placeholder for checking UPM-ID existence
  Future<bool> upmIdExists(String upmId) async {
    // TODO: Replace with Firebase check later
    await Future.delayed(const Duration(milliseconds: 200));
    return false;
  }

  Future<void> registerUser() async {
    final username = usernameController.text.trim();
    final upmId = upm_idController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (username.isEmpty ||
        upmId.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Minimum password length check
    if (password.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 5 characters long'),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    if (await usernameExists(username)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Username already exists')));
      return;
    }

    if (await upmIdExists(upmId)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('UPM-ID already exists')));
      return;
    }

    // Registration logic here (add Firebase logic later)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Registered as $userType')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.start, // <-- changed from center to start
              children: [
                const SizedBox(height: 50),
                const Icon(Icons.person_add, size: 100),
                const SizedBox(height: 50),
                Text(
                  'Create your account',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
                const SizedBox(height: 25),
                // Username
                MyTextField(
                  controller: usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                // Matrics ID
                MyTextField(
                  controller: upm_idController,
                  hintText: 'UPM-ID',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                // Password
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                // Confirm Password
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                // User Type Dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: DropdownButtonFormField<String>(
                    value: userType,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color.fromARGB(255, 183, 206, 255),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor: const Color.fromARGB(255, 183, 206, 255),
                    items:
                        userTypes
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        userType = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 25),
                MyButton(onTap: registerUser, text: "Register"),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // google sign up button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SquareTile(imagePath: 'lib/images/google.png'),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
