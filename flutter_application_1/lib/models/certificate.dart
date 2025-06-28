import 'dart:typed_data';

class Certificate {
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';

  final String id;
  final String recipientName;
  final String organization;
  final String purpose;
  final DateTime issued;
  final DateTime expiry;
  final Uint8List signatureBytes;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final String createdBy;

  Certificate({
    required this.id,
    required this.recipientName,
    required this.organization,
    required this.purpose,
    required this.issued,
    required this.expiry,
    required this.signatureBytes,
    this.status = 'pending',
    required this.createdAt,
    required this.createdBy,
  });

  // Change toMap/fromMap for Firestore compatibility
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipientName': recipientName,
      'organization': organization,
      'purpose': purpose,
      'issued': issued.toIso8601String(),
      'expiry': expiry.toIso8601String(),
      'signatureBytes': signatureBytes,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory Certificate.fromMap(Map<String, dynamic> map) {
    return Certificate(
      id: map['id'],
      recipientName: map['recipientName'],
      organization: map['organization'],
      purpose: map['purpose'],
      issued: DateTime.parse(map['issued']),
      expiry: DateTime.parse(map['expiry']),
      signatureBytes: Uint8List.fromList(List<int>.from(map['signatureBytes'])),
      status: map['status'] ?? Certificate.pending,
      createdAt: DateTime.parse(map['createdAt']),
      createdBy: map['createdBy'],
    );
  }
}
