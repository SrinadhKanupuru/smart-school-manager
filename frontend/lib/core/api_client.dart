import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class ApiClient {
  String? _token;
  String? _schoolId;

  String? get schoolId => _schoolId;

  void setSchoolId(String? schoolId) {
    _schoolId = schoolId;
  }

  ApiClient._internal();
  static final ApiClient instance = ApiClient._internal();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
  }

  String? get token => _token;

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  Map<String, String> _headers() {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    if (_schoolId != null) {
      headers['x-school-id'] = _schoolId!;
    }
    return headers;
  }

  Future<http.Response> get(String endpoint) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    return await http.get(uri, headers: _headers());
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    return await http.post(uri, headers: _headers(), body: jsonEncode(body));
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    return await http.put(uri, headers: _headers(), body: jsonEncode(body));
  }

  Future<http.Response> delete(String endpoint) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    return await http.delete(uri, headers: _headers());
  }

  Future<http.Response> uploadFile(String endpoint, List<int> bytes, String filename) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final request = http.MultipartRequest('POST', uri);
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    if (_schoolId != null) {
      request.headers['x-school-id'] = _schoolId!;
    }
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename,
    ));
    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> uploadMultipart(
    String endpoint,
    List<int> fileBytes,
    String filename,
    Map<String, String> fields,
  ) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final request = http.MultipartRequest('POST', uri);
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    if (_schoolId != null) {
      request.headers['x-school-id'] = _schoolId!;
    }
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: filename,
    ));
    request.fields.addAll(fields);
    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}
