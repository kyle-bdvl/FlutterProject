import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'CertificateCreatePage.dart';
import 'CertificateListPreviewPage.dart';
import 'signaturePage.dart';

class CreatePage extends StatelessWidget {
  final String username;

  const CreatePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CertificateCreatePage(
                        onDataSaved: (
                          name,
                          org,
                          purpose,
                          issued,
                          expiry,
                          signature,
                        ) {
                          print("Certificate Created");
                        },
                        username: username,
                      ),
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.add, size: 50, color: Colors.white),
                ),
                SizedBox(height: 20),
                Text(
                  'Create Page',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('Create new certificates or items here.'),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload CSV File'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['csv'],
              );
              if (result != null && result.files.single.path != null) {
                final file = File(result.files.single.path!);
                final contents = await file.readAsString();
                final csvTable = const CsvToListConverter().convert(contents);

                if (csvTable.isNotEmpty) {
                  List<CertificateData> certs = [];
                  for (int i = 1; i < csvTable.length; i++) {
                    final row = csvTable[i];
                    if (row.length < 5) continue;

                    final name = row[0].toString();
                    final org = row[1].toString();
                    final purpose = row[2].toString();
                    final issuedDate =
                        DateTime.tryParse(row[3].toString()) ?? DateTime.now();
                    final expiryDate =
                        DateTime.tryParse(row[4].toString()) ??
                        DateTime.now().add(const Duration(days: 365));

                    // Prompt for signature for each certificate
                    final signatureBytes = await Navigator.push<Uint8List>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignaturePage(),
                      ),
                    );
                    if (signatureBytes == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Signature required for $name. Process cancelled.',
                          ),
                        ),
                      );
                      return;
                    }

                    certs.add(
                      CertificateData(
                        name: name,
                        organization: org,
                        purpose: purpose,
                        issued: issuedDate,
                        expiry: expiryDate,
                        signatureBytes: signatureBytes,
                        createdBy: username,
                        fromCsv: true,
                      ),
                    );
                  }

                  if (certs.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                CertificateListPreviewPage(certificates: certs),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No valid certificates found in CSV.'),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('CSV file is empty.')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No file selected.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
