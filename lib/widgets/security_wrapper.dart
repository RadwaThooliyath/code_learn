import 'package:flutter/material.dart';
import 'package:uptrail/services/security_service.dart';

class SecurityWrapper extends StatefulWidget {
  final Widget child;
  final bool showSecurityInfo;

  const SecurityWrapper({
    super.key,
    required this.child,
    this.showSecurityInfo = false,
  });

  @override
  State<SecurityWrapper> createState() => _SecurityWrapperState();
}

class _SecurityWrapperState extends State<SecurityWrapper> with WidgetsBindingObserver {
  bool _isScreenRecording = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkScreenRecording();
    
    // Show security info if requested
    if (widget.showSecurityInfo) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SecurityService.showScreenshotInfo(context);
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Check for screen recording when app resumes
    if (state == AppLifecycleState.resumed) {
      _checkScreenRecording();
    }
  }

  Future<void> _checkScreenRecording() async {
    try {
      final isRecording = await SecurityService.instance.isScreenRecording();
      if (mounted && isRecording != _isScreenRecording) {
        setState(() {
          _isScreenRecording = isRecording;
        });
        
        if (isRecording) {
          _showScreenRecordingAlert();
        }
      }
    } catch (e) {
      // Silently handle error
    }
  }

  void _showScreenRecordingAlert() {
    SecurityService.showSecurityAlert(
      context,
      'Screen recording detected! Please stop recording to continue using the app.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        
        // Show overlay when screen recording is detected
        if (_isScreenRecording)
          Positioned.fill(
            child: Container(
              color: Colors.black87,
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.videocam_off,
                          color: Colors.red[600],
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Screen Recording Detected',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Please stop screen recording to continue accessing course content.',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _checkScreenRecording,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Check Again',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}