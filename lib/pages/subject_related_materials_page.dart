import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'deeper_subject_related_materials_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class SubjectRelatedMaterialsPage extends StatelessWidget {
  final String subjectName;
  final List<dynamic> allMaterials;
  const SubjectRelatedMaterialsPage({
    super.key,
    required this.subjectName,
    required this.allMaterials,
  });

  Future<void> _openInDrive(
    BuildContext context,
    String url,
    String materialTitle,
  ) async {
    try {
      FirebaseAnalytics.instance.logEvent(
        name: 'file_opened_in_drive',
        parameters: {
          'material_title': materialTitle,
          'subject_name': subjectName,
        },
      );
      final viewUrl = _driveViewUrl(url);
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
            content: Text('Opening material in Google Drive...'),
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

  String _driveViewUrl(String url) {
    final match = RegExp(r'(?:id=|/d/)([A-Za-z0-9_-]{10,})').firstMatch(url);
    if (match != null) {
      final id = match.group(1);
      return 'https://drive.google.com/file/d/$id/view';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final subjectMaterials = allMaterials
        .where((item) => item['subject'] == subjectName)
        .toList();
    final uniqueTypes = subjectMaterials
        .map((item) => item['type'])
        .toSet()
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '$subjectName Materials',
          style: const TextStyle(fontFamily: 'Orbitron'),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: uniqueTypes.length,
              itemBuilder: (context, index) {
                final type = uniqueTypes[index];
                return InkWell(
                  onTap: () {
                    final typeStr = type?.toString().toLowerCase() ?? '';

                    FirebaseAnalytics.instance.logEvent(
                      name: 'download_button_clicked',
                      parameters: {
                        'material_title': typeStr,
                        'subject_name': subjectName,
                      },
                    );

                    if (typeStr == 'notes') {
                      final notesMaterials = subjectMaterials
                          .where(
                            (item) =>
                                (item['type']?.toString().toLowerCase() ??
                                    '') ==
                                'notes',
                          )
                          .toList();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DeeperSubjectRelatedMaterialsPage(
                                subjectName: subjectName,
                                materials: notesMaterials,
                                labelKey: 'unit',
                                cardLabelPrefix: 'Unit',
                              ),
                        ),
                      );
                    } else if (typeStr == 'pyq' ||
                        typeStr == 'previous year' ||
                        typeStr == 'previous year question paper') {
                      final pyqMaterials = subjectMaterials
                          .where(
                            (item) =>
                                (item['type']?.toString().toLowerCase() ??
                                    '') ==
                                typeStr,
                          )
                          .toList();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DeeperSubjectRelatedMaterialsPage(
                                subjectName: subjectName,
                                materials: pyqMaterials,
                                labelKey: 'pyq_year',
                                cardLabelPrefix: 'Year',
                              ),
                        ),
                      );
                    } else {
                      final material = subjectMaterials.firstWhere(
                        (item) => item['type'] == type,
                        orElse: () => null,
                      );
                      final url = material != null ? material['url'] : null;
                      if (url == null || url.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'No PDF available for this material.',
                            ),
                          ),
                        );
                        return;
                      }
                      _openInDrive(
                        context,
                        url,
                        type?.toString() ?? 'Material',
                      );
                    }
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        type?.toString() ?? 'Unknown Type',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Orbitron',
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
