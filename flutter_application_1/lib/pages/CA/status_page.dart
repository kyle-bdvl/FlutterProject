import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // Add this to pubspec.yaml

class StatusPage extends StatelessWidget {
  final String username;

  const StatusPage({super.key, required this.username});

  void _shareCertificate(String title, String date) {
    final message = "Certificate: $title\nIssued: $date\nStatus: Approved ✅";
    Share.share(message); // Simple sharing action
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CA Certificate Status for $username")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("✅ Approved Certificates", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildCertTile("B.Sc. Software Engineering", "2023-01-15", Colors.green),
            const SizedBox(height: 24),
            const Text("❌ Rejected Certificates", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildCertTile("Diploma in Business", "2022-10-05", Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildCertTile(String title, String date, Color statusColor) {
  return Card(
    elevation: 2,
    child: ListTile(
      title: Text(title),
      subtitle: Text("Issued: $date"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            statusColor == Colors.green ? "Approved" : "Rejected",
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
          ),
          if (statusColor == Colors.green)
            IconButton(
              icon: const Icon(Icons.share, color: Colors.blue),
              onPressed: () {
                Share.share("Certificate: $title\nIssued on: $date\nStatus: Approved");
              },
            ),
        ],
      ),
    ),
  );
}
}