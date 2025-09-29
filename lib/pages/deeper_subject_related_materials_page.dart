import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/download_helper.dart';

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
  PdfControllerPinch? pdfController;
  bool isLoading = true;
  String? errorMessage;
  int totalPages = 0;
  int currentPage = 1;

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

      // First download the PDF data
      final response = await Dio().get(
        widget.url,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data == null || response.data.isEmpty) {
        throw Exception('Failed to load PDF data.');
      }

      // Then create the PDF controller with the data
      pdfController = PdfControllerPinch(
        document: PdfDocument.openData(response.data),
        viewportFraction: 0.8,
      );

      pdfController?.addListener(() {
        setState(() {
          currentPage = pdfController?.page.round() ?? 1;
          // Fixed type issue by ensuring `totalPages` is non-null.
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

  Future<void> _openInPdfViewer() async {
    try {
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
              Text('Preparing PDF...'),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );

      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      final fileName =
          '${widget.title.replaceAll(RegExp(r'[^\w\s-]'), '')}.pdf';
      final filePath = '${tempDir.path}/$fileName';

      await dio.download(widget.url, filePath);

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Failed to download PDF');
      }

      await launchUrl(Uri.file(filePath), mode: LaunchMode.externalApplication);

      FirebaseAnalytics.instance.logEvent(
        name: 'open_in_pdf_viewer',
        parameters: {'subject': widget.subjectName, 'title': widget.title},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening in PDF viewer...'),
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
            content: Text('Error opening PDF: ${e.toString()}'),
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

  // Future<void> _downloadPdf() async {
  //   try {
  //     Directory? downloadsDir;
  //     if (Platform.isAndroid) {
  //       downloadsDir = Directory('/storage/emulated/0/Download');
  //       if (!downloadsDir.existsSync()) {
  //         downloadsDir = await getExternalStorageDirectory();
  //       }
  //     } else {
  //       downloadsDir = await getApplicationDocumentsDirectory();
  //     }

  //     if (downloadsDir != null) {
  //       final fileName = '${widget.subjectName}_${widget.title}.pdf';
  //       final savePath = '${downloadsDir.path}/$fileName';

  //       await Dio().download(widget.url, savePath);

  //       // Log download event to Firebase Analytics
  //       await FirebaseAnalytics.instance.logEvent(
  //         name: 'download_button_clicked',
  //         parameters: {
  //           'subject_name': widget.subjectName,
  //           'material_title': widget.title,
  //         },
  //       );

  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Downloaded to Downloads/$fileName'),
  //             backgroundColor: Colors.green,
  //           ),
  //         );
  //       }
  //     } else {
  //       throw Exception('Could not access downloads directory');
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Download failed: ${e.toString()}'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  Future<void> _downloadPdf() async {
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
              Text('Downloading...'),
            ],
          ),
          duration: Duration(seconds: 5),
        ),
      );

      final fileName = '${widget.subjectName}_${widget.title}.pdf';
      final result = await DownloadHelper.downloadToPublicDownloads(
        widget.url,
        fileName,
      );

      // Log download event
      FirebaseAnalytics.instance.logEvent(
        name: 'download_button_clicked',
        parameters: {
          'subject_name': widget.subjectName,
          'material_title': widget.title,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded: $result'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: _openInPdfViewer,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Try Open Instead',
              textColor: Colors.white,
              onPressed: _openInPdfViewer,
            ),
          ),
        );
      }
    }
  }

  //

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
              : Scrollbar(
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
