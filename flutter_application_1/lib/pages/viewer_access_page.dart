import 'package:flutter/material.dart';

// Fake "Certificate Viewer" screen
class CertificateViewScreen extends StatelessWidget {
  const CertificateViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Certificate Viewer')),
      body: Center(
        child: Text(
          '🎓 Here is your certificate!',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}

// Viewer Access Screen UI
class ViewerAccessPage extends StatefulWidget {
  const ViewerAccessPage({super.key});

  @override
  _ViewerAccessPageState createState() => _ViewerAccessPageState();
}

class _ViewerAccessPageState extends State<ViewerAccessPage> {
  final TextEditingController tokenController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Access Certificate')),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Input field for token/link
            TextField(
              controller: tokenController,
              decoration: InputDecoration(
                labelText: 'Enter token or link',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20),

            // Access button
            ElevatedButton(
              onPressed: () {
                // Dummy logic: only allow "123456" as correct token
                if (tokenController.text == '123456') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CertificateViewScreen(),
                    ),
                  );
                } else {
                  // Show error message if wrong
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('❌ Access Denied')));
                }
              },
              child: Text('Access Certificate'),
            ),
          ],
        ),
      ),
    );
  }
}
