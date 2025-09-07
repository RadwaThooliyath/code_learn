import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/utils/app_text_style.dart';

class PDFViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PDFViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String? localPath;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  int currentPage = 0;
  int totalPages = 0;
  PDFViewController? controller;

  @override
  void initState() {
    super.initState();
    _downloadAndSavePDF();
  }

  Future<void> _downloadAndSavePDF() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      // Download PDF file
      final response = await http.get(Uri.parse(widget.pdfUrl));
      
      if (response.statusCode == 200) {
        // Get temporary directory
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/temp_resource.pdf');
        
        // Write PDF data to file
        await file.writeAsBytes(response.bodyBytes);
        
        setState(() {
          localPath = file.path;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Error loading PDF: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: AppTextStyle.headline2.copyWith(fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (totalPages > 0)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.logoBrightBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${currentPage + 1} / $totalPages',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Loading PDF...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load PDF',
              style: AppTextStyle.headline2.copyWith(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _downloadAndSavePDF,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.logoBrightBlue,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (localPath == null) {
      return const Center(
        child: Text(
          'No PDF to display',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return PDFView(
      filePath: localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      pageSnap: true,
      defaultPage: 0,
      fitPolicy: FitPolicy.BOTH,
      preventLinkNavigation: false,
      backgroundColor: AppColors.background,
      onRender: (pages) {
        setState(() {
          totalPages = pages ?? 0;
        });
      },
      onViewCreated: (PDFViewController pdfViewController) {
        controller = pdfViewController;
      },
      onPageChanged: (int? page, int? total) {
        setState(() {
          currentPage = page ?? 0;
          totalPages = total ?? 0;
        });
      },
      onError: (error) {
        setState(() {
          hasError = true;
          errorMessage = error.toString();
        });
      },
    );
  }

  @override
  void dispose() {
    // Clean up the temporary PDF file
    if (localPath != null) {
      try {
        File(localPath!).deleteSync();
      } catch (e) {
        // Ignore cleanup errors
      }
    }
    super.dispose();
  }
}