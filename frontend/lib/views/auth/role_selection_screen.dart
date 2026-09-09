import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  final List<Map<String, dynamic>> _roles = const [
    {
      'title': 'Correspondent',
      'icon': Icons.admin_panel_settings_outlined,
      'color': Color(0xFF673AB7),
      'description': 'School Owner/Registrar'
    },
    {
      'title': 'Principal',
      'icon': Icons.assignment_ind_outlined,
      'color': Color(0xFF3F51B5),
      'description': 'Academic Admin'
    },
    {
      'title': 'Head Master / HM',
      'icon': Icons.co_present_outlined,
      'color': Color(0xFF009688),
      'description': 'Class & Staff Admin'
    },
    {
      'title': 'Staff / Teacher',
      'icon': Icons.people_outline,
      'color': Color(0xFF4CAF50),
      'description': 'Mark Grades & Attendance'
    },
    {
      'title': 'PT Trainer',
      'icon': Icons.fitness_center_outlined,
      'color': Color(0xFFFF9800),
      'description': 'Sports Coordination'
    },
    {
      'title': 'Parent',
      'icon': Icons.family_restroom_outlined,
      'color': Color(0xFFE91E63),
      'description': 'Track Studies & Routes'
    },
  ];

  void _onRoleSelected(BuildContext context, String role) {
    if (role == 'Correspondent') {
      Navigator.pushNamed(context, '/register-school');
    } else {
      // Show info dialog, then redirect to login
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Account Onboarding', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: Text(
            'To access as a $role, your school must first register and set up your profile.\n\n'
            'For demo purposes, you can login directly using our seeded credentials:\n'
            '• correspondent@school.com / password123\n'
            '• hm@school.com / password123\n'
            '• sharma@school.com (Teacher) / password123\n'
            '• parent@school.com / password123',
            style: GoogleFonts.outfit(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('Go to Login'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Your Role',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select your role to continue registration or logging in',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                itemCount: _roles.length,
                itemBuilder: (context, index) {
                  final role = _roles[index];
                  return Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: role['title'] == 'Correspondent' 
                            ? AppTheme.primaryColor.withOpacity(0.3) 
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    elevation: 2,
                    child: InkWell(
                      onTap: () => _onRoleSelected(context, role['title']),
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: role['color'].withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                role['icon'],
                                size: 36,
                                color: role['color'],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              role['title'],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              role['description'],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text(
                      'Login',
                      style: GoogleFonts.outfit(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
