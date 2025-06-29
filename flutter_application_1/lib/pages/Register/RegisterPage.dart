import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_application_1/widgets/my_button.dart';
import 'package:flutter_application_1/widgets/my_textfiled.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController         = TextEditingController();
  final emailOrUpmIdController     = TextEditingController();
  final passwordController         = TextEditingController();
  final confirmPasswordController  = TextEditingController();
  String userType = 'Recipient';
  final List<String> userTypes = [
    'Certificate Authority (CA)',
    'Recipient',
  ];
  bool isLoading = false;

  Future<void> registerUser() async {
    final username       = usernameController.text.trim();
    final emailOrUpmId   = emailOrUpmIdController.text.trim();
    final password       = passwordController.text;
    final confirmPass    = confirmPasswordController.text;

    if ([username, emailOrUpmId, password, confirmPass]
        .any((e) => e.isEmpty)) {
      showMessage('Please fill in all fields');
      return;
    }

    // UPM-ID → student email fallback
    String email;
    String upmId = '';
    if (RegExp(r'^[a-zA-Z0-9.]+$')
        .hasMatch(emailOrUpmId) &&
        !emailOrUpmId.contains('@')) {
      upmId = emailOrUpmId;
      email = '$upmId@student.upm.edu.my';
    } else {
      email = emailOrUpmId;
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        showMessage('Please enter a valid email address');
        return;
      }
    }

    if (password.length < 8 ||
        !password.contains(RegExp(r'[A-Z]')) ||
        !password.contains(RegExp(r'[a-z]')) ||
        !password.contains(RegExp(r'[!@#\$&*~]'))) {
      showMessage(
        'Password must be at least 8 chars with upper, lower & special',
      );
      return;
    }
    if (password != confirmPass) {
      showMessage('Passwords do not match');
      return;
    }

    setState(() => isLoading = true);
    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'username': username,
        'upmId': upmId,
        'email': email,
        'originalInput': emailOrUpmId,
        'userType': userType,
        'createdAt': FieldValue.serverTimestamp(),
      });

      showMessage('Registered successfully as $userType');
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showMessage('This email is already registered');
      } else {
        showMessage(e.message ?? 'Registration failed');
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailOrUpmIdController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(Icons.person_add, size: 80),
                const SizedBox(height: 20),
                Text(
                  'Create your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),

                // — Username
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: MyTextField(
                    controller: usernameController,
                    hintText: 'Username',
                    obscureText: false,
                  ),
                ),
                const SizedBox(height: 10),

                // — UPM-ID or Email
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: MyTextField(
                    controller: emailOrUpmIdController,
                    hintText: 'UPM-ID or Email',
                    obscureText: false,
                    onChanged: (v) {
                      final t = v.trim();
                      if (v != t) {
                        emailOrUpmIdController.value =
                            emailOrUpmIdController.value.copyWith(
                              text: t,
                              selection:
                              TextSelection.collapsed(offset: t.length),
                            );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // — Password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 10),

                // — Confirm Password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: MyTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 10),

                // — User Type dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: SizedBox(
                    height: 60,
                    child: DropdownButtonFormField<String>(
                      value: userType,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                        const Color.fromARGB(255, 183, 206, 255),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                      ),
                      dropdownColor:
                      const Color.fromARGB(255, 183, 206, 255),
                      items: userTypes
                          .map(
                            (t) => DropdownMenuItem(
                          value: t,
                          child: Text(t),
                        ),
                      )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => userType = v!),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // — Register button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: isLoading
                      ? const Center(
                    child: CircularProgressIndicator(),
                  )
                      : MyButton(
                    onTap: registerUser,
                    text: 'Register',
                  ),
                ),

                const SizedBox(height: 20),

                // — Already have an account?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
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

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
