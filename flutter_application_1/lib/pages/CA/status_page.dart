import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "✅ Approved Certificates",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // NEW: Share All Button
                if (approved.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () async {
                      final pdfBytes =
                          await _generateCombinedPdf(approved);
                      final tempDir = await getTemporaryDirectory();
                      final file = File(
                          '${tempDir.path}/All_Approved_Certificates.pdf');
                      await file.writeAsBytes(pdfBytes);
                      await Share.shareXFiles(
                        [XFile(file.path)],
                        text: 'Here are my approved certificates!',
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Share All Approved"),
                  ),

                const SizedBox(height: 8),
                ...approved.map((c) => _buildCertTile(context, c, Colors.green)),
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
                onPressed: () async {
                  final pdfBytes = await _generatePdf(cert);
                  final tempDir = await getTemporaryDirectory();
                  final file = File(
                    '${tempDir.path}/Certificate_${cert.recipientName.replaceAll(' ', '_')}.pdf',
                  );
                  await file.writeAsBytes(pdfBytes);
                  await Share.shareXFiles([
                    XFile(file.path),
                  ], text: 'Here is my approved certificate!');
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _generatePdf(Certificate cert) async {
    final pdf = pw.Document();
    final ttf = pw.Font.ttf(await rootBundle.load('assets/fonts/times.ttf'));
    final signatureImage = pw.MemoryImage(cert.signatureBytes);
    final borderColor = PdfColor.fromHex("#D4AF37");

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: borderColor, width: 6),
            ),
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'UNIVERSITI PUTRA MALAYSIA',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.brown800,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 24),
                pw.Text(cert.recipientName, style: pw.TextStyle(font: ttf, fontSize: 20)),
                pw.SizedBox(height: 12),
                pw.Text(cert.organization, style: pw.TextStyle(font: ttf, fontSize: 16)),
                pw.SizedBox(height: 12),
                pw.Text(cert.purpose, style: pw.TextStyle(font: ttf, fontSize: 16)),
                pw.SizedBox(height: 12),
                pw.Text("Issued: ${cert.issued.toString().split(' ')[0]}", style: pw.TextStyle(font: ttf, fontSize: 14)),
                pw.Text("Expiry: ${cert.expiry.toString().split(' ')[0]}", style: pw.TextStyle(font: ttf, fontSize: 14)),
                pw.SizedBox(height: 24),
                pw.Image(signatureImage, width: 120, height: 60),
                pw.Text("Signature", style: pw.TextStyle(font: ttf, fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> _generateCombinedPdf(List<Certificate> certs) async {
    final pdf = pw.Document();
    final ttf = pw.Font.ttf(await rootBundle.load('assets/fonts/times.ttf'));
    final borderColor = PdfColor.fromHex("#D4AF37");

    for (var cert in certs) {
      final signatureImage = pw.MemoryImage(cert.signatureBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: borderColor, width: 6),
              ),
              padding: const pw.EdgeInsets.all(32),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'UNIVERSITI PUTRA MALAYSIA',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.brown800,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Divider(thickness: 1),
                  pw.SizedBox(height: 24),
                  pw.Text(cert.recipientName, style: pw.TextStyle(font: ttf, fontSize: 20)),
                  pw.SizedBox(height: 12),
                  pw.Text(cert.organization, style: pw.TextStyle(font: ttf, fontSize: 16)),
                  pw.SizedBox(height: 12),
                  pw.Text(cert.purpose, style: pw.TextStyle(font: ttf, fontSize: 16)),
                  pw.SizedBox(height: 12),
                  pw.Text("Issued: ${cert.issued.toString().split(' ')[0]}", style: pw.TextStyle(font: ttf, fontSize: 14)),
                  pw.Text("Expiry: ${cert.expiry.toString().split(' ')[0]}", style: pw.TextStyle(font: ttf, fontSize: 14)),
                  pw.SizedBox(height: 24),
                  pw.Image(signatureImage, width: 120, height: 60),
                  pw.Text("Signature", style: pw.TextStyle(font: ttf, fontSize: 12)),
                ],
              ),
            );
          },
        ),
      );
    }

    return pdf.save();
  }
}
