import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'signaturePage.dart'; // Adjust import if needed
import 'CertificatePreviewPage.dart'; // Your preview page
import '../../services/certificate_service.dart';

class CertificateCreatePage extends StatefulWidget {
  final Function(String, String, String, DateTime, DateTime, Uint8List)
  onDataSaved;
  final String username; // Add username parameter

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
      setState(() => isIssued ? issued = picked : expiry = picked);
    }
  }

  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Navigate to SignaturePage to get signature bytes
        final signatureBytes = await Navigator.push<Uint8List>(
          context,
          MaterialPageRoute(builder: (context) => const SignaturePage()),
        );

        if (signatureBytes != null) {
          // Navigate to CertificatePreviewPage with all details and wait for confirmation
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CertificatePreviewPage(
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

          if (result == true) {
            // Save certificate using the service (status will be 'pending')
            await _certificateService.createCertificate(
              recipientName: nameController.text,
              organization: orgController.text,
              purpose: purposeController.text,
              issued: issued,
              expiry: expiry,
              signatureBytes: signatureBytes,
              createdBy: widget.username,
            );

            // Call onDataSaved callback if user confirmed
            widget.onDataSaved(
              nameController.text,
              orgController.text,
              purposeController.text,
              issued,
              expiry,
              signatureBytes,
            );

            // Show success message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Certificate created successfully and sent for approval!',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }

            // Close this page
            if (mounted) {
              Navigator.pop(context);
            }
          }
        } else {
          // User didn't provide signature or canceled
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Signature not captured, try again"),
              ),
            );
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
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
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
      appBar: AppBar(title: const Text("Create Certificate")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "Enter Certificate Info",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Recipient Name"),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: orgController,
                decoration: const InputDecoration(labelText: "Organization"),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: purposeController,
                decoration: const InputDecoration(labelText: "Purpose"),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Issued Date"),
                    Text(
                      "${issued.toLocal()}".split(' ')[0],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => pickDate(true),
              ),

              ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Expiry Date"),
                    Text(
                      "${expiry.toLocal()}".split(' ')[0],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => pickDate(false),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : submit,
                child:
                    _isSubmitting
                        ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text("Processing..."),
                          ],
                        )
                        : const Text("Next: Add Signature"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
