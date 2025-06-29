import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/pages/Register/login_page.dart';
import 'package:flutter_application_1/pages/CA/CreatePage.dart';
import 'package:flutter_application_1/pages/CA/Profile.dart';
import 'package:flutter_application_1/pages/CA/status_page.dart';
import 'package:flutter_application_1/pages/CA/ListPage.dart';
import '../../models/certificate.dart';
import '../../services/certificate_service.dart';
import '../CA/CertificatePreviewPage.dart';

class DashboardPage extends StatefulWidget {
  final String username;
  final String profileImagePath;

  const DashboardPage({
    super.key,
    required this.username,
    required this.profileImagePath,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final CertificateService _certificateService = CertificateService();

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

  Icon _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Icon(Icons.check_circle, color: Colors.white, size: 16);
      case 'rejected':
        return const Icon(Icons.cancel, color: Colors.white, size: 16);
      case 'pending':
        return const Icon(Icons.hourglass_top, color: Colors.white, size: 16);
      default:
        return const Icon(Icons.help, color: Colors.white, size: 16);
    }
  }

  Future<void> _confirmAndSignOut() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MediaQuery.of(context).size.width * 0.05;

    Widget body;
    switch (_selectedIndex) {
      case 1:
        body = ListPage(username: widget.username);
        break;
      case 2:
        body = CreatePage(username: widget.username);
        break;
      case 3:
        body = StatusPage(username: widget.username);
        break;
      case 4:
        body = const Profile();
        break;
      case 0:
      default:
        body = CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recipient Dashboard label
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Recipient Dashboard',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Greeting card
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage:
                              AssetImage(widget.profileImagePath),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, ${widget.username}',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                      'Here’s your dashboard overview'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Data-driven stats & recent certificates
                    StreamBuilder<List<Certificate>>(
                      stream: _certificateService
                          .getUserCertificates(widget.username),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final allCerts = snapshot.data ?? [];

                        // totals
                        final approvedCount = allCerts
                            .where((c) =>
                        c.status.toLowerCase() == 'approved')
                            .length;
                        final pendingCount = allCerts
                            .where((c) =>
                        c.status.toLowerCase() == 'pending')
                            .length;
                        final rejectedCount = allCerts
                            .where((c) =>
                        c.status.toLowerCase() == 'rejected')
                            .length;

                        // latest three
                        final recentThree = allCerts.take(3).toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _buildStatCard(
                                    'Approved', approvedCount, Colors.green),
                                const SizedBox(width: 8),
                                _buildStatCard(
                                    'Pending', pendingCount, Colors.orange),
                                const SizedBox(width: 8),
                                _buildStatCard(
                                    'Rejected', rejectedCount, Colors.red),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Latest 3 Certificates',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 220,
                              child: recentThree.isEmpty
                                  ? const Center(
                                  child:
                                  Text('No recent certificates'))
                                  : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: recentThree.length,
                                separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                                itemBuilder: (context, i) =>
                                    _buildCertificateCard(
                                        recentThree[i]),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: ElevatedButton(
                                onPressed: () =>
                                    setState(() => _selectedIndex = 1),
                                child:
                                const Text('View All Certificates'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 90,
        titleSpacing: 0,
        title: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 10,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage(widget.profileImagePath),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Logout with confirmation
              IconButton(
                icon: const Icon(Icons.logout, size: 30, color: Colors.blue),
                onPressed: _confirmAndSignOut,
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(bottom: false, child: body),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (idx) {
          if (idx == _selectedIndex) return;
          setState(() => _selectedIndex = idx);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_rounded), label: 'Certificates'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle, size: 35), label: 'Create'),
          BottomNavigationBarItem(
              icon: Icon(Icons.verified_user), label: 'Status'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    final bgColor = color.withOpacity(0.1);
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text('$count',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateCard(Certificate cert) {
    final statusColor = _getStatusColor(cert.status);
    return GestureDetector(
      onTap: () {
        Navigator.push(
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
        );
      },
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: statusColor,
              child: _getStatusIcon(cert.status),
            ),
            const SizedBox(height: 8),
            Text(
              cert.recipientName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              cert.organization,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              cert.purpose,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              cert.status.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: statusColor),
            ),
            const SizedBox(height: 6),
            Text(
              cert.issued
                  .toLocal()
                  .toIso8601String()
                  .split('T')[0],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
