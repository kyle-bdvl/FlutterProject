import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/my_button.dart';
import 'package:flutter_application_1/widgets/my_textfield.dart';
import 'package:flutter_application_1/constants/route_names.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String errorText = '';

  void resetPassword() {
    final password = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Validation checks
    if (password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        errorText = 'Please fill in both password fields.';
      });
      return;
    }

    if (password.length < 8) {
      setState(() {
        errorText = 'Password must be at least 8 characters long.';
      });
      return;
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      setState(() {
        errorText = 'Password must contain an uppercase letter.';
      });
      return;
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      setState(() {
        errorText = 'Password must contain a lowercase letter.';
      });
      return;
    }

    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      setState(() {
        errorText = 'Password must include a special character.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        errorText = 'Passwords do not match.';
      });
      return;
    }

    // Success
    setState(() {
      errorText = ''; // Clear error
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password has been reset successfully.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushNamedAndRemoveUntil(context, routeLogin, (route) => false);
    });
  }

  void goBackToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, routeLogin);
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
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
                const Icon(Icons.lock_reset, size: 100),
                const SizedBox(height: 50),
                Text(
                  'Reset your password',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: newPasswordController,
                  hintText: 'New Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                if (errorText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      errorText,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 25),
                MyButton(text: 'Reset Password', onTap: resetPassword),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => goBackToLogin(context),
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
