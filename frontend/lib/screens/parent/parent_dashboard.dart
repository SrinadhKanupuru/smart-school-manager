import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/parent_mock_data.dart';
import '../../widgets/parent/parent_ui_components.dart';
import 'parent_data_provider.dart';
import 'parent_navigation_provider.dart';
import '../../models/parent_portal_models.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<ParentDataProvider>(context);
    final nav = Provider.of<ParentNavigationProvider>(context, listen: false);
    final child = data.selectedChild;
    final att = data.currentAttendance;
    final hwList = data.currentHomeworks;
    final fee = data.currentFeeSummary;
    final upcomingExams = data.currentUpcomingExams;
    final notices = data.notices;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Staggered Top Greeting & Date Header
          ParentAnimatedEntrance(
            index: 0,
            child: _buildHeaderGreeting(context),
          ),

          const SizedBox(height: 16),

          // 2. Beautiful Child Selector & Hero Dossier Card
          ParentAnimatedEntrance(
            index: 1,
            child: _buildChildSelectorHeroCard(context, data, nav),
          ),

          const SizedBox(height: 20),

          // 3. "Needs Your Attention" Smart Priority Alerts
          ParentAnimatedEntrance(
            index: 2,
            child: _buildNeedsAttentionSection(context, child, hwList, fee, nav),
          ),

          const SizedBox(height: 20),

          // 4. 5 KPI Metrics Grid with Micro-Hover
          ParentAnimatedEntrance(
            index: 3,
            child: _buildKpiMetricsGrid(context, child, att, hwList, fee, nav),
          ),

          const SizedBox(height: 24),

          // 5. Two-Column Dashboard Content Layout (Responsive)
          ParentAnimatedEntrance(
            index: 4,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 960;

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column (60%)
                      Expanded(
                        flex: 60,
                        child: Column(
                          children: [
                            _buildAttendanceOverview(context, att, nav),
                            const SizedBox(height: 20),
                            _buildTodayHomework(context, hwList, nav),
                            const SizedBox(height: 20),
                            _buildQuickActions(context, nav),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Right Column (40%)
                      Expanded(
                        flex: 40,
                        child: Column(
                          children: [
                            _buildUpcomingExams(context, upcomingExams, nav),
                            const SizedBox(height: 20),
                            _buildFeeSummary(context, fee, nav),
                            const SizedBox(height: 20),
                            _buildRecentNotices(context, notices, nav),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildAttendanceOverview(context, att, nav),
                      const SizedBox(height: 20),
                      _buildTodayHomework(context, hwList, nav),
                      const SizedBox(height: 20),
                      _buildUpcomingExams(context, upcomingExams, nav),
                      const SizedBox(height: 20),
                      _buildFeeSummary(context, fee, nav),
                      const SizedBox(height: 20),
                      _buildQuickActions(context, nav),
                      const SizedBox(height: 20),
                      _buildRecentNotices(context, notices, nav),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderGreeting(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning, ${ParentMockData.parentName}',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: ParentDesignTokens.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Here's what requires your attention for your child today.",
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: ParentDesignTokens.textSecondary,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ParentDesignTokens.surface,
            borderRadius: ParentDesignTokens.radiusMd,
            border: Border.all(color: ParentDesignTokens.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: ParentDesignTokens.warmAccent),
              const SizedBox(width: 8),
              Text(
                'Term 1 • Sep 2026',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ParentDesignTokens.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChildSelectorHeroCard(
    BuildContext context,
    ParentDataProvider data,
    ParentNavigationProvider nav,
  ) {
    final child = data.selectedChild;

    return ParentCard(
      padding: const EdgeInsets.all(20),
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Top Segmented Multi-Child Bar if multiple children exist
          if (data.children.length > 1) ...[
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ParentDesignTokens.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: data.children.map((c) {
                  final isSelected = c.id == child.id;
                  return Expanded(
                    child: InkWell(
                      onTap: () => data.selectChild(c),
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: isSelected ? ParentDesignTokens.shadowSm : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 11,
                              backgroundColor: isSelected ? ParentDesignTokens.warmAccent : const Color(0xFFCBD5E1),
                              child: Text(
                                c.name.substring(0, 1),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${c.name} (${c.shortClass})',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? ParentDesignTokens.textPrimary : ParentDesignTokens.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Active Child Info Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 640;

              return Flex(
                direction: isNarrow ? Axis.vertical : Axis.horizontal,
                crossAxisAlignment: isNarrow ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: ParentDesignTokens.warmAccentLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: ParentDesignTokens.warmAccentBorder),
                        ),
                        child: Center(
                          child: Text(
                            child.name.substring(0, 1),
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: ParentDesignTokens.warmAccentDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                child.name,
                                style: GoogleFonts.inter(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                  color: ParentDesignTokens.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ParentBadge.info(label: 'ID: ${child.id}'),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${child.classAndSection} • Roll No: ${child.rollNo} • Teacher: ${child.classTeacher}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: ParentDesignTokens.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (isNarrow) const SizedBox(height: 14) else const Spacer(),
                  Row(
                    children: [
                      _buildMiniBadgeMetric('Attendance', '${child.attendancePercentage}%', ParentDesignTokens.emerald),
                      const SizedBox(width: 10),
                      _buildMiniBadgeMetric('Avg Score', '${child.averageScore}%', ParentDesignTokens.sky),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () => nav.navigateToChildProfile(child.id),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          side: const BorderSide(color: ParentDesignTokens.border),
                        ),
                        child: Text(
                          'View Dossier',
                          style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: ParentDesignTokens.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadgeMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.inter(fontSize: 11, color: ParentDesignTokens.textSecondary),
          ),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedsAttentionSection(
    BuildContext context,
    ChildStudent child,
    List<ChildHomework> hwList,
    ChildFeeSummary fee,
    ParentNavigationProvider nav,
  ) {
    final pendingHw = hwList.where((h) => h.isPending).take(1).toList();

    return ParentCard(
      padding: const EdgeInsets.all(18),
      backgroundColor: const Color(0xFFFAFAFA),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.notifications_active_outlined, size: 16, color: Color(0xFFB45309)),
              ),
              const SizedBox(width: 10),
              Text(
                'Needs Your Attention',
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: ParentDesignTokens.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              if (pendingHw.isNotEmpty)
                _buildAttentionItem(
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFD97706),
                  bg: const Color(0xFFFFFBEB),
                  text: '${pendingHw.first.subject} homework due today: "${pendingHw.first.title}"',
                  actionLabel: 'View Homework',
                  onTap: () => nav.setModule(ParentModule.homework),
                ),
              if (fee.pendingFees > 0)
                _buildAttentionItem(
                  icon: Icons.error_outline_rounded,
                  color: const Color(0xFFE11D48),
                  bg: const Color(0xFFFFF1F2),
                  text: '₹${fee.pendingFees.toStringAsFixed(0)} Term 2 tuition installment due on ${fee.nextDueDate}',
                  actionLabel: 'Pay Fees',
                  onTap: () => nav.setModule(ParentModule.fees),
                ),
              _buildAttentionItem(
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF059669),
                bg: const Color(0xFFECFDF5),
                text: 'Attendance confirmed present today at 08:20 AM',
                actionLabel: 'Attendance Log',
                onTap: () => nav.setModule(ParentModule.attendance),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttentionItem({
    required IconData icon,
    required Color color,
    required Color bg,
    required String text,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ParentDesignTokens.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onTap,
            child: Text(
              '$actionLabel →',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiMetricsGrid(
    BuildContext context,
    ChildStudent child,
    ChildAttendanceSummary att,
    List<ChildHomework> hwList,
    ChildFeeSummary fee,
    ParentNavigationProvider nav,
  ) {
    final pendingHw = hwList.where((h) => h.isPending).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 5;
        if (constraints.maxWidth < 620) {
          crossAxisCount = 2;
        } else if (constraints.maxWidth < 980) {
          crossAxisCount = 3;
        }

        final cards = [
          _buildMetricCard(
            title: 'Attendance',
            value: '${att.percentage}%',
            supporting: '${att.presentDays} of ${att.totalWorkingDays} days present',
            statusBadge: ParentBadge.success(label: 'On Track'),
            icon: Icons.fact_check_rounded,
            color: ParentDesignTokens.emerald,
            onTap: () => nav.setModule(ParentModule.attendance),
          ),
          _buildMetricCard(
            title: 'Homework',
            value: '$pendingHw Pending',
            supporting: pendingHw == 0 ? 'All assignments done' : 'Due this week',
            statusBadge: pendingHw > 0
                ? ParentBadge.warning(label: 'Action')
                : ParentBadge.success(label: 'Completed'),
            icon: Icons.menu_book_rounded,
            color: ParentDesignTokens.warmAccent,
            onTap: () => nav.setModule(ParentModule.homework),
          ),
          _buildMetricCard(
            title: 'Assignments',
            value: '1 Pending',
            supporting: 'Math project due soon',
            statusBadge: ParentBadge.info(label: 'In Review'),
            icon: Icons.assignment_rounded,
            color: ParentDesignTokens.brand,
            onTap: () => nav.setModule(ParentModule.assignments),
          ),
          _buildMetricCard(
            title: 'Average Score',
            value: '${child.averageScore}%',
            supporting: 'Grade A+ • Top 10%',
            statusBadge: ParentBadge.success(label: 'Distinction'),
            icon: Icons.emoji_events_rounded,
            color: ParentDesignTokens.sky,
            onTap: () => nav.setModule(ParentModule.exams),
          ),
          _buildMetricCard(
            title: 'Fees Due',
            value: fee.pendingFees > 0 ? '₹${fee.pendingFees.toStringAsFixed(0)}' : '₹0',
            supporting: fee.pendingFees > 0 ? 'Due: ${fee.nextDueDate}' : 'Reconciled',
            statusBadge: fee.pendingFees > 0
                ? ParentBadge.danger(label: 'Due Soon')
                : ParentBadge.success(label: 'Cleared'),
            icon: Icons.account_balance_wallet_rounded,
            color: fee.pendingFees > 0 ? ParentDesignTokens.rose : ParentDesignTokens.emerald,
            onTap: () => nav.setModule(ParentModule.fees),
          ),
        ];

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards.map((c) {
            final width = (constraints.maxWidth - (crossAxisCount - 1) * 12) / crossAxisCount;
            return SizedBox(width: width, child: c);
          }).toList(),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String supporting,
    required Widget statusBadge,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ParentCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              statusBadge,
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: ParentDesignTokens.textPrimary,
              letterSpacing: -0.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ParentDesignTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            supporting,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              color: ParentDesignTokens.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceOverview(
    BuildContext context,
    ChildAttendanceSummary att,
    ParentNavigationProvider nav,
  ) {
    return ParentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ParentSectionHeader(
            title: 'Attendance Overview',
            subtitle: 'September 2026 • Real-time morning audit',
            icon: Icons.fact_check_rounded,
            trailing: TextButton(
              onPressed: () => nav.setModule(ParentModule.attendance),
              child: const Text('View Full Log →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildAttendanceCountPill('Present', '${att.presentDays}d', ParentDesignTokens.emerald, ParentDesignTokens.emeraldLight)),
              const SizedBox(width: 8),
              Expanded(child: _buildAttendanceCountPill('Absent', '${att.absentDays}d', ParentDesignTokens.rose, ParentDesignTokens.roseLight)),
              const SizedBox(width: 8),
              Expanded(child: _buildAttendanceCountPill('Late', '${att.lateDays}d', ParentDesignTokens.warmAccent, ParentDesignTokens.warmAccentLight)),
              const SizedBox(width: 8),
              Expanded(child: _buildAttendanceCountPill('Leave', '${att.leaveDays}d', ParentDesignTokens.purple, ParentDesignTokens.purpleLight)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: att.percentage / 100.0,
                backgroundColor: ParentDesignTokens.surfaceMuted,
                valueColor: const AlwaysStoppedAnimation<Color>(ParentDesignTokens.emerald),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance Compliance: ${att.percentage}% (Outstanding)',
                style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: ParentDesignTokens.emerald),
              ),
              Text(
                'Institutional Min: 75%',
                style: GoogleFonts.inter(fontSize: 11, color: ParentDesignTokens.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCountPill(String label, String val, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayHomework(
    BuildContext context,
    List<ChildHomework> hwList,
    ParentNavigationProvider nav,
  ) {
    return ParentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ParentSectionHeader(
            title: "Today's Homework",
            subtitle: 'Direct assignments published by faculty',
            icon: Icons.menu_book_rounded,
            trailing: TextButton(
              onPressed: () => nav.setModule(ParentModule.homework),
              child: const Text('View All →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 14),
          ...hwList.take(3).map((hw) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ParentDesignTokens.surfaceHover,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ParentDesignTokens.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hw.isCompleted ? ParentDesignTokens.emeraldLight : ParentDesignTokens.warmAccentLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      hw.isCompleted ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                      size: 16,
                      color: hw.isCompleted ? ParentDesignTokens.emerald : ParentDesignTokens.warmAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              hw.subject,
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: ParentDesignTokens.textPrimary),
                            ),
                            ParentBadge(
                              label: hw.isCompleted ? 'Completed' : 'Due Today',
                              color: hw.isCompleted ? ParentDesignTokens.emerald : ParentDesignTokens.rose,
                              backgroundColor: hw.isCompleted ? ParentDesignTokens.emeraldLight : ParentDesignTokens.roseLight,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hw.title,
                          style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ParentNavigationProvider nav) {
    final actions = [
      {'label': 'Attendance', 'icon': Icons.fact_check_rounded, 'mod': ParentModule.attendance, 'color': ParentDesignTokens.emerald},
      {'label': 'Homework', 'icon': Icons.menu_book_rounded, 'mod': ParentModule.homework, 'color': ParentDesignTokens.warmAccent},
      {'label': 'Results', 'icon': Icons.emoji_events_rounded, 'mod': ParentModule.exams, 'color': ParentDesignTokens.sky},
      {'label': 'Pay Fees', 'icon': Icons.payment_rounded, 'mod': ParentModule.fees, 'color': ParentDesignTokens.purple},
      {'label': 'Timetable', 'icon': Icons.table_chart_rounded, 'mod': ParentModule.timetable, 'color': const Color(0xFFEC4899)},
      {'label': 'Apply Leave', 'icon': Icons.event_busy_rounded, 'mod': ParentModule.leave, 'color': ParentDesignTokens.warmAccentDark},
    ];

    return ParentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ParentSectionHeader(
            title: 'Quick Actions',
            subtitle: '1-Click navigation shortcuts',
            icon: Icons.bolt_rounded,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: actions.map((act) {
              return InkWell(
                onTap: () => nav.setModule(act['mod'] as ParentModule),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: (act['color'] as Color).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: (act['color'] as Color).withValues(alpha: 0.2)),
                        ),
                        child: Icon(act['icon'] as IconData, size: 20, color: act['color'] as Color),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        act['label'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ParentDesignTokens.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingExams(
    BuildContext context,
    List<ChildExam> exams,
    ParentNavigationProvider nav,
  ) {
    return ParentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ParentSectionHeader(
            title: 'Upcoming Exams',
            subtitle: 'Mid-Term 2026 schedule',
            icon: Icons.calendar_month_rounded,
            trailing: TextButton(
              onPressed: () => nav.setModule(ParentModule.exams),
              child: const Text('All Schedule →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          ...exams.take(3).map((ex) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ParentDesignTokens.surfaceHover,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ParentDesignTokens.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: ParentDesignTokens.brandTint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${ex.date.day}',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: ParentDesignTokens.brand),
                        ),
                        Text(
                          'SEP',
                          style: GoogleFonts.inter(fontSize: 8.5, fontWeight: FontWeight.w700, color: ParentDesignTokens.brand),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ex.subject,
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: ParentDesignTokens.textPrimary),
                        ),
                        Text(
                          '${ex.time} • ${ex.room}',
                          style: GoogleFonts.inter(fontSize: 11, color: ParentDesignTokens.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeeSummary(
    BuildContext context,
    ChildFeeSummary fee,
    ParentNavigationProvider nav,
  ) {
    return ParentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ParentSectionHeader(
            title: 'Fee Summary',
            subtitle: 'Academic Year 2025-26',
            icon: Icons.account_balance_wallet_rounded,
            trailing: TextButton(
              onPressed: () => nav.setModule(ParentModule.fees),
              child: const Text('Ledger →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFeeStat('Total Fee', '₹${fee.totalFees.toStringAsFixed(0)}', ParentDesignTokens.textPrimary),
              _buildFeeStat('Paid', '₹${fee.paidFees.toStringAsFixed(0)}', ParentDesignTokens.emerald),
              _buildFeeStat('Pending', '₹${fee.pendingFees.toStringAsFixed(0)}', fee.pendingFees > 0 ? ParentDesignTokens.rose : ParentDesignTokens.emerald),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => nav.setModule(ParentModule.fees),
              icon: const Icon(Icons.payment_rounded, size: 16),
              label: Text(fee.pendingFees > 0 ? 'Pay Outstanding (₹${fee.pendingFees.toStringAsFixed(0)})' : 'View Verified Receipts'),
              style: ElevatedButton.styleFrom(
                backgroundColor: fee.pendingFees > 0 ? ParentDesignTokens.warmAccent : ParentDesignTokens.emerald,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 11),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: ParentDesignTokens.textSecondary)),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w800, color: color),
        ),
      ],
    );
  }

  Widget _buildRecentNotices(
    BuildContext context,
    List<ParentNoticeItem> notices,
    ParentNavigationProvider nav,
  ) {
    return ParentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ParentSectionHeader(
            title: 'School Notices',
            subtitle: 'Recent circulars and meeting alerts',
            icon: Icons.campaign_rounded,
            trailing: TextButton(
              onPressed: () => nav.setModule(ParentModule.notices),
              child: const Text('All Notices →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          ...notices.take(3).map((n) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: ParentDesignTokens.warmAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.title,
                          style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: ParentDesignTokens.textPrimary),
                        ),
                        Text(
                          '${n.date.day} Sep • ${n.category}',
                          style: GoogleFonts.inter(fontSize: 10.5, color: ParentDesignTokens.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
