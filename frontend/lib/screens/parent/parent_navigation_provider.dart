import 'package:flutter/material.dart';

enum ParentModule {
  dashboard,
  children,
  attendance,
  homework,
  assignments,
  exams,
  fees,
  timetable,
  notices,
  messages,
  leave,
  profile,
  settings,
}

class ParentNavigationProvider with ChangeNotifier {
  ParentModule _currentModule = ParentModule.dashboard;
  String? _focusedChildId;

  ParentModule get currentModule => _currentModule;
  String? get focusedChildId => _focusedChildId;

  void setModule(ParentModule module, {String? childId}) {
    _currentModule = module;
    if (childId != null) {
      _focusedChildId = childId;
    }
    notifyListeners();
  }

  void navigateToChildProfile(String childId) {
    _focusedChildId = childId;
    _currentModule = ParentModule.children;
    notifyListeners();
  }
}
