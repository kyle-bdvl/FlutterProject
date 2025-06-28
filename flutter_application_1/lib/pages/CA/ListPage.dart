import 'package:flutter/material.dart';
import '../../models/certificate.dart';
import '../../services/certificate_service.dart';
import 'CertificatePreviewPage.dart';

class ListPage extends StatefulWidget {
  final String username;

  const ListPage({super.key, required this.username});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final CertificateService _certificateService = CertificateService();

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Icon _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Icon(Icons.check_circle, color: Colors.white);
      case 'rejected':
        return const Icon(Icons.cancel, color: Colors.white);
      case 'pending':
        return const Icon(Icons.hourglass_top, color: Colors.white);
      default:
        return const Icon(Icons.help, color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Certificates'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {}); // Just rebuild to refresh the stream
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Certificate>>(
        stream: _certificateService.getUserCertificates(widget.username),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final certificates = snapshot.data!;
          if (certificates.isEmpty) {
            return const Center(child: Text('No certificates yet.'));
          }
          return ListView.builder(
            itemCount: certificates.length,
            itemBuilder: (context, index) {
              final certificate = certificates[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(certificate.status),
                    child: _getStatusIcon(certificate.status),
                  ),
                  title: Text(
                    certificate.recipientName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(certificate.purpose),
                      Text(
                        'Organization: ${certificate.organization}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Issued: ${certificate.issued.toString().split(' ')[0]}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(certificate.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      certificate.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => CertificatePreviewPage(
                              recipientName: certificate.recipientName,
                              organization: certificate.organization,
                              purpose: certificate.purpose,
                              issued: certificate.issued,
                              expiry: certificate.expiry,
                              signatureBytes: certificate.signatureBytes,
                              createdBy: certificate.createdBy,
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
