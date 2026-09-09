import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/constants.dart';

class AcademicProvider extends ChangeNotifier {
  List<dynamic> _classes = [];
  List<dynamic> _attendanceHistory = [];
  List<dynamic> _homeworkList = [];
  List<dynamic> _diaryList = [];
  List<dynamic> _examMarks = [];
  List<dynamic> _timetable = [];
  List<dynamic> _students = [];
  List<dynamic> _resourceList = [];
  bool _isLoading = false;

  List<dynamic> get classes => _classes;
  List<dynamic> get attendanceHistory => _attendanceHistory;
  List<dynamic> get homeworkList => _homeworkList;
  List<dynamic> get diaryList => _diaryList;
  List<dynamic> get examMarks => _examMarks;
  List<dynamic> get timetable => _timetable;
  List<dynamic> get students => _students;
  List<dynamic> get resourceList => _resourceList;
  bool get isLoading => _isLoading;

  Future<void> fetchClasses() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.get(ApiConstants.classes);
      if (response.statusCode == 200) {
        _classes = jsonDecode(response.body);
      }
    } catch (e) {
      print('Fetch classes error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAttendance(String date, List<Map<String, String>> attendanceData) async {
    try {
      final response = await ApiClient.instance.post(ApiConstants.attendance, {
        'date': date,
        'attendanceData': attendanceData,
      });
      return response.statusCode == 200;
    } catch (e) {
      print('Mark attendance error: $e');
      return false;
    }
  }

  Future<void> fetchAttendanceHistory(String classSectionId, {String? date}) async {
    String endpoint = '${ApiConstants.attendanceHistory}?classSectionId=$classSectionId';
    if (date != null) {
      endpoint += '&date=$date';
    }

    try {
      final response = await ApiClient.instance.get(endpoint);
      if (response.statusCode == 200) {
        _attendanceHistory = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print('Fetch attendance history error: $e');
    }
  }

  Future<bool> uploadHomework({
    required String classSectionId,
    required String subject,
    required String title,
    required String description,
    required String dueDate,
    String? fileUrl,
  }) async {
    try {
      final response = await ApiClient.instance.post(ApiConstants.homework, {
        'classSectionId': classSectionId,
        'subject': subject,
        'title': title,
        'description': description,
        'dueDate': dueDate,
        'fileUrl': fileUrl,
      });
      return response.statusCode == 201;
    } catch (e) {
      print('Upload homework error: $e');
      return false;
    }
  }

  Future<void> fetchHomework(String classSectionId) async {
    try {
      final response = await ApiClient.instance.get('${ApiConstants.homeworkList}?classSectionId=$classSectionId');
      if (response.statusCode == 200) {
        _homeworkList = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print('Fetch homework error: $e');
    }
  }

  Future<bool> addDiary({
    required String classSectionId,
    required String date,
    required String subject,
    required String details,
  }) async {
    try {
      final response = await ApiClient.instance.post(ApiConstants.diary, {
        'classSectionId': classSectionId,
        'date': date,
        'subject': subject,
        'details': details,
      });
      return response.statusCode == 201;
    } catch (e) {
      print('Add diary error: $e');
      return false;
    }
  }

  Future<void> fetchDiary(String classSectionId, {String? date}) async {
    String endpoint = '${ApiConstants.diaryList}?classSectionId=$classSectionId';
    if (date != null) {
      endpoint += '&date=$date';
    }

    try {
      final response = await ApiClient.instance.get(endpoint);
      if (response.statusCode == 200) {
        _diaryList = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print('Fetch diary error: $e');
    }
  }

  Future<bool> enterMarks({
    required String examName,
    required String classId,
    String? date,
    required List<Map<String, dynamic>> marksData,
  }) async {
    try {
      final response = await ApiClient.instance.post(ApiConstants.marks, {
        'examName': examName,
        'classId': classId,
        'date': date,
        'marksData': marksData,
      });
      return response.statusCode == 200;
    } catch (e) {
      print('Enter marks error: $e');
      return false;
    }
  }

  Future<void> fetchExamMarks(String classId) async {
    try {
      final response = await ApiClient.instance.get('${ApiConstants.marksList}?classId=$classId');
      if (response.statusCode == 200) {
        _examMarks = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print('Fetch marks error: $e');
    }
  }

  Future<void> fetchTimetable({String? classSectionId, String? teacherId}) async {
    String endpoint = ApiConstants.timetable;
    if (classSectionId != null) {
      endpoint += '?classSectionId=$classSectionId';
    } else if (teacherId != null) {
      endpoint += '?teacherId=$teacherId';
    } else {
      return;
    }

    try {
      final response = await ApiClient.instance.get(endpoint);
      if (response.statusCode == 200) {
        _timetable = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print('Fetch timetable error: $e');
    }
  }

  Future<bool> addTimetableSlot({
    required String classSectionId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required String subject,
    required String teacherId,
    required String roomNo,
  }) async {
    try {
      final response = await ApiClient.instance.post(ApiConstants.timetable, {
        'classSectionId': classSectionId,
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
        'subject': subject,
        'teacherId': teacherId,
        'roomNo': roomNo,
      });
      return response.statusCode == 201;
    } catch (e) {
      print('Add timetable slot error: $e');
      return false;
    }
  }

  Future<void> fetchStudents() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.get(ApiConstants.students);
      if (response.statusCode == 200) {
        _students = jsonDecode(response.body);
      }
    } catch (e) {
      print('Fetch students error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addStudent({
    required String fullName,
    required String rollNo,
    String? classSectionId,
    required String gender,
    required String dateOfBirth,
    List<Map<String, dynamic>>? initialFees,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.post(ApiConstants.students, {
        'fullName': fullName,
        'rollNo': rollNo,
        if (classSectionId != null) 'classSectionId': classSectionId,
        'gender': gender,
        'dateOfBirth': dateOfBirth,
        if (initialFees != null) 'initialFees': initialFees,
      });
      return response.statusCode == 201;
    } catch (e) {
      print('Add student error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createClass(String name) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.post('/academic/classes', {
        'name': name,
      });
      if (response.statusCode == 201) {
        await fetchClasses();
        return true;
      }
      return false;
    } catch (e) {
      print('Create class error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createClassSection({
    required String classId,
    required String name,
    String? classTeacherId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.post('/academic/classes/sections', {
        'classId': classId,
        'name': name,
        if (classTeacherId != null) 'classTeacherId': classTeacherId,
      });
      if (response.statusCode == 201) {
        await fetchClasses();
        return true;
      }
      return false;
    } catch (e) {
      print('Create class section error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> assignStudentsToClass({
    required String classSectionId,
    required List<String> studentIds,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.post('/academic/students/assign-class', {
        'classSectionId': classSectionId,
        'studentIds': studentIds,
      });
      if (response.statusCode == 200) {
        await fetchClasses();
        await fetchStudents();
        return null; // success
      }
      final data = jsonDecode(response.body);
      return data['error'] as String? ?? 'Failed to assign students';
    } catch (e) {
      print('Assign students error: $e');
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateTimetableSlot({
    required String id,
    required String classSectionId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required String subject,
    required String teacherId,
    required String roomNo,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.put('/academic/timetable/$id', {
        'classSectionId': classSectionId,
        'dayOfWeek': dayOfWeek,
        'startTime': startTime,
        'endTime': endTime,
        'subject': subject,
        'teacherId': teacherId,
        'roomNo': roomNo,
      });
      if (response.statusCode == 200) {
        return null; // success
      }
      final data = jsonDecode(response.body);
      return data['error'] as String? ?? 'Failed to update timetable slot';
    } catch (e) {
      print('Update timetable slot error: $e');
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTimetableSlot(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.delete('/academic/timetable/$id');
      return response.statusCode == 200;
    } catch (e) {
      print('Delete timetable slot error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadResource({
    required String classSectionId,
    required String subject,
    required String title,
    String? description,
    required String resourceType,
    required String fileUrl,
  }) async {
    try {
      final response = await ApiClient.instance.post(ApiConstants.resources, {
        'classSectionId': classSectionId,
        'subject': subject,
        'title': title,
        'description': description,
        'resourceType': resourceType,
        'fileUrl': fileUrl,
      });
      return response.statusCode == 201;
    } catch (e) {
      print('Upload resource error: $e');
      return false;
    }
  }

  Future<void> fetchResources(String classSectionId) async {
    try {
      final response = await ApiClient.instance.get('${ApiConstants.resources}?classSectionId=$classSectionId');
      if (response.statusCode == 200) {
        _resourceList = jsonDecode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print('Fetch resources error: $e');
    }
  }

  Future<String?> uploadFile(List<int> bytes, String filename) async {
    try {
      final response = await ApiClient.instance.uploadFile('/academic/upload-file', bytes, filename);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['fileUrl'] as String;
      }
      return null;
    } catch (e) {
      print('Upload file error: $e');
      return null;
    }
  }

  Future<bool> assignClassTeacher(String sectionId, String? classTeacherId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient.instance.put('/academic/classes/sections/$sectionId/class-teacher', {
        'classTeacherId': classTeacherId,
      });
      if (response.statusCode == 200) {
        await fetchClasses();
        return true;
      }
      return false;
    } catch (e) {
      print('Assign class teacher error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
