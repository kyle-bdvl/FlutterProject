import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/my_button.dart';
import 'package:flutter_application_1/widgets/my_textfiled.dart';
import 'package:flutter_application_1/widgets/square_tile.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String userType = 'Recipient';

  final List<String> userTypes = [
    'System Administrator',
    'Certificate Authority (CA)',
    'Recipient',
  ];

  void registerUser() {
    // Registration logic here
    // You can add validation and backend integration as needed
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
              mainAxisAlignment: MainAxisAlignment.center,
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
                MyButton(onTap: registerUser),
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
                const SizedBox(height: 50),
                // google sign up button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SquareTile(imagePath: 'lib/images/google.png'),
                  ],
                ),
                const SizedBox(height: 50),
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
