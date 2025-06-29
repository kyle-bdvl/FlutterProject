import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../services/certificate_service.dart';
import 'share_certificate_page.dart';

class CertificatePreviewPage extends StatefulWidget {
  final String recipientName;
  final String organization;
  final String purpose;
  final DateTime issued;
  final DateTime expiry;
  final Uint8List signatureBytes;
  final String createdBy;
  final bool fromListPage; // <-- Add this

  const CertificatePreviewPage({
    super.key,
    required this.recipientName,
    required this.organization,
    required this.purpose,
    required this.issued,
    required this.expiry,
    required this.signatureBytes,
    required this.createdBy,
    this.fromListPage = false, // <-- Default to false
  });

  @override
  State<CertificatePreviewPage> createState() => _CertificatePreviewPageState();
}

class _CertificatePreviewPageState extends State<CertificatePreviewPage> {
  bool _isSaving = false;

  String formatDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  Future<Uint8List> _generatePdf(final PdfPageFormat format) async {
    final pdf = pw.Document();
    final ttf = pw.Font.ttf(await rootBundle.load('assets/fonts/times.ttf'));
    final signatureImage = pw.MemoryImage(widget.signatureBytes);
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
                pw.Text(
                  'Certificate of Achievement',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 30,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
                pw.SizedBox(height: 32),
                pw.Text(
                  'This is to certify that',
                  style: pw.TextStyle(fontSize: 18),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  widget.recipientName,
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.deepPurple,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text(
                  'has successfully completed',
                  style: pw.TextStyle(font: ttf, fontSize: 18),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  widget.purpose,
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 16,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey800,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
                pw.SizedBox(height: 8),
                pw.SizedBox(height: 12),
                pw.Text(
                  'at ${widget.organization}',
                  style: pw.TextStyle(font: ttf, fontSize: 18),
                ),
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text(
                          'Issued on',
                          style: pw.TextStyle(font: ttf, fontSize: 14),
                        ),
                        pw.Text(
                          formatDate(widget.issued),
                          style: pw.TextStyle(font: ttf, fontSize: 14),
                        ),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text(
                          'Expires on',
                          style: pw.TextStyle(font: ttf, fontSize: 14),
                        ),
                        pw.Text(
                          formatDate(widget.expiry),
                          style: pw.TextStyle(font: ttf, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Container(height: 100, child: pw.Image(signatureImage)),
                pw.Text(
                  'Authorized Signature',
                  style: pw.TextStyle(font: ttf, fontSize: 14),
                ),
                pw.SizedBox(height: 24),
                pw.Divider(thickness: 1),
                pw.Text(
                  'Generated via Digital Certificate System • Berilmu Berbakti',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _saveCertificate() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await CertificateService().createCertificate(
        recipientName: widget.recipientName,
        organization: widget.organization,
        purpose: widget.purpose,
        issued: widget.issued,
        expiry: widget.expiry,
        signatureBytes: widget.signatureBytes,
        createdBy: widget.createdBy,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Certificate saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => ShareCertificatePage(
                recipientName: widget.recipientName,
                organization: widget.organization,
                purpose: widget.purpose,
                issued: widget.issued,
                expiry: widget.expiry,
                signatureBytes: widget.signatureBytes,
                createdBy: widget.createdBy,
              ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving certificate: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Certificate Preview")),
      body: Column(
        children: [
          // PDF Preview
          Expanded(
            child: PdfPreview(
              build: (format) => _generatePdf(format),
              allowPrinting: true,
              allowSharing: true,
            ),
          ),
          // Bottom save button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveCertificate,
                icon:
                    _isSaving
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.save),
                label: Text(
                  _isSaving ? 'Saving Certificate...' : 'Save Certificate',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
