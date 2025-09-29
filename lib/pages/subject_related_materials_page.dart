import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdfx/pdfx.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'deeper_subject_related_materials_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:android_intent_plus/android_intent.dart';

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

                      // Log download/redirect event
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
                          overflow: TextOverflow
                              .ellipsis, // Added to handle long text
                          maxLines: 2, // Limits the text to 2 lines
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
  PdfControllerPinch? pdfController;
  bool isLoading = true;
  String? errorMessage;
  int currentPage = 1;
  int totalPages = 0;

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

      final response = await Dio().get(
        widget.url,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data == null || response.data.isEmpty) {
        throw Exception('Failed to load PDF data.');
      }

      pdfController = PdfControllerPinch(
        document: PdfDocument.openData(response.data),
        viewportFraction: 0.8,
      );

      pdfController?.addListener(() {
        setState(() {
          currentPage = pdfController?.page.round() ?? 1;
          totalPages = pdfController?.pagesCount ?? 0;
        });
      });

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

  String _chromeDirectDriveUrl(String url) {
    // Already rewritten?
    if (url.contains('drive.usercontent.google.com')) return url;

    // Extract file id from either id= or /d/<id>/
    final match = RegExp(r'(?:id=|/d/)([A-Za-z0-9_-]{10,})').firstMatch(url);
    if (match != null) {
      final id = match.group(1);
      return 'https://drive.usercontent.google.com/download?id=$id&export=download';
    }
    return url;
  }

  Future<void> _downloadPdf() async {
    final directUrl = _chromeDirectDriveUrl(widget.url);

    try {
      if (Platform.isAndroid) {
        // Force full Chrome (not Drive, not WebView)
        final intent = AndroidIntent(
          action: 'action_view',
          data: directUrl,
          package: 'com.android.chrome',
        );
        await intent.launch();

        FirebaseAnalytics.instance.logEvent(
          name: 'download_button_clicked',
          parameters: {
            'subject_name': widget.subjectName,
            'material_title': widget.title,
            'force_package': 'com.android.chrome',
          },
        );
        return;
      }

      // Non-Android: just open in in-app browser (Safari VC / Custom Tab)
      final opened = await launchUrl(
        Uri.parse(directUrl),
        mode: LaunchMode.inAppBrowserView,
      );
      if (!opened) {
        await launchUrl(
          Uri.parse(directUrl),
          mode: LaunchMode.externalApplication,
        );
      }

      FirebaseAnalytics.instance.logEvent(
        name: 'download_button_clicked',
        parameters: {
          'subject_name': widget.subjectName,
          'material_title': widget.title,
          'force_package': 'n/a',
        },
      );
    } catch (e) {
      // Fallback sequence
      try {
        final fallbackOpened = await launchUrl(
          Uri.parse(directUrl),
          mode: LaunchMode.inAppBrowserView,
        );
        if (!fallbackOpened) {
          await launchUrl(
            Uri.parse(directUrl),
            mode: LaunchMode.externalApplication,
          );
        }
      } catch (_) {}
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Open failed: $e')));
      }
    }
  }

  Future<void> _openInPdfViewer() async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Opening PDF...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Open the PDF URL directly in external app/browser
      final launched = await launchUrl(
        Uri.parse(widget.url),
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('No app available to open PDF');
      }

      // Log analytics
      FirebaseAnalytics.instance.logEvent(
        name: 'open_in_pdf_viewer',
        parameters: {'subject': widget.subjectName, 'title': widget.title},
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF opened in external app'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _openInPdfViewer,
            ),
          ),
        );
      }
    }
  }

  // ...existing code...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontFamily: 'Orbitron'),
        ),
        actions: [
          IconButton(
            onPressed: _openInPdfViewer,
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Open in PDF Viewer',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download',
            onPressed: _downloadPdf,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading PDF...'),
                ],
              ),
            )
          else if (errorMessage != null)
            Center(
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          else
            // Replaced the custom rotated Slider with a native Scrollbar for consistency and better UX.
            Scrollbar(
              thumbVisibility: true,
              interactive: true,
              thickness: 8,
              radius: const Radius.circular(6),
              child: PdfViewPinch(controller: pdfController!),
            ),
          if (!isLoading && errorMessage == null)
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$currentPage / ${totalPages == 0 ? '?' : totalPages}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    pdfController?.dispose();
    super.dispose();
  }
}
