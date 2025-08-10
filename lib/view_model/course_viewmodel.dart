import 'package:uptrail/model/course_model.dart';
import 'package:uptrail/services/course_service.dart';
import 'package:flutter/cupertino.dart';

class CourseViewModel extends ChangeNotifier {
  final CourseService _courseService = CourseService();
  
  List<Course> _courses = [];
  List<Course> _enrolledCourses = [];
  List<CourseCategory> _categories = [];
  Course? _selectedCourse;
  
  bool _isLoading = false;
  bool _isLoadingDetail = false;
  bool _isLoadingEnrolled = false;
  bool _isLoadingCategories = false;
  String _error = '';
  String _searchQuery = '';

  List<Course> get courses => _courses;
  List<Course> get enrolledCourses => _enrolledCourses;
  List<CourseCategory> get categories => _categories;
  Course? get selectedCourse => _selectedCourse;
  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isLoadingEnrolled => _isLoadingEnrolled;
  bool get isLoadingCategories => _isLoadingCategories;
  String get error => _error;
  String get searchQuery => _searchQuery;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingDetail(bool loading) {
    _isLoadingDetail = loading;
    notifyListeners();
  }

  void _setLoadingEnrolled(bool loading) {
    _isLoadingEnrolled = loading;
    notifyListeners();
  }

  void _setLoadingCategories(bool loading) {
    _isLoadingCategories = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _setError('');
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchCourses({
    String? category,
    bool? isFree,
    int? page,
    String? search,
  }) async {
    _setLoading(true);
    _setError('');
    
    try {
      _courses = await _courseService.getCourses(
        category: category,
        isFree: isFree,
        page: page,
        search: search,
      );
      print("✅ Fetched ${_courses.length} courses");
    } catch (e) {
      _setError('Failed to load courses: $e');
      print("❌ Error fetching courses: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchCourseDetail(int courseId) async {
    _setLoadingDetail(true);
    _setError('');
    
    try {
      _selectedCourse = await _courseService.getCourseDetail(courseId);
      print("✅ Fetched course detail: ${_selectedCourse?.title}");
    } catch (e) {
      _setError('Failed to load course details: $e');
      print("❌ Error fetching course detail: $e");
    } finally {
      _setLoadingDetail(false);
    }
  }

  Future<void> searchCourses(String query) async {
    if (query.isEmpty) {
      await fetchCourses();
      return;
    }
    
    _setLoading(true);
    _setError('');
    setSearchQuery(query);
    
    try {
      _courses = await _courseService.searchCourses(query);
      print("✅ Found ${_courses.length} courses for query: $query");
    } catch (e) {
      _setError('Failed to search courses: $e');
      print("❌ Error searching courses: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchCoursesWithFilters({
    String? query,
    String? category,
    bool? isFree,
  }) async {
    _setLoading(true);
    _setError('');
    
    if (query != null && query.isNotEmpty) {
      setSearchQuery(query);
    }
    
    try {
      if (query != null && query.isNotEmpty) {
        _courses = await _courseService.searchCourses(query);
        
        // Apply filters to search results if needed
        if (category != null || isFree != null) {
          _courses = _courses.where((course) {
            bool matchesCategory = category == null || course.category == category;
            bool matchesPrice = isFree == null || course.isFree == isFree;
            return matchesCategory && matchesPrice;
          }).toList();
        }
      } else {
        // Use regular course fetching with filters
        _courses = await _courseService.getCourses(
          category: category,
          isFree: isFree,
        );
      }
      
      print("✅ Found ${_courses.length} courses with filters");
    } catch (e) {
      _setError('Failed to search courses: $e');
      print("❌ Error searching courses: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchCategories() async {
    _setLoadingCategories(true);
    _setError('');
    
    try {
      _categories = await _courseService.getCategories();
      print("✅ Fetched ${_categories.length} categories");
    } catch (e) {
      _setError('Failed to load categories: $e');
      print("❌ Error fetching categories: $e");
    } finally {
      _setLoadingCategories(false);
    }
  }

  Future<void> fetchEnrolledCourses() async {
    _setLoadingEnrolled(true);
    _setError('');
    
    try {
      _enrolledCourses = await _courseService.getEnrolledCourses();
      print("✅ Fetched ${_enrolledCourses.length} enrolled courses");
    } catch (e) {
      _setError('Failed to load enrolled courses: $e');
      print("❌ Error fetching enrolled courses: $e");
    } finally {
      _setLoadingEnrolled(false);
    }
  }

  void clearSelectedCourse() {
    _selectedCourse = null;
    notifyListeners();
  }

  Future<void> refreshCourses() async {
    await fetchCourses();
  }

  Future<void> loadCoursesByCategory(String category) async {
    await fetchCourses(category: category);
  }

  Future<void> loadFreeCourses() async {
    await fetchCourses(isFree: true);
  }

  Future<void> loadPaidCourses() async {
    await fetchCourses(isFree: false);
  }
}