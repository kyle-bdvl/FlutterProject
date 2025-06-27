import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/my_button.dart';
import 'package:flutter_application_1/widgets/my_textfiled.dart';
import 'package:flutter_application_1/constants/route_names.dart';

const String mockOtp = '12345';

class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({super.key});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final otpController = TextEditingController();
  String errorText = '';
  late String email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    email = args['email'];
  }

  void verifyOtp() {
    if (otpController.text == mockOtp) {
      Navigator.pushReplacementNamed(
        context,
        routeResetPassword,
        arguments: {'email': email},
      );
    } else {
      setState(() => errorText = 'Invalid OTP. Please try again.');
    }
  }

  void goBackToLogin() =>
      Navigator.pushReplacementNamed(context, routeLogin);

  void goBackToForgotPassword() =>
      Navigator.pushReplacementNamed(context, routeForgotPassword);

  @override
  void dispose() {
    otpController.dispose();
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
          onPressed: goBackToForgotPassword,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: ListView(
            children: [
              const SizedBox(height: 80),
              const Icon(Icons.lock_open, size: 100),
              const SizedBox(height: 40),
              Text(
                'Enter the OTP sent to $email',
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              MyTextField(
                controller: otpController,
                hintText: 'Enter OTP',
                obscureText: false,
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
              MyButton(text: 'Verify Code', onTap: verifyOtp),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: goBackToLogin,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.arrow_back, size: 16, color: Colors.blue),
                    SizedBox(width: 4),
                    Text(
                      'Back to Login',
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
