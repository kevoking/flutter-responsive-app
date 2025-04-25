// auth/auth_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthRepository {
  final String baseUrl;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  AuthRepository({required this.baseUrl});

  // API-based authentication
  Future<User> login(String email, String password) async {
    try {
      // final response = await http.post(
      //   Uri.parse('$baseUrl/auth/login'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'email': email,
      //     'password': password,
      //   }),
      // );

      final user = User(
        id: '123',
        name: 'John Doe',
        email: email,
        roles: ['user', 'admin'],
        photoUrl: 'https://example.com/photo.jpg',
      );

      // Simulating network delay and response for demo purposes
      final response = await Future.delayed(Duration(seconds: 2), () {
        return http.Response(
          jsonEncode({'user': user.toJson(), 'token': 'fake_token'}),
          200,
        );
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final userData = data['user'];

        // Save auth data to local storage
        final prefs = await SharedPreferences.getInstance();
        print('SharedPreferences initialized');
        await prefs.setString(_tokenKey, token);
        await prefs.setString(_userKey, jsonEncode(userData));

        final u = User.fromJson(userData);
        return user;
      } else {
        final error =
            jsonDecode(response.body)['message'] ?? 'Authentication failed';
        throw Exception(error);
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);

    // Optionally call logout endpoint
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      }
    } catch (e) {
      // Silently fail - we still want to clear local storage
    }
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    final token = prefs.getString(_tokenKey);

    if (userJson == null || token == null) {
      return null;
    }

    // Validate token (optional)
    try {
      // final response = await http.get(
      //   Uri.parse('$baseUrl/auth/me'),
      //   headers: {
      //     'Authorization': 'Bearer $token',
      //     'Content-Type': 'application/json',
      //   },
      // );
      final user = User(
        id: '123',
        name: 'John Doe',
        email: 'john@example.com',
        roles: ['user', 'admin'],
        photoUrl: 'https://example.com/photo.jpg',
      );
      // Simulating network delay and response for demo purposes
      final response = await Future.delayed(Duration(seconds: 2), () {
        return http.Response(jsonEncode(user.toJson()), 200);
      });

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return User.fromJson(userData);
      } else {
        // Token invalid, clear storage
        await prefs.remove(_tokenKey);
        await prefs.remove(_userKey);
        return null;
      }
    } catch (e) {
      // If server is unreachable, use cached user data
      try {
        return User.fromJson(jsonDecode(userJson));
      } catch (_) {
        return null;
      }
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}
