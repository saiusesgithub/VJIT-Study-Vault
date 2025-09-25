import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class SubjectRelatedMaterialsPage extends StatelessWidget {
  // Helper to launch a URL
  // void _launchUrl(BuildContext context, String? url) async {
  //   if (url == null || url.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('No URL available for this material.')),
  //     );
  //     return;
  //   }
  //   final uri = Uri.tryParse(url);
  //   if (uri != null && await canLaunchUrl(uri)) {
  //     await launchUrl(uri, mode: LaunchMode.externalApplication);
  //   } else {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('Could not launch URL.')));
  //   }
  // }

  final String subjectName;
  final List<dynamic> allMaterials;
  const SubjectRelatedMaterialsPage({
    super.key,
    required this.subjectName,
    required this.allMaterials,
  });

  @override
  Widget build(BuildContext context) {
    // Filter materials for this subject
    final subjectMaterials = allMaterials
        .where((item) => item['subject'] == subjectName)
        .toList();
    // Get unique types for this subject
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
                    final material = subjectMaterials.firstWhere(
                      (item) => item['type'] == type,
                      orElse: () => null,
                    );
                    final url = material != null ? material['url'] : null;
                    if (url == null || url.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No PDF available for this material.'),
                        ),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: Text(type?.toString() ?? 'Material'),
                            actions: [
                              IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: () async {
                                  try {
                                    final dir =
                                        await getApplicationDocumentsDirectory();
                                    final savePath =
                                        '${dir.path}/${type?.toString() ?? 'material'}.pdf';
                                    await Dio().download(url, savePath);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Downloaded to $savePath',
                                        ),
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
                                Center(child: Text('$progress %')),
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
                        type?.toString() ?? 'Unknown Type',
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
        ],
      ),
    );
  }
}
