import 'package:flutter/material.dart';
import '../pdf_viewer_screen.dart';

class LessonResourcesWidget extends StatelessWidget {
  final String? resourceUrl;
  final String lessonTitle;

  const LessonResourcesWidget({
    super.key,
    this.resourceUrl,
    required this.lessonTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (resourceUrl == null || resourceUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.attach_file,
                  color: Colors.blue[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  "Lesson Resources",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "VIEW ONLY",
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildResourceItem(context),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceItem(BuildContext context) {
    final fileName = _getFileNameFromUrl(resourceUrl!);
    final fileExtension = _getFileExtension(fileName);
    final isImage = _isImageFile(fileExtension);
    final isPdf = fileExtension.toLowerCase() == 'pdf';

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: _buildFileIcon(fileExtension, isImage, isPdf),
        title: Text(
          fileName,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getFileTypeDescription(fileExtension, isImage, isPdf),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (isPdf)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "Tap to view in-app",
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.visibility,
            color: Colors.blue[700],
            size: 20,
          ),
          onPressed: () => _viewFile(context),
          tooltip: isPdf ? "View PDF" : "View File",
        ),
      ),
    );
  }

  Widget _buildFileIcon(String extension, bool isImage, bool isPdf) {
    if (isPdf) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.picture_as_pdf,
          color: Colors.red[700],
          size: 20,
        ),
      );
    } else if (isImage) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.image,
          color: Colors.blue[700],
          size: 20,
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.insert_drive_file,
          color: Colors.grey[700],
          size: 20,
        ),
      );
    }
  }

  String _getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        return segments.last;
      }
      return "Resource File";
    } catch (e) {
      return "Resource File";
    }
  }

  String _getFileExtension(String fileName) {
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex != -1 && lastDotIndex < fileName.length - 1) {
      return fileName.substring(lastDotIndex + 1);
    }
    return '';
  }

  bool _isImageFile(String extension) {
    final imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'svg', 'webp'];
    return imageExtensions.contains(extension.toLowerCase());
  }

  String _getFileTypeDescription(String extension, bool isImage, bool isPdf) {
    if (isPdf) return "PDF Document";
    if (isImage) return "Image File";
    if (extension.isNotEmpty) return "${extension.toUpperCase()} File";
    return "Resource File";
  }

  void _viewFile(BuildContext context) {
    if (resourceUrl == null || resourceUrl!.isEmpty) return;
    
    final fileName = _getFileNameFromUrl(resourceUrl!);
    final fileExtension = _getFileExtension(fileName);
    final isPdf = fileExtension.toLowerCase() == 'pdf';
    
    if (isPdf) {
      // Navigate to in-app PDF viewer
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PDFViewerScreen(
            pdfUrl: resourceUrl!,
            title: 'Resource: $fileName',
          ),
        ),
      );
    } else {
      // For non-PDF files, show a message that only PDFs are supported for in-app viewing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only PDF files can be viewed in-app'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}