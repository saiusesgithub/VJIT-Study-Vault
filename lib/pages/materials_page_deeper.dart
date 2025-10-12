import 'package:flutter/material.dart';
import '../utils/material_launcher.dart';
import '../utils/glassmorphic_elements.dart';
import '../utils/animations.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '$subjectName $cardLabelPrefix Options',
          style: const TextStyle(
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A237E), Color(0xFF0D47A1), Color(0xFF00838F)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: RefreshIndicator(
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

                return StaggeredAnimation(
                  index: idx,
                  child: ScaleAnimation(
                    child: InkWell(
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
                    child: GlassmorphicContainer(
                      blur: 8,
                      opacity: 0.25,
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          '$cardLabelPrefix $labelValue',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Orbitron',
                            fontSize: 15,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black38,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
