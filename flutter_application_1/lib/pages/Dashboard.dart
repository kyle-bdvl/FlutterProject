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

  // Helper to build each page with the same navbar
  Widget _buildPage(Widget page, int selectedIndex) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

  @override
  Widget build(BuildContext context) {
    // Each index corresponds to a page
    switch (_selectedIndex) {
      case 0:
        return _buildPage(
          Center(
            child: Text(
              'Welcome to your Dashboard, ${widget.username}!',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          0,
        );
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
