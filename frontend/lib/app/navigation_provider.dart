import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/teacher_model.dart';
import '../models/student_model.dart';
import '../data/mock_data.dart';
import '../core/api_client.dart';

enum AppModule {
  dashboard,
  principal,
  teachers,
  students,
  parentPortal,
  attendance,
  leaveManagement,
  academics,
  account,
  reports,
  settings,
}

class NavigationProvider with ChangeNotifier {
  AppModule _currentModule = AppModule.dashboard;
  bool _isSidebarCollapsed = false;
  String _searchQuery = '';
  
  TeacherModel? _selectedTeacher;
  StudentModel? _selectedStudent;

  AppModule get currentModule => _currentModule;
  bool get isSidebarCollapsed => _isSidebarCollapsed;
  String get searchQuery => _searchQuery;
  TeacherModel? get selectedTeacher => _selectedTeacher;
  StudentModel? get selectedStudent => _selectedStudent;

  int get unreadNotificationCount =>
      MockData.notifications.where((n) => !n.isRead).length;

  void setModule(AppModule module) {
    if (_currentModule != module) {
      _currentModule = module;
      _selectedTeacher = null;
      _selectedStudent = null;
      notifyListeners();
    }
  }

  void toggleSidebar() {
    _isSidebarCollapsed = !_isSidebarCollapsed;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectTeacher(TeacherModel? teacher) {
    _selectedTeacher = teacher;
    notifyListeners();
  }

  void selectStudent(StudentModel? student) {
    _selectedStudent = student;
    notifyListeners();
  }

  void markAllNotificationsAsRead() {
    for (var n in MockData.notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void approveLeave(String leaveId, String? remarks) {
    final leave = MockData.leaves.firstWhere((l) => l.id == leaveId);
    leave.status = 'Approved';
    leave.adminRemarks = remarks ?? 'Approved by Super Admin.';
    notifyListeners();
  }

  void rejectLeave(String leaveId, String? remarks) {
    final leave = MockData.leaves.firstWhere((l) => l.id == leaveId);
    leave.status = 'Rejected';
    leave.adminRemarks = remarks ?? 'Rejected by Super Admin.';
    notifyListeners();
  }

  void addStudent(StudentModel student) {
    MockData.students.insert(0, student);
    notifyListeners();
  }

  void addTeacher(TeacherModel teacher) {
    MockData.teachers.insert(0, teacher);
    notifyListeners();
    // Persist to PostgreSQL database asynchronously
    ApiClient.instance.post('/school/quick-teacher', {
      'fullName': teacher.name,
      'email': teacher.email,
      'phoneNumber': teacher.phone,
      'subject': teacher.subject,
      'handledClass': teacher.handledClass,
      'qualification': teacher.qualification,
      'experienceYears': 5,
      'salaryAmount': 45000,
    }).catchError((e) {
      debugPrint('Sync teacher error: $e');
      return http.Response('{"error": "$e"}', 500);
    });
  }
}
