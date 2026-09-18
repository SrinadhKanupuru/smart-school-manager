import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../data/mock_data.dart';
import '../../models/student_model.dart';
import '../../app/navigation_provider.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/custom_modal.dart';
import '../../widgets/drawers/student_detail_drawer.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _searchQuery = '';
  String _classFilter = 'All Classes';
  String _feeFilter = 'All Fee Status';

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationProvider>(context);

    // If a student was selected externally via search, open their profile modal
    if (nav.selectedStudent != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final std = nav.selectedStudent!;
        nav.selectStudent(null);
        StudentDetailDialog.show(context, std);
      });
    }

    final students = nav.students.where((s) {
      final matchesSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.studentId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.parentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.rollNo.contains(_searchQuery);
      final matchesClass = _classFilter == 'All Classes' || s.className == _classFilter;
      final matchesFee = _feeFilter == 'All Fee Status' || s.feeStatus == _feeFilter;
      return matchesSearch && matchesClass && matchesFee;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          PageHeader(
            title: 'Student Directory & Admissions',
            subtitle: 'Access student academic records, class enrollments, fee dues, and parent contacts',
            trailing: ElevatedButton.icon(
              onPressed: () => CustomModals.showAddStudentDialog(context),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: const Text('Enroll Student'),
            ),
          ),

          // 5 Top KPI Cards
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return Row(
                  children: [
                    Expanded(child: _buildStudentKpi('Total Students', '1,248', Icons.school_rounded, AppColors.primary, AppColors.primaryTint)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStudentKpi('Present Today', '1,203', Icons.check_circle_rounded, AppColors.success, AppColors.successLight)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStudentKpi('Absent Today', '33', Icons.cancel_rounded, AppColors.danger, AppColors.dangerLight)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStudentKpi('Late Today', '12', Icons.access_time_filled_rounded, AppColors.warning, AppColors.warningLight)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStudentKpi('Attendance %', '96.4%', Icons.insights_rounded, const Color(0xFF0EA5E9), const Color(0xFFF0F9FF))),
                  ],
                );
              } else {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(width: (constraints.maxWidth - 12) / 2, child: _buildStudentKpi('Total Students', '1,248', Icons.school_rounded, AppColors.primary, AppColors.primaryTint)),
                    SizedBox(width: (constraints.maxWidth - 12) / 2, child: _buildStudentKpi('Present Today', '1,203', Icons.check_circle_rounded, AppColors.success, AppColors.successLight)),
                    SizedBox(width: (constraints.maxWidth - 12) / 2, child: _buildStudentKpi('Absent Today', '33', Icons.cancel_rounded, AppColors.danger, AppColors.dangerLight)),
                    SizedBox(width: (constraints.maxWidth - 12) / 2, child: _buildStudentKpi('Late Today', '12', Icons.access_time_filled_rounded, AppColors.warning, AppColors.warningLight)),
                    SizedBox(width: constraints.maxWidth, child: _buildStudentKpi('Attendance %', '96.4%', Icons.insights_rounded, const Color(0xFF0EA5E9), const Color(0xFFF0F9FF))),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24),

          // Filters & Table Card
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
                            hintText: 'Search by student name, roll no, parent...',
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Class Filter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _classFilter,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                          items: const [
                            DropdownMenuItem(value: 'All Classes', child: Text('All Classes')),
                            DropdownMenuItem(value: 'Grade 10', child: Text('Grade 10')),
                            DropdownMenuItem(value: 'Grade 9', child: Text('Grade 9')),
                            DropdownMenuItem(value: 'Grade 8', child: Text('Grade 8')),
                            DropdownMenuItem(value: 'Grade 7', child: Text('Grade 7')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _classFilter = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Fee Filter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _feeFilter,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                          items: const [
                            DropdownMenuItem(value: 'All Fee Status', child: Text('All Fee Status')),
                            DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                            DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                            DropdownMenuItem(value: 'Overdue', child: Text('Overdue')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _feeFilter = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Students Table
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppColors.surfaceMuted),
                    dataRowMaxHeight: 64,
                    columnSpacing: 24,
                    columns: [
                      DataColumn(label: Text('Student Name', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Student ID', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Class & Sec', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Roll No', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Parent / Contact', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Attendance %', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Fee Status', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Status', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Actions', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                    ],
                    rows: students.map((s) {
                      Color feeBg = AppColors.successLight;
                      Color feeColor = AppColors.success;
                      if (s.feeStatus == 'Pending') {
                        feeBg = AppColors.warningLight;
                        feeColor = AppColors.warning;
                      } else if (s.feeStatus == 'Overdue') {
                        feeBg = AppColors.dangerLight;
                        feeColor = AppColors.danger;
                      }

                      return DataRow(
                        cells: [
                          DataCell(
                            InkWell(
                              onTap: () => StudentDetailDialog.show(context, s),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColors.primaryTint,
                                    child: Text(
                                      s.name.split(' ').map((e) => e[0]).take(2).join(),
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.name,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Text('${s.gender} • DOB: ${s.dob}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataCell(Text(s.studentId, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryTint,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${s.className}-${s.section}',
                                style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                              ),
                            ),
                          ),
                          DataCell(Text(s.rollNo, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600))),
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.parentName, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500)),
                                Text(s.parentPhone, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                SizedBox(
                                  width: 44,
                                  child: Text('${s.attendancePercentage}%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
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
                                    widthFactor: (s.attendancePercentage / 100).clamp(0.0, 1.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: s.attendancePercentage >= 95 ? AppColors.success : AppColors.warning,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: feeBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                s.feeStatus,
                                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: feeColor),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                s.status,
                                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
                              ),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
                              tooltip: 'Open Student Profile',
                              onPressed: () => StudentDetailDialog.show(context, s),
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

  Widget _buildStudentKpi(String title, String value, IconData icon, Color color, Color bgColor) {
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
