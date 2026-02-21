import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mediar/models/album_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/album.dart';
import 'api.dart';

class AlbumService {

  static Future<List<AlbumModel>> fetchAlbums() async {
    await API.init();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null) {
      throw Exception('No JWT token found. Please login.');
    }

    final response = await http.get(
      Uri.parse('${API.apiBaseUrl}/api/albums'),
      headers: API.authHeaders(token)
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => AlbumModel.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login.');
    } else {
      throw Exception('Failed to load albums: ${response.statusCode}');
    }
  }


  static Future<AlbumDetailModel> fetchAlbum(int albumId) async {
    await API.init();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    if (token == null) {
      throw Exception('No JWT token found. Please login.');
    }

    final response = await http.get(
      Uri.parse('${API.apiBaseUrl}/api/album/$albumId'),
      headers: API.authHeaders(token)
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return AlbumDetailModel.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login.');
    } else {
      throw Exception('Failed to load album: ${response.statusCode}');
    }
  }

  static Future<void> createAlbum({
    required String name,
    required String description,
    required File image,
  }) async {
    await API.init();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${API.apiBaseUrl}/api/albums/'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['Name'] = name;
    request.fields['Description'] = description;

    request.files.add(
      await http.MultipartFile.fromPath(
        'coverImage',
        image.path,
      ),
    );

    final response = await request.send();

    if (response.statusCode != 201) {
      throw Exception('Failed to create album');
    }
  }

  static Future<void> updateAlbum({
    required int albumId,
    required String name,
    required String description,
    required File? image,
  }) async {
    await API.init();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('${API.apiBaseUrl}/api/album/${albumId.toString()}'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['Name'] = name;
    request.fields['Description'] = description;

    if (image != null){
      request.files.add(
        await http.MultipartFile.fromPath(
          'CoverImage',
          image.path,
        ),
      );
    }

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update album');
    }
  }

  static Future<void> deleteAlbum({
    required int albumId,
  }) async {
    await API.init();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    final request = http.MultipartRequest(
      'DELETE',
      Uri.parse('${API.apiBaseUrl}/api/album/${albumId.toString()}'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['albumId'] = albumId.toString();

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete media');
    }
  }


  //============================ Media ===============================//


  static Future<void> createMedia({
    required albumId,
    required File image,
  }) async {
    await API.init();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${API.apiBaseUrl}/api/album/${albumId.toString()}/media/'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['albumId'] = albumId.toString();
    request.files.add(
      await http.MultipartFile.fromPath(
        'mediaImage',
        image.path,
      ),
    );

    final response = await request.send();

    if (response.statusCode != 201) {
      throw Exception('Failed to create media');
    }
  }

  static Future<void> deleteMedia({
    required int mediaId,
  }) async {
    await API.init();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    final request = http.MultipartRequest(
      'DELETE',
      Uri.parse('${API.apiBaseUrl}/api/album/media/${mediaId.toString()}'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['mediaId'] = mediaId.toString();

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete media');
    }
  }

}
