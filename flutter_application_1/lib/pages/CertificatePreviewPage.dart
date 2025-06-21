import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

  Future<Uint8List> _generatePdf(final PdfPageFormat format) async {
    final pdf = pw.Document();
    final signatureImage = pw.MemoryImage(signatureBytes);

    final borderColor = PdfColor.fromHex("#D4AF37"); // gold

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: borderColor, width: 6),
            ),
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Header
                pw.Text(
                  'UNIVERSITI PUTRA MALAYSIA',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.brown800,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 24),

                // Title
                pw.Text(
                  'Certificate of Achievement',
                  style: pw.TextStyle(
                    fontSize: 30,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),

                pw.SizedBox(height: 32),

                // Content
                pw.Text(
                  'This is to certify that',
                  style: pw.TextStyle(fontSize: 18),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  recipientName,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.deepPurple,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  'has successfully completed',
                  style: pw.TextStyle(fontSize: 18),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  purpose,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey800,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 12),
                pw.Text('at $organization', style: pw.TextStyle(fontSize: 18)),

                pw.Spacer(),

                // Date section
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text('Issued on', style: pw.TextStyle(fontSize: 14)),
                        pw.Text(
                          formatDate(issued),
                          style: pw.TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text(
                          'Expires on',
                          style: pw.TextStyle(fontSize: 14),
                        ),
                        pw.Text(
                          formatDate(expiry),
                          style: pw.TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 24),

                // Signature
                pw.Container(height: 100, child: pw.Image(signatureImage)),
                pw.Text(
                  'Authorized Signature',
                  style: pw.TextStyle(fontSize: 14),
                ),

                pw.SizedBox(height: 24),

                // Footer
                pw.Divider(thickness: 1),
                pw.Text(
                  'Generated via Digital Certificate System • Berilmu Berbakti',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Certificate Preview")),
      body: PdfPreview(
        build: (format) => _generatePdf(format),
        allowPrinting: true,
        allowSharing: true,
      ),
    );
  }
}
