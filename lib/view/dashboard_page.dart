import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uptrail/app_constants/colors.dart';
import 'package:uptrail/utils/app_spacing.dart';
import 'package:uptrail/view_model/content_viewmodel.dart';
import 'package:uptrail/view/widgets/content_sections.dart';
import 'package:uptrail/view/widgets/stats_widget.dart';
import 'package:uptrail/view/all_testimonials_page.dart';
import 'package:uptrail/view/all_news_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contentViewModel = Provider.of<ContentViewModel>(
        context,
        listen: false,
      );
      

      contentViewModel.fetchHomePageContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<ContentViewModel>(
            builder: (context, contentViewModel, child) {
              return IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: contentViewModel.isDashboardLoading 
                      ? Colors.grey 
                      : Colors.white,
                ),
                onPressed: contentViewModel.isDashboardLoading 
                    ? null 
                    : () {
                        contentViewModel.fetchHomePageContent(forceRefresh: true);
                      },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final contentViewModel = Provider.of<ContentViewModel>(
            context,
            listen: false,
          );
          await contentViewModel.fetchHomePageContent(forceRefresh: true);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Consumer<ContentViewModel>(
            builder: (context, contentViewModel, child) {
              if (contentViewModel.isDashboardLoading) {
                return Container(
                  height: MediaQuery.of(context).size.height - 200,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Loading dashboard...',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              if (contentViewModel.error != null) {
                return Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[300],
                        size: 48,
                      ),
                      AppSpacing.medium,
                      Text(
                        'Unable to load dashboard',
                        style: TextStyle(
                          color: Colors.red[300],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.small,
                      Text(
                        contentViewModel.error!,
                        style: TextStyle(
                          color: Colors.red[200],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.medium,
                      ElevatedButton(
                        onPressed: () {
                          contentViewModel.fetchHomePageContent(forceRefresh: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brightPinkCrayola,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  children: [
                    // Welcome Section
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.logoDarkTeal.withValues(alpha: 0.8),
                            AppColors.robinEggBlue.withValues(alpha: 0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.dashboard,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Success Dashboard',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.small,
                          Text(
                            'Track student achievements, success stories, and latest updates',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Stats Section
                    if (contentViewModel.stats != null) ...[
                      StatsWidget(stats: contentViewModel.stats!),
                      AppSpacing.veryLarge,
                    ],
                    
                    // Recent Placements Section
                    PlacementsSection(
                      placements: contentViewModel.featuredPlacements,
                      isLoading: contentViewModel.isDashboardLoading,
                      onSeeAll: () {
                        _showAllPlacementsPage(context);
                      },
                    ),
                    AppSpacing.veryLarge,
                    
                    // Student Success Stories Section  
                    TestimonialsSection(
                      testimonials: contentViewModel.featuredTestimonials,
                      isLoading: contentViewModel.isDashboardLoading,
                      onSeeAll: () {
                        _showAllTestimonialsPage(context);
                      },
                    ),
                    AppSpacing.veryLarge,
                    
                    // Latest News Section
                    NewsSection(
                      news: contentViewModel.featuredNews,
                      isLoading: contentViewModel.isDashboardLoading,
                      onSeeAll: () {
                        _showAllNewsPage(context);
                      },
                    ),
                    
                    // Additional Insights Section
                    if (contentViewModel.featuredPlacements.isNotEmpty ||
                        contentViewModel.featuredTestimonials.isNotEmpty ||
                        contentViewModel.featuredNews.isNotEmpty) ...[
                      AppSpacing.veryLarge,
                      _buildInsightsSection(contentViewModel),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsSection(ContentViewModel contentViewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card2.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.brightPinkCrayola.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights,
                color: AppColors.brightPinkCrayola,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Quick Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          AppSpacing.medium,
          _buildInsightItem(
            icon: Icons.trending_up,
            title: 'Latest Placement',
            value: contentViewModel.featuredPlacements.isNotEmpty
                ? '${contentViewModel.featuredPlacements.first.studentName} at ${contentViewModel.featuredPlacements.first.companyName}'
                : 'No recent placements',
            color: Colors.green,
          ),
          AppSpacing.small,
          _buildInsightItem(
            icon: Icons.star,
            title: 'Average Rating',
            value: contentViewModel.featuredTestimonials.isNotEmpty
                ? '${(contentViewModel.featuredTestimonials.map((t) => t.overallRating).reduce((a, b) => a + b) / contentViewModel.featuredTestimonials.length).toStringAsFixed(1)}/5'
                : 'No ratings yet',
            color: Colors.amber,
          ),
          AppSpacing.small,
          _buildInsightItem(
            icon: Icons.article,
            title: 'Latest Update',
            value: contentViewModel.featuredNews.isNotEmpty
                ? contentViewModel.featuredNews.first.title.length > 40
                    ? '${contentViewModel.featuredNews.first.title.substring(0, 40)}...'
                    : contentViewModel.featuredNews.first.title
                : 'No recent updates',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAllPlacementsPage(BuildContext context) {
    // TODO: Navigate to dedicated placements page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All Placements page - Coming Soon!'),
        backgroundColor: AppColors.brightPinkCrayola,
      ),
    );
  }

  void _showAllTestimonialsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AllTestimonialsPage(),
      ),
    );
  }

  void _showAllNewsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AllNewsPage(),
      ),
    );
  }
}