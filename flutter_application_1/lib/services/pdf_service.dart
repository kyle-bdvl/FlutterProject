import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class PdfService {
  static Future<Uint8List> generateSamplePdf({
    required String documentName,
    required String issuer,
    required String purpose,
    required String dateIssued,
    required String status,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.blue, width: 2),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        documentName.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'TRUE COPY CERTIFICATION',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 30),

                // Document Information
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'DOCUMENT INFORMATION',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue,
                        ),
                      ),
                      pw.SizedBox(height: 15),
                      _buildInfoRow('Document Type:', documentName),
                      _buildInfoRow('Issuing Authority:', issuer),
                      _buildInfoRow('Purpose:', purpose),
                      _buildInfoRow('Date Issued:', dateIssued),
                      _buildInfoRow('Status:', status),
                      if (approvedBy != null)
                        _buildInfoRow('Approved By:', approvedBy),
                      if (approvedAt != null)
                        _buildInfoRow(
                          'Approved Date:',
                          DateFormat('MMM dd, yyyy').format(approvedAt),
                        ),
                      if (rejectionReason != null)
                        _buildInfoRow('Rejection Reason:', rejectionReason),
                    ],
                  ),
                ),

                pw.SizedBox(height: 30),

                // Sample Content
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SAMPLE DOCUMENT CONTENT',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue,
                        ),
                      ),
                      pw.SizedBox(height: 15),
                      pw.Text(
                        'This is a sample $documentName document for demonstration purposes. '
                        'In a real application, this would contain the actual document content '
                        'scanned or uploaded by the user.',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'The document was issued by $issuer for the purpose of $purpose. '
                        'This true copy certification ensures that this document is a faithful '
                        'reproduction of the original.',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 30),

                // Footer
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(8),
                    ),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'CERTIFICATION STATEMENT',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'I hereby certify that this is a true and accurate copy of the original document. '
                        'This certification is valid for official purposes.',
                        style: const pw.TextStyle(fontSize: 11),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 15),
                      pw.Text(
                        'Generated on: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // Generate different types of sample PDFs
  static Future<Uint8List> generateAcademicTranscript() async {
    return generateSamplePdf(
      documentName: 'Academic Transcript',
      issuer: 'University of Technology',
      purpose: 'Employment Verification',
      dateIssued: '2024-01-15',
      status: 'Pending',
    );
  }

  static Future<Uint8List> generateBirthCertificate() async {
    return generateSamplePdf(
      documentName: 'Birth Certificate',
      issuer: 'Department of Civil Registration',
      purpose: 'Passport Application',
      dateIssued: '2024-01-10',
      status: 'Approved',
      approvedBy: 'Admin User',
      approvedAt: DateTime.now().subtract(const Duration(days: 1)),
    );
  }

  static Future<Uint8List> generateEmploymentCertificate() async {
    return generateSamplePdf(
      documentName: 'Employment Certificate',
      issuer: 'Sample Company Ltd.',
      purpose: 'Loan Application',
      dateIssued: '2024-01-20',
      status: 'Rejected',
      rejectionReason: 'Missing required metadata',
    );
  }

  static Future<Uint8List> generateMedicalCertificate() async {
    return generateSamplePdf(
      documentName: 'Medical Certificate',
      issuer: 'City General Hospital',
      purpose: 'Insurance Claim',
      dateIssued: '2024-01-20',
      status: 'Pending',
    );
  }

  static Future<Uint8List> generatePoliceClearance() async {
    return generateSamplePdf(
      documentName: 'Police Clearance',
      issuer: 'Local Police Station',
      purpose: 'Security Clearance',
      dateIssued: '2024-01-18',
      status: 'Pending',
    );
  }

  // Get PDF for specific document
  static Future<Uint8List> getPdfForDocument(String documentName) async {
    switch (documentName.toLowerCase()) {
      case 'academic transcript':
        return generateAcademicTranscript();
      case 'birth certificate':
        return generateBirthCertificate();
      case 'employment certificate':
        return generateEmploymentCertificate();
      case 'medical certificate':
        return generateMedicalCertificate();
      case 'police clearance':
        return generatePoliceClearance();
      default:
        return generateSamplePdf(
          documentName: documentName,
          issuer: 'Sample Issuer',
          purpose: 'Sample Purpose',
          dateIssued: '2024-01-01',
          status: 'Pending',
        );
    }
  }
}
