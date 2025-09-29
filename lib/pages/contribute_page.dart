import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

class ContributePage extends StatefulWidget {
  const ContributePage({super.key});

  @override
  State<ContributePage> createState() => _ContributePageState();
}

class _ContributePageState extends State<ContributePage> {
  List<String> contributors = [];

  @override
  void initState() {
    super.initState();
    _loadContributors();
  }

  Future<void> _loadContributors() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://vjit-study-vault.web.app/contributors.json',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          contributors = data.cast<String>();
        });
      } else {
        throw Exception('Failed to load contributors');
      }
    } catch (e) {
      setState(() {
        contributors = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching contributors: $e')),
      );
    }
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
                    'Contribute your PDFs or Google Drive links via WhatsApp. Your contributions will help countless students. Your name will be featured here forever, visible to countless students!',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Featured Contributors',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: contributors.isEmpty
                  ? const Center(
                      child: Text(
                        'No contributors yet. Your name could be here!',
                      ),
                    )
                  : ListView.builder(
                      itemCount: contributors.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(contributors[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
