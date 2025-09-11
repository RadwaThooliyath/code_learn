import 'package:flutter/material.dart';
import 'package:uptrail/model/content_models.dart';
import 'package:uptrail/services/content_repository.dart';

class ContentViewModel extends ChangeNotifier {
  final ContentRepository _repository = ContentRepository();

  bool _isLoading = false;
  bool _isDashboardLoading = false;
  bool _isNewsLoading = false;
  bool _isPlacementsLoading = false;
  bool _isTestimonialsLoading = false;
  String? _error;

  DashboardData? _dashboardData;
  List<NewsArticle> _news = [];
  List<Placement> _placements = [];
  List<Testimonial> _testimonials = [];
  ContentCategories? _categories;

  int _newsCurrentPage = 1;
  int _placementsCurrentPage = 1;
  int _testimonialsCurrentPage = 1;
  bool _hasMoreNews = true;
  bool _hasMorePlacements = true;
  bool _hasMoreTestimonials = true;

  // Getters
  bool get isLoading => _isLoading;
  bool get isDashboardLoading => _isDashboardLoading;
  bool get isNewsLoading => _isNewsLoading;
  bool get isPlacementsLoading => _isPlacementsLoading;
  bool get isTestimonialsLoading => _isTestimonialsLoading;
  String? get error => _error;

  DashboardData? get dashboardData => _dashboardData;
  List<NewsArticle> get news => _news;
  List<Placement> get placements => _placements;
  List<Testimonial> get testimonials => _testimonials;
  ContentCategories? get categories => _categories;

  // Featured content getters
  List<NewsArticle> get featuredNews => _dashboardData?.latestNews ?? [];
  List<Placement> get featuredPlacements => _dashboardData?.featuredPlacements ?? [];
  List<Testimonial> get featuredTestimonials => _dashboardData?.featuredTestimonials ?? [];
  DashboardStats? get stats => _dashboardData?.stats;

  // Pagination getters
  int get newsCurrentPage => _newsCurrentPage;
  int get placementsCurrentPage => _placementsCurrentPage;
  int get testimonialsCurrentPage => _testimonialsCurrentPage;
  bool get hasMoreNews => _hasMoreNews;
  bool get hasMorePlacements => _hasMorePlacements;
  bool get hasMoreTestimonials => _hasMoreTestimonials;

