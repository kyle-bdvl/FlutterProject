import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'Profile.dart';
import 'CreatePage.dart';
import 'ListPage.dart';
import 'SearchPage.dart';

class DashboardPage extends StatefulWidget {
  final String username;
  final String profileImagePath; // Path to user's profile image

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

  // Mock recent certificates data
  final List<Map<String, String>> recentCertificates = [
    {
      'title': 'B.Sc. Computer Science',
      'date': '2023-01-01',
      'status': 'Verified',
    },
    {'title': 'M.Sc. Data Science', 'date': '2024-03-15', 'status': 'Pending'},
    {'title': 'Diploma in AI', 'date': '2022-08-10', 'status': 'Verified'},
  ];

  // Helper to build each page with the same navbar
  Widget _buildPage(Widget page, int selectedIndex) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              // User profile picture
              CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage(widget.profileImagePath),
              ),
              const SizedBox(width: 12),
              // Username
              Text(
                widget.username,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Notification bell
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  size: 30,
                  color: Colors.blue,
                ),
                onPressed: () {
                  // Notification logic here
                },
              ),

              // CSV Upload Button
            ],
          ),
        ),
      ),
      body: page,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          if (index == _selectedIndex) return;
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_rounded),
            label: 'Certificates',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 35),
            label: 'Create',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _dashboardHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile section
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundImage: AssetImage(widget.profileImagePath),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.username,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Welcome back!",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Recent Certificates",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentCertificates.length,
            itemBuilder: (context, index) {
              final cert = recentCertificates[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Icon(
                    cert['status'] == 'Verified'
                        ? Icons.verified
                        : Icons.hourglass_top,
                    color:
                        cert['status'] == 'Verified'
                            ? Colors.green
                            : Colors.orange,
                  ),
                  title: Text(cert['title'] ?? ''),
                  subtitle: Text('Issued: ${cert['date']}'),
                  trailing: Text(
                    cert['status'] ?? '',
                    style: TextStyle(
                      color:
                          cert['status'] == 'Verified'
                              ? Colors.green
                              : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Center(
            child: Column(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.upload_file,
                    size: 30,
                    color: Colors.green,
                  ),
                  tooltip: 'Upload CSV',
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['csv'],
                    );

                    if (result != null && result.files.single.path != null) {
                      final file = File(result.files.single.path!);
                      final contents = await file.readAsString();

                      final csvTable = const CsvToListConverter().convert(
                        contents,
                      );
                      if (csvTable.isNotEmpty) {
                        final headers = List<String>.from(
                          csvTable[0].map((e) => e.toString()),
                        );
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('CSV Headers (Metadata)'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      headers
                                          .map((header) => Text('• $header'))
                                          .toList(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('CSV file is empty.')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No file selected.')),
                      );
                    }
                  },
                ),
                Text("Upload CSV file"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Each index corresponds to a page
    switch (_selectedIndex) {
      case 0:
        return _buildPage(_dashboardHome(), 0);
      case 1:
        return _buildPage(const ListPage(), 1);
      case 2:
        return _buildPage(const CreatePage(), 2);
      case 3:
        return _buildPage(const SearchPage(), 3);
      case 4:
        return _buildPage(const Profile(), 4);
      default:
        return _buildPage(
          Center(child: Text('Page not found')),
          _selectedIndex,
        );
    }
  }
}
