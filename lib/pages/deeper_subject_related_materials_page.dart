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
