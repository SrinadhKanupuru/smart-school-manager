import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../models/kpi_card_data.dart';
import '../../widgets/common/stat_card.dart';
import 'faculty_navigation_provider.dart';

class FacultyDashboardScreen extends StatelessWidget {
  const FacultyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<FacultyNavigationProvider>(context);

    // KPI Cards as specified in user requirements
    final facultyKpis = [
      const KpiCardData(
        title: 'My Classes',
        value: '4 Classes',
        changePercentage: 'Grade 8, 9 & 10',
        isPositive: true,
        comparisonPeriod: 'Active Term',
        icon: Icons.class_outlined,
        iconColor: Color(0xFF2563EB),
        iconBgColor: Color(0xFFEFF6FF),
        sparklineData: [4, 4, 4, 4, 4, 4, 4],
      ),
      const KpiCardData(
        title: 'Total Students',
        value: '142',
        changePercentage: '+3 new',
        isPositive: true,
        comparisonPeriod: 'vs last month',
        icon: Icons.groups_outlined,
        iconColor: Color(0xFF8B5CF6),
        iconBgColor: Color(0xFFF5F3FF),
        sparklineData: [135, 137, 139, 139, 140, 142, 142],
      ),
      const KpiCardData(
        title: 'Present Today',
        value: '136 / 95.8%',
        changePercentage: '+1.4%',
        isPositive: true,
        comparisonPeriod: 'vs yesterday',
        icon: Icons.check_circle_outline_rounded,
        iconColor: Color(0xFF10B981),
        iconBgColor: Color(0xFFECFDF5),
        sparklineData: [92, 94, 91, 95, 93, 96, 95.8],
      ),
      const KpiCardData(
        title: 'Absent Today',
        value: '6 Students',
        changePercentage: '2 On Leave',
        isPositive: false,
        comparisonPeriod: '4 Unexcused',
        icon: Icons.person_off_outlined,
        iconColor: Color(0xFFEF4444),
        iconBgColor: Color(0xFFFEF2F2),
        sparklineData: [8, 6, 9, 5, 7, 4, 6],
      ),
      const KpiCardData(
        title: 'Pending Homework',
        value: '3 Batches',
        changePercentage: '48 Submissions',
        isPositive: false,
        comparisonPeriod: 'Due for review',
        icon: Icons.assignment_late_outlined,
        iconColor: Color(0xFFF59E0B),
        iconBgColor: Color(0xFFFFFBEB),
        sparklineData: [1, 2, 4, 5, 3, 3, 3],
      ),
      const KpiCardData(
        title: 'Upcoming Exams',
        value: 'Physics Mid-Term',
        changePercentage: 'In 3 Days',
        isPositive: true,
        comparisonPeriod: 'Sep 15, 2026',
        icon: Icons.quiz_outlined,
        iconColor: Color(0xFF0284C7),
        iconBgColor: Color(0xFFF0F9FF),
        sparklineData: [10, 15, 20, 30, 45, 60, 90],
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header & Quick Action Row
            _buildWelcomeHeader(context, nav),
            const SizedBox(height: 20),

            // 6 Top KPI Cards Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width > 1100
                    ? 3
                    : width > 680
                        ? 2
                        : 1;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 135,
                  ),
                  itemCount: facultyKpis.length,
                  itemBuilder: (context, index) {
                    return StatCard(data: facultyKpis[index]);
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // Main 2-Column Row (Today's Timetable & Attendance Overview)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Today's Timetable
                      Expanded(
                        flex: 55,
                        child: _buildTimetableCard(context, nav),
                      ),
                      const SizedBox(width: 20),
                      // Right Column: Class Attendance Overview
                      Expanded(
                        flex: 45,
                        child: _buildAttendanceOverviewCard(context, nav),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildTimetableCard(context, nav),
                      const SizedBox(height: 20),
                      _buildAttendanceOverviewCard(context, nav),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // Bottom 2-Column Row (Pending Homework / Assignments & Recent Student Activity)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Pending Homework & Upcoming Exams
                      Expanded(
                        flex: 50,
                        child: _buildHomeworkAndExamsCard(context, nav),
                      ),
                      const SizedBox(width: 20),
                      // Right: Recent Student Activity Feed
                      Expanded(
                        flex: 50,
                        child: _buildRecentActivityCard(context),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildHomeworkAndExamsCard(context, nav),
                      const SizedBox(height: 20),
                      _buildRecentActivityCard(context),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Top Welcome Header with Quick Action Shortcut Buttons
  Widget _buildWelcomeHeader(BuildContext context, FacultyNavigationProvider nav) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;

          return Flex(
            direction: isWide ? Axis.horizontal : Axis.vertical,
            crossAxisAlignment:
                isWide ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Faculty Workspace',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.successBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Term In Session',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF065F46),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome back, Ms. Kavya Sharma. You have 3 classes and 1 lab scheduled today.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (!isWide) const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => nav.setModule(FacultyModule.attendance),
                    icon: const Icon(Icons.fact_check_outlined, size: 16),
                    label: const Text('Mark Attendance'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => nav.setModule(FacultyModule.homework),
                    icon: const Icon(Icons.add_task_rounded, size: 16, color: AppColors.primary),
                    label: const Text('Assign Homework'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => nav.setModule(FacultyModule.leave),
                    icon: const Icon(Icons.event_note_rounded, size: 16, color: Color(0xFF8B5CF6)),
                    label: const Text('Apply Leave'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// Today's Timetable Schedule Card
  Widget _buildTimetableCard(BuildContext context, FacultyNavigationProvider nav) {
    final periods = [
      {
        'period': 'Period 1',
        'time': '09:00 AM – 09:45 AM',
        'class': 'Grade 9-A',
        'subject': 'Physics (Laws of Motion)',
        'room': 'Room 204 (Science Wing)',
        'isCurrent': false,
        'isDone': true,
      },
      {
        'period': 'Period 2',
        'time': '09:50 AM – 10:35 AM',
        'class': 'Grade 10-B',
        'subject': 'Physics (Electromagnetism)',
        'room': 'Room 302',
        'isCurrent': true,
        'isDone': false,
      },
      {
        'period': 'Break',
        'time': '10:35 AM – 10:55 AM',
        'class': 'Staff Lounge',
        'subject': 'Short Tea Break',
        'room': 'Staff Block B',
        'isCurrent': false,
        'isDone': false,
      },
      {
        'period': 'Period 3',
        'time': '11:00 AM – 11:45 AM',
        'class': 'Grade 8-C',
        'subject': 'General Science (Light & Optics)',
        'room': 'Room 108',
        'isCurrent': false,
        'isDone': false,
      },
      {
        'period': 'Period 4',
        'time': '11:50 AM – 12:35 PM',
        'class': 'Grade 9-A',
        'subject': 'Physics Lab Practical',
        'room': 'Senior Science Lab 1',
        'isCurrent': false,
        'isDone': false,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.schedule_rounded, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Today\'s Timetable',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => nav.setModule(FacultyModule.timetable),
                icon: const Icon(Icons.calendar_month_outlined, size: 14),
                label: const Text('Full Week'),
                style: TextButton.styleFrom(
                  textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: periods.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final p = periods[index];
              final isCurrent = p['isCurrent'] as bool;
              final isDone = p['isDone'] as bool;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCurrent ? const Color(0xFFEFF6FF) : AppColors.surfaceHover,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent ? const Color(0xFF93C5FD) : AppColors.border,
                    width: isCurrent ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Time block
                    Container(
                      width: 78,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCurrent ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isCurrent ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        p['period'] as String,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isCurrent ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                p['subject'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'ACTIVE NOW',
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                              if (isDone) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.successLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'COMPLETED',
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF065F46),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${p['class']} • ${p['room']} • ${p['time']}',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
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
        ],
      ),
    );
  }

  /// Class Attendance Overview Card
  Widget _buildAttendanceOverviewCard(
      BuildContext context, FacultyNavigationProvider nav) {
    final classAttendance = [
      {'class': 'Grade 9-A (Physics)', 'present': 38, 'total': 40, 'percent': 95.0},
      {'class': 'Grade 10-B (Physics)', 'present': 42, 'total': 44, 'percent': 95.5},
      {'class': 'Grade 8-C (Science)', 'present': 34, 'total': 36, 'percent': 94.4},
      {'class': 'Physics Practical Lab', 'present': 22, 'total': 22, 'percent': 100.0},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.fact_check_rounded, color: AppColors.success, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Class Attendance',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => nav.setModule(FacultyModule.attendance),
                icon: const Icon(Icons.edit_note_rounded, size: 14),
                label: const Text('Mark Today'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  textStyle: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: classAttendance.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final c = classAttendance[index];
              final percent = c['percent'] as double;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        c['class'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${c['present']}/${c['total']} (${percent.toStringAsFixed(1)}%)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: percent >= 95 ? AppColors.success : const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent / 100,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percent >= 95 ? AppColors.success : const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Absent Alert Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.dangerLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.dangerBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.danger),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '2 students in Grade 9-A have exceeded 3 consecutive absences. Automated parent SMS sent.',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: const Color(0xFF991B1B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Pending Homework & Upcoming Exams Card
  Widget _buildHomeworkAndExamsCard(
      BuildContext context, FacultyNavigationProvider nav) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.assignment_turned_in_outlined,
                        color: Color(0xFFD97706), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Pending Homework & Exams',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => nav.setModule(FacultyModule.homework),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Homework 1
          _buildHomeworkItem(
            title: 'Newton’s Laws Numerical Problems',
            className: 'Grade 9-A',
            submitted: '36/40 Submitted',
            dueDate: 'Due: Tomorrow, 10:00 AM',
            status: 'Grading in Progress',
            statusColor: const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 10),

          // Homework 2
          _buildHomeworkItem(
            title: 'Electromagnetic Induction Lab Writeup',
            className: 'Grade 10-B',
            submitted: '41/44 Submitted',
            dueDate: 'Due: Sep 16, 2026',
            status: 'Submissions Open',
            statusColor: const Color(0xFF2563EB),
          ),
          const SizedBox(height: 14),

          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // Upcoming Exam Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Row(
              children: [
                const Icon(Icons.quiz_rounded, color: Color(0xFF0284C7), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mid-Term Physics Exam (Grade 9 & 10)',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0369A1),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Scheduled for Sep 15, 2026 • Question Paper Approved',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: const Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkItem({
    required String title,
    required String className,
    required String submitted,
    required String dueDate,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceHover,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$className • $submitted • $dueDate',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Recent Student Activity Feed
  Widget _buildRecentActivityCard(BuildContext context) {
    final activities = [
      {
        'title': 'Aarav Patel (Grade 9-A)',
        'action': 'Submitted Physics Numerical Assignment #4',
        'time': '12 mins ago',
        'icon': Icons.file_upload_outlined,
        'color': AppColors.primary,
      },
      {
        'title': 'Riya Sen (Grade 10-B)',
        'action': 'Applied for 1-day Medical Leave (Dental Appointment)',
        'time': '34 mins ago',
        'icon': Icons.medical_services_outlined,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'title': 'Tanvi Verma (Grade 9-A)',
        'action': 'Marked Present via biometric gate sensor',
        'time': '1 hour ago',
        'icon': Icons.check_circle_outline_rounded,
        'color': AppColors.success,
      },
      {
        'title': 'Exam Department',
        'action': 'Physics Mid-Term question paper vetted and sanctioned',
        'time': '2 hours ago',
        'icon': Icons.task_alt_rounded,
        'color': const Color(0xFF0284C7),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.history_rounded,
                    color: Color(0xFF8B5CF6), size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Recent Student Activity',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (_, __) => const Divider(height: 16, color: AppColors.border),
            itemBuilder: (context, index) {
              final a = activities[index];
              final iconColor = a['color'] as Color;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(a['icon'] as IconData, size: 15, color: iconColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a['title'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a['action'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    a['time'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
