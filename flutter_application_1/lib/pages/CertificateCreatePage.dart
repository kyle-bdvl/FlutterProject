import 'package:flutter/material.dart';

class CertificateCreatePage extends StatefulWidget {
  final Function(String, String, String, DateTime, DateTime) onDataSaved;
  const CertificateCreatePage({Key? key, required this.onDataSaved})
    : super(key: key);

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

  void submit() {
    if (_formKey.currentState!.validate()) {
      widget.onDataSaved(
        nameController.text,
        orgController.text,
        purposeController.text,
        issued,
        expiry,
      );
    }
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
                title: Text("Issued: ${issued.toLocal()}".split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => pickDate(true),
              ),
              ListTile(
                title: Text("Expiry: ${expiry.toLocal()}".split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => pickDate(false),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submit,
                child: const Text("Next: Add Signature"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
