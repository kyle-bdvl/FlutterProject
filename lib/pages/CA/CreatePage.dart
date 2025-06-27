import 'package:flutter/material.dart';
import 'CertificateCreatePage.dart';

class CreatePage extends StatelessWidget {
  final String username;

  const CreatePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CertificateCreatePage(
                    onDataSaved: (
                      name,
                      org,
                      purpose,
                      issued,
                      expiry,
                      signature,
                    ) {
                      print("Certificate Created");
                    },
                    username: username,
                  ),
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.green,
              child: Icon(Icons.add, size: 50, color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              'Create Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Create new certificates or items here.'),
          ],
        ),
      ),
    );
  }
}
