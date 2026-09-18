import 'package:flutter/material.dart';
import '../models/teacher_model.dart';
import '../models/student_model.dart';
import '../models/principal_model.dart';
import '../models/parent_model.dart';
import '../models/leave_model.dart';
import '../models/fee_data.dart';
import '../models/kpi_card_data.dart';
import '../data/mock_data.dart';
import '../services/api_service.dart';

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

  // Live Database Backed Lists
  List<StudentModel> _students = [];
  List<TeacherModel> _teachers = [];
  List<PrincipalModel> _principals = [];
  List<ParentModel> _parents = [];
  List<LeaveApplication> _leaves = [];
  List<FeeTransaction> _fees = [];
  Map<String, dynamic> _dashboardStats = {};
  bool _isLoading = false;

  AppModule get currentModule => _currentModule;
  bool get isSidebarCollapsed => _isSidebarCollapsed;
  String get searchQuery => _searchQuery;
  TeacherModel? get selectedTeacher => _selectedTeacher;
  StudentModel? get selectedStudent => _selectedStudent;

  List<StudentModel> get students => _students.isNotEmpty ? _students : MockData.students;
  List<TeacherModel> get teachers => _teachers.isNotEmpty ? _teachers : MockData.teachers;
  List<PrincipalModel> get principals => _principals.isNotEmpty ? _principals : MockData.principals;
  List<ParentModel> get parents => _parents.isNotEmpty ? _parents : MockData.parents;
  List<LeaveApplication> get leaves => _leaves.isNotEmpty ? _leaves : MockData.leaves;
  List<FeeTransaction> get fees => _fees.isNotEmpty ? _fees : MockData.feeTransactions;
  Map<String, dynamic> get dashboardStats => _dashboardStats;
  bool get isLoading => _isLoading;

  int get unreadNotificationCount =>
      MockData.notifications.where((n) => !n.isRead).length;

  NavigationProvider() {
    loadAllData();
  }

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        ApiService.instance.fetchStudents(),
        ApiService.instance.fetchTeachers(),
        ApiService.instance.fetchPrincipals(),
        ApiService.instance.fetchParents(),
        ApiService.instance.fetchLeaves(),
        ApiService.instance.fetchFeeTransactions(),
        ApiService.instance.fetchAdminDashboardKpis(),
      ]);

      _students = results[0] as List<StudentModel>;
      _teachers = results[1] as List<TeacherModel>;
      _principals = results[2] as List<PrincipalModel>;
      _parents = results[3] as List<ParentModel>;
      _leaves = results[4] as List<LeaveApplication>;
      _fees = results[5] as List<FeeTransaction>;
      _dashboardStats = results[6] as Map<String, dynamic>;

      // Keep MockData lists synchronized as well
      if (_students.isNotEmpty) {
        MockData.students = List.from(_students);
      }
      if (_teachers.isNotEmpty) {
        MockData.teachers = List.from(_teachers);
      }
      if (_principals.isNotEmpty) {
        MockData.principals = List.from(_principals);
      }
      if (_parents.isNotEmpty) {
        MockData.parents = List.from(_parents);
      }
      if (_leaves.isNotEmpty) {
        MockData.leaves = List.from(_leaves);
      }
      if (_fees.isNotEmpty) {
        MockData.feeTransactions = List.from(_fees);
      }
    } catch (e) {
      debugPrint('NavigationProvider.loadAllData error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  Future<void> approveLeave(String leaveId, String? remarks) async {
    try {
      final leave = leaves.firstWhere((l) => l.id == leaveId, orElse: () => MockData.leaves.first);
      leave.status = 'Approved';
      leave.adminRemarks = remarks ?? 'Approved by Super Admin.';
      notifyListeners();
      await ApiService.instance.updateLeaveStatus(leaveId: leaveId, status: 'APPROVED', remarks: remarks);
    } catch (e) {
      debugPrint('approveLeave error: $e');
    }
  }

  Future<void> rejectLeave(String leaveId, String? remarks) async {
    try {
      final leave = leaves.firstWhere((l) => l.id == leaveId, orElse: () => MockData.leaves.first);
      leave.status = 'Rejected';
      leave.adminRemarks = remarks ?? 'Rejected by Super Admin.';
      notifyListeners();
      await ApiService.instance.updateLeaveStatus(leaveId: leaveId, status: 'REJECTED', remarks: remarks);
    } catch (e) {
      debugPrint('rejectLeave error: $e');
    }
  }

  Future<void> addStudent(StudentModel student) async {
    _students.insert(0, student);
    MockData.students.insert(0, student);
    notifyListeners();
    try {
      final created = await ApiService.instance.addStudent(student);
      if (created != null) {
        final idx = _students.indexWhere((s) => s.id == student.id || s.name == student.name);
        if (idx != -1) {
          _students[idx] = created;
          MockData.students[idx] = created;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('addStudent error: $e');
    }
  }

  Future<void> addTeacher(TeacherModel teacher) async {
    _teachers.insert(0, teacher);
    MockData.teachers.insert(0, teacher);
    notifyListeners();
    try {
      final created = await ApiService.instance.addTeacher(teacher);
      if (created != null) {
        final idx = _teachers.indexWhere((t) => t.id == teacher.id || t.name == teacher.name);
        if (idx != -1) {
          _teachers[idx] = created;
          MockData.teachers[idx] = created;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('addTeacher error: $e');
    }
  }

  Future<void> addPrincipal(PrincipalModel principal) async {
    _principals.insert(0, principal);
    MockData.principals.insert(0, principal);
    notifyListeners();
    try {
      final created = await ApiService.instance.addPrincipal(principal);
      if (created != null) {
        final idx = _principals.indexWhere((p) => p.id == principal.id || p.name == principal.name);
        if (idx != -1) {
          _principals[idx] = created;
          MockData.principals[idx] = created;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('addPrincipal error: $e');
    }
  }
}

