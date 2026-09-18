import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../app/auth_role_provider.dart';
import '../../screens/faculty/faculty_navigation_provider.dart';

class FacultySidebar extends StatelessWidget {
  final bool isDrawer;

  const FacultySidebar({super.key, this.isDrawer = false});

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<FacultyNavigationProvider>(context);
    final auth = Provider.of<AuthRoleProvider>(context);
    final facultyUser = auth.currentFacultyUser;

    const navItems = [
      _FacultyNavItemData(FacultyModule.dashboard, 'Dashboard', Icons.grid_view_rounded),
      _FacultyNavItemData(FacultyModule.classes, 'My Classes', Icons.class_outlined),
      _FacultyNavItemData(FacultyModule.students, 'Students', Icons.people_outline_rounded),
      _FacultyNavItemData(FacultyModule.attendance, 'Attendance', Icons.fact_check_outlined),
      _FacultyNavItemData(FacultyModule.homework, 'Homework', Icons.assignment_outlined),
      _FacultyNavItemData(FacultyModule.assignments, 'Assignments', Icons.task_outlined),
      _FacultyNavItemData(FacultyModule.exams, 'Exams & Results', Icons.quiz_outlined),
      _FacultyNavItemData(FacultyModule.timetable, 'Timetable', Icons.calendar_today_outlined),
      _FacultyNavItemData(FacultyModule.leave, 'Leave', Icons.event_busy_outlined),
      _FacultyNavItemData(FacultyModule.messages, 'Messages', Icons.mail_outline_rounded),
      _FacultyNavItemData(FacultyModule.profile, 'Profile', Icons.person_outline_rounded),
      _FacultyNavItemData(FacultyModule.settings, 'Settings', Icons.settings_outlined),
    ];

    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Top Logo & Faculty Desk Branding
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.school_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Smart School',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'Faculty Desk',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Academic Portal • 2026–27',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),

          // Scrollable Nav Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = nav.currentModule == item.module;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        nav.setModule(item.module);
                        if (isDrawer) {
                          Navigator.of(context).pop();
                        }
                      },
                      hoverColor: AppColors.sidebarHoverBg,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.sidebarActiveBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 18,
                              color: isSelected
                                  ? AppColors.sidebarActiveText
                                  : AppColors.sidebarInactiveText,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.label,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.sidebarActiveText
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Container(
                                width: 4,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Bottom Teacher Profile Footer & Logout
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFFDBEAFE),
                    child: Text(
                      'KS',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          facultyUser?.name ?? 'Ms. Kavya Sharma',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          facultyUser?.employeeId ?? 'FAC001 • Faculty',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.danger),
                    tooltip: 'Sign Out',
                    onPressed: () {
                      auth.logout();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Logged out from Faculty Portal.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FacultyNavItemData {
  final FacultyModule module;
  final String label;
  final IconData icon;

  const _FacultyNavItemData(this.module, this.label, this.icon);
}
