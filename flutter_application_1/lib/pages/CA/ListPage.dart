import 'package:flutter/material.dart';
import '../../models/certificate.dart';
import '../../services/certificate_service.dart';
import 'CertificatePreviewPage.dart';

class ListPage extends StatefulWidget {
  final String username;

  const ListPage({super.key, required this.username});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> with SingleTickerProviderStateMixin {
  final CertificateService _certificateService = CertificateService();
  late final AnimationController _reloadController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _reloadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _reloadController.reset();
        setState(() {}); // rebuild stream
      }
    });
  }

  @override
  void dispose() {
    _reloadController.dispose();
    super.dispose();
  }

  void _onRefreshTapped() => _reloadController.forward();

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case Certificate.approved:
        return Colors.green;
      case Certificate.pending:
        return Colors.orange;
      case Certificate.rejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Icon _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case Certificate.approved:
        return const Icon(Icons.check_circle, color: Colors.white);
      case Certificate.pending:
        return const Icon(Icons.hourglass_top, color: Colors.white);
      case Certificate.rejected:
        return const Icon(Icons.cancel, color: Colors.white);
      default:
        return const Icon(Icons.help, color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('My Certificates'),
        centerTitle: true,
        elevation: 2,
        actions: [
          RotationTransition(
            turns: Tween(begin: 0.0, end: 1.0).animate(_reloadController),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.blue),
              onPressed: _onRefreshTapped,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: (val) => setState(() {
                _searchQuery = val.trim().toLowerCase();
              }),
              decoration: InputDecoration(
                hintText: 'Search certificates by name',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Certificate>>(
              stream: _certificateService.getUserCertificates(widget.username),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('Failed to load certificates.'));
                }
                // Apply filter
                final all = snapshot.data!;
                final filtered = _searchQuery.isEmpty
                    ? all
                    : all
                    .where((c) =>
                    c.recipientName.toLowerCase().contains(_searchQuery))
                    .toList();
                if (filtered.isEmpty) {
                  return const Center(child: Text('No certificates found.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final cert = filtered[i];
                    final statusColor = _getStatusColor(cert.status);

                    // Use same pastel backgrounds
                    final bgColor = statusColor == Colors.green
                        ? Colors.lightBlue.shade50
                        : statusColor == Colors.orange
                        ? Colors.amber.shade50
                        : statusColor == Colors.red
                        ? Colors.pink.shade50
                        : statusColor.withOpacity(0.15);
                    final borderColor = statusColor.withOpacity(0.4);

                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          backgroundColor: statusColor,
                          child: _getStatusIcon(cert.status),
                        ),
                        title: Text(cert.recipientName,
                            style:
                            const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cert.purpose),
                            const SizedBox(height: 4),
                            Text('Organization: ${cert.organization}',
                                style: const TextStyle(fontSize: 12)),
                            Text(
                              'Issued: ${cert.issued.toLocal().toIso8601String().split('T')[0]}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(
                            cert.status.toUpperCase(),
                            style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10),
                          ),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CertificatePreviewPage(
                              recipientName: cert.recipientName,
                              organization: cert.organization,
                              purpose: cert.purpose,
                              issued: cert.issued,
                              expiry: cert.expiry,
                              signatureBytes: cert.signatureBytes,
                              createdBy: cert.createdBy,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
