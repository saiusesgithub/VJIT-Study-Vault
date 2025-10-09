import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:url_launcher/url_launcher.dart';

class MaterialLauncher {
  static Future<void> openInDrive(
    BuildContext context, {
    required String url,
    required String materialTitle,
    required String subjectName,
  }) async {
    try {
      FirebaseAnalytics.instance.logEvent(
        name: 'file_opened_in_drive',
        parameters: {
          'material_title': materialTitle,
          'subject_name': subjectName,
        },
      );

      final viewUrl = _getDriveViewUrl(url);
      final launched = await launchUrl(
        Uri.parse(viewUrl),
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Could not open the material');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening material...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open material: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static String _getDriveViewUrl(String url) {
    final match = RegExp(r'(?:id=|/d/)([A-Za-z0-9_-]{10,})').firstMatch(url);
    if (match != null) {
      final id = match.group(1);
      return 'https://drive.google.com/file/d/$id/view';
    }
    return url;
  }

  static Future<void> openVideo(
    BuildContext context, {
    required String url,
  }) async {
    final launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the video link.'),
        ),
      );
    }
  }
  static Future<void> logMaterialClick({
    required String materialTitle,
    required String subjectName,
  }) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'material_clicked',
      parameters: {
        'material_title': materialTitle,
        'subject_name': subjectName,
      },
    );
  }
}
