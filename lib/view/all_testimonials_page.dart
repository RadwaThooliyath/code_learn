import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/model/content_models.dart';
import 'package:uptrail/view_model/content_viewmodel.dart';
import 'package:uptrail/utils/app_spacing.dart';
import 'package:uptrail/view/widgets/testimonial_card.dart';

class AllTestimonialsPage extends StatefulWidget {
  const AllTestimonialsPage({super.key});

  @override
  State<AllTestimonialsPage> createState() => _AllTestimonialsPageState();
}

class _AllTestimonialsPageState extends State<AllTestimonialsPage> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedType;
  String? _selectedCourse;
  int? _selectedRating;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTestimonials();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);
      if (contentViewModel.hasMoreTestimonials && !contentViewModel.isTestimonialsLoading) {
        contentViewModel.loadMoreTestimonials(
          testimonialType: _selectedType,
          course: _selectedCourse,
          rating: _selectedRating,
        );
      }
    }
  }

  void _loadTestimonials() {
    final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);
    contentViewModel.fetchTestimonials(
      testimonialType: _selectedType,
      course: _selectedCourse,
      rating: _selectedRating,
      forceRefresh: true,
    );
  }

  void _applyFilters() {
    _loadTestimonials();
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedCourse = null;
      _selectedRating = null;
      _searchQuery = '';
      _searchController.clear();
    });
    _loadTestimonials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Student Testimonials',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadTestimonials();
        },
        child: Column(
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search testimonials...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[400]),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                            _applyFilters();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.card2.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.brightPinkCrayola),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onSubmitted: (value) {
                  _applyFilters();
                },
              ),
            ),

            // Active Filters
            if (_selectedType != null || _selectedCourse != null || _selectedRating != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildActiveFilters(),
              ),

            // Testimonials List
            Expanded(
              child: Consumer<ContentViewModel>(
                builder: (context, contentViewModel, child) {
                  if (contentViewModel.isTestimonialsLoading && contentViewModel.testimonials.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (contentViewModel.error != null && contentViewModel.testimonials.isEmpty) {
                    return _buildErrorState(contentViewModel.error!);
                  }

                  if (contentViewModel.testimonials.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: contentViewModel.testimonials.length + 
                        (contentViewModel.hasMoreTestimonials ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == contentViewModel.testimonials.length) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final testimonial = contentViewModel.testimonials[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: TestimonialCard(
                          testimonial: testimonial,
                          onTap: () => _showTestimonialDetail(testimonial),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_selectedType != null)
            _buildFilterChip('Type: ${_formatFilterValue(_selectedType!)}', () {
              setState(() => _selectedType = null);
              _applyFilters();
            }),
          if (_selectedCourse != null)
            _buildFilterChip('Course: $_selectedCourse', () {
              setState(() => _selectedCourse = null);
              _applyFilters();
            }),
          if (_selectedRating != null)
            _buildFilterChip('Rating: $_selectedRating+ stars', () {
              setState(() => _selectedRating = null);
              _applyFilters();
            }),
          TextButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text('Clear All'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.brightPinkCrayola.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.brightPinkCrayola.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.brightPinkCrayola,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 16,
              color: AppColors.brightPinkCrayola,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            AppSpacing.large,
            const Text(
              'No Testimonials Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.medium,
            Text(
              'Try adjusting your search criteria or check back later for new testimonials.',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.large,
            ElevatedButton(
              onPressed: _clearFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brightPinkCrayola,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            AppSpacing.large,
            Text(
              'Failed to Load Testimonials',
              style: TextStyle(
                color: Colors.red[300],
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.medium,
            Text(
              error,
              style: TextStyle(
                color: Colors.red[200],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.large,
            ElevatedButton(
              onPressed: _loadTestimonials,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brightPinkCrayola,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Testimonials',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              AppSpacing.medium,

              // Testimonial Type Filter
              const Text(
                'Type',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.small,
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterOption('All', _selectedType == null, () {
                    setModalState(() => _selectedType = null);
                  }),
                  _buildFilterOption('Text', _selectedType == 'text_image', () {
                    setModalState(() => _selectedType = 'text_image');
                  }),
                  _buildFilterOption('Video', _selectedType == 'video_youtube', () {
                    setModalState(() => _selectedType = 'video_youtube');
                  }),
                ],
              ),
              AppSpacing.medium,

              // Rating Filter
              const Text(
                'Minimum Rating',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.small,
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterOption('All', _selectedRating == null, () {
                    setModalState(() => _selectedRating = null);
                  }),
                  for (int i = 5; i >= 1; i--)
                    _buildFilterOption('$i+ Stars', _selectedRating == i, () {
                      setModalState(() => _selectedRating = i);
                    }),
                ],
              ),
              AppSpacing.large,

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // State is already updated via setModalState
                    });
                    Navigator.pop(context);
                    _applyFilters();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brightPinkCrayola,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.brightPinkCrayola 
              : AppColors.background.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppColors.brightPinkCrayola 
                : Colors.grey[600]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[300],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _formatFilterValue(String value) {
    switch (value) {
      case 'text_image':
        return 'Text';
      case 'video_youtube':
        return 'Video';
      default:
        return value.split('_').map((word) => 
          word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
        ).join(' ');
    }
  }

  void _showTestimonialDetail(Testimonial testimonial) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.card2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      testimonial.studentName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              AppSpacing.small,
              Text(
                testimonial.courseName,
                style: TextStyle(
                  color: AppColors.brightPinkCrayola,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.medium,
              Row(
                children: [
                  for (int i = 1; i <= 5; i++)
                    Icon(
                      i <= testimonial.overallRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    '${testimonial.overallRating}/5',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              AppSpacing.medium,
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    testimonial.testimonialText,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              if (testimonial.currentPosition != null && testimonial.currentPosition!.isNotEmpty) ...[
                AppSpacing.medium,
                Text(
                  'Current Position: ${testimonial.currentPosition}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
              if (testimonial.currentCompany != null && testimonial.currentCompany!.isNotEmpty) ...[
                AppSpacing.small,
                Text(
                  'Company: ${testimonial.currentCompany}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}