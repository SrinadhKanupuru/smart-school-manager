import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../data/mock_data.dart';
import '../../data/principal_mock_data.dart';
import '../../models/leave_model.dart';
import '../../widgets/common/quick_action_card.dart';
import '../../widgets/common/custom_modal.dart';
import '../../widgets/cards/event_card.dart';
import '../../widgets/charts/attendance_line_chart.dart';
import '../../widgets/charts/fee_donut_chart.dart';
import '../../widgets/charts/academic_performance_chart.dart';
import '../../widgets/charts/faculty_attendance_card.dart';
import '../../widgets/timeline/activity_timeline.dart';
import 'principal_navigation_provider.dart';

class PrincipalDashboardScreen extends StatefulWidget {
  const PrincipalDashboardScreen({super.key});

  @override
  State<PrincipalDashboardScreen> createState() => _PrincipalDashboardScreenState();
}

class _PrincipalDashboardScreenState extends State<PrincipalDashboardScreen> {
  String _leaveTabRole = 'Faculty';

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<PrincipalNavigationProvider>(context, listen: false);
    final String currentDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    // Pending leaves for Principal review
    final pendingLeaves = MockData.leaves.where((l) =>
        (_leaveTabRole == 'Faculty' ? l.role == 'Teacher' : l.role == 'Student') &&
        l.status == 'Pending').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Welcome Section & Hero Banner
          _buildPrincipalHeroBanner(context, currentDate),
          const SizedBox(height: 24),

          // 2. School Overview KPI Cards (8 KPI Cards)
          _buildSchoolOverviewKpis(),
          const SizedBox(height: 24),

