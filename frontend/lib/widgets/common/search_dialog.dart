import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../app/navigation_provider.dart';
import '../../data/mock_data.dart';

class GlobalSearchDialog extends StatefulWidget {
  const GlobalSearchDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => const GlobalSearchDialog(),
    );
  }

  @override
  State<GlobalSearchDialog> createState() => _GlobalSearchDialogState();
}

class _GlobalSearchDialogState extends State<GlobalSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationProvider>(context, listen: false);

    // Search across modules, students, teachers
    final matchedStudents = MockData.students.where((s) =>
        s.name.toLowerCase().contains(_query.toLowerCase()) ||
        s.className.toLowerCase().contains(_query.toLowerCase()) ||
        s.studentId.toLowerCase().contains(_query.toLowerCase())).toList();

    final matchedTeachers = MockData.teachers.where((t) =>
        t.name.toLowerCase().contains(_query.toLowerCase()) ||
        t.subject.toLowerCase().contains(_query.toLowerCase()) ||
        t.employeeId.toLowerCase().contains(_query.toLowerCase())).toList();

    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.only(top: 80, left: 16, right: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 12,
      child: Container(
        width: 620,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Input Row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search student, teacher, class, module...',
                        hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        fillColor: Colors.transparent,
                      ),
                      onChanged: (val) => setState(() => _query = val),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'ESC to close',
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Quick Results / Modules
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 380),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  if (_query.isEmpty) ...[
                    _buildSectionHeader('QUICK JUMP TO MODULES'),
                    _buildModuleTile('Dashboard', Icons.grid_view_rounded, () {
                      nav.setModule(AppModule.dashboard);
                      Navigator.pop(context);
                    }),
                    _buildModuleTile('Teachers Management', Icons.school_outlined, () {
                      nav.setModule(AppModule.teachers);
                      Navigator.pop(context);
                    }),
                    _buildModuleTile('Students Directory', Icons.groups_outlined, () {
                      nav.setModule(AppModule.students);
                      Navigator.pop(context);
                    }),
                    _buildModuleTile('Attendance Analytics', Icons.fact_check_outlined, () {
                      nav.setModule(AppModule.attendance);
                      Navigator.pop(context);
                    }),
                    _buildModuleTile('Accounts & Fee Management', Icons.account_balance_wallet_outlined, () {
                      nav.setModule(AppModule.account);
                      Navigator.pop(context);
                    }),
                  ] else ...[
                    if (matchedStudents.isNotEmpty) ...[
                      _buildSectionHeader('STUDENTS (${matchedStudents.length})'),
                      ...matchedStudents.map((s) => ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryTint,
                              child: Text(s.name[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                            ),
                            title: Text(s.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                            subtitle: Text('${s.className}-${s.section} • Roll: ${s.rollNo}', style: GoogleFonts.inter(fontSize: 11)),
                            trailing: Text(s.feeStatus, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: s.feeStatus == 'Paid' ? AppColors.success : AppColors.danger)),
                            onTap: () {
                              nav.setModule(AppModule.students);
                              nav.selectStudent(s);
                              Navigator.pop(context);
                            },
                          )),
                    ],
                    if (matchedTeachers.isNotEmpty) ...[
                      _buildSectionHeader('TEACHERS (${matchedTeachers.length})'),
                      ...matchedTeachers.map((t) => ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFF5F3FF),
                              child: Text(t.name[0], style: const TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.w700)),
                            ),
                            title: Text(t.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                            subtitle: Text('${t.subject} • ${t.handledClass}', style: GoogleFonts.inter(fontSize: 11)),
                            trailing: Text('${t.attendancePercentage}% Att.', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success)),
                            onTap: () {
                              nav.setModule(AppModule.teachers);
                              nav.selectTeacher(t);
                              Navigator.pop(context);
                            },
                          )),
                    ],
                    if (matchedStudents.isEmpty && matchedTeachers.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No matches found for "$_query"',
                            style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        title,
        style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildModuleTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 18, color: AppColors.primary),
      title: Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
