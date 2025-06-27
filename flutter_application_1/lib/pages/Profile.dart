import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  final String? username;
  final String? profileImagePath;
  final int certificatesCount;
  final int verifiedCount;
  final int pendingCount;

  const Profile({
    super.key,
    this.username,
    this.profileImagePath,
    this.certificatesCount = 0,
    this.verifiedCount = 0,
    this.pendingCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile picture
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  profileImagePath != null
                      ? AssetImage(profileImagePath!)
                      : const AssetImage('lib/images/default_profile.png'),
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 16),
            // Username
            Text(
              username ?? "User",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "Welcome to your profile!",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // Stats
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStat(
                      "Certificates",
                      certificatesCount,
                      Icons.description,
                      Colors.blue,
                    ),
                    _buildStat(
                      "Verified",
                      verifiedCount,
                      Icons.verified,
                      Colors.green,
                    ),
                    _buildStat(
                      "Pending",
                      pendingCount,
                      Icons.hourglass_top,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Actions
            ListTile(
              leading: const Icon(Icons.list_alt, color: Colors.blue),
              title: const Text('My Certificates'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pushNamed(context, '/certificates');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text('Settings'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to settings page (implement if needed)
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Implement logout logic
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}
