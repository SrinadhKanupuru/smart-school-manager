import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../data/mock_data.dart';
import '../../widgets/common/section_header.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  String _timeRange = 'Daily';
  String _classFilter = 'All Classes';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          PageHeader(
            title: 'Attendance Overview & Register',
            subtitle: 'Real-time institution-wide daily attendance, biometric logs, and classroom rosters',
            trailing: ElevatedButton.icon(
              onPressed: () => _showQuickMarkDialog(context),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: const Text('Mark Class Attendance'),
            ),
          ),

          // Filters Row: Tab Selector (Students / Teachers) + Date Picker + Range
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.cardDecoration(),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Dual Tabs Pill
                Container(
                  width: 280,
                  height: 40,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    onTap: (_) => setState(() {}),
                    indicator: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                    tabs: const [
                      Tab(text: 'Students (1,248)'),
                      Tab(text: 'Teachers (86)'),
                    ],
                  ),
                ),

                // Date Picker + Time Range Selector + Class Filter
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Date Button
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2025),
                          lastDate: DateTime(2027),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                      icon: const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primary),
                      label: Text(
                        DateFormat('dd MMM yyyy').format(_selectedDate),
                        style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Time Range Filter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _timeRange,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                          items: const [
                            DropdownMenuItem(value: 'Daily', child: Text('Daily View')),
                            DropdownMenuItem(value: 'Weekly', child: Text('Weekly View')),
                            DropdownMenuItem(value: 'Monthly', child: Text('Monthly View')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _timeRange = val);
                          },
                        ),
                      ),
                    ),

                    if (_tabController.index == 0) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(8),
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
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _classFilter = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tab Content Area
          _tabController.index == 0
              ? _buildStudentAttendanceTab()
              : _buildTeacherAttendanceTab(),
        ],
      ),
    );
  }

  Widget _buildStudentAttendanceTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 5 Summary Metric Cards
        Row(
          children: [
            Expanded(child: _buildAttendanceStat('Total Students', '1,248', AppColors.primary, AppColors.primaryTint)),
            const SizedBox(width: 12),
            Expanded(child: _buildAttendanceStat('Present', '1,203 (96.4%)', AppColors.success, AppColors.successLight)),
            const SizedBox(width: 12),
            Expanded(child: _buildAttendanceStat('Absent', '33 (2.6%)', AppColors.danger, AppColors.dangerLight)),
            const SizedBox(width: 12),
            Expanded(child: _buildAttendanceStat('Late Arrival', '12 (1.0%)', AppColors.warning, AppColors.warningLight)),
            const SizedBox(width: 12),
            Expanded(child: _buildAttendanceStat('Approved Leave', '18', const Color(0xFF8B5CF6), const Color(0xFFF5F3FF))),
          ],
        ),
        const SizedBox(height: 20),

        // Student Attendance Table
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Classroom Attendance Roster (${DateFormat('d MMMM yyyy').format(_selectedDate)})',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(AppColors.surfaceMuted),
                  columnSpacing: 28,
                  columns: [
                    DataColumn(label: Text('Student', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Class & Sec', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Roll No', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Check-in Time', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Monthly Rate', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Status Today', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                  ],
                  rows: MockData.students.map((s) {
                    return DataRow(
                      cells: [
                        DataCell(Text(s.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13))),
                        DataCell(Text('${s.className}-${s.section}', style: GoogleFonts.inter(fontSize: 12.5))),
                        DataCell(Text(s.rollNo, style: GoogleFonts.inter(fontSize: 12))),
                        DataCell(Text('08:15 AM', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary))),
                        DataCell(Text('${s.attendancePercentage}%', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.success))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('Present', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
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
    );
  }

  Widget _buildTeacherAttendanceTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 4 Summary Metric Cards
        Row(
          children: [
            Expanded(child: _buildAttendanceStat('Total Faculty', '86 Staff', AppColors.primary, AppColors.primaryTint)),
            const SizedBox(width: 12),
            Expanded(child: _buildAttendanceStat('Present Today', '78 (90.7%)', AppColors.success, AppColors.successLight)),
            const SizedBox(width: 12),
            Expanded(child: _buildAttendanceStat('Absent', '4 (4.6%)', AppColors.danger, AppColors.dangerLight)),
            const SizedBox(width: 12),
            Expanded(child: _buildAttendanceStat('On Approved Leave', '4 (4.6%)', AppColors.warning, AppColors.warningLight)),
          ],
        ),
        const SizedBox(height: 20),

        // Teacher Attendance Table
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppDecorations.cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Staff Biometric & Daily Punch Logs',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(AppColors.surfaceMuted),
                  columnSpacing: 28,
                  columns: [
                    DataColumn(label: Text('Faculty Member', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Emp ID', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Subject', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Punch In', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Semester Att. %', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Status Today', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                  ],
                  rows: MockData.teachers.map((t) {
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
                        DataCell(Text(t.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13))),
                        DataCell(Text(t.employeeId, style: GoogleFonts.inter(fontSize: 12))),
                        DataCell(Text(t.subject, style: GoogleFonts.inter(fontSize: 12))),
                        DataCell(Text(t.status == 'Present' ? '08:04 AM' : '—', style: GoogleFonts.inter(fontSize: 12))),
                        DataCell(Text('${t.attendancePercentage}%', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary))),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(t.status, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
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
    );
  }

  Widget _buildAttendanceStat(String label, String value, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  void _showQuickMarkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Submit Quick Attendance Batch', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 17)),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: 'Grade 10-A',
                decoration: const InputDecoration(labelText: 'Select Class & Section'),
                items: const [
                  DropdownMenuItem(value: 'Grade 10-A', child: Text('Grade 10 - Section A')),
                  DropdownMenuItem(value: 'Grade 10-B', child: Text('Grade 10 - Section B')),
                  DropdownMenuItem(value: 'Grade 9-A', child: Text('Grade 9 - Section A')),
                ],
                onChanged: (_) {},
              ),
              const SizedBox(height: 12),
              const Text('Mark all students present with one-click exception logging:'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(backgroundColor: AppColors.success, content: Text('Attendance recorded for Grade 10-A!')),
              );
            },
            child: const Text('Submit Attendance'),
          ),
        ],
      ),
    );
  }
}
