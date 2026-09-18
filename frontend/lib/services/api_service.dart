import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/student_model.dart';
import '../models/teacher_model.dart';
import '../models/principal_model.dart';
import '../models/parent_model.dart';
import '../models/leave_model.dart';
import '../models/fee_data.dart';
import '../models/kpi_card_data.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // -------------------------------------------------------------
  // STUDENTS CRUD
  // -------------------------------------------------------------
  Future<List<StudentModel>> fetchStudents({String? classSectionId}) async {
    try {
      String endpoint = ApiConstants.students;
      if (classSectionId != null && classSectionId.isNotEmpty) {
        endpoint += '?classSectionId=$classSectionId';
      }
      final res = await ApiClient.instance.get(endpoint);
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => StudentModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('ApiService.fetchStudents error: $e');
    }
    return [];
  }

  Future<StudentModel?> addStudent(StudentModel student, {String? classSectionId}) async {
    try {
      final res = await ApiClient.instance.post('/academic/direct-add-student', {
        'fullName': student.name,
        'rollNo': student.rollNo,
        'className': student.className,
        'section': student.section,
        'gender': student.gender,
        'dob': student.dob,
        'bloodGroup': student.bloodGroup,
        'address': student.address,
        'parentName': student.parentName,
        'parentPhone': student.parentPhone,
        'classSectionId': classSectionId,
      });
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final stuData = data['student'] ?? data;
        return StudentModel.fromJson(stuData);
      }
    } catch (e) {
      debugPrint('ApiService.addStudent error: $e');
    }
    return null;
  }

  Future<bool> deleteStudent(String studentId) async {
    try {
      final res = await ApiClient.instance.delete('/academic/students/$studentId');
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.deleteStudent error: $e');
      return false;
    }
  }

  // -------------------------------------------------------------
  // TEACHERS CRUD
  // -------------------------------------------------------------
  Future<List<TeacherModel>> fetchTeachers() async {
    try {
      final res = await ApiClient.instance.get('/school/teachers');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List list = data['teachers'] ?? data;
        return list.map((e) => TeacherModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('ApiService.fetchTeachers error: $e');
    }
    return [];
  }

  Future<TeacherModel?> addTeacher(TeacherModel teacher) async {
    try {
      final res = await ApiClient.instance.post('/school/quick-teacher', {
        'fullName': teacher.name,
        'email': teacher.email,
        'phoneNumber': teacher.phone,
        'subject': teacher.subject,
        'handledClass': teacher.handledClass,
        'qualification': teacher.qualification,
        'experienceYears': 5,
        'salaryAmount': 45000,
      });
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final tData = data['teacher'] ?? data;
        return TeacherModel.fromJson(tData);
      }
    } catch (e) {
      debugPrint('ApiService.addTeacher error: $e');
    }
    return null;
  }

  // -------------------------------------------------------------
  // PRINCIPALS CRUD
  // -------------------------------------------------------------
  Future<List<PrincipalModel>> fetchPrincipals() async {
    try {
      final res = await ApiClient.instance.get('/school/principals');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List list = data['principals'] ?? data;
        return list.map((e) => PrincipalModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('ApiService.fetchPrincipals error: $e');
    }
    return [];
  }

  Future<PrincipalModel?> addPrincipal(PrincipalModel principal) async {
    try {
      final res = await ApiClient.instance.post('/school/quick-principal', {
        'fullName': principal.name,
        'email': principal.email,
        'phoneNumber': principal.phone,
        'qualification': principal.qualification,
        'branch': principal.branch,
      });
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return PrincipalModel.fromJson(data['principal'] ?? data);
      }
    } catch (e) {
      debugPrint('ApiService.addPrincipal error: $e');
    }
    return null;
  }

  // -------------------------------------------------------------
  // PARENTS CRUD
  // -------------------------------------------------------------
  Future<List<ParentModel>> fetchParents() async {
    try {
      final res = await ApiClient.instance.get('/school/parents-list');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List list = data['parents'] ?? data;
        return list.map((e) => ParentModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('ApiService.fetchParents error: $e');
    }
    return [];
  }

  // -------------------------------------------------------------
  // ATTENDANCE (STUDENTS & STAFF)
  // -------------------------------------------------------------
  Future<bool> markStudentAttendance({
    required DateTime date,
    required List<Map<String, dynamic>> attendanceData,
  }) async {
    try {
      final res = await ApiClient.instance.post(ApiConstants.attendance, {
        'date': date.toIso8601String(),
        'attendanceData': attendanceData,
      });
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.markStudentAttendance error: $e');
      return false;
    }
  }

  // -------------------------------------------------------------
  // LEAVE MANAGEMENT
  // -------------------------------------------------------------
  Future<List<LeaveApplication>> fetchLeaves() async {
    try {
      final res = await ApiClient.instance.get(ApiConstants.leaves);
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => LeaveApplication.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('ApiService.fetchLeaves error: $e');
    }
    return [];
  }

  Future<bool> updateLeaveStatus({
    required String leaveId,
    required String status,
    String? remarks,
  }) async {
    try {
      final res = await ApiClient.instance.put('${ApiConstants.leaves}/$leaveId', {
        'status': status.toUpperCase(),
        'rejectionReason': remarks,
      });
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.updateLeaveStatus error: $e');
      return false;
    }
  }

  // -------------------------------------------------------------
  // FEES & PAYMENTS
  // -------------------------------------------------------------
  Future<List<FeeTransaction>> fetchFeeTransactions() async {
    try {
      final res = await ApiClient.instance.get('/account/fees');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List list = data['fees'] ?? data;
        return list.map((e) => FeeTransaction.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('ApiService.fetchFeeTransactions error: $e');
    }
    return [];
  }

  Future<bool> payFee({
    required String feeId,
    required double amount,
    required String paymentMode,
  }) async {
    try {
      final res = await ApiClient.instance.post('/account/pay-fee', {
        'feeId': feeId,
        'amount': amount,
        'paymentMode': paymentMode,
      });
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.payFee error: $e');
      return false;
    }
  }

  // -------------------------------------------------------------
  // DASHBOARD KPIS & STATS
  // -------------------------------------------------------------
  Future<Map<String, dynamic>> fetchAdminDashboardKpis() async {
    try {
      final res = await ApiClient.instance.get('/dashboard/admin');
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint('ApiService.fetchAdminDashboardKpis error: $e');
    }
    return {};
  }
}
