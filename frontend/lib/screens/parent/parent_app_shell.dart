import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import 'parent_navigation_provider.dart';
import 'parent_dashboard.dart';
import 'children_screen.dart';
import 'attendance_screen.dart';
import 'homework_screen.dart';
import 'assignments_screen.dart';
import 'exams_results_screen.dart';
import 'fees_screen.dart';
import 'timetable_screen.dart';
import 'notices_screen.dart';
import 'messages_screen.dart';
import 'leave_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../../widgets/parent/parent_sidebar.dart';
import '../../widgets/parent/parent_header.dart';
import '../../widgets/common/search_dialog.dart';

class ParentAppShell extends StatefulWidget {
  const ParentAppShell({super.key});

  @override
  State<ParentAppShell> createState() => _ParentAppShellState();
}

class _ParentAppShellState extends State<ParentAppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<ParentNavigationProvider>(context);

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
              drawer: isDesktop ? null : const Drawer(child: ParentSidebar(isDrawer: true)),
              body: Row(
                children: [
                  // Desktop Permanent Left Sidebar
                  if (isDesktop) const ParentSidebar(),

                  // Main Content Area
                  Expanded(
                    child: Column(
                      children: [
                        // Top Header
                        ParentHeader(
                          showMenuButton: !isDesktop,
                          onMenuPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),

                        // Active Screen View with animation
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
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

  Widget _buildCurrentScreen(ParentModule module) {
    switch (module) {
      case ParentModule.dashboard:
        return const ParentDashboardScreen();
      case ParentModule.children:
        return const ParentChildrenScreen();
      case ParentModule.attendance:
        return const ParentAttendanceScreen();
      case ParentModule.homework:
        return const ParentHomeworkScreen();
      case ParentModule.assignments:
        return const ParentAssignmentsScreen();
      case ParentModule.exams:
        return const ParentExamsResultsScreen();
      case ParentModule.fees:
        return const ParentFeesScreen();
      case ParentModule.timetable:
        return const ParentTimetableScreen();
      case ParentModule.notices:
        return const ParentNoticesScreen();
      case ParentModule.messages:
        return const ParentMessagesScreen();
      case ParentModule.leave:
        return const ParentLeaveScreen();
      case ParentModule.profile:
        return const ParentProfileScreen();
      case ParentModule.settings:
        return const ParentSettingsScreen();
    }
  }
}
