import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/my_button.dart';
import 'package:flutter_application_1/widgets/my_textfiled.dart';
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
  late String email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    email = args['email'];
  }

  void resetPassword() {
    final password = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      setState(() => errorText = 'Please fill in both password fields.');
      return;
    }
    if (password.length < 8 ||
        !RegExp(r'[A-Z]').hasMatch(password) ||
        !RegExp(r'[a-z]').hasMatch(password) ||
        !RegExp(r'[!@#\\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      setState(() => errorText = 'Password must meet all security criteria.');
      return;
    }
    if (password != confirmPassword) {
      setState(() => errorText = 'Passwords do not match.');
      return;
    }

    setState(() => errorText = '');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('Password reset successful.')
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        duration: const Duration(seconds: 1),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushNamedAndRemoveUntil(context, routeLogin, (route) => false);
    });
  }

  void goBackToLogin() => Navigator.pushReplacementNamed(context, routeLogin);

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(height: 60),
                const Icon(Icons.lock_reset, size: 100),
                const SizedBox(height: 40),
                Text(
                  'Resetting password for:',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Narrower container for fields and button
                Center(
                  child: SizedBox(
                    width: 320,
                    child: Column(
                      children: [
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
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 25),
                        MyButton(
                          text: 'Reset Password',
                          onTap: resetPassword,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),
                GestureDetector(
                  onTap: goBackToLogin,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.arrow_back, size: 16, color: Colors.blue),
                      SizedBox(width: 4),
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
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
