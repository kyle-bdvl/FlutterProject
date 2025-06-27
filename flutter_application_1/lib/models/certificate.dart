import 'dart:typed_data';

class Certificate {
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

  Map<String, dynamic> toJson() {
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

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'],
      recipientName: json['recipientName'],
      organization: json['organization'],
      purpose: json['purpose'],
      issued: DateTime.parse(json['issued']),
      expiry: DateTime.parse(json['expiry']),
      signatureBytes: Uint8List.fromList(
        List<int>.from(json['signatureBytes']),
      ),
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'],
    );
  }
}
