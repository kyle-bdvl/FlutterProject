import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignaturePage extends StatefulWidget {
  const SignaturePage({Key? key}) : super(key: key);

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  void _saveSignature() async {
    if (_controller.isNotEmpty) {
      final signature = await _controller.toPngBytes();
      if (signature != null) {
        Navigator.pop(context, signature); // Return signature bytes
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a signature")),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Draw Signature")),
      body: Column(
        children: [
          const SizedBox(height: 16),
          const Text("Sign Below", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Container(
            color: Colors.grey[300],
            margin: const EdgeInsets.all(16),
            height: 300,
            child: Signature(
              controller: _controller,
              backgroundColor: Colors.white,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _controller.clear,
                icon: const Icon(Icons.clear),
                label: const Text("Clear"),
              ),
              ElevatedButton.icon(
                onPressed: _saveSignature,
                icon: const Icon(Icons.check),
                label: const Text("Done"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
