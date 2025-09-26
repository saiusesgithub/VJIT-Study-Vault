import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          MaterialButton(
            onPressed: () {
              // Implement check for new materials
            },
            child: const Text('Check For New Materials'),
          ),
          SegmentedButton(
            // Implement on selection changed
            segments: [
              ButtonSegment(value: 'Light'),
              ButtonSegment(value: 'Dark'),
            ],
            selected: {'Light'},
          ),
          MaterialButton(
            onPressed: () {
              // Implement a feedback form here
            },
            child: const Text('Feedback / Report Bug'),
          ),
          MaterialButton(
            onPressed: () {
              // Implement contribute action here
            },
            child: const Text('Contribute'),
          ),
          Text('Made by sAI sRUJAN from IT@VJIT'),
          Text(
            'icons - github , linkedin , insta',
          ), // Add actual icons with links
        ],
      ),
    );
  }
}

// change branch / year / semester
