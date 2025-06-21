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

  void verifyOtp() {
    if (otpController.text == mockOtp) {
      Navigator.pushReplacementNamed(context, routeResetPassword);
    } else {
      setState(() {
        errorText = 'Invalid OTP. Please try again.';
      });
    }
  }

  void goBackToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, routeLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const Icon(Icons.lock_open, size: 100),
              const SizedBox(height: 50),
              Text(
                'Enter the OTP sent to your email',
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
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
                  ),
                ),
              const SizedBox(height: 25),
              MyButton(text: 'Verify Code', onTap: verifyOtp),

              const SizedBox(height: 20),

              // ← Back to Login
              GestureDetector(
                onTap: () => goBackToLogin(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_back, size: 16, color: Colors.blue),
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
    );
  }
}
