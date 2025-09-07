import 'dart:convert';
import 'package:uptrail/api_constants/api_constants.dart';
import 'package:uptrail/model/team_model.dart';
import 'package:uptrail/services/auth_service.dart';
import 'package:uptrail/services/storage_service.dart';
import 'package:http/http.dart' as http;

class TeamService {
  final AuthService _authService = AuthService();
  
  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _makeAuthorizedRequest(
    Future<http.Response> Function() request,
  ) async {
    var response = await request();
    
    if (response.statusCode == 401) {
      final newToken = await _authService.refreshToken();
      
      if (newToken != null) {
        response = await request();
      } else {
      }
    }
    
    return response;
  }

  Future<List<Team>> getMyTeams({
    String? ordering,
    int? page,
    String? search,
  }) async {
    try {
      Uri url = Uri.parse(ApiConstants.myTeams);
      
      Map<String, String> queryParams = {};
      if (ordering != null) queryParams['ordering'] = ordering;
      if (page != null) queryParams['page'] = page.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      if (queryParams.isNotEmpty) {
        url = url.replace(queryParameters: queryParams);
      }

      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> teams;
        if (data is Map && data.containsKey('results')) {
          teams = data['results'] as List;
        } else if (data is List) {
          teams = data;
        } else {
          return [];
        }
        
        return teams.map((teamJson) => Team.fromJson(teamJson)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('User not authenticated');
      } else {
        throw Exception('Failed to fetch my teams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching my teams: $e');
    }
  }

  Future<List<Team>> getAllTeams({
    String? ordering,
    int? page,
    String? search,
  }) async {
    try {
      Uri url = Uri.parse(ApiConstants.teams);
      
      Map<String, String> queryParams = {};
      if (ordering != null) queryParams['ordering'] = ordering;
      if (page != null) queryParams['page'] = page.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      if (queryParams.isNotEmpty) {
        url = url.replace(queryParameters: queryParams);
      }

      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> teams;
        if (data is Map && data.containsKey('results')) {
          teams = data['results'] as List;
        } else if (data is List) {
          teams = data;
        } else {
          return [];
        }
        
        return teams.map((teamJson) => Team.fromJson(teamJson)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('User not authenticated');
      } else {
        throw Exception('Failed to fetch teams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching teams: $e');
    }
  }

  Future<Team?> getTeamDetails(int teamId) async {
    try {
      final url = Uri.parse(ApiConstants.teamDetail(teamId));
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Team.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('User not authenticated');
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch team details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching team details: $e');
    }
  }

  Future<Team?> createTeam(TeamCreateRequest request) async {
    try {
      final url = Uri.parse(ApiConstants.teams);
      
      final body = jsonEncode(request.toJson());
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.post(
          url,
          headers: await _getHeaders(),
          body: body,
        );
      });
      
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Team.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('User not authenticated');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create team');
      }
    } catch (e) {
      throw Exception('Error creating team: $e');
    }
  }

  Future<Team?> updateTeam(int teamId, TeamUpdateRequest request) async {
    try {
      final url = Uri.parse(ApiConstants.teamDetail(teamId));
      
      final body = jsonEncode(request.toJson());
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.put(
          url,
          headers: await _getHeaders(),
          body: body,
        );
      });
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Team.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('User not authenticated');
      } else if (response.statusCode == 403) {
        throw Exception('Not allowed to update this team');
      } else if (response.statusCode == 404) {
        throw Exception('Team not found');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update team');
      }
    } catch (e) {
      throw Exception('Error updating team: $e');
    }
  }

  Future<bool> deleteTeam(int teamId) async {
    try {
      final url = Uri.parse(ApiConstants.teamDetail(teamId));
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.delete(url, headers: await _getHeaders());
      });
      
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('User not authenticated');
      } else if (response.statusCode == 403) {
        throw Exception('Not allowed to delete this team');
      } else if (response.statusCode == 404) {
        throw Exception('Team not found');
      } else {
        throw Exception('Failed to delete team: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting team: $e');
    }
  }

  Future<Map<String, dynamic>?> joinTeam(int teamId) async {
    try {
      final url = Uri.parse(ApiConstants.joinTeam(teamId));
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.post(url, headers: await _getHeaders());
      });
      
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('User not authenticated');
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Cannot join team');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to join team');
      }
    } catch (e) {
      throw Exception('Error joining team: $e');
    }
  }

  Future<Map<String, dynamic>?> leaveTeam(int teamId) async {
    try {
      final url = Uri.parse(ApiConstants.leaveTeam(teamId));
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.post(url, headers: await _getHeaders());
      });
      
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('User not authenticated');
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Cannot leave team');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to leave team');
      }
    } catch (e) {
      throw Exception('Error leaving team: $e');
    }
  }
}