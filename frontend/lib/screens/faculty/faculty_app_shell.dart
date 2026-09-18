import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import 'faculty_navigation_provider.dart';
import 'faculty_dashboard_screen.dart';
import 'faculty_classes_screen.dart';
import 'faculty_attendance_screen.dart';
import 'faculty_homework_screen.dart';
import 'faculty_exams_screen.dart';
import 'faculty_timetable_screen.dart';
import 'faculty_leave_screen.dart';
import 'faculty_messages_screen.dart';
import 'faculty_profile_screen.dart';
import '../../widgets/faculty/faculty_sidebar.dart';
import '../../widgets/faculty/faculty_header.dart';
import '../../widgets/common/search_dialog.dart';

class FacultyAppShell extends StatefulWidget {
  const FacultyAppShell({super.key});

  @override
  State<FacultyAppShell> createState() => _FacultyAppShellState();
}

class _FacultyAppShellState extends State<FacultyAppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<FacultyNavigationProvider>(context);

    // Global Ctrl+K shortcut listener
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
          GlobalSearchDialog.show(context);
        },
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () {
          GlobalSearchDialog.show(context);
        },
      },
      child: Focus(
        autofocus: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1024;

            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: AppColors.background,
              drawer: isDesktop ? null : const Drawer(child: FacultySidebar(isDrawer: true)),
              body: Row(
                children: [
                  // Desktop Permanent Left Sidebar
                  if (isDesktop) const FacultySidebar(),

                  // Main Content Area
                  Expanded(
                    child: Column(
                      children: [
                        // Top Header
                        FacultyHeader(
                          showMenuButton: !isDesktop,
                          onMenuPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),

                        // Active Faculty Screen View
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            child: KeyedSubtree(
                              key: ValueKey(nav.currentModule),
                              child: _buildCurrentScreen(nav.currentModule),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentScreen(FacultyModule module) {
    switch (module) {
      case FacultyModule.dashboard:
        return const FacultyDashboardScreen();
      case FacultyModule.classes:
        return const FacultyClassesScreen();
      case FacultyModule.students:
        return const FacultyClassesScreen(showStudentsOnly: true);
      case FacultyModule.attendance:
        return const FacultyAttendanceScreen();
      case FacultyModule.homework:
        return const FacultyHomeworkScreen();
      case FacultyModule.assignments:
        return const FacultyHomeworkScreen(isAssignmentsTab: true);
      case FacultyModule.exams:
        return const FacultyExamsScreen();
      case FacultyModule.results:
        return const FacultyExamsScreen(isResultsTab: true);
      case FacultyModule.timetable:
        return const FacultyTimetableScreen();
      case FacultyModule.leave:
        return const FacultyLeaveScreen();
      case FacultyModule.messages:
        return const FacultyMessagesScreen();
      case FacultyModule.profile:
        return const FacultyProfileScreen();
      case FacultyModule.settings:
        return const FacultyProfileScreen(isSettingsTab: true);
    }
  }
}
