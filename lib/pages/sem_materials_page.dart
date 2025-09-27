import 'package:flutter/material.dart';
import 'package:vjitstudyvault/pages/subject_related_materials_page.dart';

class SemMaterialsPage extends StatelessWidget {
  final int? year;
  final int? semester;
  final String? branch;
  final List<dynamic> materials;
  final bool materialsLoaded;
  final Future<void> Function() loadMaterials;

  const SemMaterialsPage({
    super.key,
    required this.year,
    required this.semester,
    required this.branch,
    required this.materials,
    required this.materialsLoaded,
    required this.loadMaterials,
  });

  String numberWithSuffix(int? year) {
    if (year == null) return '';
    switch (year) {
      case 1:
        return '1st';
      case 2:
        return '2nd';
      case 3:
        return '3rd';
      case 4:
        return '4th';
      default:
        return '$year';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredMaterials = <dynamic>[];
    final seenSubjects = <String>{};
    for (var item in materials) {
      if (item['year'] == year &&
          item['semester'] == semester &&
          item['branch'] == branch &&
          !seenSubjects.contains(item['subject'])) {
        filteredMaterials.add(item);
        seenSubjects.add(item['subject']);
      }
    }
    return RefreshIndicator(
      onRefresh: loadMaterials,
      child: Builder(
        builder: (context) {
          if (!materialsLoaded) {
            return ListView(
              children: const [
                SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
            children: [
              Text(
                'Materials Of '
                '${numberWithSuffix(year)} year '
                '${numberWithSuffix(semester)} sem of '
                '${branch ?? 'Not set'} branch',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Orbitron',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
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
                  itemCount: filteredMaterials.length,
                  itemBuilder: (context, index) {
                    final item = filteredMaterials[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubjectRelatedMaterialsPage(
                              subjectName: item['subject'],
                              allMaterials: materials,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item['subject'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: 'Orbitron',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              item['textbook_url'] != null
                                  ? Image.network(
                                      item['textbook_url'],
                                      height: 40,
                                      width: 40,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.book,
                                              size: 40,
                                              color: Colors.grey,
                                            );
                                          },
                                    )
                                  : const Icon(
                                      Icons.book,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
