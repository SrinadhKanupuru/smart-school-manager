import 'package:flutter/foundation.dart';

class ApiConstants {
  // Dynamic host determination: handles Web, Mobile LAN, and local desktop seamlessly
  static String get baseUrl {
    if (kIsWeb) {
      try {
        final host = Uri.base.host;
        if (host.isNotEmpty) {
          return 'http://$host:5000/api';
        }
      } catch (_) {}
    }
    return 'http://localhost:5000/api';
  }

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/me';

  // School onboarding
  static const String addUser = '/school/users';
  static const String addParent = '/school/parents';
  static const String schoolsList = '/school/schools';
  static const String usersByRole = '/school/users-by-role';
  static const String registerStaffWithFace = '/school/register-staff-with-face';
  static const String verifyStaffAttendance = '/school/verify-attendance';
  static const String holidays = '/school/holidays';

  // Academics
  static const String classes = '/academic/classes';
  static const String students = '/academic/students';
  static const String attendance = '/academic/attendance';
  static const String attendanceHistory = '/academic/attendance-history';
  static const String homework = '/academic/homework';
  static const String homeworkList = '/academic/homework-list';
  static const String diary = '/academic/diary';
  static const String diaryList = '/academic/diary-list';
  static const String marks = '/academic/marks';
  static const String marksList = '/academic/marks-list';
  static const String timetable = '/academic/timetable';
  static const String resources = '/academic/resources';

  // Admin
  static const String leave = '/admin/leave';
  static const String leaves = '/admin/leaves';
  static const String rectifications = '/admin/rectifications';
  static const String salaries = '/admin/salaries';
  static const String generateSalaries = '/admin/generate-salaries';
  static const String paySalary = '/admin/pay-salary';
  static const String expenses = '/admin/expenses';
  static const String events = '/admin/events';
  static const String notices = '/admin/notices';
  // Loans & Advances
  static const String loans = '/admin/loans';
  static const String leaveTypes = '/admin/leave-types';
  static const String loanSkips = '/admin/loan-skips';
  static const String loanForeclosures = '/admin/loan-foreclosures';

  // Transport & complaints
  static const String routes = '/transport/routes';
  static const String complaint = '/complaint';

  // Salary Component & Template Management
  static const String salaryComponents = '/school/salary-components';
  static const String salaryTemplates = '/school/salary-templates';
  static const String assignSalaryTemplate = '/school/teachers';

  // Parent Dashboard
  static const String children = '/parent/children';
  static const String childLeave = '/parent/child-leave';
  static const String payFee = '/parent/pay-fee';
}
