import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/true_copy_document.dart';
import '../services/true_copy_service.dart';
import '../widgets/my_button.dart';
import '../widgets/pdf_preview_widget.dart';

class TrueCopyApprovalPage extends StatefulWidget {
  const TrueCopyApprovalPage({super.key});

  @override
  State<TrueCopyApprovalPage> createState() => _TrueCopyApprovalPageState();
}

class _TrueCopyApprovalPageState extends State<TrueCopyApprovalPage> {
  List<TrueCopyDocument> documents = [];
  List<TrueCopyDocument> filteredDocuments = [];
  bool isLoading = true;
  String selectedStatus = 'All';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final docs = await TrueCopyService.fetchDocuments();
      setState(() {
        documents = docs;
        filteredDocuments = docs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showSnackBar('Error loading documents: $e', isError: true);
    }
  }

  void _filterDocuments() {
    setState(() {
      filteredDocuments =
          documents.where((doc) {
            final matchesStatus =
                selectedStatus == 'All' || doc.status == selectedStatus;
            final matchesSearch =
                searchQuery.isEmpty ||
                doc.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                doc.issuer.toLowerCase().contains(searchQuery.toLowerCase()) ||
                doc.purpose.toLowerCase().contains(searchQuery.toLowerCase());
            return matchesStatus && matchesSearch;
          }).toList();
    });
  }

  Future<void> _approveDocument(TrueCopyDocument document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Approval'),
            content: Text(
              'Are you sure you want to approve "${document.name}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Approve'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        isLoading = true;
      });

      try {
        final success = await TrueCopyService.approveDocument(
          document.id,
          'Admin User',
        );
        if (success) {
          _showSnackBar('Document approved successfully!');
          _loadDocuments(); // Reload to get updated data
        } else {
          _showSnackBar('Failed to approve document', isError: true);
        }
      } catch (e) {
        _showSnackBar('Error approving document: $e', isError: true);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _rejectDocument(TrueCopyDocument document) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reject Document'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Are you sure you want to reject "${document.name}"?'),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Rejection Reason',
                    border: OutlineInputBorder(),
                    hintText: 'Enter reason for rejection...',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Reject'),
              ),
            ],
          ),
    );

    if (confirmed == true && reasonController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      try {
        final success = await TrueCopyService.rejectDocument(
          document.id,
          'Admin User',
          reasonController.text,
        );
        if (success) {
          _showSnackBar('Document rejected successfully!');
          _loadDocuments(); // Reload to get updated data
        } else {
          _showSnackBar('Failed to reject document', isError: true);
        }
      } catch (e) {
        _showSnackBar('Error rejecting document: $e', isError: true);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _viewDocument(TrueCopyDocument document) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(document.name),
            content: SingleChildScrollView(
              child: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDocumentInfo(document),
                    const SizedBox(height: 16),
                    PdfPreviewWidget(
                      documentName: document.name,
                      fileUrl: document.fileUrl,
                      isApproved: document.status == 'Approved',
                      issuer:
                          document.issuer.isEmpty
                              ? 'Not specified'
                              : document.issuer,
                      purpose: document.purpose,
                      dateIssued:
                          document.dateIssued.isEmpty
                              ? 'Not specified'
                              : document.dateIssued,
                      status: document.status,
                      approvedBy: document.approvedBy,
                      approvedAt: document.approvedAt,
                      rejectionReason: document.rejectionReason,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildDocumentInfo(TrueCopyDocument document) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          'Issuer:',
          document.issuer.isEmpty ? 'Not specified' : document.issuer,
        ),
        _buildInfoRow('Purpose:', document.purpose),
        _buildInfoRow(
          'Date Issued:',
          document.dateIssued.isEmpty ? 'Not specified' : document.dateIssued,
        ),
        _buildInfoRow('Status:', document.status),
        _buildInfoRow(
          'Uploaded:',
          DateFormat('MMM dd, yyyy').format(document.uploadedAt),
        ),
        if (document.approvedBy != null)
          _buildInfoRow('Approved by:', document.approvedBy!),
        if (document.rejectionReason != null)
          _buildInfoRow('Rejection reason:', document.rejectionReason!),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
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
      default:
        return Colors.grey;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('True Copy Approval'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search documents...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    searchQuery = value;
                    _filterDocuments();
                  },
                ),
                const SizedBox(height: 12),
                // Status Filter
                Row(
                  children: [
                    const Text('Filter by status: '),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: selectedStatus,
                      items:
                          ['All', 'Pending', 'Approved', 'Rejected']
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                        _filterDocuments();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Documents List
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredDocuments.isEmpty
                    ? const Center(
                      child: Text(
                        'No documents found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredDocuments.length,
                      itemBuilder: (context, index) {
                        final document = filteredDocuments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Document Header
                                Row(
                                  children: [
                                    Icon(
                                      Icons.description,
                                      color: _getStatusColor(document.status),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        document.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(document.status),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        document.status,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Document Info
                                _buildDocumentInfo(document),
                                const SizedBox(height: 16),
                                // Action Buttons
                                Column(
                                  children: [
                                    // First row - View button
                                    SizedBox(
                                      width: double.infinity,
                                      child: MyButton(
                                        onTap: () => _viewDocument(document),
                                        text: 'View',
                                      ),
                                    ),
                                    if (document.status == 'Pending') ...[
                                      const SizedBox(height: 8),
                                      // Second row - Approve and Reject buttons
                                      Row(
                                        children: [
                                          Expanded(
                                            child: MyButton(
                                              onTap:
                                                  () => _approveDocument(
                                                    document,
                                                  ),
                                              text: 'Approve',
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: MyButton(
                                              onTap:
                                                  () =>
                                                      _rejectDocument(document),
                                              text: 'Reject',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
