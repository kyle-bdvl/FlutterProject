import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'signaturePage.dart'; // Adjust import if needed
import 'CertificatePreviewPage.dart'; // Your preview page
import '../../services/certificate_service.dart';

class CertificateCreatePage extends StatefulWidget {
  final Function(String, String, String, DateTime, DateTime, Uint8List)
  onDataSaved;
  final String username;

  const CertificateCreatePage({
    super.key,
    required this.onDataSaved,
    required this.username,
  });

  @override
  State<CertificateCreatePage> createState() => _CertificateCreatePageState();
}

class _CertificateCreatePageState extends State<CertificateCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final orgController = TextEditingController();
  final purposeController = TextEditingController();
  DateTime issued = DateTime.now();
  DateTime expiry = DateTime.now().add(const Duration(days: 365));
  final CertificateService _certificateService = CertificateService();
  bool _isSubmitting = false;

  Future<void> pickDate(bool isIssued) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isIssued ? issued : expiry,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isIssued) {
          issued = picked;
        } else {
          expiry = picked;
        }
      });
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final signatureBytes = await Navigator.push<Uint8List>(
        context,
        MaterialPageRoute(builder: (_) => const SignaturePage()),
      );
      if (signatureBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signature not captured.")),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      final confirmed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder:
              (_) => CertificatePreviewPage(
                recipientName: nameController.text,
                organization: orgController.text,
                purpose: purposeController.text,
                issued: issued,
                expiry: expiry,
                signatureBytes: signatureBytes,
                createdBy: widget.username,
              ),
        ),
      );

      if (confirmed == true) {
        await _certificateService.createCertificate(
          recipientName: nameController.text,
          organization: orgController.text,
          purpose: purposeController.text,
          issued: issued,
          expiry: expiry,
          signatureBytes: signatureBytes,
          createdBy: widget.username,
        );
        widget.onDataSaved(
          nameController.text,
          orgController.text,
          purposeController.text,
          issued,
          expiry,
          signatureBytes,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Certificate created successfully and sent for approval!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating certificate: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    orgController.dispose();
    purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // match StatusPage top section background
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Create Certificate"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "Enter Certificate Information",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Recipient Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: orgController,
                decoration: const InputDecoration(labelText: "Organization"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: purposeController,
                decoration: const InputDecoration(labelText: "Purpose"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 20),
              ListTile(
                tileColor: Colors.white,
                title: const Text("Issued Date"),
                subtitle: Text(
                  "${issued.toLocal()}".split(' ')[0],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => pickDate(true),
              ),
              const SizedBox(height: 8),
              ListTile(
                tileColor: Colors.white,
                title: const Text("Expiry Date"),
                subtitle: Text(
                  "${expiry.toLocal()}".split(' ')[0],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => pickDate(false),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[400],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isSubmitting ? null : submit,
                child:
                    _isSubmitting
                        ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Processing...",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        )
                        : const Text(
                          "Next: Add Signature",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