  void _setError(String? error) {
    _error = error;
    print('ContentViewModel Error: $error');
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  Future<void> fetchHomePageContent({bool forceRefresh = false}) async {
    if (_isDashboardLoading) return;

    print('ContentViewModel: Starting home page content fetch (forceRefresh: $forceRefresh)');
    _isDashboardLoading = true;
    _clearError();
    notifyListeners();

    try {
      // Fetch all content in parallel
      final results = await Future.wait([
        _repository.getPlacements(featured: true, forceRefresh: forceRefresh),
        _repository.getTestimonials(featured: null, forceRefresh: forceRefresh), // Get all testimonials
        _repository.getNews(featured: true, forceRefresh: forceRefresh),
      ]);

      final placementsResponse = results[0] as PaginatedResponse<Placement>;
      final testimonialsResponse = results[1] as PaginatedResponse<Testimonial>;
      final newsResponse = results[2] as PaginatedResponse<NewsArticle>;

      // Create dashboard data from individual responses
      _dashboardData = DashboardData(
        featuredPlacements: placementsResponse.results,
        featuredTestimonials: testimonialsResponse.results,
        latestNews: newsResponse.results,
        stats: DashboardStats(
          totalStudents: 0, // Will be calculated from actual data or separate endpoint
          totalPlacements: placementsResponse.count,
          averagePackage: 0.0, // Calculate from placements data
          coursesAvailable: 0, // From separate endpoint if needed
        ),
      );

      print('ContentViewModel: Home page content loaded successfully');
      print('- Featured placements: ${_dashboardData?.featuredPlacements.length ?? 0}');
      print('- Featured testimonials: ${_dashboardData?.featuredTestimonials.length ?? 0}');
      print('- Latest news: ${_dashboardData?.latestNews.length ?? 0}');
      
      // If API returned empty data, show a message but don't fall back to mock data
      if (_dashboardData!.featuredPlacements.isEmpty && 
          _dashboardData!.featuredTestimonials.isEmpty && 
          _dashboardData!.latestNews.isEmpty) {
        print('ContentViewModel: API returned empty data - this is normal if backend has no content yet');
      }
      
      // Calculate average package from placements data
      if (_dashboardData!.featuredPlacements.isNotEmpty) {
        final packagesWithValues = _dashboardData!.featuredPlacements
            .where((p) => p.canShowPackage && p.packageAmount != null)
            .map((p) => p.packageAmount!)
            .toList();
        
        if (packagesWithValues.isNotEmpty) {
          final avgPackage = packagesWithValues.reduce((a, b) => a + b) / packagesWithValues.length;
          _dashboardData = DashboardData(
            featuredPlacements: _dashboardData!.featuredPlacements,
            featuredTestimonials: _dashboardData!.featuredTestimonials,
            latestNews: _dashboardData!.latestNews,
            stats: DashboardStats(
              totalStudents: _dashboardData!.stats.totalStudents,
              totalPlacements: _dashboardData!.stats.totalPlacements,
              averagePackage: avgPackage,
              coursesAvailable: _dashboardData!.stats.coursesAvailable,
            ),
          );
          print('- Calculated average package: ${avgPackage.toStringAsFixed(1)} LPA');
        }
      }
      
    } catch (e) {
      print('ContentViewModel: Home page content fetch failed: $e');
      _setError('Failed to load dashboard content: ${e.toString()}');
      
      // Try to load from cache as fallback
      try {
        final cachedPlacements = await _repository.getPlacements(featured: true, forceRefresh: false);
        final cachedTestimonials = await _repository.getTestimonials(featured: null, forceRefresh: false); // Get all testimonials
        final cachedNews = await _repository.getNews(featured: true, forceRefresh: false);
        
        _dashboardData = DashboardData(
          featuredPlacements: cachedPlacements.results,
          featuredTestimonials: cachedTestimonials.results,
          latestNews: cachedNews.results,
          stats: DashboardStats(
            totalStudents: 0,
            totalPlacements: cachedPlacements.count,
            averagePackage: 0.0,
            coursesAvailable: 0,
          ),
        );
        
        print('ContentViewModel: Loaded cached data successfully');
      } catch (cacheError) {
        print('ContentViewModel: Cache also failed: $cacheError');
        print('ContentViewModel: Loading mock data as last resort');
        loadMockData();
      }
    } finally {
      _isDashboardLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNews({
    int page = 1,
    String? category,
    String? search,
    bool? featured,
    bool forceRefresh = false,
    bool loadMore = false,
  }) async {
    if (_isNewsLoading) return;

    _isNewsLoading = true;
    if (!loadMore) _clearError();
    notifyListeners();

    try {
      final response = await _repository.getNews(
        page: page,
        category: category,
        search: search,
        featured: featured,
        forceRefresh: forceRefresh,
      );

      if (loadMore) {
        _news.addAll(response.results);
      } else {
        _news = response.results;
      }

      _newsCurrentPage = response.currentPage;
      _hasMoreNews = response.next != null;
    } catch (e) {
      _setError('Failed to load news: ${e.toString()}');
    } finally {
      _isNewsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreNews({
    String? category,
    String? search,
    bool? featured,
  }) async {
    if (!_hasMoreNews || _isNewsLoading) return;

    await fetchNews(
      page: _newsCurrentPage + 1,
      category: category,
      search: search,
      featured: featured,
      loadMore: true,
    );
  }

  Future<NewsArticle?> fetchNewsDetail(String slug, {bool forceRefresh = false}) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      final newsDetail = await _repository.getNewsDetail(slug, forceRefresh: forceRefresh);
      _isLoading = false;
      notifyListeners();
      return newsDetail;
    } catch (e) {
      _setError('Failed to load news detail: ${e.toString()}');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> fetchPlacements({
    int page = 1,
    String? placementType,
    String? course,
    bool? featured,
    bool forceRefresh = false,
    bool loadMore = false,
  }) async {
    if (_isPlacementsLoading) return;

    _isPlacementsLoading = true;
    if (!loadMore) _clearError();
    notifyListeners();

    try {
      final response = await _repository.getPlacements(
        page: page,
        placementType: placementType,
        course: course,
        featured: featured,
        forceRefresh: forceRefresh,
      );

      if (loadMore) {
        _placements.addAll(response.results);
      } else {
        _placements = response.results;
      }

      _placementsCurrentPage = response.currentPage;
      _hasMorePlacements = response.next != null;
    } catch (e) {
      _setError('Failed to load placements: ${e.toString()}');
    } finally {
      _isPlacementsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMorePlacements({
    String? placementType,
    String? course,
    bool? featured,
  }) async {
    if (!_hasMorePlacements || _isPlacementsLoading) return;

    await fetchPlacements(
      page: _placementsCurrentPage + 1,
      placementType: placementType,
      course: course,
      featured: featured,
      loadMore: true,
    );
  }

  Future<void> fetchTestimonials({
    int page = 1,
    String? testimonialType,
    String? course,
    int? rating,
    bool? featured,
    bool forceRefresh = false,
    bool loadMore = false,
  }) async {
    if (_isTestimonialsLoading) return;

    _isTestimonialsLoading = true;
    if (!loadMore) _clearError();
    notifyListeners();

    try {
      final response = await _repository.getTestimonials(
        page: page,
        testimonialType: testimonialType,
        course: course,
        rating: rating,
        featured: featured,
        forceRefresh: forceRefresh,
      );

      if (loadMore) {
        _testimonials.addAll(response.results);
      } else {
        _testimonials = response.results;
      }

      _testimonialsCurrentPage = response.currentPage;
      _hasMoreTestimonials = response.next != null;
    } catch (e) {
      _setError('Failed to load testimonials: ${e.toString()}');
    } finally {
      _isTestimonialsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreTestimonials({
    String? testimonialType,
    String? course,
    int? rating,
    bool? featured,
  }) async {
    if (!_hasMoreTestimonials || _isTestimonialsLoading) return;

    await fetchTestimonials(
      page: _testimonialsCurrentPage + 1,
      testimonialType: testimonialType,
      course: course,
      rating: rating,
      featured: featured,
      loadMore: true,
    );
  }

  Future<LeadSubmissionResponse> submitLead(LeadSubmission lead) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      final response = await _repository.submitLead(lead);
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to submit lead: ${e.toString()}');
    }
  }

  List<UserLead> _userLeads = [];
  bool _isLeadsLoading = false;

  List<UserLead> get userLeads => _userLeads;
  bool get isLeadsLoading => _isLeadsLoading;

  Future<void> fetchMyLeads({bool forceRefresh = false}) async {
    if (_isLeadsLoading) return;

    _isLeadsLoading = true;
    _clearError();
    notifyListeners();

    try {
      print('ContentViewModel: Fetching user leads (forceRefresh: $forceRefresh)');
      _userLeads = await _repository.getMyLeads(forceRefresh: forceRefresh);
      print('ContentViewModel: Successfully fetched ${_userLeads.length} leads');
    } catch (e) {
      print('ContentViewModel: Error fetching user leads: $e');
      _setError('Failed to load your applications: ${e.toString()}');
    } finally {
      _isLeadsLoading = false;
      notifyListeners();
    }
  }

  Future<UserLead?> fetchMyLeadDetail(int leadId, {bool forceRefresh = false}) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      print('ContentViewModel: Fetching lead detail for ID: $leadId');
      final lead = await _repository.getMyLeadDetail(leadId, forceRefresh: forceRefresh);
      _isLoading = false;
      notifyListeners();
      return lead;
    } catch (e) {
      print('ContentViewModel: Error fetching lead detail: $e');
      _setError('Failed to load application details: ${e.toString()}');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>?> searchContent({
    required String query,
    String? type,
    int limit = 5,
  }) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      final results = await _repository.searchContent(
        query: query,
        type: type,
        limit: limit,
      );
      _isLoading = false;
      notifyListeners();
      return results;
    } catch (e) {
      _setError('Failed to search content: ${e.toString()}');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> fetchCategories({bool forceRefresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      _categories = await _repository.getCategories(forceRefresh: forceRefresh);
    } catch (e) {
      _setError('Failed to load categories: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refreshAll() {
    fetchHomePageContent(forceRefresh: true);
    fetchNews(forceRefresh: true);
    fetchPlacements(forceRefresh: true);
    fetchTestimonials(forceRefresh: true);
    fetchCategories(forceRefresh: true);
    fetchMyLeads(forceRefresh: true);
  }

  void resetPagination() {
    _newsCurrentPage = 1;
    _placementsCurrentPage = 1;
    _testimonialsCurrentPage = 1;
    _hasMoreNews = true;
    _hasMorePlacements = true;
    _hasMoreTestimonials = true;
    _news.clear();
    _placements.clear();
    _testimonials.clear();
  }

  void clearCache() {
    ContentRepository.clearCache();
    resetPagination();
    _dashboardData = null;
    _categories = null;
    notifyListeners();
  }

  // Method to load mock data for testing UI
  void loadMockData() {
    print('ContentViewModel: Loading mock data for UI testing');
    
    final mockPlacements = [
      Placement(
        id: 1,
        studentName: "Raj Kumar",
        companyName: "Google",
        jobTitle: "Software Engineer",
        courseCompleted: "Full Stack Development",
        placementType: "full_time",
        placementTypeDisplay: "Full Time",
        packageAmount: 25.0,
        packageCurrency: "INR",
        canShowPackage: true,
        isFeatured: true,
        publishedAt: DateTime.now().subtract(const Duration(days: 5)),
        location: "Bangalore",
      ),
      Placement(
        id: 2,
        studentName: "Priya Singh",
        companyName: "Microsoft",
        jobTitle: "Frontend Developer",
        courseCompleted: "React Development",
        placementType: "full_time",
        placementTypeDisplay: "Full Time",
        packageAmount: 18.5,
        packageCurrency: "INR",
        canShowPackage: true,
        isFeatured: true,
        publishedAt: DateTime.now().subtract(const Duration(days: 3)),
        location: "Hyderabad",
      ),
    ];

    final mockTestimonials = [
      Testimonial(
        id: 1,
        studentName: "Anjali Verma",
        courseName: "Data Science",
        testimonialType: "text_image",
        testimonialTypeDisplay: "Text with Image",
        testimonialText: "This course completely transformed my career! The practical approach and industry-relevant projects helped me land my dream job at Amazon.",
        overallRating: 5,
        courseRating: 5,
        instructorRating: 5,
        currentPosition: "Data Analyst",
        currentCompany: "Amazon",
        careerImpact: "Promoted to Senior Analyst",
        isFeatured: true,
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Testimonial(
        id: 2,
        studentName: "Rohit Sharma",
        courseName: "DevOps Engineering",
        testimonialType: "video_youtube",
        testimonialTypeDisplay: "YouTube Video",
        testimonialText: "Amazing mentorship and hands-on learning experience. The instructors are industry experts who provide real-world insights.",
        youtubeVideoId: "example",
        overallRating: 5,
        courseRating: 4,
        instructorRating: 5,
        currentPosition: "DevOps Engineer",
        currentCompany: "Flipkart",
        isFeatured: true,
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    final mockNews = [
      NewsArticle(
        id: 1,
        title: "New AI/ML Course Launched with Industry Partnership",
        slug: "new-ai-ml-course-launched",
        excerpt: "We're excited to announce our new AI/ML course developed in partnership with leading tech companies, featuring real-world projects and mentorship.",
        content: "Full content here...",
        category: "course_updates",
        categoryDisplay: "Course Updates",
        isFeatured: true,
        viewCount: 245,
        publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
        createdBy: "Uptrail Team",
      ),
      NewsArticle(
        id: 2,
        title: "Student Success Story: From Fresher to Senior Developer",
        slug: "student-success-story-senior-developer",
        excerpt: "Read how Arjun went from being a college fresher to landing a senior developer role at a Fortune 500 company within 18 months.",
        content: "Full content here...",
        category: "student_success",
        categoryDisplay: "Student Success",
        isFeatured: true,
        viewCount: 189,
        publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
        createdBy: "Career Team",
      ),
    ];

    _dashboardData = DashboardData(
      featuredPlacements: mockPlacements,
      featuredTestimonials: mockTestimonials,
      latestNews: mockNews,
      stats: DashboardStats(
        totalStudents: 1250,
        totalPlacements: 890,
        averagePackage: 15.2,
        coursesAvailable: 25,
      ),
    );

    _isDashboardLoading = false;
    _error = null;
    notifyListeners();

    print('ContentViewModel: Mock data loaded successfully');
    print('- Mock placements: ${mockPlacements.length}');
    print('- Mock testimonials: ${mockTestimonials.length}');
    print('- Mock news: ${mockNews.length}');
  }
}