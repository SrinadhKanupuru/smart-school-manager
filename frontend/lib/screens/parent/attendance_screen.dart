import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../widgets/parent/parent_ui_components.dart';
import 'parent_data_provider.dart';
import '../../models/parent_portal_models.dart';

class ParentAttendanceScreen extends StatefulWidget {
  const ParentAttendanceScreen({super.key});

  @override
  State<ParentAttendanceScreen> createState() => _ParentAttendanceScreenState();
}

class _ParentAttendanceScreenState extends State<ParentAttendanceScreen> {
  String _selectedFilter = 'This Month';
  int _selectedMonthOffset = 0; // 0 for Current Month, -1 for Prev Month

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<ParentDataProvider>(context);
    final child = data.selectedChild;
    final att = data.currentAttendance;
    final isDesktop = MediaQuery.of(context).size.width >= 960;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen Header
          ParentAnimatedEntrance(
            index: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attendance Records',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: ParentDesignTokens.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Verified institutional daily log for ${child.name} (${child.grade} - Section ${child.section})',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: ParentDesignTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Filter Segmented Control
                Container(
                  decoration: BoxDecoration(
                    color: ParentDesignTokens.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ParentDesignTokens.border),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: ['This Month', 'Last Month', 'Academic Year'].map((tab) {
                      final isSelected = _selectedFilter == tab;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedFilter = tab;
                            if (tab == 'Last Month') {
                              _selectedMonthOffset = -1;
                            } else {
                              _selectedMonthOffset = 0;
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSelected ? ParentDesignTokens.shadowSm : null,
                          ),
                          child: Text(
                            tab,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? ParentDesignTokens.brand : ParentDesignTokens.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Hero Attendance Overview Banner Card
          ParentAnimatedEntrance(
            index: 1,
            child: ParentCard(
              padding: const EdgeInsets.all(24),
              child: isDesktop
                  ? Row(
                      children: [
                        // Left: Percentage Gauge
                        _buildGaugeSection(att),
                        const SizedBox(width: 32),
                        Container(width: 1, height: 110, color: ParentDesignTokens.border),
                        const SizedBox(width: 32),
                        // Right: Breakdown stat pills
                        Expanded(child: _buildBreakdownGrid(att)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGaugeSection(att),
                        const SizedBox(height: 20),
                        const Divider(height: 1, color: ParentDesignTokens.border),
                        const SizedBox(height: 20),
                        _buildBreakdownGrid(att),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 24),

          // Attendance Trend Chart + Monthly Calendar Heatmap
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Monthly Calendar
                    Expanded(
                      flex: 6,
                      child: ParentAnimatedEntrance(
                        index: 2,
                        child: _buildCalendarCard(att),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Weekly Trend Line Chart
                    Expanded(
                      flex: 4,
                      child: ParentAnimatedEntrance(
                        index: 3,
                        child: _buildTrendChartCard(att),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    ParentAnimatedEntrance(index: 2, child: _buildCalendarCard(att)),
                    const SizedBox(height: 20),
                    ParentAnimatedEntrance(index: 3, child: _buildTrendChartCard(att)),
                  ],
                ),

          const SizedBox(height: 24),

          // Daily Attendance History Table
          ParentAnimatedEntrance(
            index: 4,
            child: ParentCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Biometric Punch Log',
                              style: GoogleFonts.inter(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: ParentDesignTokens.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Automated entry & exit logs registered at school gates',
                              style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textMuted),
                            ),
                          ],
                        ),
                        ParentBadge.info(label: 'Total ${att.totalDays} Academic Days', icon: Icons.schedule_rounded),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: ParentDesignTokens.border),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: att.dailyRecords.take(8).length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: ParentDesignTokens.borderSubtle),
                    itemBuilder: (context, index) {
                      final rec = att.dailyRecords[index];
                      final isPresent = rec.status == 'Present';
                      final isAbsent = rec.status == 'Absent';
                      final isLate = rec.status == 'Late';

                      Color badgeBg;
                      Color badgeFg;
                      IconData statusIcon;

                      if (isPresent) {
                        badgeBg = ParentDesignTokens.emeraldLight;
                        badgeFg = ParentDesignTokens.emerald;
                        statusIcon = Icons.check_circle_rounded;
                      } else if (isAbsent) {
                        badgeBg = ParentDesignTokens.roseLight;
                        badgeFg = ParentDesignTokens.rose;
                        statusIcon = Icons.cancel_rounded;
                      } else if (isLate) {
                        badgeBg = ParentDesignTokens.warmAccentLight;
                        badgeFg = ParentDesignTokens.warmAccentDark;
                        statusIcon = Icons.alarm_rounded;
                      } else {
                        badgeBg = ParentDesignTokens.purpleLight;
                        badgeFg = ParentDesignTokens.purple;
                        statusIcon = Icons.event_busy_rounded;
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: badgeFg.withValues(alpha: 0.2)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${rec.date.day}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: badgeFg,
                                    ),
                                  ),
                                  Text(
                                    'SEP',
                                    style: GoogleFonts.inter(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: badgeFg,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Session ${rec.date.day} September 2026',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: ParentDesignTokens.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    rec.remarks ?? (isPresent ? 'On-time classroom check-in (08:24 AM)' : 'No gate scan recorded'),
                                    style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(statusIcon, size: 13, color: badgeFg),
                                  const SizedBox(width: 5),
                                  Text(
                                    rec.statusLabel,
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: badgeFg,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGaugeSection(ChildAttendanceSummary att) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 90,
          height: 90,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: att.percentage / 100,
                strokeWidth: 8,
                backgroundColor: ParentDesignTokens.borderSubtle,
                valueColor: const AlwaysStoppedAnimation<Color>(ParentDesignTokens.emerald),
                strokeCap: StrokeCap.round,
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${att.percentage}%',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: ParentDesignTokens.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Overall',
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: ParentDesignTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  '${att.percentage}%',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: ParentDesignTokens.emerald,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8),
                ParentBadge.success(label: 'Excellent Status'),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Requirement: Minimum 75% required for CBSE exams',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: ParentDesignTokens.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBreakdownGrid(ChildAttendanceSummary att) {
    return Row(
      children: [
        Expanded(
          child: _buildMiniStat(
            label: 'Present Days',
            value: '${att.presentDays}',
            subtext: 'Days Attended',
            color: ParentDesignTokens.emerald,
            bg: ParentDesignTokens.emeraldLight,
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniStat(
            label: 'Absent',
            value: '${att.absentDays}',
            subtext: 'Unexcused',
            color: ParentDesignTokens.rose,
            bg: ParentDesignTokens.roseLight,
            icon: Icons.cancel_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniStat(
            label: 'Late Entries',
            value: '${att.lateDays}',
            subtext: 'Delayed scans',
            color: ParentDesignTokens.warmAccentDark,
            bg: ParentDesignTokens.warmAccentLight,
            icon: Icons.schedule_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMiniStat(
            label: 'Sanctioned',
            value: '${att.leaveDays}',
            subtext: 'Approved Leave',
            color: ParentDesignTokens.purple,
            bg: ParentDesignTokens.purpleLight,
            icon: Icons.event_busy_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required String subtext,
    required Color color,
    required Color bg,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Icon(icon, size: 14, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: ParentDesignTokens.textPrimary,
            ),
          ),
          Text(
            subtext,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              color: ParentDesignTokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(ChildAttendanceSummary att) {
    const daysOfWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return ParentCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'September 2026 Calendar',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: ParentDesignTokens.textPrimary,
                ),
              ),
              // Legend
              Wrap(
                spacing: 10,
                children: [
                  _buildLegendItem('Present', ParentDesignTokens.emerald),
                  _buildLegendItem('Absent', ParentDesignTokens.rose),
                  _buildLegendItem('Late', ParentDesignTokens.warmAccentDark),
                  _buildLegendItem('Leave', ParentDesignTokens.purple),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Day headers (Mon - Sun)
          Row(
            children: daysOfWeek.map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: ParentDesignTokens.textMuted,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Calendar Days Grid (padded for starting Tuesday)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 30 + 1, // 1 offset for starting Tuesday
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              if (index == 0) {
                return const SizedBox(); // Empty space for Monday
              }
              final dayNum = index;
              final rec = att.dailyRecords.firstWhere(
                (r) => r.date.day == dayNum,
                orElse: () => ChildAttendanceDay(date: DateTime(2026, 9, dayNum), status: AttendanceStatus.present),
              );

              Color bg;
              Color fg;
              if (rec.status == AttendanceStatus.present) {
                bg = ParentDesignTokens.emeraldLight;
                fg = ParentDesignTokens.emerald;
              } else if (rec.status == AttendanceStatus.absent) {
                bg = ParentDesignTokens.roseLight;
                fg = ParentDesignTokens.rose;
              } else if (rec.status == AttendanceStatus.late) {
                bg = ParentDesignTokens.warmAccentLight;
                fg = ParentDesignTokens.warmAccentDark;
              } else {
                bg = ParentDesignTokens.purpleLight;
                fg = ParentDesignTokens.purple;
              }

              return Tooltip(
                message: '$dayNum Sep 2026: ${rec.statusLabel}',
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: fg.withValues(alpha: 0.25)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$dayNum',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: fg,
                          ),
                        ),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: ParentDesignTokens.textSecondary),
        ),
      ],
    );
  }

  Widget _buildTrendChartCard(ChildAttendanceSummary att) {
    final weeklyRates = [94.0, 96.0, 92.0, 98.0];

    return ParentCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Attendance Trend',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: ParentDesignTokens.textPrimary,
                ),
              ),
              ParentBadge.success(label: '+2.4% vs Aug'),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Week-by-week attendance progression',
            style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textSecondary),
          ),
          const SizedBox(height: 24),

          // Bar/Line Representation
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (i) {
                final rate = weeklyRates[i];
                final heightFraction = (rate - 80) / 20;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${rate.toInt()}%',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ParentDesignTokens.brand,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: heightFraction),
                      duration: Duration(milliseconds: 500 + (i * 100)),
                      curve: Curves.easeOutCubic,
                      builder: (context, val, _) {
                        return Container(
                          width: 32,
                          height: (val * 100).clamp(10, 100),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [ParentDesignTokens.brandLight, ParentDesignTokens.brand],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'W${i + 1}',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: ParentDesignTokens.textMuted,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ParentDesignTokens.brandTint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.insights_rounded, size: 14, color: ParentDesignTokens.brand),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Peak consistency observed in Week 4 with 98% attendance.',
                    style: GoogleFonts.inter(fontSize: 11.5, color: ParentDesignTokens.brand),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
