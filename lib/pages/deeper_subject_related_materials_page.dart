import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';

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
      appBar: AppBar(title: Text('$subjectName $cardLabelPrefix Options')),
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
            // Updated to display all materials, even if they share the same labelKey value.
            itemCount: materials.length,
            itemBuilder: (context, idx) {
              final material = materials[idx];
              final labelValue = material[labelKey];
              final url = material['url'];

              return InkWell(
                onTap: () {
                  if (url == null || url.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'No PDF for $cardLabelPrefix $labelValue',
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
                        title: '$cardLabelPrefix $labelValue',
                        subjectName: subjectName,
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
  late int totalPages;
  late int currentPage;

  @override
  void initState() {
    super.initState();
    currentPage = 1;
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
        viewportFraction: 0.8, // Increased scroll sensitivity
      );

      pdfController.addListener(() {
        setState(() {
          currentPage = pdfController.page.round();
          // Fixed type issue by ensuring `totalPages` is non-null.
          totalPages = pdfController.pagesCount ?? 0;
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

  Future<void> _downloadPdf() async {
    try {
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
      body: Stack(
        children: [
          isLoading
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
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : PdfViewPinch(controller: pdfController),
          if (!isLoading && errorMessage == null)
            Align(
              alignment: Alignment.centerRight,
              child: RotatedBox(
                quarterTurns: 1,
                child: Slider(
                  value: currentPage.toDouble(),
                  min: 1,
                  max: totalPages.toDouble(),
                  divisions: totalPages,
                  label: 'Page $currentPage',
                  onChanged: (value) {
                    pdfController.jumpToPage(value.toInt());
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    pdfController.dispose();
    super.dispose();
  }
}
