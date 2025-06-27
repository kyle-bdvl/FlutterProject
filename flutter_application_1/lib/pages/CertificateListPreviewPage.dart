import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'CertificatePreviewPage.dart';

class CertificateData {
  final String name;
  final String organization;
  final String purpose;
  final DateTime issued;
  final DateTime expiry;
  final Uint8List signatureBytes;
  final String createdBy;

  CertificateData({
    required this.name,
    required this.organization,
    required this.purpose,
    required this.issued,
    required this.expiry,
    required this.signatureBytes,
    required this.createdBy,
  });
}

class CertificateListPreviewPage extends StatefulWidget {
  final List<CertificateData> certificates;

  const CertificateListPreviewPage({super.key, required this.certificates});

  @override
  State<CertificateListPreviewPage> createState() =>
      _CertificateListPreviewPageState();
}

class _CertificateListPreviewPageState
    extends State<CertificateListPreviewPage> {
  PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.certificates[_currentIndex].name} (${_currentIndex + 1}/${widget.certificates.length})',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed:
                _currentIndex > 0
                    ? () {
                      _controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    }
                    : null,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed:
                _currentIndex < widget.certificates.length - 1
                    ? () {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    }
                    : null,
          ),
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.certificates.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final cert = widget.certificates[index];
          return CertificatePreviewPage(
            recipientName: cert.name,
            organization: cert.organization,
            purpose: cert.purpose,
            issued: cert.issued,
            expiry: cert.expiry,
            signatureBytes: cert.signatureBytes,
            createdBy: cert.createdBy,
          );
        },
      ),
    );
  }
}
