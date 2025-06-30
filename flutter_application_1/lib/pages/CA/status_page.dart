import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:share_plus/share_plus.dart';
import '../../models/certificate.dart';
import '../../services/certificate_service.dart';
import '../CA/CertificatePreviewPage.dart';

class StatusPage extends StatefulWidget {
  final String username;

  const StatusPage({super.key, required this.username});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> with SingleTickerProviderStateMixin {
  late final AnimationController _reloadController;

  @override
  void initState() {
    super.initState();
    _reloadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _reloadController.reset();
        setState(() {}); // rebuild to refresh stream
      }
    });
  }

  @override
  void dispose() {
    _reloadController.dispose();
    super.dispose();
  }

  void _onRefreshTapped() {
    _reloadController.forward();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case Certificate.approved:
        return Colors.green;
      case Certificate.rejected:
        return Colors.red;
      case Certificate.pending:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Icon _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case Certificate.approved:
        return const Icon(Icons.check_circle, color: Colors.white);
      case Certificate.rejected:
        return const Icon(Icons.cancel, color: Colors.white);
      case Certificate.pending:
        return const Icon(Icons.hourglass_top, color: Colors.white);
      default:
        return const Icon(Icons.help, color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Certificate Status'),
        centerTitle: true,
        elevation: 2,
        actions: [
          RotationTransition(
            turns: Tween<double>(begin: 0, end: 1).animate(_reloadController),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.blue),
              onPressed: _onRefreshTapped,
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Certificate>>(
        stream: CertificateService().getUserCertificates(widget.username),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final allCerts = snapshot.data!;
          final approved = allCerts.where((c) => c.status == Certificate.approved).toList();
          final pending  = allCerts.where((c) => c.status == Certificate.pending).toList();
          final rejected = allCerts.where((c) => c.status == Certificate.rejected).toList();

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSummaryHeader(approved.length, pending.length, rejected.length),
              const SizedBox(height: 24),

              const Text('✅ Approved',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (approved.isEmpty)
                const Text('No approved certificates.')
              else ...[
                ElevatedButton.icon(
                  onPressed: () async {
                    final pdfBytes = await _generateCombinedPdf(approved);
                    final dir = await getTemporaryDirectory();
                    final file = File('${dir.path}/All_Approved.pdf');
                    await file.writeAsBytes(pdfBytes);
                    await Share.shareXFiles([XFile(file.path)],
                        text: 'My approved certificates');
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Share All'),
                ),
                const SizedBox(height: 8),
                for (var cert in approved) _buildCertTile(context, cert, Colors.green),
              ],

              const SizedBox(height: 24),
              const Text('⏳ Pending',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (pending.isEmpty)
                const Text('No pending certificates.')
              else
                for (var cert in pending) _buildCertTile(context, cert, Colors.orange),

              const SizedBox(height: 24),
              const Text('❌ Rejected',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (rejected.isEmpty)
                const Text('No rejected certificates.')
              else
                for (var cert in rejected) _buildCertTile(context, cert, Colors.red),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryHeader(int a, int p, int r) {
    Widget card(String label, int count, Color color, Color background) {
      return Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: color)),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        card('Approved', a, Colors.green, Colors.lightBlue.shade50),
        const SizedBox(width: 12),
        card('Pending', p, Colors.orange, Colors.amber.shade50),
        const SizedBox(width: 12),
        card('Rejected', r, Colors.red, Colors.pink.shade50),
      ],
    );
  }

  Widget _buildCertTile(BuildContext context, Certificate cert, Color statusColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CertificatePreviewPage(
                recipientName: cert.recipientName,
                organization: cert.organization,
                purpose: cert.purpose,
                issued: cert.issued,
                expiry: cert.expiry,
                signatureBytes: cert.signatureBytes,
                createdBy: cert.createdBy,
              ),
            ),
          );
        },
        title: Text(cert.recipientName),
        subtitle: Text('Issued: ${cert.issued.toLocal().toIso8601String().split('T')[0]}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              statusColor == Colors.green
                  ? 'Approved'
                  : statusColor == Colors.orange
                  ? 'Pending'
                  : 'Rejected',
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
            if (statusColor == Colors.green)
              IconButton(
                icon: const Icon(Icons.share, color: Colors.blue),
                onPressed: () async {
                  final pdfBytes = await _generatePdf(cert);
                  final dir = await getTemporaryDirectory();
                  final file = File('${dir.path}/${cert.recipientName.replaceAll(' ', '_')}.pdf');
                  await file.writeAsBytes(pdfBytes);
                  await Share.shareXFiles(
                      [XFile(file.path)], text: 'My approved certificate');
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
    final sigImg = pw.MemoryImage(cert.signatureBytes);
    final borderColor = PdfColor.fromHex('#D4AF37');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Container(
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
              pw.Divider(),
              pw.SizedBox(height: 24),
              pw.Text(cert.recipientName, style: pw.TextStyle(font: ttf, fontSize: 20)),
              pw.SizedBox(height: 12),
              pw.Text(cert.organization, style: pw.TextStyle(font: ttf, fontSize: 16)),
              pw.SizedBox(height: 12),
              pw.Text(cert.purpose, style: pw.TextStyle(font: ttf, fontSize: 16)),
              pw.SizedBox(height: 12),
              pw.Text(
                'Issued: ${cert.issued.toLocal().toIso8601String().split('T')[0]}',
                style: pw.TextStyle(font: ttf, fontSize: 14),
              ),
              pw.Text(
                'Expiry: ${cert.expiry.toLocal().toIso8601String().split('T')[0]}',
                style: pw.TextStyle(font: ttf, fontSize: 14),
              ),
              pw.SizedBox(height: 24),
              pw.Image(sigImg, width: 120, height: 60),
              pw.Text('Signature', style: pw.TextStyle(font: ttf, fontSize: 12)),
            ],
          ),
        ),
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> _generateCombinedPdf(List<Certificate> certs) async {
    final pdf = pw.Document();
    final ttf = pw.Font.ttf(await rootBundle.load('assets/fonts/times.ttf'));
    final borderColor = PdfColor.fromHex('#D4AF37');

    for (final cert in certs) {
      final sigImg = pw.MemoryImage(cert.signatureBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (_) => pw.Container(
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
                pw.Divider(),
                pw.SizedBox(height: 24),
                pw.Text(cert.recipientName, style: pw.TextStyle(font: ttf, fontSize: 20)),
                pw.SizedBox(height: 12),
                pw.Text(cert.organization, style: pw.TextStyle(font: ttf, fontSize: 16)),
                pw.SizedBox(height: 12),
                pw.Text(cert.purpose, style: pw.TextStyle(font: ttf, fontSize: 16)),
                pw.SizedBox(height: 12),
                pw.Text(
                  'Issued: ${cert.issued.toLocal().toIso8601String().split('T')[0]}',
                  style: pw.TextStyle(font: ttf, fontSize: 14),
                ),
                pw.Text(
                  'Expiry: ${cert.expiry.toLocal().toIso8601String().split('T')[0]}',
                  style: pw.TextStyle(font: ttf, fontSize: 14),
                ),
                pw.SizedBox(height: 24),
                pw.Image(sigImg, width: 120, height: 60),
                pw.Text('Signature', style: pw.TextStyle(font: ttf, fontSize: 12)),
              ],
            ),
          ),
        ),
      );
    }

    return pdf.save();
  }
}
