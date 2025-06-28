import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

// This screen lets the user download their saved certificate
class ShareCertificatePage extends StatefulWidget {
  final String recipientName;
  final String organization;
  final String purpose;
  final DateTime issued;
  final DateTime expiry;
  final Uint8List signatureBytes;
  final String createdBy;

  const ShareCertificatePage({
    super.key,
    required this.recipientName,
    required this.organization,
    required this.purpose,
    required this.issued,
    required this.expiry,
    required this.signatureBytes,
    required this.createdBy,
  });

  @override
  _ShareCertificatePageState createState() => _ShareCertificatePageState();
}

class _ShareCertificatePageState extends State<ShareCertificatePage> {
  bool _isDownloading = false;

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

  Future<void> _downloadCertificate() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      // Request storage permission for Android
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Storage permission is required to download the certificate',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Generate the PDF
      final pdfBytes = await _generatePdf(PdfPageFormat.a4);

      // Get the download directory
      Directory? downloadDir;
      if (Platform.isAndroid) {
        downloadDir = Directory('/storage/emulated/0/Download');
        if (!await downloadDir.exists()) {
          downloadDir = await getExternalStorageDirectory();
        }
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
      }

      if (downloadDir == null) {
        throw Exception('Could not access download directory');
      }

      // Create filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename =
          'Certificate_${widget.recipientName.replaceAll(' ', '_')}_$timestamp.pdf';
      final file = File('${downloadDir.path}/$filename');

      // Write the PDF to file
      await file.writeAsBytes(pdfBytes);

      setState(() {
        _isDownloading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Certificate downloaded successfully!\nSaved as: $filename',
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () async {
              try {
                await OpenFile.open(file.path);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Could not open file: $e'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading certificate: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Download Certificate'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Certificate saved successfully! Ready for download.',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            Text(
              'Download Certificate',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 16),

            // Certificate preview
            Container(
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: PdfPreview(
                build: (format) => _generatePdf(format),
                allowPrinting: false,
                allowSharing: false,
                maxPageWidth: 400,
              ),
            ),

            SizedBox(height: 24),

            // Download button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isDownloading ? null : _downloadCertificate,
                icon:
                    _isDownloading
                        ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Icon(Icons.download),
                label: Text(
                  _isDownloading ? 'Downloading...' : 'Download Certificate',
                ),
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

            SizedBox(height: 16),

            // Print button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Open print dialog
                  Printing.layoutPdf(
                    onLayout: (format) => _generatePdf(format),
                  );
                },
                icon: Icon(Icons.print),
                label: Text('Print Certificate'),
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

            SizedBox(height: 24),

            // Info section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Download Options',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Download Certificate: Save the certificate as a PDF file to your device\n'
                    '• Print Certificate: Print the certificate directly to a printer\n'
                    '• The certificate is now saved and can be accessed anytime from your saved certificates',
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
