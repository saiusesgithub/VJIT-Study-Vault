import 'package:flutter/material.dart';
import '../utils/material_launcher.dart';

class DeeperSubjectRelatedMaterialsPage extends StatelessWidget {
  final String subjectName;
  final List<dynamic> materials;
  final String labelKey; // e.g. 'unit', 'pyq_year'
  final String cardLabelPrefix; // e.g. 'Unit', 'Year', 'Type'
  const DeeperSubjectRelatedMaterialsPage({
    super.key,
    required this.subjectName,
    required this.materials,
    required this.labelKey,
    required this.cardLabelPrefix,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$subjectName $cardLabelPrefix Options',
          style: const TextStyle(fontFamily: 'Orbitron'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // No remote fetch here, so just pop and push to force parent reload
          Navigator.of(context).pop();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: materials.length,
            itemBuilder: (context, idx) {
              final material = materials[idx];
              final labelValue = material[labelKey];
              final url = material['url'];

              return InkWell(
                onTap: () async {
                  if (url == null || url.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'No content available for $cardLabelPrefix $labelValue',
                        ),
                      ),
                    );
                    return;
                  }

                  if (material['type'] == 'Video') {
                    await MaterialLauncher.openVideo(context, url: url);
                  } else {
                    await MaterialLauncher.openInDrive(
                      context,
                      url: url,
                      materialTitle: '$cardLabelPrefix $labelValue',
                      subjectName: subjectName,
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
                      '$cardLabelPrefix $labelValue',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Orbitron',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
