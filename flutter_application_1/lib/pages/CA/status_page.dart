import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/certificate.dart';
import '../../services/certificate_service.dart';

class StatusPage extends StatelessWidget {
  final String username;

  const StatusPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CA Certificate Status for $username")),
      body: StreamBuilder<List<Certificate>>(
        stream: CertificateService().getUserCertificates(username),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final certs = snapshot.data!;
          final approved =
              certs.where((c) => c.status == Certificate.approved).toList();
          final rejected =
              certs.where((c) => c.status == Certificate.rejected).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                const Text(
                  "✅ Approved Certificates",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...approved.map(
                  (c) => _buildCertTile(context, c, Colors.green),
                ),
                const SizedBox(height: 24),
                const Text(
                  "❌ Rejected Certificates",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...rejected.map((c) => _buildCertTile(context, c, Colors.red)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCertTile(
    BuildContext context,
    Certificate cert,
    Color statusColor,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(cert.recipientName),
        subtitle: Text("Issued: ${cert.issued.toString().split(' ')[0]}"),
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
                  Share.share(
                    "Certificate: ${cert.recipientName}\nIssued on: ${cert.issued.toString().split(' ')[0]}\nStatus: Approved",
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
