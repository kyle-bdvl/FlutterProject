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
      setState(() {
        errorText = 'Email is required.';
      });
      return;
    }

    if (!email.endsWith('@student.upm.edu.my')) {
      setState(() {
        errorText = 'Email must be a valid @student.upm.edu.my address.';
      });
      return;
    }

    // Clear any previous error and continue
    setState(() {
      errorText = '';
    });

    Navigator.pushReplacementNamed(context, routeVerifyOtp);
  }

  void goBackToLogin() {
    Navigator.pushReplacementNamed(context, routeLogin);
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // email icon
                const Icon(Icons.email, size: 100),

                const SizedBox(height: 50),

                // instruction text
                Text(
                  'Enter your email to receive an OTP',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),

                const SizedBox(height: 25),

                // email text field
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                // error text
                if (errorText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      errorText,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                const SizedBox(height: 25),

                // send button
                MyButton(text: 'Send Verification Code', onTap: sendOtp),

                const SizedBox(height: 20),

                // ← Back to Login
                GestureDetector(
                  onTap: goBackToLogin,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.arrow_back,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Back to Login',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
