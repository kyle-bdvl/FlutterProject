import 'package:flutter/material.dart';

// This screen lets the user simulate sharing a certificate link
class ShareCertificatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with the screen title
      appBar: AppBar(title: Text('Share Certificate')),

      // Main body content
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Add spacing around the content
        child: Column(
          children: [
            // Input field for the user's email (just for UI, not functional yet)
            TextField(
              decoration: InputDecoration(labelText: 'Enter email to share with'),
            ),

            SizedBox(height: 20), // Space between input and button

            // A button that "pretends" to generate a share link
            ElevatedButton(
              onPressed: () {
                // When clicked, show a fake link using a snack bar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Link generated: example.com/abc123')),
                );
              },
              child: Text('Generate Share Link'),
            ),
          ],
        ),
      ),
    );
  }
}
