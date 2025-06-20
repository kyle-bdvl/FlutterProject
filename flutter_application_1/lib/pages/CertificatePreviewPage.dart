import 'dart:typed_data';
import 'package:flutter/material.dart';

class CertificatePreviewPage extends StatelessWidget {
  final String recipientName;
  final String organization;
  final String purpose;
  final DateTime issued;
  final DateTime expiry;
  final Uint8List signatureBytes;

  const CertificatePreviewPage({
    Key? key,
    required this.recipientName,
    required this.organization,
    required this.purpose,
    required this.issued,
    required this.expiry,
    required this.signatureBytes,
  }) : super(key: key);

  String formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Certificate Preview")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Certificate of Achievement",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                Text(
                  "This is to certify that",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  recipientName,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text("has successfully completed"),
                const SizedBox(height: 8),
                Text(
                  purpose,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 12),
                Text("at $organization"),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [Text("Issued on"), Text(formatDate(issued))],
                    ),
                    Column(
                      children: [Text("Expires on"), Text(formatDate(expiry))],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Image.memory(signatureBytes, height: 100),
                const Text("Authorized Signature"),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true); // Return true when confirmed
                  },
                  child: const Text("Confirm & Save"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
