import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/model/content_models.dart';
import 'package:uptrail/view_model/content_viewmodel.dart';
import 'package:uptrail/utils/app_spacing.dart';
import 'package:uptrail/view/widgets/news_card.dart';
import 'package:uptrail/view/news_detail_page.dart';

class AllNewsPage extends StatefulWidget {
  const AllNewsPage({super.key});

  @override
  State<AllNewsPage> createState() => _AllNewsPageState();
}

class _AllNewsPageState extends State<AllNewsPage> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _categories = [
    {'value': 'announcement', 'label': 'Announcements'},
    {'value': 'course_updates', 'label': 'Course Updates'},
    {'value': 'student_success', 'label': 'Student Success'},
    {'value': 'industry_news', 'label': 'Industry News'},
    {'value': 'events', 'label': 'Events'},
    {'value': 'tips', 'label': 'Tips & Guides'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNews();
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
      if (contentViewModel.hasMoreNews && !contentViewModel.isNewsLoading) {
        contentViewModel.loadMoreNews(
          category: _selectedCategory,
          search: _searchQuery.isEmpty ? null : _searchQuery,
        );
      }
    }
  }

  void _loadNews() {
    final contentViewModel = Provider.of<ContentViewModel>(context, listen: false);
    contentViewModel.fetchNews(
      category: _selectedCategory,
      search: _searchQuery.isEmpty ? null : _searchQuery,
      forceRefresh: true,
    );
  }

  void _applyFilters() {
    _loadNews();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _searchQuery = '';
      _searchController.clear();
    });
    _loadNews();
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
          'Latest News & Updates',
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
          _loadNews();
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
                  hintText: 'Search news and updates...',
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

            // Category Filter Chips
            if (_categories.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: _buildCategoryChip('All', _selectedCategory == null),
                      );
                    }
                    final category = _categories[index - 1];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: _buildCategoryChip(
                        category['label']!,
                        _selectedCategory == category['value'],
                        category['value'],
                      ),
                    );
                  },
                ),
              ),

            AppSpacing.medium,

            // Active Filters
            if (_selectedCategory != null || _searchQuery.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildActiveFilters(),
              ),

            // News List
            Expanded(
              child: Consumer<ContentViewModel>(
                builder: (context, contentViewModel, child) {
                  if (contentViewModel.isNewsLoading && contentViewModel.news.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (contentViewModel.error != null && contentViewModel.news.isEmpty) {
                    return _buildErrorState(contentViewModel.error!);
                  }

                  if (contentViewModel.news.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: contentViewModel.news.length + 
                        (contentViewModel.hasMoreNews ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == contentViewModel.news.length) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final article = contentViewModel.news[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: NewsCard(
                          article: article,
                          onTap: () => _navigateToNewsDetail(article),
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

  Widget _buildCategoryChip(String label, bool isSelected, [String? value]) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = isSelected ? null : value;
        });
        _applyFilters();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.brightPinkCrayola 
              : AppColors.card2.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(25),
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

  Widget _buildActiveFilters() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_selectedCategory != null)
            _buildFilterChip(
              'Category: ${_getCategoryLabel(_selectedCategory!)}',
              () {
                setState(() => _selectedCategory = null);
                _applyFilters();
              },
            ),
          if (_searchQuery.isNotEmpty)
            _buildFilterChip('Search: "$_searchQuery"', () {
              setState(() {
                _searchQuery = '';
                _searchController.clear();
              });
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
              Icons.newspaper,
              size: 80,
              color: Colors.grey[400],
            ),
            AppSpacing.large,
            const Text(
              'No News Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.medium,
            Text(
              'Try adjusting your search criteria or check back later for new updates.',
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
              'Failed to Load News',
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
              onPressed: _loadNews,
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
                    'Filter News',
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

              // Category Filter
              const Text(
                'Category',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.small,
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterOption('All', _selectedCategory == null, () {
                    setModalState(() => _selectedCategory = null);
                  }),
                  ..._categories.map((category) => _buildFilterOption(
                    category['label']!,
                    _selectedCategory == category['value'],
                    () => setModalState(() => _selectedCategory = category['value']),
                  )),
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

  String _getCategoryLabel(String value) {
    final category = _categories.firstWhere(
      (cat) => cat['value'] == value,
      orElse: () => {'label': value},
    );
    return category['label']!;
  }

  void _navigateToNewsDetail(NewsArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailPage(article: article),
      ),
    );
  }
}