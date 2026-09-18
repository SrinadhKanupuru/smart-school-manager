import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../data/mock_data.dart';
import '../../models/teacher_model.dart';
import '../../app/navigation_provider.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/custom_modal.dart';
import '../../widgets/drawers/teacher_detail_drawer.dart';

class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});

  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  String _searchQuery = '';
  String _statusFilter = 'All Status';
  String _subjectFilter = 'All Subjects';

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationProvider>(context);

    // Filter teachers list
    final teachers = nav.teachers.where((t) {
      final matchesSearch = t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.employeeId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.subject.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.handledClass.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == 'All Status' || t.status == _statusFilter;
      final matchesSubject = _subjectFilter == 'All Subjects' || t.subject.contains(_subjectFilter);
      return matchesSearch && matchesStatus && matchesSubject;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          PageHeader(
            title: 'Faculty & Teacher Management',
            subtitle: 'Manage faculty profiles, subject allocation, performance, and daily staff attendance',
            trailing: ElevatedButton.icon(
              onPressed: () => CustomModals.showAddTeacherDialog(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Faculty'),
            ),
          ),

          // 5 Top KPI Cards
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return Row(
                  children: [
                    Expanded(child: _buildTeacherKpi('Total Teachers', '86', Icons.groups_rounded, AppColors.primary, AppColors.primaryTint)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTeacherKpi('Present Today', '78', Icons.check_circle_rounded, AppColors.success, AppColors.successLight)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTeacherKpi('Absent Today', '4', Icons.cancel_rounded, AppColors.danger, AppColors.dangerLight)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTeacherKpi('On Leave', '4', Icons.event_busy_rounded, AppColors.warning, AppColors.warningLight)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTeacherKpi('Attendance %', '95.2%', Icons.trending_up_rounded, const Color(0xFF0EA5E9), const Color(0xFFF0F9FF))),
                  ],
                );
              } else {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(width: (constraints.maxWidth - 12) / 2, child: _buildTeacherKpi('Total Teachers', '86', Icons.groups_rounded, AppColors.primary, AppColors.primaryTint)),
                    SizedBox(width: (constraints.maxWidth - 12) / 2, child: _buildTeacherKpi('Present Today', '78', Icons.check_circle_rounded, AppColors.success, AppColors.successLight)),
                    SizedBox(width: (constraints.maxWidth - 12) / 2, child: _buildTeacherKpi('Absent Today', '4', Icons.cancel_rounded, AppColors.danger, AppColors.dangerLight)),
                    SizedBox(width: (constraints.maxWidth - 12) / 2, child: _buildTeacherKpi('On Leave', '4', Icons.event_busy_rounded, AppColors.warning, AppColors.warningLight)),
                    SizedBox(width: constraints.maxWidth, child: _buildTeacherKpi('Attendance %', '95.2%', Icons.trending_up_rounded, const Color(0xFF0EA5E9), const Color(0xFFF0F9FF))),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24),

          // Search, Filters & Faculty Table Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppDecorations.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: TextField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search_rounded),
                            hintText: 'Search by name, ID, or subject...',
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Status Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _statusFilter,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                          items: const [
                            DropdownMenuItem(value: 'All Status', child: Text('All Status')),
                            DropdownMenuItem(value: 'Present', child: Text('Present')),
                            DropdownMenuItem(value: 'On Leave', child: Text('On Leave')),
                            DropdownMenuItem(value: 'Absent', child: Text('Absent')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _statusFilter = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Subject Filter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _subjectFilter,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                          items: const [
                            DropdownMenuItem(value: 'All Subjects', child: Text('All Subjects')),
                            DropdownMenuItem(value: 'Science', child: Text('Science & Physics')),
                            DropdownMenuItem(value: 'Mathematics', child: Text('Mathematics')),
                            DropdownMenuItem(value: 'English', child: Text('English Literature')),
                            DropdownMenuItem(value: 'Chemistry', child: Text('Chemistry')),
                            DropdownMenuItem(value: 'Computer', child: Text('Computer Science')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _subjectFilter = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Faculty Table
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppColors.surfaceMuted),
                    dataRowMaxHeight: 64,
                    columnSpacing: 22,
                    columns: [
                      DataColumn(label: Text('Teacher Name', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Emp ID', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Subject', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Handled Classes', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Attendance %', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Present', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Absent', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Leave', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Status', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Profile', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                    ],
                    rows: teachers.map((t) {
                      Color statusBg = AppColors.successLight;
                      Color statusColor = AppColors.success;
                      if (t.status == 'On Leave') {
                        statusBg = AppColors.warningLight;
                        statusColor = AppColors.warning;
                      } else if (t.status == 'Absent') {
                        statusBg = AppColors.dangerLight;
                        statusColor = AppColors.danger;
                      }

                      return DataRow(
                        cells: [
                          DataCell(
                            InkWell(
                              onTap: () => TeacherDetailDialog.show(context, t),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: const Color(0xFFF5F3FF),
                                    child: Text(
                                      t.name.split(' ').map((e) => e[0]).take(2).join(),
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8B5CF6)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.name,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Text(t.email, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataCell(Text(t.employeeId, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600))),
                          DataCell(Text(t.subject, style: GoogleFonts.inter(fontSize: 12.5))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryTint,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                t.handledClass,
                                style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                SizedBox(
                                  width: 44,
                                  child: Text('${t.attendancePercentage}%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 36,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: AppColors.border,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: (t.attendancePercentage / 100).clamp(0.0, 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: t.attendancePercentage >= 95 ? AppColors.success : AppColors.warning,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text('${t.presentDays}d', style: GoogleFonts.inter(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600))),
                          DataCell(Text('${t.absentDays}d', style: GoogleFonts.inter(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w600))),
                          DataCell(Text('${t.leaveDays}d', style: GoogleFonts.inter(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                t.status,
                                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                              ),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
                              tooltip: 'Open Full Profile',
                              onPressed: () => TeacherDetailDialog.show(context, t),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherKpi(String title, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(title, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
