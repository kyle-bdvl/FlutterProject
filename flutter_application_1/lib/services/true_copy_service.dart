import 'dart:async';
import '../models/true_copy_document.dart';

class TrueCopyService {
  // Mock data for demonstration
  static final List<TrueCopyDocument> _mockDocuments = [
    TrueCopyDocument(
      id: '1',
      fileUrl: 'https://example.com/document1.pdf',
      name: 'Academic Transcript',
      issuer: 'University of Technology',
      purpose: 'Employment Verification',
      dateIssued: '2024-01-15',
      status: 'Pending',
      uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TrueCopyDocument(
      id: '2',
      fileUrl: 'https://example.com/document2.pdf',
      name: 'Birth Certificate',
      issuer: 'Department of Civil Registration',
      purpose: 'Passport Application',
      dateIssued: '2024-01-10',
      status: 'Approved',
      uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
      approvedBy: 'Admin User',
      approvedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TrueCopyDocument(
      id: '3',
      fileUrl: 'https://example.com/document3.pdf',
      name: 'Employment Certificate',
      issuer: '', // Missing issuer
      purpose: 'Loan Application',
      dateIssued: '', // Missing date
      status: 'Rejected',
      uploadedAt: DateTime.now().subtract(const Duration(days: 1)),
      rejectionReason: 'Missing required metadata',
    ),
    TrueCopyDocument(
      id: '4',
      fileUrl: 'https://example.com/document4.pdf',
      name: 'Medical Certificate',
      issuer: 'City General Hospital',
      purpose: 'Insurance Claim',
      dateIssued: '2024-01-20',
      status: 'Pending',
      uploadedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    TrueCopyDocument(
      id: '5',
      fileUrl: 'https://example.com/document5.pdf',
      name: 'Police Clearance',
      issuer: 'Local Police Station',
      purpose: 'Security Clearance',
      dateIssued: '2024-01-18',
      status: 'Pending',
      uploadedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    TrueCopyDocument(
      id: '6',
      fileUrl: 'https://example.com/document6.pdf',
      name: 'Marriage Certificate',
      issuer: '', // Missing issuer
      purpose: 'Visa Application',
      dateIssued: '', // Missing date
      status: 'Pending',
      uploadedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  static final List<AdminLog> _mockLogs = [
    AdminLog(
      id: '1',
      action: 'Approved',
      documentId: '2',
      documentName: 'Birth Certificate',
      adminName: 'Admin User',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AdminLog(
      id: '2',
      action: 'Rejected',
      documentId: '3',
      documentName: 'Employment Certificate',
      adminName: 'Admin User',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      reason: 'Missing required metadata',
    ),
  ];

  // Fetch all documents
  static Future<List<TrueCopyDocument>> fetchDocuments() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    return List.from(_mockDocuments);
  }

  // Fetch documents by status
  static Future<List<TrueCopyDocument>> fetchDocumentsByStatus(
    String status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockDocuments.where((doc) => doc.status == status).toList();
  }

  // Fetch documents with missing metadata
  static Future<List<TrueCopyDocument>>
  fetchDocumentsWithMissingMetadata() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockDocuments
        .where((doc) => doc.issuer.isEmpty || doc.dateIssued.isEmpty)
        .toList();
  }

  // Approve document
  static Future<bool> approveDocument(
    String documentId,
    String adminName,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    final index = _mockDocuments.indexWhere((doc) => doc.id == documentId);
    if (index != -1) {
      _mockDocuments[index] = _mockDocuments[index].copyWith(
        status: 'Approved',
        approvedBy: adminName,
        approvedAt: DateTime.now(),
      );

      // Add to logs
      _mockLogs.add(
        AdminLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          action: 'Approved',
          documentId: documentId,
          documentName: _mockDocuments[index].name,
          adminName: adminName,
          timestamp: DateTime.now(),
        ),
      );

      return true;
    }
    return false;
  }

  // Reject document
  static Future<bool> rejectDocument(
    String documentId,
    String adminName,
    String reason,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    final index = _mockDocuments.indexWhere((doc) => doc.id == documentId);
    if (index != -1) {
      _mockDocuments[index] = _mockDocuments[index].copyWith(
        status: 'Rejected',
        rejectionReason: reason,
      );

      // Add to logs
      _mockLogs.add(
        AdminLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          action: 'Rejected',
          documentId: documentId,
          documentName: _mockDocuments[index].name,
          adminName: adminName,
          timestamp: DateTime.now(),
          reason: reason,
        ),
      );

      return true;
    }
    return false;
  }

  // Fetch admin logs
  static Future<List<AdminLog>> fetchAdminLogs() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockLogs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Search documents
  static Future<List<TrueCopyDocument>> searchDocuments(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final lowercaseQuery = query.toLowerCase();
    return _mockDocuments
        .where(
          (doc) =>
              doc.name.toLowerCase().contains(lowercaseQuery) ||
              doc.issuer.toLowerCase().contains(lowercaseQuery) ||
              doc.purpose.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }
}
