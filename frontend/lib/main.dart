import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'app/navigation_provider.dart';
import 'app/app_shell.dart';
import 'app/auth_role_provider.dart';
import 'providers/school_provider.dart';
import 'providers/academic_provider.dart';
import 'providers/admin_provider.dart';
import 'screens/auth/saas_login_screen.dart';
import 'screens/principal/principal_navigation_provider.dart';
import 'screens/principal/principal_app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthRoleProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => PrincipalNavigationProvider()),
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
            '/principal': (context) => const PrincipalAppShell(),
            '/admin': (context) => const AppShell(),
          },
        );
      },
    );
  }
}
