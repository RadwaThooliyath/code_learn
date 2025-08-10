import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/storage_service.dart';

class AuthenticatedImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget Function(BuildContext context)? loadingWidget;
  final Widget Function(BuildContext context, Object error)? errorWidget;

  const AuthenticatedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  State<AuthenticatedImage> createState() => _AuthenticatedImageState();
}

class _AuthenticatedImageState extends State<AuthenticatedImage> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final token = await StorageService.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      print("🔐 Loading authenticated image: ${widget.imageUrl}");
      print("🔑 Using token: ${token != null ? 'YES' : 'NO'}");

      final response = await http.get(
        Uri.parse(widget.imageUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        setState(() {
          _imageBytes = response.bodyBytes;
          _isLoading = false;
        });
        print("✅ Image loaded successfully");
      } else if (response.statusCode == 404) {
        print("📁 Image not found on server - this is a backend configuration issue");
        print("🔧 Possible solutions:");
        print("   1. Check if images are uploaded to correct server directory");
        print("   2. Verify web server allows access to /codelearnmedia/ path");
        print("   3. Update API to return correct image URLs");
        throw Exception('Image not found (404) - Backend issue');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print("❌ Authenticated image load error: $e");
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidget?.call(context) ?? 
        const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        );
    }

    if (_error != null) {
      return widget.errorWidget?.call(context, _error!) ??
        const Center(
          child: Icon(
            Icons.image_not_supported,
            color: Colors.white,
            size: 50,
          ),
        );
    }

    if (_imageBytes != null) {
      return Image.memory(
        _imageBytes!,
        fit: widget.fit,
      );
    }

    return const SizedBox.shrink();
  }
}