          // 3. Attendance Section: Student Attendance (Line Chart) + Faculty Attendance (Donut/Breakdown)
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 920) {
                return const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 58,
                      child: AttendanceLineChartCard(),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 42,
                      child: FacultyAttendanceCard(),
                    ),
                  ],
                );
              } else {
                return const Column(
                  children: [
                    AttendanceLineChartCard(),
                    SizedBox(height: 20),
                    FacultyAttendanceCard(),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24),

          // 4. Academic Performance Overview (Bar Chart + Indicators)
          const AcademicPerformanceCard(),
          const SizedBox(height: 24),

          // 5. Fee Overview Section (Principal Read-Only Visibility)
          _buildFeeOverviewSection(),
          const SizedBox(height: 24),

          // 6. Pending Leave Requests Section (Approve / Reject Action Workflows)
          _buildPendingLeavesCard(context, pendingLeaves),
          const SizedBox(height: 24),

          // 7. Quick Actions Section
          _buildPrincipalQuickActions(context, nav),
          const SizedBox(height: 24),

          // 8. Bottom Grid: Upcoming Events (Left) + Recent School Activity (Right)
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 880) {
                return const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 52,
                      child: UpcomingEventsCard(),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 48,
                      child: ActivityTimelineCard(),
                    ),
                  ],
                );
              } else {
                return const Column(
                  children: [
                    UpcomingEventsCard(),
                    SizedBox(height: 20),
                    ActivityTimelineCard(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // 1. Welcome Section & Hero Banner
  Widget _buildPrincipalHeroBanner(BuildContext context, String currentDate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5B21B6), // Rich Deep Violet
            Color(0xFF6D28D9),
            Color(0xFF7C3AED),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 780;

          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.school_rounded, size: 12, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                PrincipalMockData.schoolName,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Session 2026–27',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Greeting
                    Text(
                      'Good Morning, ${PrincipalMockData.principalName}!',
                      style: GoogleFonts.inter(
                        fontSize: isWide ? 26 : 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Here's your school's overview for today.",
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: const Color(0xFFDDD6FE),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Principal Quote / Directive
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFDE047), size: 16),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Daily Academic Focus: Mid-Term Examination question paper verification & classroom reviews.',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.95),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (isWide) ...[
                const SizedBox(width: 20),
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
                  ),
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 52,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // 2. School Overview 8 KPI Cards
  Widget _buildSchoolOverviewKpis() {
    final kpis = [
      _PrincipalStatItem('Total Students', '1,248', 'Enrolled across Grades 1–12', '+5.2%', true, Icons.school_rounded, const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
      _PrincipalStatItem('Students Present Today', '1,203 (96.4%)', 'High turnout rate', '+1.8%', true, Icons.check_circle_rounded, const Color(0xFF10B981), const Color(0xFFECFDF5)),
      _PrincipalStatItem('Students Absent', '45', '3.6% absentees today', 'SMS Alerted', false, Icons.cancel_rounded, const Color(0xFFEF4444), const Color(0xFFFEF2F2)),
      _PrincipalStatItem('Total Teachers', '86', 'Active faculty staff', '100% Allocated', true, Icons.groups_rounded, const Color(0xFF8B5CF6), const Color(0xFFF5F3FF)),
      _PrincipalStatItem('Teachers Present Today', '82 (95.3%)', 'Classes fully covered', 'On Duty', true, Icons.fact_check_rounded, const Color(0xFF059669), const Color(0xFFF0FDF4)),
      _PrincipalStatItem('Teachers Absent', '4', 'Substitutes deployed', 'Handled', false, Icons.person_off_rounded, const Color(0xFFDC2626), const Color(0xFFFEF2F2)),
      _PrincipalStatItem('Teachers On Leave', '2', 'Sanctioned medical leaves', 'Approved', true, Icons.event_busy_rounded, const Color(0xFFF59E0B), const Color(0xFFFFFBEB)),
      _PrincipalStatItem('Pending Leave Requests', '8', 'Requires Principal review', 'Action Needed', false, Icons.pending_actions_rounded, const Color(0xFFD97706), const Color(0xFFFEF3C7)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 4;
        if (constraints.maxWidth < 650) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 1100) {
          crossAxisCount = 2;
        }

        final double cardWidth = (constraints.maxWidth - ((crossAxisCount - 1) * 14)) / crossAxisCount;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: kpis.map((kpi) {
            return SizedBox(
              width: cardWidth,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            kpi.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: kpi.bgColor, borderRadius: BorderRadius.circular(10)),
                          child: Icon(kpi.icon, size: 18, color: kpi.color),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      kpi.value,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            kpi.subtext,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: kpi.bgColor, borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            kpi.badge,
                            style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: kpi.color),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // 5. Fee Overview Section (Principal Read-Only View)
  Widget _buildFeeOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fee Overview & Collection Status',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Principal institutional financial visibility & collection target tracker',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                'View Only (Principal)',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Row of Fee Cards + Donut Chart
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    flex: 38,
                    child: FeeDonutChartCard(),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 62,
                    child: _buildPrincipalFeeMetricsCard(),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  const FeeDonutChartCard(),
                  const SizedBox(height: 20),
                  _buildPrincipalFeeMetricsCard(),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildPrincipalFeeMetricsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Academic Year 2026–27 Fee Ledger Summary', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildFeeMetricTile("Today's Collection", '₹85,000', Icons.today_rounded, AppColors.primary, AppColors.primaryTint),
              const SizedBox(width: 12),
              _buildFeeMetricTile('This Month', '₹18,76,200', Icons.calendar_month_rounded, const Color(0xFF0EA5E9), const Color(0xFFF0F9FF)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildFeeMetricTile('Total Collected', '₹18,76,200 (76.4%)', Icons.check_circle_rounded, AppColors.success, AppColors.successLight),
              const SizedBox(width: 12),
              _buildFeeMetricTile('Pending Fees', '₹4,32,600 (17.6%)', Icons.pending_actions_rounded, AppColors.warning, AppColors.warningLight),
              const SizedBox(width: 12),
              _buildFeeMetricTile('Overdue Fees', '₹1,47,300 (6.0%)', Icons.error_outline_rounded, AppColors.danger, AppColors.dangerLight),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeeMetricTile(String label, String value, IconData icon, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary))),
                Icon(icon, size: 14, color: color),
              ],
            ),
            const SizedBox(height: 6),
            Text(value, style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  // 6. Pending Leave Requests Section (Approve / Reject Action Workflows)
  Widget _buildPendingLeavesCard(BuildContext context, List<LeaveApplication> pendingLeaves) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pending Leave Requests (Action Required)', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Review and sanction staff & student leave applications directly', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              // Role Toggle (Faculty vs Student)
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    _buildLeaveTogglePill('Faculty', _leaveTabRole == 'Faculty'),
                    _buildLeaveTogglePill('Students', _leaveTabRole == 'Students'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (pendingLeaves.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text('No pending $_leaveTabRole leaves to review.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.surfaceMuted),
                columnSpacing: 24,
                columns: [
                  DataColumn(label: Text('Applicant Name', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('Leave Type', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('From', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('To', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('Days', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('Reason', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('Status', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('Actions', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                ],
                rows: pendingLeaves.map((l) {
                  return DataRow(
                    cells: [
                      DataCell(Text(l.applicantName, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(6)),
                          child: Text(l.leaveType, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                        ),
                      ),
                      DataCell(Text(l.fromDate, style: GoogleFonts.inter(fontSize: 12))),
                      DataCell(Text(l.toDate, style: GoogleFonts.inter(fontSize: 12))),
                      DataCell(Text('${l.days}d', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700))),
                      DataCell(
                        Container(
                          constraints: const BoxConstraints(maxWidth: 180),
                          child: Text(l.reason, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary)),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(12)),
                          child: Text(l.status, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.warning)),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                              tooltip: 'Approve Leave',
                              onPressed: () {
                                setState(() {
                                  l.status = 'Approved';
                                  l.adminRemarks = 'Approved by Principal Dr. Rajeshwari Raman.';
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(backgroundColor: AppColors.success, content: Text('Leave approved for ${l.applicantName}')),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel_rounded, color: AppColors.danger, size: 20),
                              tooltip: 'Reject Leave',
                              onPressed: () {
                                setState(() {
                                  l.status = 'Rejected';
                                  l.adminRemarks = 'Rejected by Principal.';
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(backgroundColor: AppColors.danger, content: Text('Leave rejected for ${l.applicantName}')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeaveTogglePill(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _leaveTabRole = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? const Color(0xFF7C3AED) : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // 7. Quick Actions Section
  Widget _buildPrincipalQuickActions(BuildContext context, PrincipalNavigationProvider nav) {
    final actions = [
      QuickActionItem(
        label: 'View Teachers',
        icon: Icons.school_rounded,
        color: const Color(0xFF8B5CF6),
        bgColor: const Color(0xFFF5F3FF),
        onTap: () => nav.setModule(PrincipalModule.teachers),
      ),
      QuickActionItem(
        label: 'View Students',
        icon: Icons.groups_rounded,
        color: const Color(0xFF2563EB),
        bgColor: const Color(0xFFEFF6FF),
        onTap: () => nav.setModule(PrincipalModule.students),
      ),
      QuickActionItem(
        label: 'View Attendance',
        icon: Icons.fact_check_rounded,
        color: const Color(0xFF10B981),
        bgColor: const Color(0xFFECFDF5),
        onTap: () => nav.setModule(PrincipalModule.attendance),
      ),
      QuickActionItem(
        label: 'Review Leaves',
        icon: Icons.event_busy_rounded,
        color: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFFFBEB),
        onTap: () => nav.setModule(PrincipalModule.leaveManagement),
      ),
      QuickActionItem(
        label: 'View Fees',
        icon: Icons.account_balance_wallet_rounded,
        color: const Color(0xFF0EA5E9),
        bgColor: const Color(0xFFF0F9FF),
        onTap: () => nav.setModule(PrincipalModule.account),
      ),
      QuickActionItem(
        label: 'Generate Report',
        icon: Icons.analytics_rounded,
        color: const Color(0xFFEC4899),
        bgColor: const Color(0xFFFDF2F8),
        onTap: () => CustomModals.showGenerateReportDialog(context),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Principal Quick Actions',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 6;
            if (constraints.maxWidth < 600) {
              crossAxisCount = 2;
            } else if (constraints.maxWidth < 950) {
              crossAxisCount = 3;
            }

            final double cardWidth = (constraints.maxWidth - ((crossAxisCount - 1) * 14)) / crossAxisCount;

            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: actions.map((act) {
                return SizedBox(
                  width: cardWidth,
                  child: QuickActionCard(item: act),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _PrincipalStatItem {
  final String title;
  final String value;
  final String subtext;
  final String badge;
  final bool isPositive;
  final IconData icon;
  final Color color;
  final Color bgColor;

  _PrincipalStatItem(this.title, this.value, this.subtext, this.badge, this.isPositive, this.icon, this.color, this.bgColor);
}
