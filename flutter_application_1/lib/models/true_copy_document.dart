class TrueCopyDocument {
  final String id;
  final String fileUrl;
  final String name;
  final String issuer;
  final String purpose;
  final String dateIssued;
  final String status; // Pending, Approved, Rejected
  final DateTime uploadedAt;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;

  TrueCopyDocument({
    required this.id,
    required this.fileUrl,
    required this.name,
    required this.issuer,
    required this.purpose,
    required this.dateIssued,
    required this.status,
    required this.uploadedAt,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
  });

  factory TrueCopyDocument.fromJson(Map<String, dynamic> json) {
    return TrueCopyDocument(
      id: json['id'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      name: json['name'] ?? '',
      issuer: json['issuer'] ?? '',
      purpose: json['purpose'] ?? '',
      dateIssued: json['dateIssued'] ?? '',
      status: json['status'] ?? 'Pending',
      uploadedAt: DateTime.parse(
        json['uploadedAt'] ?? DateTime.now().toIso8601String(),
      ),
      approvedBy: json['approvedBy'],
      approvedAt:
          json['approvedAt'] != null
              ? DateTime.parse(json['approvedAt'])
              : null,
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileUrl': fileUrl,
      'name': name,
      'issuer': issuer,
      'purpose': purpose,
      'dateIssued': dateIssued,
      'status': status,
      'uploadedAt': uploadedAt.toIso8601String(),
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }

  TrueCopyDocument copyWith({
    String? id,
    String? fileUrl,
    String? name,
    String? issuer,
    String? purpose,
    String? dateIssued,
    String? status,
    DateTime? uploadedAt,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
  }) {
    return TrueCopyDocument(
      id: id ?? this.id,
      fileUrl: fileUrl ?? this.fileUrl,
      name: name ?? this.name,
      issuer: issuer ?? this.issuer,
      purpose: purpose ?? this.purpose,
      dateIssued: dateIssued ?? this.dateIssued,
      status: status ?? this.status,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

class AdminLog {
  final String id;
  final String action; // "Approved", "Rejected"
  final String documentId;
  final String documentName;
  final String adminName;
  final DateTime timestamp;
  final String? reason;

  AdminLog({
    required this.id,
    required this.action,
    required this.documentId,
    required this.documentName,
    required this.adminName,
    required this.timestamp,
    this.reason,
  });

  factory AdminLog.fromJson(Map<String, dynamic> json) {
    return AdminLog(
      id: json['id'] ?? '',
      action: json['action'] ?? '',
      documentId: json['documentId'] ?? '',
      documentName: json['documentName'] ?? '',
      adminName: json['adminName'] ?? '',
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'documentId': documentId,
      'documentName': documentName,
      'adminName': adminName,
      'timestamp': timestamp.toIso8601String(),
      'reason': reason,
    };
  }
}
