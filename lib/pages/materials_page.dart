import 'package:flutter/material.dart';
import 'materials_page_deeper.dart';
import '../utils/material_launcher.dart';

class SubjectRelatedMaterialsPage extends StatelessWidget {
  final String subjectName;
  final List<dynamic> allMaterials;
  const SubjectRelatedMaterialsPage({
    super.key,
    required this.subjectName,
    required this.allMaterials,
  });

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
                  onTap: () async {
                    final typeStr = type?.toString().toLowerCase() ?? '';

                    await MaterialLauncher.logMaterialClick(
                      materialTitle: typeStr,
                      subjectName: subjectName,
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
                      await MaterialLauncher.openInDrive(
                        context,
                        url: url,
                        materialTitle: type?.toString() ?? 'Material',
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
