import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'CertificateListPreviewPage.dart';
import 'signaturePage.dart';
import 'package:flutter/material.dart';
import '../models/certificate.dart';
import '../services/certificate_service.dart';
import 'CertificatePreviewPage.dart';

class ListPage extends StatefulWidget {
  final String username;

  const ListPage({super.key, required this.username});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final CertificateService _certificateService = CertificateService();
  List<Certificate> _certificates = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _certificates = _certificateService.getUserCertificates(widget.username);
      _isLoading = false;
    });
  }

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
        automaticallyImplyLeading: false, // <-- Add this line
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCertificates,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCertificates,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload CSV Button
              Center(
                child: Column(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.upload_file,
                        size: 30,
                        color: Colors.green,
                      ),
                      tooltip: 'Upload CSV',
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['csv'],
                        );

                        if (result != null &&
                            result.files.single.path != null) {
                          final file = File(result.files.single.path!);
                          final contents = await file.readAsString();

                          final csvTable = const CsvToListConverter().convert(
                            contents,
                          );

                          if (csvTable.isNotEmpty) {
                            List<CertificateData> certs = [];
                            for (int i = 1; i < csvTable.length; i++) {
                              final row = csvTable[i];
                              if (row.length < 5)
                                continue; // Skip incomplete rows

                              final name = row[0].toString();
                              final org = row[1].toString();
                              final purpose = row[2].toString();
                              final issuedDate =
                                  DateTime.tryParse(row[3].toString()) ??
                                  DateTime.now();
                              final expiryDate =
                                  DateTime.tryParse(row[4].toString()) ??
                                  DateTime.now().add(const Duration(days: 365));

                              // Ask for signature for each certificate
                              final signatureBytes =
                                  await Navigator.push<Uint8List>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignaturePage(),
                                    ),
                                  );

                              if (signatureBytes == null) continue;

                              certs.add(
                                CertificateData(
                                  name: name,
                                  organization: org,
                                  purpose: purpose,
                                  issued: issuedDate,
                                  expiry: expiryDate,
                                  signatureBytes: signatureBytes,
                                  createdBy: widget.username,
                                ),
                              );
                            }

                            if (certs.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => CertificateListPreviewPage(
                                        certificates: certs,
                                      ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('No certificates to preview.'),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('CSV file is empty.'),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No file selected.')),
                          );
                        }
                      },
                    ),
                    const Text("Upload CSV file"),
                  ],
                ),
              ),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_certificates.isEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No certificates yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create your first certificate to get started',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _certificates.length,
                    itemBuilder: (context, index) {
                      final certificate = _certificates[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(
                              certificate.status,
                            ),
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
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
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
                              const SizedBox(height: 4),
                              Text(
                                'ID: ${certificate.id.substring(certificate.id.length - 6)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
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
                                      signatureBytes:
                                          certificate.signatureBytes,
                                      createdBy: certificate.createdBy,
                                    ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
