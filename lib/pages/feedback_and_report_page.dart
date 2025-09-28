import 'package:flutter/material.dart';

class FeedbackAndReportPage extends StatelessWidget {
  const FeedbackAndReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback & Report')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: const Text(
            'We value your feedback and suggestions! The Feedback and Report feature is coming soon. Stay tuned to help us improve and make this app better for everyone.',
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
