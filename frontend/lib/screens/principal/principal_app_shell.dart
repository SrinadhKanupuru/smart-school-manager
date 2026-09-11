import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import 'principal_navigation_provider.dart';
import 'principal_dashboard.dart';
import 'principal_notices_screen.dart';
import '../../widgets/principal/principal_sidebar.dart';
import '../../widgets/principal/principal_header.dart';
import '../../widgets/common/search_dialog.dart';
import '../teachers/teachers_screen.dart';
import '../students/students_screen.dart';
import '../attendance/attendance_screen.dart';
import '../leave_management/leave_management_screen.dart';
import '../academics/academics_screen.dart';
import '../account/account_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';

class PrincipalAppShell extends StatefulWidget {
  final VoidCallback? onSwitchToSuperAdmin;

  const PrincipalAppShell({super.key, this.onSwitchToSuperAdmin});

  @override
  State<PrincipalAppShell> createState() => _PrincipalAppShellState();
}

class _PrincipalAppShellState extends State<PrincipalAppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<PrincipalNavigationProvider>(context);

    // Global Ctrl+K / Cmd+K listener
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
              drawer: isDesktop ? null : const Drawer(child: PrincipalSidebar(isDrawer: true)),
              body: Row(
                children: [
                  // Permanent left sidebar on desktop
                  if (isDesktop) const PrincipalSidebar(),

                  // Main content column
                  Expanded(
                    child: Column(
                      children: [
                        // Top Header
                        PrincipalHeader(
                          showMenuButton: !isDesktop,
                          onMenuPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                          onSwitchToSuperAdmin: widget.onSwitchToSuperAdmin,
                        ),

                        // Active Principal Module Screen
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

  Widget _buildCurrentScreen(PrincipalModule module) {
    switch (module) {
      case PrincipalModule.dashboard:
        return const PrincipalDashboardScreen();
      case PrincipalModule.teachers:
        return const TeachersScreen();
      case PrincipalModule.students:
        return const StudentsScreen();
      case PrincipalModule.attendance:
        return const AttendanceScreen();
      case PrincipalModule.leaveManagement:
        return const LeaveManagementScreen();
      case PrincipalModule.academics:
        return const AcademicsScreen();
      case PrincipalModule.account:
        return const AccountScreen();
      case PrincipalModule.reports:
        return const ReportsScreen();
      case PrincipalModule.notices:
        return const PrincipalNoticesScreen();
      case PrincipalModule.settings:
        return const SettingsScreen();
    }
  }
}
