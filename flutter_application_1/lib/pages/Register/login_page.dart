import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'RegisterPage.dart';
import '../Admin/AdminDashboard.dart';
import '../CA/Dashboard.dart';
import '../Admin/AdminLoginPage.dart';
import 'package:flutter_application_1/constants/route_names.dart';
import 'package:flutter_application_1/widgets/my_button.dart';
import 'package:flutter_application_1/widgets/my_textfiled.dart';
import 'package:flutter_application_1/widgets/square_tile.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  static const String ADMIN_EMAIL = "admin123@upm.edu.my";

  Future<void> signUserIn(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage('Please fill in all fields');
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        if (email == ADMIN_EMAIL) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
        } else {
          final name = credential.user!.displayName ?? email.split('@')[0];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardPage(
                username: name,
                profileImagePath: 'lib/images/default_profile.png',
              ),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? 'Login failed');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> signInWithGoogleUPM(BuildContext context) async {
    setState(() => isLoading = true);

    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // force account picker

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final email = googleUser.email;
      if (!email.endsWith('@student.upm.edu.my')) {
        await googleSignIn.signOut();
        showMessage('Only @student.upm.edu.my accounts are allowed');
        setState(() => isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final authResult = await FirebaseAuth.instance.signInWithCredential(credential);
      final uid = authResult.user!.uid;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      String userType;

      if (!userDoc.exists) {
        // Ask user for userType
        userType = await showDialog(
          context: context,
          builder: (context) {
            String selectedType = 'Recipient'; // default
            return AlertDialog(
              title: const Text('Select User Type'),
              content: StatefulBuilder(
                builder: (context, setState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: ['Certificate Authority (CA)', 'Recipient'].map((type) {
                    return RadioListTile(
                      title: Text(type),
                      value: type,
                      groupValue: selectedType,
                      onChanged: (value) {
                        setState(() => selectedType = value!);
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(selectedType),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'username': googleUser.displayName ?? 'UPM User',
          'email': email,
          'userType': userType,
          'createdAt': FieldValue.serverTimestamp(),
        });

        showMessage('Account registered successfully as $userType');
      } else {
        userType = userDoc['userType'];
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(
            username: googleUser.displayName ?? email.split('@')[0],
            profileImagePath: 'lib/images/upm_logo.png',
          ),
        ),
      );
    } catch (e) {
      showMessage('Google sign-in failed: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: Colors.blue),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminLoginPage()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),
                const Icon(Icons.lock, size: 100),
                const SizedBox(height: 50),
                Text('Welcome back!', style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                const SizedBox(height: 25),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: MyTextField(
                    controller: emailController,
                    hintText: 'UPM Email',
                    obscureText: false,
                  ),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, routeForgotPassword),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : MyButton(
                    onTap: () => signUserIn(context),
                    text: "Sign In",
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(child: Divider(thickness: 0.5, color: Colors.grey[400])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text('Or continue with', style: TextStyle(color: Colors.grey[700])),
                      ),
                      Expanded(child: Divider(thickness: 0.5, color: Colors.grey[400])),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                GestureDetector(
                  onTap: () => signInWithGoogleUPM(context),
                  child: const SquareTile(imagePath: 'lib/images/upm_logo.png', size: 50),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?", style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      ),
                      child: const Text(
                        "Register now",
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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
