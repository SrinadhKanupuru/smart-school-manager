import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberMe = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get rememberMe => _rememberMe;
  bool get isAuthenticated => _currentUser != null;

  bool get isFaculty => _currentUser?.role == UserRole.faculty;
  bool get isPrincipal => _currentUser?.role == UserRole.principal;
  bool get isSuperAdmin => _currentUser?.role == UserRole.superAdmin;

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Attempts to authenticate the user
  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.authenticate(
        identifier: identifier,
        password: password,
      );

      _isLoading = false;

      if (result.isSuccess && result.user != null) {
        _currentUser = result.user;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.errorMessage ?? 'Invalid Employee ID or password.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Sends password reset instructions
  Future<String?> sendPasswordReset(String identifier) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final msg = await _authService.sendPasswordResetLink(identifier);
      _isLoading = false;
      notifyListeners();
      return msg;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  /// Logs out active session
  void logout() {
    _currentUser = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// For direct testing / role override
  void setMockUser(UserModel user) {
    _currentUser = user;
    _errorMessage = null;
    notifyListeners();
  }
}
