import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

class ContributePage extends StatefulWidget {
  const ContributePage({super.key});

  @override
  State<ContributePage> createState() => _ContributePageState();
}

class _ContributePageState extends State<ContributePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contribute')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contribute to VJIT Study Vault',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    final Uri whatsappUri = Uri(
                      scheme: 'https',
                      host: 'wa.me',
                      path: '7569799199',
                    );
                    launchUrl(whatsappUri);
                  },
                  child: const Icon(Ionicons.logo_whatsapp),
                ),
                const SizedBox(height: 8),
                const Flexible(
                  child: Text(
                    'Contribute your PDFs or Google Drive links via WhatsApp. Your contributions will help countless students.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
