import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mediar/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './api.dart';

class AuthService {

  static Future<String> login(String email, String password) async {
    await API.init();
    final response = await http.post(
      Uri.parse('${API.apiBaseUrl}/api/account/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  static Future<void> register(
    String name,
    String email,
    String password,
    String permission,
  ) async {
    await API.init();

    final response = await http.post(
      Uri.parse('${API.apiBaseUrl}/api/account/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'permission': permission,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      try {
        final body = jsonDecode(response.body);
        final message = body['message'] ?? 'Registration failed';
        throw Exception(message);
      } catch (_) {
        throw Exception('Registration failed: ${response.body}');
      }
    }
  }


  static Future<List<UserModel>> fetchUsers() async {
    await API.init();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null) {
      throw Exception('No JWT token found. Please login.');
    }

    final response = await http.get(
      Uri.parse('${API.apiBaseUrl}/api/account/users'),
      headers: API.authHeaders(token)
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => UserModel.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login.');
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
  }

  static void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt'); 
  }

  static Future<void> deleteUser({
    required int userId,
  }) async {
    await API.init();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    final request = http.MultipartRequest(
      'DELETE',
      Uri.parse('${API.apiBaseUrl}/api/account/users/${userId.toString()}'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['userId'] = userId.toString();

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }

  static Future<void> updateUser({
    required int userId,
    required String name,
    required String password,
    required String? newPassword,
  }) async {
    await API.init();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('${API.apiBaseUrl}/api/account/$userId'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['Name'] = name;
    request.fields['Password'] = password;

    if (newPassword != null) {
      request.fields['NewPassword'] = newPassword;
    }

    final response = await request.send();

    if (response.statusCode == 401) {
      throw Exception('WRONG_PASSWORD');
    }

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('UPDATE_FAILED');
    }
  }

}
