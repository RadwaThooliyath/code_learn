import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uptrail/model/content_models.dart';
import 'package:uptrail/services/content_service.dart';

class ContentRepository {
  static const String _dashboardCacheKey = 'dashboard_cache';
  static const String _newsCacheKey = 'news_cache';
  static const String _placementsCacheKey = 'placements_cache';
  static const String _testimonialsCacheKey = 'testimonials_cache';
  static const String _categoriesCacheKey = 'categories_cache';
  static const Duration _cacheExpiry = Duration(minutes: 15);

  static Future<void> _saveToCache(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString(key, jsonEncode(cacheData));
  }

  static Future<Map<String, dynamic>?> _getFromCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedString = prefs.getString(key);
    
    if (cachedString != null) {
      try {
        final cacheData = jsonDecode(cachedString);
        final timestamp = cacheData['timestamp'] as int;
        final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        
        if (DateTime.now().difference(cachedTime) < _cacheExpiry) {
          return cacheData['data'];
        } else {
          await prefs.remove(key);
        }
      } catch (e) {
        await prefs.remove(key);
      }
    }
    
    return null;
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_dashboardCacheKey),
      prefs.remove(_newsCacheKey),
      prefs.remove(_placementsCacheKey),
      prefs.remove(_testimonialsCacheKey),
      prefs.remove(_categoriesCacheKey),
    ]);
  }

  Future<DashboardData> getDashboardData({bool forceRefresh = false}) async {
    print('ContentRepository: getDashboardData called (forceRefresh: $forceRefresh)');
    
    if (!forceRefresh) {
      print('ContentRepository: Checking cache for dashboard data');
      final cachedData = await _getFromCache(_dashboardCacheKey);
      if (cachedData != null) {
        print('ContentRepository: Using cached dashboard data');
        return DashboardData.fromJson(cachedData);
      }
      print('ContentRepository: No cached data found, fetching from API');
    } else {
      print('ContentRepository: Force refresh requested, skipping cache');
    }

    try {
      print('ContentRepository: Calling ContentService.getDashboardData()');
      final dashboardData = await ContentService.getDashboardData();
      print('ContentRepository: Successfully received data from service');
      await _saveToCache(_dashboardCacheKey, dashboardData.toJson());
      print('ContentRepository: Data saved to cache');
      return dashboardData;
    } catch (e) {
      print('ContentRepository: Service call failed: $e');
      final cachedData = await _getFromCache(_dashboardCacheKey);
      if (cachedData != null) {
        print('ContentRepository: Falling back to cached data due to error');
        return DashboardData.fromJson(cachedData);
      }
      print('ContentRepository: No cached data available, rethrowing error');
      rethrow;
    }
  }

  Future<PaginatedResponse<NewsArticle>> getNews({
    int page = 1,
    String? category,
    String? search,
    bool? featured,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${_newsCacheKey}_${page}_${category ?? ''}_${search ?? ''}_${featured ?? ''}';
    
    if (!forceRefresh) {
      final cachedData = await _getFromCache(cacheKey);
      if (cachedData != null) {
        return PaginatedResponse.fromJson(cachedData, (item) => NewsArticle.fromJson(item));
      }
    }

    try {
      final newsData = await ContentService.getNews(
        page: page,
        category: category,
        search: search,
        featured: featured,
      );
      
      final jsonData = {
        'results': newsData.results.map((item) => item.toJson()).toList(),
        'pagination': {
          'count': newsData.count,
          'next': newsData.next,
          'previous': newsData.previous,
          'current_page': newsData.currentPage,
          'total_pages': newsData.totalPages,
        },
      };
      
      await _saveToCache(cacheKey, jsonData);
      return newsData;
    } catch (e) {
      final cachedData = await _getFromCache(cacheKey);
      if (cachedData != null) {
        return PaginatedResponse.fromJson(cachedData, (item) => NewsArticle.fromJson(item));
      }
      rethrow;
    }
  }

  Future<NewsArticle> getNewsDetail(String slug, {bool forceRefresh = false}) async {
    final cacheKey = 'news_detail_$slug';
    
    if (!forceRefresh) {
      final cachedData = await _getFromCache(cacheKey);
      if (cachedData != null) {
        return NewsArticle.fromJson(cachedData);
      }
    }

    try {
      final newsDetail = await ContentService.getNewsDetail(slug);
      await _saveToCache(cacheKey, newsDetail.toJson());
      return newsDetail;
    } catch (e) {
      final cachedData = await _getFromCache(cacheKey);
      if (cachedData != null) {
        return NewsArticle.fromJson(cachedData);
      }
      rethrow;
    }
  }

  Future<PaginatedResponse<Placement>> getPlacements({
    int page = 1,
    String? placementType,
    String? course,
    bool? featured,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${_placementsCacheKey}_${page}_${placementType ?? ''}_${course ?? ''}_${featured ?? ''}';
    
    if (!forceRefresh) {
      final cachedData = await _getFromCache(cacheKey);
      if (cachedData != null) {
        return PaginatedResponse.fromJson(cachedData, (item) => Placement.fromJson(item));
      }
    }

    try {
      final placementsData = await ContentService.getPlacements(
        page: page,
        placementType: placementType,
        course: course,
        featured: featured,
      );
      
      final jsonData = {
        'results': placementsData.results.map((item) => item.toJson()).toList(),
        'pagination': {
          'count': placementsData.count,
          'next': placementsData.next,
          'previous': placementsData.previous,
          'current_page': placementsData.currentPage,
          'total_pages': placementsData.totalPages,
        },
      };
      
      await _saveToCache(cacheKey, jsonData);
      return placementsData;
    } catch (e) {
      final cachedData = await _getFromCache(cacheKey);
      if (cachedData != null) {
        return PaginatedResponse.fromJson(cachedData, (item) => Placement.fromJson(item));
      }
      rethrow;
    }
  }

  Future<PaginatedResponse<Testimonial>> getTestimonials({
    int page = 1,
    String? testimonialType,
    String? course,
    int? rating,
    bool? featured,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${_testimonialsCacheKey}_${page}_${testimonialType ?? ''}_${course ?? ''}_${rating ?? ''}_${featured ?? ''}';
    
    if (!forceRefresh) {
      final cachedData = await _getFromCache(cacheKey);
      if (cachedData != null) {
        return PaginatedResponse.fromJson(cachedData, (item) => Testimonial.fromJson(item));
      }
    }

    try {
      final testimonialsData = await ContentService.getTestimonials(
        page: page,
        testimonialType: testimonialType,
        course: course,
        rating: rating,
        featured: featured,
      );
      
      final jsonData = {
        'results': testimonialsData.results.map((item) => item.toJson()).toList(),
        'pagination': {
          'count': testimonialsData.count,
          'next': testimonialsData.next,
          'previous': testimonialsData.previous,
          'current_page': testimonialsData.currentPage,
          'total_pages': testimonialsData.totalPages,
        },
      };
      
      await _saveToCache(cacheKey, jsonData);
      return testimonialsData;
    } catch (e) {
      final cachedData = await _getFromCache(cacheKey);
      if (cachedData != null) {
        return PaginatedResponse.fromJson(cachedData, (item) => Testimonial.fromJson(item));
      }
      rethrow;
    }
  }

  Future<LeadSubmissionResponse> submitLead(LeadSubmission lead) async {
    return await ContentService.submitLead(lead);
  }

  Future<List<UserLead>> getMyLeads({bool forceRefresh = false}) async {
    final cacheKey = 'my_leads_cache';
    
    if (!forceRefresh) {
      final cachedData = await _getFromCache(cacheKey);
      if (cachedData != null) {
        final List<dynamic> leadsData = cachedData['leads'];
        return leadsData.map((leadJson) => UserLead.fromJson(leadJson)).toList();
      }
    }

    try {
      final leads = await ContentService.getMyLeads();
      
      // Cache the leads data
      final jsonData = {
        'leads': leads.map((lead) => {
          'id': lead.id,
          'name': lead.name,
          'email': lead.email,
          'phone': lead.phone,
          'area_of_interest': lead.areaOfInterest,
          'other_interest': lead.otherInterest,
          'current_experience': lead.currentExperience,
          'career_goals': lead.careerGoals,
          'learning_timeline': lead.learningTimeline,
          'budget_range': lead.budgetRange,
          'preferred_time': lead.preferredTime,
          'specific_topics': lead.specificTopics,
          'preferred_contact_method': lead.preferredContactMethod,
          'source': lead.source,
          'status': lead.status,
          'created_at': lead.submittedAt.toIso8601String(),
          'contacted_at': lead.contactedAt?.toIso8601String(),
          'updated_at': lead.lastUpdated?.toIso8601String(),
          'notes': lead.notes,
          'assigned_to': lead.assignedTo,
        }).toList(),
      };
      
      await _saveToCache(cacheKey, jsonData);
      return leads;
    } catch (e) {
      // Try to return cached data if API call fails
      final cachedData = await _getFromCache(cacheKey);
      if (cachedData != null) {
        final List<dynamic> leadsData = cachedData['leads'];
        return leadsData.map((leadJson) => UserLead.fromJson(leadJson)).toList();
      }
      rethrow;
    }
  }

  Future<UserLead> getMyLeadDetail(int leadId, {bool forceRefresh = false}) async {
    final cacheKey = 'my_lead_detail_$leadId';
    
    if (!forceRefresh) {
      final cachedData = await _getFromCache(cacheKey);
      if (cachedData != null) {
        return UserLead.fromJson(cachedData);
      }
    }

    try {
      final lead = await ContentService.getMyLeadDetail(leadId);
      
      // Cache the lead detail
      final jsonData = {
        'id': lead.id,
        'name': lead.name,
        'email': lead.email,
        'phone': lead.phone,
        'area_of_interest': lead.areaOfInterest,
        'other_interest': lead.otherInterest,
        'current_experience': lead.currentExperience,
        'career_goals': lead.careerGoals,
        'learning_timeline': lead.learningTimeline,
        'budget_range': lead.budgetRange,
        'preferred_time': lead.preferredTime,
        'specific_topics': lead.specificTopics,
        'preferred_contact_method': lead.preferredContactMethod,
        'source': lead.source,
        'status': lead.status,
        'created_at': lead.submittedAt.toIso8601String(),
        'contacted_at': lead.contactedAt?.toIso8601String(),
        'updated_at': lead.lastUpdated?.toIso8601String(),
        'notes': lead.notes,
        'assigned_to': lead.assignedTo,
      };
      
      await _saveToCache(cacheKey, jsonData);
      return lead;
    } catch (e) {
      // Try to return cached data if API call fails
      final cachedData = await _getFromCache(cacheKey);
      if (cachedData != null) {
        return UserLead.fromJson(cachedData);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> searchContent({
    required String query,
    String? type,
    int limit = 5,
  }) async {
    return await ContentService.searchContent(
      query: query,
      type: type,
      limit: limit,
    );
  }

  Future<ContentCategories> getCategories({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedData = await _getFromCache(_categoriesCacheKey);
      if (cachedData != null) {
        return ContentCategories.fromJson(cachedData);
      }
    }

    try {
      final categories = await ContentService.getCategories();
      await _saveToCache(_categoriesCacheKey, {
        'news_categories': categories.newsCategories.map((item) => {'code': item.code, 'name': item.name}).toList(),
        'placement_types': categories.placementTypes.map((item) => {'code': item.code, 'name': item.name}).toList(),
        'testimonial_types': categories.testimonialTypes.map((item) => {'code': item.code, 'name': item.name}).toList(),
        'courses': categories.courses,
      });
      return categories;
    } catch (e) {
      final cachedData = await _getFromCache(_categoriesCacheKey);
      if (cachedData != null) {
        return ContentCategories.fromJson(cachedData);
      }
      rethrow;
    }
  }
}