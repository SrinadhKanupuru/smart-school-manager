import 'package:flutter/material.dart';

enum FacultyModule {
  dashboard,
  classes,
  students,
  attendance,
  homework,
  assignments,
  exams,
  results,
  timetable,
  leave,
  messages,
  profile,
  settings,
}

class FacultyNavigationProvider with ChangeNotifier {
  FacultyModule _currentModule = FacultyModule.dashboard;
  String _searchQuery = '';
  int _unreadNotifCount = 2;
  String _selectedClass = 'Grade 9-A';

  FacultyModule get currentModule => _currentModule;
  String get searchQuery => _searchQuery;
  int get unreadNotificationCount => _unreadNotifCount;
  String get selectedClass => _selectedClass;

  void setModule(FacultyModule module) {
    if (_currentModule != module) {
      _currentModule = module;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedClass(String className) {
    _selectedClass = className;
    notifyListeners();
  }

  void clearNotifications() {
    _unreadNotifCount = 0;
    notifyListeners();
  }
}
