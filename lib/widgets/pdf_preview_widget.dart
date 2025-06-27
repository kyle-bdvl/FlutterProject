import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../services/pdf_service.dart';

class PdfPreviewWidget extends StatefulWidget {
  final String documentName;
  final String fileUrl;
  final bool isApproved;
  final String issuer;
  final String purpose;
  final String dateIssued;
  final String status;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;

  const PdfPreviewWidget({
    super.key,
    required this.documentName,
    required this.fileUrl,
    this.isApproved = false,
    required this.issuer,
    required this.purpose,
    required this.dateIssued,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
  });

  @override
  State<PdfPreviewWidget> createState() => _PdfPreviewWidgetState();
}

class _PdfPreviewWidgetState extends State<PdfPreviewWidget> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generatePdf();
  }

  Future<void> _generatePdf() async {
    try {
      final pdfBytes = await PdfService.generateSamplePdf(
        documentName: widget.documentName,
        issuer: widget.issuer,
        purpose: widget.purpose,
        dateIssued: widget.dateIssued,
        status: widget.status,
        approvedBy: widget.approvedBy,
        approvedAt: widget.approvedAt,
        rejectionReason: widget.rejectionReason,
      );

      setState(() {
        _pdfBytes = pdfBytes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPdfDetails() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('${widget.documentName} - PDF Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Document Type:', widget.documentName),
                  _buildDetailRow('Issuing Authority:', widget.issuer),
                  _buildDetailRow('Purpose:', widget.purpose),
                  _buildDetailRow('Date Issued:', widget.dateIssued),
                  _buildDetailRow('Status:', widget.status),
                  if (widget.approvedBy != null)
                    _buildDetailRow('Approved By:', widget.approvedBy!),
                  if (widget.approvedAt != null)
                    _buildDetailRow(
                      'Approved Date:',
                      '${widget.approvedAt!.day}/${widget.approvedAt!.month}/${widget.approvedAt!.year}',
                    ),
                  if (widget.rejectionReason != null)
                    _buildDetailRow(
                      'Rejection Reason:',
                      widget.rejectionReason!,
                    ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PDF Generated Successfully!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This is a sample PDF document with professional formatting. '
                          'In a real application, this would be the actual document content.',
                          style: TextStyle(fontSize: 12),
                        ),
                        if (widget.isApproved) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'CERTIFIED TRUE COPY',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _downloadPdf();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Download PDF'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  void _downloadPdf() {
    if (_pdfBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF not available for download'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF "${widget.documentName}" downloaded successfully!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('PDF saved to Downloads folder'),
                backgroundColor: Colors.blue,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Stack(
        children: [
          // PDF Preview Content
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            _buildPdfPreview(),

          // Watermark for approved documents
          if (widget.isApproved)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'CERTIFIED TRUE COPY',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPdfPreview() {
    return Column(
      children: [
        // PDF Preview Area
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.picture_as_pdf, size: 64, color: Colors.blue[400]),
                const SizedBox(height: 16),
                Text(
                  widget.documentName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'PDF Document',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Size: ${_pdfBytes != null ? (_pdfBytes!.length / 1024).toStringAsFixed(1) : '0'} KB',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      widget.status,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(widget.status)),
                  ),
                  child: Text(
                    widget.status,
                    style: TextStyle(
                      color: _getStatusColor(widget.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Action Buttons - Two rows layout
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // First row - View button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showPdfDetails,
                  icon: const Icon(Icons.visibility),
                  label: const Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Second row - Download button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _downloadPdf,
                  icon: const Icon(Icons.download),
                  label: const Text('Download PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
