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
      print("🔄 Token expired, attempting refresh...");
      final newToken = await _authService.refreshToken();
      
      if (newToken != null) {
        print("✅ Token refreshed, retrying request...");
        response = await request();
      } else {
        print("❌ Token refresh failed, user needs to re-login");
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

      print("👥 Fetching my teams from: $url");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> teams;
        if (data is Map && data.containsKey('results')) {
          teams = data['results'] as List;
        } else if (data is List) {
          teams = data;
        } else {
          print("❌ Unexpected response format for my teams");
          return [];
        }
        
        print("✅ Found ${teams.length} teams");
        return teams.map((teamJson) => Team.fromJson(teamJson)).toList();
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else {
        print("❌ Failed to fetch my teams: ${response.statusCode}");
        throw Exception('Failed to fetch my teams: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching my teams: $e");
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

      print("🌐 Fetching all teams from: $url");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<dynamic> teams;
        if (data is Map && data.containsKey('results')) {
          teams = data['results'] as List;
        } else if (data is List) {
          teams = data;
        } else {
          print("❌ Unexpected response format for teams");
          return [];
        }
        
        print("✅ Found ${teams.length} teams");
        return teams.map((teamJson) => Team.fromJson(teamJson)).toList();
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else {
        print("❌ Failed to fetch teams: ${response.statusCode}");
        throw Exception('Failed to fetch teams: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching teams: $e");
      throw Exception('Error fetching teams: $e');
    }
  }

  Future<Team?> getTeamDetails(int teamId) async {
    try {
      final url = Uri.parse(ApiConstants.teamDetail(teamId));
      print("👥 Fetching team details from: $url");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.get(url, headers: await _getHeaders());
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Team.fromJson(data);
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else if (response.statusCode == 404) {
        print("❌ Team not found");
        return null;
      } else {
        print("❌ Failed to fetch team details: ${response.statusCode}");
        throw Exception('Failed to fetch team details: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error fetching team details: $e");
      throw Exception('Error fetching team details: $e');
    }
  }

  Future<Team?> createTeam(TeamCreateRequest request) async {
    try {
      final url = Uri.parse(ApiConstants.teams);
      print("➕ Creating team at: $url");
      
      final body = jsonEncode(request.toJson());
      print("Request Body: $body");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.post(
          url,
          headers: await _getHeaders(),
          body: body,
        );
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Team.fromJson(data);
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else {
        print("❌ Failed to create team: ${response.statusCode}");
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create team');
      }
    } catch (e) {
      print("❌ Error creating team: $e");
      throw Exception('Error creating team: $e');
    }
  }

  Future<Team?> updateTeam(int teamId, TeamUpdateRequest request) async {
    try {
      final url = Uri.parse(ApiConstants.teamDetail(teamId));
      print("✏️ Updating team at: $url");
      
      final body = jsonEncode(request.toJson());
      print("Request Body: $body");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.put(
          url,
          headers: await _getHeaders(),
          body: body,
        );
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Team.fromJson(data);
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else if (response.statusCode == 403) {
        print("❌ Forbidden - Not allowed to update this team");
        throw Exception('Not allowed to update this team');
      } else if (response.statusCode == 404) {
        print("❌ Team not found");
        throw Exception('Team not found');
      } else {
        print("❌ Failed to update team: ${response.statusCode}");
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update team');
      }
    } catch (e) {
      print("❌ Error updating team: $e");
      throw Exception('Error updating team: $e');
    }
  }

  Future<bool> deleteTeam(int teamId) async {
    try {
      final url = Uri.parse(ApiConstants.teamDetail(teamId));
      print("🗑️ Deleting team at: $url");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.delete(url, headers: await _getHeaders());
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        print("✅ Team deleted successfully");
        return true;
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else if (response.statusCode == 403) {
        print("❌ Forbidden - Not allowed to delete this team");
        throw Exception('Not allowed to delete this team');
      } else if (response.statusCode == 404) {
        print("❌ Team not found");
        throw Exception('Team not found');
      } else {
        print("❌ Failed to delete team: ${response.statusCode}");
        throw Exception('Failed to delete team: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error deleting team: $e");
      throw Exception('Error deleting team: $e');
    }
  }

  Future<Map<String, dynamic>?> joinTeam(int teamId) async {
    try {
      final url = Uri.parse(ApiConstants.joinTeam(teamId));
      print("🚀 Joining team at: $url");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.post(url, headers: await _getHeaders());
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print("✅ Successfully joined team");
        return data;
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        print("❌ Bad request: ${errorData['message']}");
        throw Exception(errorData['message'] ?? 'Cannot join team');
      } else {
        print("❌ Failed to join team: ${response.statusCode}");
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to join team');
      }
    } catch (e) {
      print("❌ Error joining team: $e");
      throw Exception('Error joining team: $e');
    }
  }

  Future<Map<String, dynamic>?> leaveTeam(int teamId) async {
    try {
      final url = Uri.parse(ApiConstants.leaveTeam(teamId));
      print("🚪 Leaving team at: $url");
      
      final response = await _makeAuthorizedRequest(() async {
        return await http.post(url, headers: await _getHeaders());
      });
      
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Successfully left team");
        return data;
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized - User not logged in");
        throw Exception('User not authenticated');
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);
        print("❌ Bad request: ${errorData['message']}");
        throw Exception(errorData['message'] ?? 'Cannot leave team');
      } else {
        print("❌ Failed to leave team: ${response.statusCode}");
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to leave team');
      }
    } catch (e) {
      print("❌ Error leaving team: $e");
      throw Exception('Error leaving team: $e');
    }
  }
}