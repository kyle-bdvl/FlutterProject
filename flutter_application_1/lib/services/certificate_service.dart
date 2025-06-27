import 'dart:typed_data';
import '../models/certificate.dart';

class CertificateService {
  static final CertificateService _instance = CertificateService._internal();
  factory CertificateService() => _instance;
  CertificateService._internal();

  // Mock storage for certificates (replace with real database later)
  final List<Certificate> _certificates = [];

  // Create a new certificate
  Future<Certificate> createCertificate({
    required String recipientName,
    required String organization,
    required String purpose,
    required DateTime issued,
    required DateTime expiry,
    required Uint8List signatureBytes,
    required String createdBy,
  }) async {
    final certificate = Certificate(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      recipientName: recipientName,
      organization: organization,
      purpose: purpose,
      issued: issued,
      expiry: expiry,
      signatureBytes: signatureBytes,
      status: 'pending', // All new certificates start as pending
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );

    _certificates.add(certificate);
    return certificate;
  }

  // Get all certificates for a user
  List<Certificate> getUserCertificates(String username) {
    return _certificates.where((cert) => cert.createdBy == username).toList();
  }

  // Get all pending certificates (for admin)
  List<Certificate> getPendingCertificates() {
    return _certificates.where((cert) => cert.status == 'pending').toList();
  }

  // Get all certificates (for admin)
  List<Certificate> getAllCertificates() {
    return List.from(_certificates);
  }

  // Update certificate status (for admin approval/rejection)
  Future<bool> updateCertificateStatus(
    String certificateId,
    String status,
  ) async {
    final index = _certificates.indexWhere((cert) => cert.id == certificateId);
    if (index != -1) {
      final cert = _certificates[index];
      _certificates[index] = Certificate(
        id: cert.id,
        recipientName: cert.recipientName,
        organization: cert.organization,
        purpose: cert.purpose,
        issued: cert.issued,
        expiry: cert.expiry,
        signatureBytes: cert.signatureBytes,
        status: status,
        createdAt: cert.createdAt,
        createdBy: cert.createdBy,
      );
      return true;
    }
    return false;
  }

  // Get certificate by ID
  Certificate? getCertificateById(String id) {
    try {
      return _certificates.firstWhere((cert) => cert.id == id);
    } catch (e) {
      return null;
    }
  }

  // Delete certificate (for cleanup)
  Future<bool> deleteCertificate(String certificateId) async {
    final index = _certificates.indexWhere((cert) => cert.id == certificateId);
    if (index != -1) {
      _certificates.removeAt(index);
      return true;
    }
    return false;
  }

  // Check if a certificate with the same details already exists for a user
  bool isCertificateAlreadySaved({
    required String recipientName,
    required String organization,
    required String purpose,
    required DateTime issued,
    required DateTime expiry,
    required String createdBy,
  }) {
    return _certificates.any(
      (cert) =>
          cert.recipientName == recipientName &&
          cert.organization == organization &&
          cert.purpose == purpose &&
          cert.issued == issued &&
          cert.expiry == expiry &&
          cert.createdBy == createdBy &&
          cert.status == 'saved',
    );
  }

  // Save certificate (for delivery process)
  Future<bool> saveCertificate({
    required String recipientName,
    required String organization,
    required String purpose,
    required DateTime issued,
    required DateTime expiry,
    required Uint8List signatureBytes,
    required String createdBy,
  }) async {
    // Check if certificate already exists
    if (isCertificateAlreadySaved(
      recipientName: recipientName,
      organization: organization,
      purpose: purpose,
      issued: issued,
      expiry: expiry,
      createdBy: createdBy,
    )) {
      return false; // Certificate already exists
    }

    try {
      final certificate = Certificate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        recipientName: recipientName,
        organization: organization,
        purpose: purpose,
        issued: issued,
        expiry: expiry,
        signatureBytes: signatureBytes,
        status: 'saved', // Mark as saved for delivery
        createdAt: DateTime.now(),
        createdBy: createdBy,
      );

      _certificates.add(certificate);

      // Simulate saving to storage/database
      await Future.delayed(Duration(milliseconds: 500));

      return true;
    } catch (e) {
      print('Error saving certificate: $e');
      return false;
    }
  }

  // Get saved certificates (for delivery)
  List<Certificate> getSavedCertificates() {
    return _certificates.where((cert) => cert.status == 'saved').toList();
  }
}
