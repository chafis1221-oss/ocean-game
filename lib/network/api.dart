// api.dart - HTTP API ke backend

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class Api {
  static String? _token;

  // ===== REGISTER =====
  static Future<Map<String, dynamic>> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        if (data['data']?['token'] != null) await _saveToken(data['data']['token']);
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ===== LOGIN =====
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (data['data']?['token'] != null) await _saveToken(data['data']['token']);
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ===== GET PROFILE =====
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await _getToken();
      if (token == null) return {'success': false, 'error': 'Not logged in'};
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/profile'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to get profile'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ===== GET LEADERBOARD =====
  static Future<Map<String, dynamic>> getLeaderboard({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/leaderboard?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to get leaderboard'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ===== GET SERVER STATUS =====
  static Future<Map<String, dynamic>> getStatus() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/status'),
        headers: {'Content-Type': 'application/json'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to get status'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ===== TOKEN STORAGE =====
  static Future<void> _saveToken(String token) async { _token = token; }
  static Future<String?> _getToken() async { return _token; }
  static Future<void> logout() async { _token = null; }
}
