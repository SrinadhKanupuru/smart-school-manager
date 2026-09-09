import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api_client.dart';
import 'core/theme.dart';
import 'providers/school_provider.dart';
import 'providers/academic_provider.dart';
import 'providers/admin_provider.dart';
import 'views/auth/splash_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/role_selection_screen.dart';
import 'views/auth/register_school_screen.dart';
import 'views/auth/otp_verification_screen.dart';
import 'views/auth/school_added_success_screen.dart';
import 'views/dashboard/correspondent_dashboard.dart';
import 'views/dashboard/hm_dashboard.dart';
import 'views/dashboard/teacher_dashboard.dart';
import 'views/dashboard/parent_dashboard.dart';
import 'views/dashboard/pt_dashboard.dart';
import 'views/forms/add_principal_hm_form.dart';
import 'views/forms/add_teacher_form.dart';
import 'views/forms/add_student_form.dart';
import 'views/forms/add_parent_form.dart';
import 'views/forms/add_bus_route_form.dart';
import 'views/teacher/mark_attendance_screen.dart';
import 'views/teacher/homework_upload_screen.dart';
import 'views/teacher/learning_diary_screen.dart';
import 'views/teacher/enter_marks_screen.dart';
import 'views/teacher/my_timetable_screen.dart';
import 'views/teacher/leave_application_screen.dart';
import 'views/teacher/time_sheet_screen.dart';
import 'views/teacher/upload_resources_screen.dart';
import 'views/teacher/my_payslips_screen.dart';
import 'views/hm/leave_approval_screen.dart';
import 'views/hm/salary_management_screen.dart';
import 'views/hm/class_teacher_assignment_screen.dart';
import 'views/hm/bus_route_management_screen.dart';
import 'views/hm/expense_tracking_screen.dart';
import 'views/hm/complaints_list_screen.dart';
import 'views/hm/class_management_screen.dart';
import 'views/hm/timetable_management_screen.dart';
import 'views/hm/fee_management_screen.dart';
import 'views/parent/fees_details_screen.dart';
import 'views/parent/bus_route_view.dart';
import 'views/parent/ask_permission_screen.dart';
import 'views/parent/submit_complaint_screen.dart';
import 'views/parent/notice_view.dart';
import 'views/shared/profile_screen.dart';
import 'views/shared/school_insights_screen.dart';
import 'views/shared/school_settings_screen.dart';
import 'views/shared/staff_attendance_screen.dart';
import 'views/shared/staff_attendance_history_screen.dart';
import 'views/shared/attendance_rectification_screen.dart';
import 'views/shared/holiday_calendar_screen.dart';
import 'views/shared/loan_advances_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SchoolProvider()..loadProfile()),
        ChangeNotifierProvider(create: (_) => AcademicProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const SmartSchoolApp(),
    ),
  );
}

class SmartSchoolApp extends StatelessWidget {
  const SmartSchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart School',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),
        '/register-school': (context) => const RegisterSchoolScreen(),
        '/otp-verification': (context) => const OtpVerificationScreen(),
        '/school-success': (context) => const SchoolAddedSuccessScreen(),
        
        // Dashboards
        '/dashboard-correspondent': (context) => const CorrespondentDashboard(),
        '/dashboard-hm': (context) => const HmDashboard(),
        '/dashboard-teacher': (context) => const TeacherDashboard(),
        '/dashboard-parent': (context) => const ParentDashboard(),
        '/dashboard-pt': (context) => const PtDashboard(),

        // Forms
        '/add-principal-hm': (context) => const AddPrincipalHmForm(),
        '/add-teacher': (context) => const AddTeacherForm(),
        '/add-student': (context) => const AddStudentForm(),
        '/add-parent': (context) => const AddParentForm(),
        '/add-bus-route': (context) => const AddBusRouteForm(),

        // Teacher Actions
        '/mark-attendance': (context) => const MarkAttendanceScreen(),
        '/homework-upload': (context) => const HomeworkUploadScreen(),
        '/learning-diary': (context) => const LearningDiaryScreen(),
        '/enter-marks': (context) => const EnterMarksScreen(),
        '/my-timetable': (context) => const MyTimetableScreen(),
        '/leave-application': (context) => const LeaveApplicationScreen(),
        '/time-sheet': (context) => const TimeSheetScreen(),
        '/upload-resources': (context) => const UploadResourcesScreen(),
        '/my-payslips': (context) => const MyPayslipsScreen(),
        
        // HM Actions
        '/leave-approval': (context) => const LeaveApprovalScreen(),
        '/salary-management': (context) => const SalaryManagementScreen(),
        '/class-teacher-assignment': (context) => const ClassTeacherAssignmentScreen(),
        '/bus-route-management': (context) => const BusRouteManagementScreen(),
        '/expense-tracking': (context) => const ExpenseTrackingScreen(),
        '/complaints-list': (context) => const ComplaintsListScreen(),
        '/class-management': (context) => const ClassManagementScreen(),
        '/timetable-management': (context) => const TimetableManagementScreen(),
        '/fees-management': (context) => const FeeManagementScreen(),

        // Parent Actions
        '/fees-details': (context) => const FeesDetailsScreen(),
        '/bus-route-view': (context) => const BusRouteView(),
        '/ask-permission': (context) => const AskPermissionScreen(),
        '/submit-complaint': (context) => const SubmitComplaintScreen(),
        '/notice-view': (context) => const NoticeView(),

        // Shared
        '/profile': (context) => const ProfileScreen(),
        '/school-insights': (context) => const SchoolInsightsScreen(),
        '/staff-attendance': (context) => const StaffAttendanceScreen(),
        '/staff-attendance-history': (context) => const StaffAttendanceHistoryScreen(),
        '/attendance-rectification': (context) => const AttendanceRectificationScreen(),
        '/school-settings': (context) => const SchoolSettingsScreen(),
        '/holiday-calendar': (context) => const HolidayCalendarScreen(),
        '/loans': (context) => const LoanAdvancesScreen(),
      },
    );
  }
}
