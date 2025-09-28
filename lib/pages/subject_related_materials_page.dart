import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:pdfx/pdfx.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'deeper_subject_related_materials_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:permission_handler/permission_handler.dart';

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
      body: RefreshIndicator(
        onRefresh: () async {
          // No remote fetch here, so just pop and push to force parent reload
          Navigator.of(context).pop();
        },
        child: ListView(
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfViewerPage(
                              url: url,
                              title: type?.toString() ?? 'Material',
                              subjectName: subjectName,
                            ),
                          ),
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
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PdfViewerPage extends StatefulWidget {
  final String url;
  final String title;
  final String subjectName;

  const PdfViewerPage({
    super.key,
    required this.url,
    required this.title,
    required this.subjectName,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late PdfControllerPinch pdfController;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePdf();
  }

  Future<void> _initializePdf() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      pdfController = PdfControllerPinch(
        document: PdfDocument.openData(
          Dio()
              .get(
                widget.url,
                options: Options(responseType: ResponseType.bytes),
              )
              .then((response) => response.data),
        ),
      );

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load PDF: ${e.toString()}';
      });
    }
  }

  Future<void> _downloadPdf() async {
    try {
      // Request storage permission
      PermissionStatus status = await Permission.storage.request();

      if (status.isGranted) {
        Directory? downloadsDir;
        if (Platform.isAndroid) {
          downloadsDir = Directory('/storage/emulated/0/Download');
          if (!downloadsDir.existsSync()) {
            downloadsDir = await getExternalStorageDirectory();
          }
        } else {
          downloadsDir = await getApplicationDocumentsDirectory();
        }

        if (downloadsDir != null) {
          final fileName = '${widget.subjectName}_${widget.title}.pdf';
          final savePath = '${downloadsDir.path}/$fileName';

          await Dio().download(widget.url, savePath);

          // Log download event to Firebase Analytics
          await FirebaseAnalytics.instance.logEvent(
            name: 'download_button_clicked',
            parameters: {
              'subject_name': widget.subjectName,
              'material_title': widget.title,
            },
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Downloaded to Downloads/$fileName'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception('Could not access downloads directory');
        }
      } else if (status.isDenied) {
        // Permission denied
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to download files.'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (status.isPermanentlyDenied) {
        // Permission permanently denied, open app settings
        openAppSettings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: _downloadPdf),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading PDF...'),
                ],
              ),
            )
          : errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initializePdf,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : PdfViewPinch(controller: pdfController),
    );
  }

  @override
  void dispose() {
    pdfController.dispose();
    super.dispose();
  }
}
