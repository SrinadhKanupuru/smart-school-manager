import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../app/auth_role_provider.dart';

class FacultyProfileScreen extends StatelessWidget {
  final bool isSettingsTab;

  const FacultyProfileScreen({super.key, this.isSettingsTab = false});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthRoleProvider>(context);
    final user = auth.currentFacultyUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSettingsTab ? 'Faculty Preferences & Account Settings' : 'Faculty Profile & Academic Bio',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'View official employment credentials, department details, and account configuration.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // Profile Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppDecorations.cardDecoration(),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      'KS',
                      style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user?.name ?? 'Ms. Kavya Sharma',
                              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryTint,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFBFDBFE)),
                              ),
                              child: Text(
                                user?.employeeId ?? 'FAC001',
                                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${user?.designation ?? "Senior Physics Faculty"} • ${user?.department ?? "Department of Science"}',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Official Email: ${user?.email ?? "faculty@smartschool.com"} • Phone: ${user?.phone ?? "+91 98765 43210"}',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      auth.logout();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logged out of Faculty account.')),
                      );
                    },
                    icon: const Icon(Icons.logout_rounded, size: 16, color: AppColors.danger),
                    label: const Text('Sign Out', style: TextStyle(color: AppColors.danger)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bio & Details Cards
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Academic Credentials
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppDecorations.cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Academic Credentials', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 14),
                        _buildInfoRow('Qualification', user?.qualification ?? 'M.Sc. Applied Physics, B.Ed'),
                        _buildInfoRow('Total Experience', user?.experience ?? '7 Years in Secondary Education'),
                        _buildInfoRow('Joining Date', user?.joiningDate ?? '10 Jun 2019'),
                        _buildInfoRow('Campus Location', 'Main Central Campus • Block B'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Assigned Teaching Classes & Labs
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppDecorations.cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Assigned Classes & Labs', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 14),
                        _buildTagRow('Classes', user?.assignedClasses ?? ['Grade 9-A (Class Teacher)', 'Grade 10-B', 'Grade 8-C']),
                        const SizedBox(height: 12),
                        _buildTagRow('Subjects', user?.subjectsTaught ?? ['Physics (Theory & Practical)', 'General Science']),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildTagRow(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textMuted)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                item,
                style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
