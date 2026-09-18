import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'app/navigation_provider.dart';
import 'app/app_shell.dart';
import 'app/auth_role_provider.dart';
import 'auth/providers/auth_provider.dart';
import 'auth/screens/faculty_login_screen.dart';
import 'providers/school_provider.dart';
import 'providers/academic_provider.dart';
import 'providers/admin_provider.dart';
import 'screens/auth/saas_login_screen.dart';
import 'screens/principal/principal_navigation_provider.dart';
import 'screens/principal/principal_app_shell.dart';
import 'screens/faculty/faculty_navigation_provider.dart';
import 'screens/faculty/faculty_app_shell.dart';
import 'screens/parent/parent_navigation_provider.dart';
import 'screens/parent/parent_data_provider.dart';
import 'screens/parent/parent_app_shell.dart';
import 'screens/parent/parent_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthRoleProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => PrincipalNavigationProvider()),
        ChangeNotifierProvider(create: (_) => FacultyNavigationProvider()),
        ChangeNotifierProvider(create: (_) => ParentNavigationProvider()),
        ChangeNotifierProvider(create: (_) => ParentDataProvider()),
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
    return Consumer<AuthRoleProvider>(
      builder: (context, auth, _) {
        Widget homeWidget;
        switch (auth.activeRole) {
          case AppActiveRole.unauthenticated:
            homeWidget = const SaasLoginScreen();
            break;
          case AppActiveRole.parent:
            homeWidget = const ParentAppShell();
            break;
          case AppActiveRole.faculty:
            homeWidget = const FacultyAppShell();
            break;
          case AppActiveRole.principal:
            homeWidget = const PrincipalAppShell();
            break;
          case AppActiveRole.superAdmin:
            homeWidget = const AppShell();
            break;
        }

        return MaterialApp(
          title: 'Smart School Manager',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          home: homeWidget,
          routes: {
            '/login': (context) => const SaasLoginScreen(),
            '/login/faculty': (context) => const FacultyLoginScreen(),
            '/login/admin': (context) => const SaasLoginScreen(),
            '/parent/login': (context) => const ParentLoginScreen(),
            '/parent/dashboard': (context) => _roleGuard(context, auth, AppActiveRole.parent, const ParentAppShell()),
            '/parent/children': (context) => _roleGuard(context, auth, AppActiveRole.parent, const ParentAppShell()),
            '/parent/attendance': (context) => _roleGuard(context, auth, AppActiveRole.parent, const ParentAppShell()),
            '/parent/homework': (context) => _roleGuard(context, auth, AppActiveRole.parent, const ParentAppShell()),
            '/parent/assignments': (context) => _roleGuard(context, auth, AppActiveRole.parent, const ParentAppShell()),
            '/parent/exams': (context) => _roleGuard(context, auth, AppActiveRole.parent, const ParentAppShell()),
            '/parent/fees': (context) => _roleGuard(context, auth, AppActiveRole.parent, const ParentAppShell()),
            '/parent/timetable': (context) => _roleGuard(context, auth, AppActiveRole.parent, const ParentAppShell()),
            '/parent/notices': (context) => _roleGuard(context, auth, AppActiveRole.parent, const ParentAppShell()),
            '/parent/messages': (context) => _roleGuard(context, auth, AppActiveRole.parent, const ParentAppShell()),
            '/parent/leave': (context) => _roleGuard(context, auth, AppActiveRole.parent, const ParentAppShell()),
            '/parent/profile': (context) => _roleGuard(context, auth, AppActiveRole.parent, const ParentAppShell()),
            '/parent/settings': (context) => _roleGuard(context, auth, AppActiveRole.parent, const ParentAppShell()),
            '/faculty': (context) => _roleGuard(context, auth, AppActiveRole.faculty, const FacultyAppShell()),
            '/principal': (context) => _roleGuard(context, auth, AppActiveRole.principal, const PrincipalAppShell()),
            '/admin': (context) => _roleGuard(context, auth, AppActiveRole.superAdmin, const AppShell()),
          },
        );
      },
    );
  }

  /// Protects routes and redirects unauthorized roles to their respective dashboards
  Widget _roleGuard(BuildContext context, AuthRoleProvider auth, AppActiveRole requiredRole, Widget targetWidget) {
    if (auth.activeRole == AppActiveRole.unauthenticated) {
      return const SaasLoginScreen();
    }
    if (auth.activeRole != requiredRole) {
      switch (auth.activeRole) {
        case AppActiveRole.parent:
          return const ParentAppShell();
        case AppActiveRole.faculty:
          return const FacultyAppShell();
        case AppActiveRole.principal:
          return const PrincipalAppShell();
        case AppActiveRole.superAdmin:
          return const AppShell();
        default:
          return const SaasLoginScreen();
      }
    }
    return targetWidget;
  }
}
