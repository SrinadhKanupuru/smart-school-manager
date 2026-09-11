import 'package:flutter/material.dart';

enum PrincipalModule {
  dashboard,
  teachers,
  students,
  attendance,
  leaveManagement,
  academics,
  account,
  reports,
  notices,
  settings,
}

class PrincipalNavigationProvider with ChangeNotifier {
  PrincipalModule _currentModule = PrincipalModule.dashboard;
  String _searchQuery = '';
  int _unreadNotifCount = 3;

  PrincipalModule get currentModule => _currentModule;
  String get searchQuery => _searchQuery;
  int get unreadNotificationCount => _unreadNotifCount;

  void setModule(PrincipalModule module) {
    if (_currentModule != module) {
      _currentModule = module;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearNotifications() {
    _unreadNotifCount = 0;
    notifyListeners();
  }
}
