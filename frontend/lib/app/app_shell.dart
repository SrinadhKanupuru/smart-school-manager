import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import 'navigation_provider.dart';
import '../widgets/common/sidebar.dart';
import '../widgets/common/app_header.dart';
import '../widgets/common/search_dialog.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/principal/principal_screen.dart';
import '../screens/teachers/teachers_screen.dart';
import '../screens/students/students_screen.dart';
import '../screens/parent_portal/parent_portal_screen.dart';
import '../screens/attendance/attendance_screen.dart';
import '../screens/leave_management/leave_management_screen.dart';
import '../screens/academics/academics_screen.dart';
import '../screens/account/account_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/settings/settings_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationProvider>(context);

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
            final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1024;
            final isMobile = constraints.maxWidth < 768;

            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: AppColors.background,
              drawer: isDesktop ? null : const Drawer(child: AppSidebar(isDrawer: true)),
              body: Row(
                children: [
                  // Permanent left sidebar on desktop
                  if (isDesktop) const AppSidebar(),

                  // Main content column
                  Expanded(
                    child: Column(
                      children: [
                        // Top Header
                        AppHeader(
                          showMenuButton: !isDesktop,
                          onMenuPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),

                        // Active Module Screen with subtle transition
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

  Widget _buildCurrentScreen(AppModule module) {
    switch (module) {
      case AppModule.dashboard:
        return const DashboardScreen();
      case AppModule.principal:
        return const PrincipalScreen();
      case AppModule.teachers:
        return const TeachersScreen();
      case AppModule.students:
        return const StudentsScreen();
      case AppModule.parentPortal:
        return const ParentPortalScreen();
      case AppModule.attendance:
        return const AttendanceScreen();
      case AppModule.leaveManagement:
        return const LeaveManagementScreen();
      case AppModule.academics:
        return const AcademicsScreen();
      case AppModule.account:
        return const AccountScreen();
      case AppModule.reports:
        return const ReportsScreen();
      case AppModule.settings:
        return const SettingsScreen();
    }
  }
}
