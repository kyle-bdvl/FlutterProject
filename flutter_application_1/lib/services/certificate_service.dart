import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/certificate.dart';

class CertificateService {
  static final CertificateService _instance = CertificateService._internal();
  factory CertificateService() => _instance;
  CertificateService._internal();

  static final CollectionReference _certCollection = FirebaseFirestore.instance
      .collection('certificates');

  // Create a new certificate (pending state)
  Future<void> createCertificate({
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
      status: Certificate.pending,
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );
    await _certCollection.doc(certificate.id).set(certificate.toMap());
  }

  // Approve certificate
  Future<void> approveCertificate(String certificateId) async {
    await _certCollection.doc(certificateId).update({
      'status': Certificate.approved,
    });
  }

  // Reject certificate
  Future<void> rejectCertificate(String certificateId) async {
    await _certCollection.doc(certificateId).update({
      'status': Certificate.rejected,
    });
  }

  // Get all certificates for a user (as a stream)
  Stream<List<Certificate>> getUserCertificates(String username) {
    return _certCollection
        .where('createdBy', isEqualTo: username)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) =>
                        Certificate.fromMap(doc.data() as Map<String, dynamic>),
                  )
                  .toList(),
        );
  }

  // Get all pending certificates (for admin, as a stream)
  Stream<List<Certificate>> getPendingCertificates() {
    return _certCollection
        .where('status', isEqualTo: Certificate.pending)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) =>
                        Certificate.fromMap(doc.data() as Map<String, dynamic>),
                  )
                  .toList(),
        );
  }

  // Get all certificates (for admin, as a stream)
  Stream<List<Certificate>> getAllCertificates() {
    return _certCollection.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map(
                (doc) =>
                    Certificate.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList(),
    );
  }
}
