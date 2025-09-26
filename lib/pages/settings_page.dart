import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () {
                  // Implement check for new materials
                },
                child: const Text('Check For New Materials'),
              ),
              const SizedBox(height: 16),
              SegmentedButton(
                // Implement on selection changed
                segments: [
                  ButtonSegment(value: 'Light'),
                  ButtonSegment(value: 'Dark'),
                ],
                selected: {'Light'},
              ),
              const SizedBox(height: 16),
              MaterialButton(
                onPressed: () {
                  // Implement a feedback form here
                },
                child: const Text('Feedback / Report Bug'),
              ),
              const SizedBox(height: 16),
              MaterialButton(
                onPressed: () {
                  // Implement contribute action here
                },
                child: const Text('Contribute'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Made by sAI sRUJAN from IT@VJIT',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Ionicons.logo_github),
                    onPressed: () {
                      launchUrl('https://github.com/saiusesgithub' as Uri);
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Ionicons.logo_linkedin),
                    onPressed: () {
                      launchUrl(
                        'https://linkedin.com/in/saisrujanpunati' as Uri,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Ionicons.logo_instagram),
                    onPressed: () {
                      launchUrl('https://instagram.com/__saisrujan__' as Uri);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// change branch / year / semester
