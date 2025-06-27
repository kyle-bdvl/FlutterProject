import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/CertificateListPreviewPage.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../services/certificate_service.dart';
import '../pages/share_certificate_page.dart';

class CertificatePreviewPage extends StatefulWidget {
  final String recipientName;
  final String organization;
  final String purpose;
  final DateTime issued;
  final DateTime expiry;
  final Uint8List signatureBytes;
  final String createdBy;
  final bool fromCsv;
  final List<CertificateData>? allCertificates; // For Save All

  const CertificatePreviewPage({
    Key? key,
    required this.recipientName,
    required this.organization,
    required this.purpose,
    required this.issued,
    required this.expiry,
    required this.signatureBytes,
    required this.createdBy,
    this.fromCsv = false,
    this.allCertificates,
  }) : super(key: key);

  @override
  State<CertificatePreviewPage> createState() => _CertificatePreviewPageState();
}

class _CertificatePreviewPageState extends State<CertificatePreviewPage> {
  bool _isSaving = false;
  bool _isAlreadySaved = false;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadySaved();
  }

  void _checkIfAlreadySaved() {
    final certificateService = CertificateService();
    _isAlreadySaved = certificateService.isCertificateAlreadySaved(
      recipientName: widget.recipientName,
      organization: widget.organization,
      purpose: widget.purpose,
      issued: widget.issued,
      expiry: widget.expiry,
      createdBy: widget.createdBy,
    );
  }

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
                // Header
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

                // Title
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

                // Content
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

                // Date section
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

                // Signature
                pw.Container(height: 100, child: pw.Image(signatureImage)),
                pw.Text(
                  'Authorized Signature',
                  style: pw.TextStyle(font: ttf, fontSize: 14),
                ),

                pw.SizedBox(height: 24),

                // Footer
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
      final success = await CertificateService().saveCertificate(
        recipientName: widget.recipientName,
        organization: widget.organization,
        purpose: widget.purpose,
        issued: widget.issued,
        expiry: widget.expiry,
        signatureBytes: widget.signatureBytes,
        createdBy: widget.createdBy,
      );

      if (success) {
        setState(() {
          _isAlreadySaved = true;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Certificate saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to download certificate page
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Certificate already saved. You can download it from your saved certificates.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
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
          // Info banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color:
                _isAlreadySaved ? Colors.orange.shade50 : Colors.blue.shade50,
            child: Row(
              children: [
                Icon(
                  _isAlreadySaved ? Icons.info_outline : Icons.info_outline,
                  color: _isAlreadySaved ? Colors.orange : Colors.blue,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _isAlreadySaved
                        ? 'This certificate has already been saved. You can download it from your saved certificates.'
                        : 'Review your certificate below. Click "Save Certificate" to proceed.',
                    style: TextStyle(
                      color:
                          _isAlreadySaved
                              ? Colors.orange.shade800
                              : Colors.blue.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // PDF Preview
          Expanded(
            child: PdfPreview(
              build: (format) => _generatePdf(format),
              allowPrinting: true,
              allowSharing: true,
            ),
          ),
          // Bottom save button - only show if not already saved
          if (!_isAlreadySaved)
            Container(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveCertificate,
                  icon:
                      _isSaving
                          ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Icon(Icons.save),
                  label: Text(
                    _isSaving ? 'Saving Certificate...' : 'Save Certificate',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          // Download button - only show if already saved
          if (_isAlreadySaved)
            Container(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
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
                  },
                  icon: Icon(Icons.download),
                  label: Text('Download Certificate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          // Save all button - only show if from CSV and certificates are available
          if (widget.fromCsv && widget.allCertificates != null)
            Container(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.save_alt),
                  label: Text('Save All Certificates'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed:
                      _isSaving
                          ? null
                          : () async {
                            setState(() {
                              _isSaving = true;
                            });
                            int savedCount = 0;
                            for (final cert in widget.allCertificates!) {
                              try {
                                final success = await CertificateService()
                                    .saveCertificate(
                                      recipientName: cert.name,
                                      organization: cert.organization,
                                      purpose: cert.purpose,
                                      issued: cert.issued,
                                      expiry: cert.expiry,
                                      signatureBytes: cert.signatureBytes,
                                      createdBy: cert.createdBy,
                                    );
                                if (success) savedCount++;
                              } catch (_) {}
                            }
                            setState(() {
                              _isSaving = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Saved $savedCount of ${widget.allCertificates!.length} certificates!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
