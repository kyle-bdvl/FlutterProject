import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/certificate_service.dart';
import 'CertificatePreviewPage.dart';

class CertificateData {
  final String name;
  final String organization;
  final String purpose;
  final DateTime issued;
  final DateTime expiry;
  final Uint8List signatureBytes;
  final String createdBy;
  // Add this field if you want to track per-certificate
  final bool fromCsv;

  CertificateData({
    required this.name,
    required this.organization,
    required this.purpose,
    required this.issued,
    required this.expiry,
    required this.signatureBytes,
    required this.createdBy,
    this.fromCsv = false,
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
  final PageController _controller = PageController();
  int _currentIndex = 0;
  bool _isSavingAll = false; // Add to your state

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon:
                    _isSavingAll
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.save_alt),
                label: Text(
                  _isSavingAll ? 'Saving...' : 'Save All Certificates',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed:
                    _isSavingAll
                        ? null
                        : () async {
                          setState(() {
                            _isSavingAll = true;
                          });
                          int savedCount = 0;
                          for (final cert in widget.certificates) {
                            try {
                              await CertificateService().createCertificate(
                                recipientName: cert.name,
                                organization: cert.organization,
                                purpose: cert.purpose,
                                issued: cert.issued,
                                expiry: cert.expiry,
                                signatureBytes: cert.signatureBytes,
                                createdBy: cert.createdBy,
                              );
                              savedCount++;
                            } catch (_) {}
                          }
                          setState(() {
                            _isSavingAll = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Saved $savedCount of ${widget.certificates.length} certificates!',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
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
                  fromListPage: true, // <-- Pass this
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
