import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/true_copy_document.dart';
import '../../services/true_copy_service.dart';
import '../../widgets/my_button.dart';
import '../TrueCopyApprovalPage.dart';
import '../../models/certificate.dart';
import '../../services/certificate_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<TrueCopyDocument> documents = [];
  List<AdminLog> adminLogs = [];
  List<TrueCopyDocument> documentsWithMissingMetadata = [];
  bool isLoading = true;
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final futures = await Future.wait([
        TrueCopyService.fetchDocuments(),
        TrueCopyService.fetchAdminLogs(),
        TrueCopyService.fetchDocumentsWithMissingMetadata(),
      ]);

      setState(() {
        documents = futures[0] as List<TrueCopyDocument>;
        adminLogs = futures[1] as List<AdminLog>;
        documentsWithMissingMetadata = futures[2] as List<TrueCopyDocument>;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar('Error loading dashboard data: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      case 'Missing Metadata':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPendingCertificatesSection() {
    return StreamBuilder<List<Certificate>>(
      stream: CertificateService().getPendingCertificates(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final pendingCerts = snapshot.data!;
        if (pendingCerts.isEmpty) {
          return const Center(child: Text('No pending certificates.'));
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: pendingCerts.length,
          itemBuilder: (context, index) {
            final cert = pendingCerts[index];
            return Card(
              child: ListTile(
                title: Text(cert.recipientName),
                subtitle: Text(
                  'Purpose: ${cert.purpose}\nOrganization: ${cert.organization}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      tooltip: 'Approve',
                      onPressed: () async {
                        await CertificateService().approveCertificate(cert.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Certificate approved!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      tooltip: 'Reject',
                      onPressed: () async {
                        await CertificateService().rejectCertificate(cert.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Certificate rejected!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOverviewSection() {
    final pendingCount =
        documents
            .where(
              (doc) =>
                  doc.status == 'Pending' &&
                  doc.issuer.isNotEmpty &&
                  doc.dateIssued.isNotEmpty,
            )
            .length;
    final approvedCount =
        documents.where((doc) => doc.status == 'Approved').length;
    final rejectedCount =
        documents.where((doc) => doc.status == 'Rejected').length;
    final missingMetadataCount =
        documents
            .where((doc) => doc.issuer.isEmpty || doc.dateIssued.isEmpty)
            .length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Pending Documents',
                  pendingCount.toString(),
                  Colors.orange,
                  Icons.pending,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Approved',
                  approvedCount.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Rejected',
                  rejectedCount.toString(),
                  Colors.red,
                  Icons.cancel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Missing Metadata',
                  missingMetadataCount.toString(),
                  Colors.amber,
                  Icons.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Pending Certificates',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          _buildPendingCertificatesSection(),
          MyButton(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TrueCopyApprovalPage(),
                ),
              );
            },
            text: 'True Copy Approval',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminLogsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Admin Actions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          adminLogs.isEmpty
              ? const Center(
                child: Text(
                  'No admin actions yet',
                  style: TextStyle(color: Colors.grey),
                ),
              )
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: adminLogs.length,
                itemBuilder: (context, index) {
                  final log = adminLogs[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            log.action == 'Approved'
                                ? Colors.green
                                : Colors.red,
                        child: Icon(
                          log.action == 'Approved' ? Icons.check : Icons.close,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        '${log.action} - ${log.documentName}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('By: ${log.adminName}'),
                          Text(
                            DateFormat(
                              'MMM dd, yyyy HH:mm',
                            ).format(log.timestamp),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          if (log.reason != null)
                            Text(
                              'Reason: ${log.reason}',
                              style: const TextStyle(color: Colors.red),
                            ),
                        ],
                      ),
                      isThreeLine: log.reason != null,
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }

  Widget _buildMissingMetadataSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Documents with Missing Metadata',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          documentsWithMissingMetadata.isEmpty
              ? const Center(
                child: Text(
                  'No documents with missing metadata',
                  style: TextStyle(color: Colors.green),
                ),
              )
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: documentsWithMissingMetadata.length,
                itemBuilder: (context, index) {
                  final document = documentsWithMissingMetadata[index];
                  final missingFields = <String>[];
                  if (document.issuer.isEmpty) missingFields.add('Issuer');
                  if (document.dateIssued.isEmpty) {
                    missingFields.add('Date Issued');
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.amber,
                        child: Icon(Icons.warning, color: Colors.white),
                      ),
                      title: Text(
                        document.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: ${document.status}'),
                          Text(
                            'Missing: ${missingFields.join(', ')}',
                            style: const TextStyle(color: Colors.red),
                          ),
                          Text(
                            'Uploaded: ${DateFormat('MMM dd, yyyy').format(document.uploadedAt)}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: MyButton(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => const TrueCopyApprovalPage(),
                            ),
                          );
                        },
                        text: 'Review',
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Container(
                      color: Colors.grey[100],
                      child: const TabBar(
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.blue,
                        tabs: [Tab(text: 'Overview'), Tab(text: 'Admin Logs')],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          SingleChildScrollView(child: _buildOverviewSection()),
                          SingleChildScrollView(
                            child: _buildAdminLogsSection(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
