import 'package:flutter/material.dart';

enum AppActiveRole {
  unauthenticated,
  principal,
  superAdmin,
}

class AuthRoleProvider with ChangeNotifier {
  // Default to unauthenticated so the user sees the Principal Login screen first!
  AppActiveRole _activeRole = AppActiveRole.unauthenticated;

  AppActiveRole get activeRole => _activeRole;
  bool get isAuthenticated => _activeRole != AppActiveRole.unauthenticated;
  bool get isPrincipal => _activeRole == AppActiveRole.principal;
  bool get isSuperAdmin => _activeRole == AppActiveRole.superAdmin;

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
    notifyListeners();
  }

  void setRole(AppActiveRole role) {
    _activeRole = role;
    notifyListeners();
  }
}
