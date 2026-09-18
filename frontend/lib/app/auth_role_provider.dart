import 'package:flutter/material.dart';
import '../auth/models/user_model.dart';

enum AppActiveRole {
  unauthenticated,
  parent,
  faculty,
  principal,
  superAdmin,
}

class AuthRoleProvider with ChangeNotifier {
  // Default to unauthenticated so user lands on Login screen
  AppActiveRole _activeRole = AppActiveRole.unauthenticated;
  UserModel? _currentFacultyUser;
  UserModel? _currentParentUser;

  AppActiveRole get activeRole => _activeRole;
  UserModel? get currentFacultyUser => _currentFacultyUser;
  UserModel? get currentParentUser => _currentParentUser;

  bool get isAuthenticated => _activeRole != AppActiveRole.unauthenticated;
  bool get isParent => _activeRole == AppActiveRole.parent;
  bool get isFaculty => _activeRole == AppActiveRole.faculty;
  bool get isPrincipal => _activeRole == AppActiveRole.principal;
  bool get isSuperAdmin => _activeRole == AppActiveRole.superAdmin;

  void loginAsParent([UserModel? user]) {
    _activeRole = AppActiveRole.parent;
    _currentParentUser = user ?? UserModel.parentDefault();
    notifyListeners();
  }

  void loginAsFaculty([UserModel? user]) {
    _activeRole = AppActiveRole.faculty;
    _currentFacultyUser = user ?? UserModel.facultyDefault();
    notifyListeners();
  }

  void loginAsPrincipal() {
    _activeRole = AppActiveRole.principal;
    notifyListeners();
  }

  void loginAsSuperAdmin() {
    _activeRole = AppActiveRole.superAdmin;
    notifyListeners();
  }

  void logout() {
    _activeRole = AppActiveRole.unauthenticated;
    _currentFacultyUser = null;
    _currentParentUser = null;
    notifyListeners();
  }

  void setRole(AppActiveRole role) {
    _activeRole = role;
    if (role == AppActiveRole.faculty && _currentFacultyUser == null) {
      _currentFacultyUser = UserModel.facultyDefault();
    } else if (role == AppActiveRole.parent && _currentParentUser == null) {
      _currentParentUser = UserModel.parentDefault();
    }
    notifyListeners();
  }
}
