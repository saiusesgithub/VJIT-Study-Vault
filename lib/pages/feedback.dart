import 'package:flutter/material.dart';

class FeedBack extends StatelessWidget {
  const FeedBack({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: const Text(
            'We value your feedback and suggestions! The Feedback feature is coming soon. Stay tuned to help us improve and make this app better for everyone.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
