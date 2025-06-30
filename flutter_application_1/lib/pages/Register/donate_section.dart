import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DonateSection extends StatelessWidget {
  const DonateSection({super.key});

  final String paymentLink = 'https://buy.stripe.com/test_9B69AS0SRgq04L61ZD0Jq00'; // your Stripe payment link

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Buy us a coffee!\nDonate with Stripe',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.coffee),
              label: const Text('Donate with Card / Google Pay'),
              onPressed: () async {
                final url = Uri.parse(paymentLink);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open link')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
