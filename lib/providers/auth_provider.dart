import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/api.dart';

class AuthProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _saveServerSettings(String ip, String port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('serverIp', ip);
    await prefs.setString('serverPort', port);
    await API.init();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String permission,
    required String serverIp,
    required String serverPort,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      await _saveServerSettings(serverIp, serverPort);
      await AuthService.register(name, email, password, permission);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required String serverIp,
    required String serverPort,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      await _saveServerSettings(serverIp, serverPort);

      final token = await AuthService.login(email, password);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt', token);

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, String>> loadServerSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'ip': prefs.getString('serverIp') ?? '',
      'port': prefs.getString('serverPort') ?? '',
    };
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
