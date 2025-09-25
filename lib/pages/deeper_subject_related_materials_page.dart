import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

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
    // Get unique values for the labelKey (e.g., units, years)
    final labelValues =
        materials
            .map((item) => item[labelKey])
            .where((val) => val != null)
            .toSet()
            .toList()
          ..sort();

    return Scaffold(
      appBar: AppBar(title: Text('$subjectName $cardLabelPrefix Options')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: labelValues.length,
          itemBuilder: (context, idx) {
            final labelValue = labelValues[idx];
            return InkWell(
              onTap: () {
                final material = materials.firstWhere(
                  (item) => item[labelKey] == labelValue,
                  orElse: () => null,
                );
                final url = material != null ? material['url'] : null;
                if (url == null || url.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No PDF for $cardLabelPrefix $labelValue'),
                    ),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: Text('$cardLabelPrefix $labelValue'),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () async {
                              try {
                                final dir =
                                    await getApplicationDocumentsDirectory();
                                final savePath =
                                    '${dir.path}/$cardLabelPrefix$labelValue.pdf';
                                await Dio().download(url, savePath);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Downloaded to $savePath'),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Download failed'),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      body: PDF().cachedFromUrl(
                        url,
                        placeholder: (progress) =>
                            Center(child: Text('\u0000$progress %')),
                        errorWidget: (error) =>
                            Center(child: Text('Failed to load PDF')),
                      ),
                    ),
                  ),
                );
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
    );
  }
}
