import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/model/course_model.dart';
import 'package:uptrail/services/course_service.dart';
import 'package:uptrail/utils/app_text_style.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoLessonPlayer extends StatefulWidget {
  final Lesson lesson;
  final int courseId;

  const VideoLessonPlayer({
    super.key,
    required this.lesson,
    required this.courseId,
  });

  @override
  State<VideoLessonPlayer> createState() => _VideoLessonPlayerState();
}

class _VideoLessonPlayerState extends State<VideoLessonPlayer> {
  late YoutubePlayerController _controller;
  final CourseService _courseService = CourseService();
  bool _isPlayerReady = false;
  bool _isLoading = false;
  
  // Progress tracking
  Duration _lastPosition = Duration.zero;
  Duration _videoDuration = Duration.zero;
  double _completionPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    final videoId = YoutubePlayer.convertUrlToId(widget.lesson.videoUrl ?? '');
    
    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          captionLanguage: 'en',
          forceHD: false,
          startAt: 0,
        ),
      );

      _controller.addListener(_onPlayerStateChange);
    }
  }

  void _onPlayerStateChange() {
    if (!_isPlayerReady) return;

    final position = _controller.value.position;
    final duration = _controller.metadata.duration;

    if (duration > Duration.zero && position != _lastPosition) {
      setState(() {
        _lastPosition = position;
        _videoDuration = duration;
        _completionPercentage = (position.inMilliseconds / duration.inMilliseconds) * 100;
      });

      // Update progress every 10 seconds or when video completes
      if (position.inSeconds % 10 == 0 || _completionPercentage >= 95) {
        _updateVideoProgress();
      }
    }
  }

  Future<void> _updateVideoProgress() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create a simple progress update request
      await _courseService.updateVideoProgress(
        videoLessonId: widget.lesson.id,
        courseId: widget.courseId,
        completedPercentage: _completionPercentage,
        completed: _completionPercentage >= 95,
      );
    } catch (e) {
      print("Failed to update video progress: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.lesson.title,
          style: AppTextStyle.headline2,
        ),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: YoutubePlayerBuilder(
        onExitFullScreen: () {
          SystemChrome.setPreferredOrientations(DeviceOrientation.values);
        },
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppColors.logoBrightBlue,
          onReady: () {
            _isPlayerReady = true;
          },
          onEnded: (data) {
            // Mark as completed when video ends
            setState(() {
              _completionPercentage = 100.0;
            });
            _updateVideoProgress();
          },
        ),
        builder: (context, player) => Column(
          children: [
            player,
            Container(
              color: AppColors.background,
              child: _buildVideoControls(),
            ),
            Expanded(
              child: Container(
                color: AppColors.background,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProgressCard(),
                      const SizedBox(height: 16),
                      _buildLessonInfo(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Progress",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${_completionPercentage.toStringAsFixed(1)}%",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _completionPercentage / 100,
              backgroundColor: Colors.grey.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                _completionPercentage >= 95 ? Colors.green : AppColors.logoBrightBlue,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_lastPosition),
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                Text(
                  _formatDuration(_videoDuration),
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
            if (_completionPercentage >= 95) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  const Text(
                    "Completed",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLessonInfo() {
    return Card(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lesson.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.lesson.description != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.lesson.description!,
                style: const TextStyle(color: Colors.black87),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.play_circle, size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Text(
                  "Video Lesson",
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                if (widget.lesson.duration != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, size: 16, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(
                    "${widget.lesson.duration} minutes",
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoControls() {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        children: [
          // Main control row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.replay_10_rounded,
                onPressed: () {
                  final currentPosition = _controller.value.position;
                  final newPosition = currentPosition - const Duration(seconds: 10);
                  _controller.seekTo(newPosition);
                },
                color: Colors.white,
                size: 42,
              ),
              _buildControlButton(
                icon: _controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                onPressed: () {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                },
                color: Colors.white,
                size: 56,
              ),
              _buildControlButton(
                icon: Icons.forward_10_rounded,
                onPressed: () {
                  final currentPosition = _controller.value.position;
                  final newPosition = currentPosition + const Duration(seconds: 10);
                  _controller.seekTo(newPosition);
                },
                color: Colors.white,
                size: 42,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Secondary controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSmallControlButton(
                icon: Icons.skip_previous_rounded,
                label: "Start",
                onPressed: () {
                  _controller.seekTo(Duration.zero);
                },
                isDark: true,
              ),
              _buildSmallControlButton(
                icon: Icons.volume_up_rounded,
                label: "Audio",
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Use device volume controls")),
                  );
                },
                isDark: true,
              ),
              _buildSmallControlButton(
                icon: Icons.fullscreen_rounded,
                label: "Fullscreen",
                onPressed: () {
                  _controller.toggleFullScreenMode();
                },
                isDark: true,
              ),
              _buildSmallControlButton(
                icon: Icons.speed_rounded,
                label: "Speed",
                onPressed: () {
                  _showSpeedDialog();
                },
                isDark: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    double size = 48,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Icon(
            icon,
            color: color,
            size: size * 0.6,
          ),
        ),
      ),
    );
  }

  Widget _buildSmallControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isDark = false,
  }) {
    final iconColor = isDark ? Colors.white70 : Colors.grey[700];
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text("Playback Speed", style: TextStyle(color: Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSpeedOption("0.5x", 0.5),
            _buildSpeedOption("0.75x", 0.75),
            _buildSpeedOption("1.0x", 1.0),
            _buildSpeedOption("1.25x", 1.25),
            _buildSpeedOption("1.5x", 1.5),
            _buildSpeedOption("2.0x", 2.0),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedOption(String label, double speed) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.black87)),
      onTap: () {
        _controller.setPlaybackRate(speed);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Speed set to $label")),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }
}