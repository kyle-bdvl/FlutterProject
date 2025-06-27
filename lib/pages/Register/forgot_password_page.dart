import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/my_button.dart';
import 'package:flutter_application_1/widgets/my_textfiled.dart';
import 'package:flutter_application_1/constants/route_names.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  String errorText = '';

  void sendOtp() {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() => errorText = 'Email is required.');
      return;
    }

    if (!email.endsWith('@student.upm.edu.my')) {
      setState(() => errorText = 'Email must be a valid @student.upm.edu.my address.');
      return;
    }

    setState(() => errorText = '');

    Navigator.pushReplacementNamed(
      context,
      routeVerifyOtp,
      arguments: {'email': email},
    );
  }

  void goBackToLogin() => Navigator.pushReplacementNamed(context, routeLogin);

  @override
  void dispose() {
    emailController.dispose();
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
          onPressed: goBackToLogin,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: ListView(
            children: [
              const SizedBox(height: 120),
              const Icon(Icons.email, size: 100),
              const SizedBox(height: 40),
              Text(
                'Enter your email to receive an OTP',
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              MyTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),
              if (errorText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    errorText,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 25),
              MyButton(text: 'Send Verification Code', onTap: sendOtp),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
