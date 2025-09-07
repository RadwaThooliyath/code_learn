import 'package:flutter/material.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/model/rating_model.dart';
import 'package:uptrail/services/rating_service.dart';
import 'rating_widget.dart';

class RatingDialog extends StatefulWidget {
  final int courseId;
  final String courseTitle;
  final CourseRating? existingRating;
  final VoidCallback? onRatingSubmitted;

  const RatingDialog({
    super.key,
    required this.courseId,
    required this.courseTitle,
    this.existingRating,
    this.onRatingSubmitted,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  final RatingService _ratingService = RatingService();
  final TextEditingController _reviewController = TextEditingController();
  
  int _selectedRating = 0;
  bool _isSubmitting = false;
  bool _isLoading = true;
  String? _errorMessage;
  UserRatingStatus? _ratingStatus;

  @override
  void initState() {
    super.initState();
    if (widget.existingRating != null) {
      _selectedRating = widget.existingRating!.rating;
      _reviewController.text = widget.existingRating!.reviewText ?? '';
    }
    _checkRatingStatus();
  }

  Future<void> _checkRatingStatus() async {
    try {
      final status = await _ratingService.getUserRatingStatus(widget.courseId);
      setState(() {
        _ratingStatus = status;
        _isLoading = false;
        
        // If user has already rated, populate the form
        if (status.hasRated && status.userRating != null) {
          _selectedRating = status.userRating!.rating;
          _reviewController.text = status.userRating!.reviewText ?? '';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to check rating status: ${e.toString().replaceAll('Exception: ', '')}';
      });
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_selectedRating == 0) {
      setState(() {
        _errorMessage = 'Please select a rating';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      print("🎯 DEBUG: Starting rating submission");
      print("🎯 Course ID: ${widget.courseId}");
      print("🎯 Selected Rating: $_selectedRating");
      print("🎯 Review Text: '${_reviewController.text.trim()}'");
      print("🎯 Has Rated Before: ${_ratingStatus?.hasRated}");
      print("🎯 Can Rate Status: ${_ratingStatus?.canRate}");
      print("🎯 Status Reason: ${_ratingStatus?.reason}");
      
      // Cross-check enrollment status by calling the rating status API again
      print("🔄 DEBUG: Cross-checking enrollment status before submission...");
      final freshRatingStatus = await _ratingService.getUserRatingStatus(widget.courseId);
      print("🔄 Fresh canRate: ${freshRatingStatus.canRate}");
      print("🔄 Fresh hasRated: ${freshRatingStatus.hasRated}");
      print("🔄 Fresh reason: ${freshRatingStatus.reason}");
      
      if (freshRatingStatus.canRate != true && freshRatingStatus.hasRated != true) {
        print("❌ DEBUG: Fresh rating status check failed - not allowed to rate");
        setState(() {
          _errorMessage = freshRatingStatus.reason ?? 'You must be enrolled in this course to rate it.';
          _isSubmitting = false;
        });
        return;
      }
      
      CourseRating result;
      if (_ratingStatus?.hasRated == true) {
        print("🔄 DEBUG: Updating existing rating via updateCourseRating()");
        result = await _ratingService.updateCourseRating(
          courseId: widget.courseId,
          rating: _selectedRating,
          reviewText: _reviewController.text.trim(),
        );
        print("✅ DEBUG: Update rating successful");
      } else {
        print("🆕 DEBUG: Submitting new rating via submitCourseRating()");
        result = await _ratingService.submitCourseRating(
          courseId: widget.courseId,
          rating: _selectedRating,
          reviewText: _reviewController.text.trim(),
        );
        print("✅ DEBUG: New rating submission successful");
      }
      
      print("🎉 DEBUG: Rating result received:");
      print("🎉 Rating ID: ${result.id}");
      print("🎉 Rating Value: ${result.rating}");
      print("🎉 Review Text: ${result.reviewText}");
      print("🎉 User: ${result.userName}");

      if (mounted) {
        Navigator.of(context).pop();
        widget.onRatingSubmitted?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingRating != null 
                  ? 'Rating updated successfully!' 
                  : 'Rating submitted successfully!'
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("❌ DEBUG: Rating submission failed with error:");
      print("❌ Error type: ${e.runtimeType}");
      print("❌ Raw error: $e");
      print("❌ Error message: ${e.toString()}");
      print("❌ Course ID: ${widget.courseId}");
      print("❌ Rating value: $_selectedRating");
      print("❌ Review text length: ${_reviewController.text.trim().length}");
      print("❌ User rating status: canRate=${_ratingStatus?.canRate}, hasRated=${_ratingStatus?.hasRated}");
      
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        _ratingStatus?.hasRated == true ? 'Update Your Rating' : 'Rate This Course',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course title
            Text(
              widget.courseTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // Loading indicator
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading rating form...'),
                  ],
                ),
              )
            // Rating form - show for enrolled users or if backend says they can rate
            else ...[
              // Temporary debug info to check if backend fix is working
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: (_ratingStatus?.canRate == true) ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (_ratingStatus?.canRate == true) ? Colors.green[300]! : Colors.red[300]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Debug Info:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: (_ratingStatus?.canRate == true) ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                    Text(
                      'canRate: ${_ratingStatus?.canRate}',
                      style: TextStyle(color: Colors.black87),
                    ),
                    Text(
                      'hasRated: ${_ratingStatus?.hasRated}',
                      style: TextStyle(color: Colors.black87),
                    ),
                    if (_ratingStatus?.reason != null)
                      Text(
                        'Reason: ${_ratingStatus!.reason}',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                  ],
                ),
              ),

            // Star rating
            const Text(
              'Your Rating:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: InteractiveStarRating(
                initialRating: _selectedRating,
                size: 40,
                onRatingChanged: (rating) {
                  setState(() {
                    _selectedRating = rating;
                    _errorMessage = null;
                  });
                },
                enabled: !_isSubmitting,
              ),
            ),
            const SizedBox(height: 16),
            
            // Optional review text
            const Text(
              'Review (Optional):',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              maxLines: 4,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                hintText: 'Share your thoughts about this course...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppColors.logoBrightBlue,
                    width: 2,
                  ),
                ),
              ),
            ),
            
            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
            ], // Close the else statement
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
            onPressed: _isSubmitting ? null : _submitRating,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.logoBrightBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(widget.existingRating != null ? 'Update' : 'Submit'),
        ),
      ],
    );
  }
}

class ReviewDialog extends StatefulWidget {
  final int courseId;
  final String courseTitle;
  final VoidCallback? onReviewSubmitted;

  const ReviewDialog({
    super.key,
    required this.courseId,
    required this.courseTitle,
    this.onReviewSubmitted,
  });

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final RatingService _ratingService = RatingService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a review title';
      });
      return;
    }

    if (content.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your review';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _ratingService.submitCourseReview(
        courseId: widget.courseId,
        title: title,
        content: content,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onReviewSubmitted?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Write a Review',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.courseTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // Review title
            const Text(
              'Review Title:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                hintText: 'Summarize your experience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppColors.logoBrightBlue,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Review content
            const Text(
              'Detailed Review:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 6,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                hintText: 'Share your detailed thoughts about this course...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppColors.logoBrightBlue,
                    width: 2,
                  ),
                ),
              ),
            ),
            
            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.logoBrightBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Submit Review'),
        ),
      ],
    );
  }
}