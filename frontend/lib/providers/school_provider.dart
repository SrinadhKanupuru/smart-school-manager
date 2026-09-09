import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/constants.dart';

class SchoolProvider extends ChangeNotifier {
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? _currentSchool;
  List<dynamic> _schools = [];
  List<dynamic> _users = [];
  List<dynamic> _myAttendanceHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get currentUser => _currentUser;
  Map<String, dynamic>? get currentSchool => _currentSchool;
  List<dynamic> get schools => _schools;
  List<dynamic> get users => _users;
  List<dynamic> get myAttendanceHistory => _myAttendanceHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _currentUser != null;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(ApiConstants.login, {
        'email': email,
        'password': password,
      });

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await ApiClient.instance.saveToken(data['token']);
        _currentUser = data['user'];
        _currentSchool = data['school'];
        if (_currentSchool != null) {
          ApiClient.instance.setSchoolId(_currentSchool!['id']);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['error'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error. Please check if backend is running.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerSchool({
    required Map<String, dynamic> schoolDetails,
    required Map<String, dynamic> correspondentDetails,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(ApiConstants.register, {
        'schoolDetails': schoolDetails,
        'correspondentDetails': correspondentDetails,
      });

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        await ApiClient.instance.saveToken(data['token']);
        _currentUser = data['user'];
        _currentSchool = data['school'];
        if (_currentSchool != null) {
          ApiClient.instance.setSchoolId(_currentSchool!['id']);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['error'] ?? 'School registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error. Please check if backend is running.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchSchools() async {
    try {
      final response = await ApiClient.instance.get(ApiConstants.schoolsList);
      if (response.statusCode == 200) {
        _schools = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print('Failed to load schools: $e');
    }
  }

  Future<void> loadProfile() async {
    if (ApiClient.instance.token == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get(ApiConstants.profile);
      if (response.statusCode == 200) {
        _currentUser = jsonDecode(response.body);
        _currentSchool = _currentUser?['school'];
        if (_currentSchool != null) {
          ApiClient.instance.setSchoolId(_currentSchool!['id']);
        }
      } else {
        await logout();
      }
    } catch (e) {
      print('Load profile error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addUser({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String role,
    Map<String, dynamic>? details,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(ApiConstants.addUser, {
        'fullName': fullName,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'role': role,
        'details': details,
      });

      final data = jsonDecode(response.body);
      _isLoading = false;
      if (response.statusCode == 201) {
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['error'] ?? 'Failed to add user';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addUserWithFace({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String role,
    Map<String, dynamic>? details,
    required List<int> fileBytes,
    required String filename,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fields = {
        'fullName': fullName,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'role': role,
        if (details != null) 'details': jsonEncode(details),
      };

      final response = await ApiClient.instance.uploadMultipart(
        ApiConstants.registerStaffWithFace,
        fileBytes,
        filename,
        fields,
      );

      final data = jsonDecode(response.body);
      _isLoading = false;
      if (response.statusCode == 201) {
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['error'] ?? 'Failed to add user with face';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> verifyStaffAttendance({
    required List<int> fileBytes,
    required String filename,
    double? latitude,
    double? longitude,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fields = {
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
      };

      final response = await ApiClient.instance.uploadMultipart(
        ApiConstants.verifyStaffAttendance,
        fileBytes,
        filename,
        fields,
      );

      final data = jsonDecode(response.body);
      _isLoading = false;
      if (response.statusCode == 200) {
        notifyListeners();
        return data;
      } else {
        _errorMessage = data['error'] ?? 'Attendance verification failed';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> addParentAndAssignStudents({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String relation,
    required List<String> studentIds,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(ApiConstants.addParent, {
        'fullName': fullName,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'relation': relation,
        'studentIds': studentIds,
      });

      final data = jsonDecode(response.body);
      _isLoading = false;
      if (response.statusCode == 201) {
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['error'] ?? 'Failed to add parent';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createSchool(Map<String, dynamic> schoolDetails) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post(ApiConstants.schoolsList, schoolDetails);
      final data = jsonDecode(response.body);
      _isLoading = false;
      if (response.statusCode == 201) {
        _currentSchool = data['school'];
        if (_currentSchool != null) {
          ApiClient.instance.setSchoolId(_currentSchool!['id']);
        }
        await fetchSchools();
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['error'] ?? 'Failed to create school';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSchool(String schoolId, Map<String, dynamic> details) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.put('${ApiConstants.schoolsList}/$schoolId', details);
      final data = jsonDecode(response.body);
      _isLoading = false;
      if (response.statusCode == 200) {
        final updatedSchool = data['school'];
        if (updatedSchool != null) {
          if (_currentSchool != null && _currentSchool!['id'] == schoolId) {
            _currentSchool = updatedSchool;
            if (_currentUser != null) {
              _currentUser!['school'] = updatedSchool;
            }
          }
        }
        await fetchSchools();
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['error'] ?? 'Failed to update school details';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSchool(String schoolId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.delete('${ApiConstants.schoolsList}/$schoolId');
      final data = jsonDecode(response.body);
      _isLoading = false;
      if (response.statusCode == 200) {
        await fetchSchools();
        if (_currentSchool != null && _currentSchool!['id'] == schoolId) {
          if (_schools.isNotEmpty) {
            _currentSchool = _schools.first;
          } else {
            _currentSchool = null;
          }
        }
        notifyListeners();
        return true;
      } else {
        _errorMessage = data['error'] ?? 'Failed to delete school';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Connection error';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> switchSchool(Map<String, dynamic> school) async {
    _currentSchool = school;
    if (_currentUser != null) {
      _currentUser!['schoolId'] = school['id'];
      _currentUser!['school'] = school;
    }
    ApiClient.instance.setSchoolId(school['id']);
    notifyListeners();
  }

  Future<void> fetchUsers({String? role}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      String endpoint = ApiConstants.usersByRole;
      if (role != null) {
        endpoint += '?role=$role';
      }
      final response = await ApiClient.instance.get(endpoint);
      if (response.statusCode == 200) {
        _users = jsonDecode(response.body);
      } else {
        _errorMessage = 'Failed to load users';
      }
    } catch (e) {
      _errorMessage = 'Connection error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyAttendanceHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await ApiClient.instance.get('/school/my-attendance');
      if (response.statusCode == 200) {
        _myAttendanceHistory = jsonDecode(response.body);
      } else {
        _errorMessage = 'Failed to load attendance history';
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await ApiClient.instance.clearToken();
    ApiClient.instance.setSchoolId(null);
    _currentUser = null;
    _currentSchool = null;
    _users = [];
    _myAttendanceHistory = [];
    notifyListeners();
  }
}
