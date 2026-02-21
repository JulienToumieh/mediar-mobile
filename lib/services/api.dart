import 'package:shared_preferences/shared_preferences.dart';

class API {
  API._();

  //static const String apiBaseUrl ='http://localhost:5050';// 'http://192.168.0.180:5050';

  static late String apiBaseUrl;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final serverIp = prefs.getString('serverIp');
    final serverPort = prefs.getString('serverPort');

    apiBaseUrl = "http://$serverIp:$serverPort";
  }

  static Map<String, String> authHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }
}
