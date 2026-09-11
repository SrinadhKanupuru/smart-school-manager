import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../data/mock_data.dart';
import '../../app/navigation_provider.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/charts/attendance_line_chart.dart';
import '../../widgets/charts/fee_donut_chart.dart';
import '../../widgets/cards/event_card.dart';
import '../../widgets/common/quick_action_card.dart';
import '../../widgets/timeline/activity_timeline.dart';
import '../../widgets/common/custom_modal.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationProvider>(context, listen: false);
    final kpis = MockData.getDashboardKpis();
    final String currentDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Dashboard Header & Hero Banner
          _buildHeroHeader(context, currentDate),
          const SizedBox(height: 24),

          // 2. 5 KPI Cards in Row (Responsive Wrap / LayoutBuilder)
          LayoutBuilder(
            builder: (context, constraints) {
              // If width is desktop (> 1100), 5 columns
              if (constraints.maxWidth > 1100) {
                return Row(
                  children: kpis.map((kpi) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: kpi == kpis.last ? 0 : 14,
                        ),
                        child: StatCard(data: kpi),
                      ),
                    );
                  }).toList(),
                );
              } else if (constraints.maxWidth > 700) {
                // 3 or 2 per row
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: kpis.map((kpi) {
                    return SizedBox(
                      width: (constraints.maxWidth - 28) / 3,
                      child: StatCard(data: kpi),
                    );
                  }).toList(),
                );
              } else {
                // Mobile stacked
                return Column(
                  children: kpis.map((kpi) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: StatCard(data: kpi),
                    );
                  }).toList(),
                );
              }
            },
          ),
          const SizedBox(height: 24),

          // 3. Analytics Section: Attendance Line Chart (Left 65%) + Fee Donut Chart (Right 35%)
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 920) {
                return const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 62,
                      child: AttendanceLineChartCard(),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 38,
                      child: FeeDonutChartCard(),
                    ),
                  ],
                );
              } else {
                return const Column(
                  children: [
                    AttendanceLineChartCard(),
                    SizedBox(height: 20),
                    FeeDonutChartCard(),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24),

          // 4. Quick Actions Section
          _buildQuickActions(context, nav),
          const SizedBox(height: 24),

          // 5. Bottom Section: Upcoming Events (Left) + Recent Activity (Right)
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

  Widget _buildHeroHeader(BuildContext context, String currentDate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E3A8A), // Deep Royal Navy
            Color(0xFF1E40AF), // Professional Blue
            Color(0xFF2563EB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E40AF).withValues(alpha: 0.25),
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
              // Left Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date & Status Pill
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                currentDate,
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
                            'Academic Year 2026–27',
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
                      'Good Morning, Srinadh! 👋',
                      style: GoogleFonts.inter(
                        fontSize: isWide ? 26 : 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Here's what's happening at your school today.",
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: const Color(0xFFBFDBFE),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Inspirational Quote
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.format_quote_rounded, color: Color(0xFFFDE047), size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '"Education is not preparation for life; education is life itself." ',
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white.withValues(alpha: 0.95),
                                    ),
                                  ),
                                  TextSpan(
                                    text: '— John Dewey',
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFFDE047),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Right Graphic / Campus Visual
              if (isWide) ...[
                const SizedBox(width: 20),
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                  ),
                  child: Center(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.account_balance_rounded,
                          size: 56,
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

  Widget _buildQuickActions(BuildContext context, NavigationProvider nav) {
    final actions = [
      QuickActionItem(
        label: 'Add Student',
        icon: Icons.person_add_alt_1_rounded,
        color: const Color(0xFF2563EB),
        bgColor: const Color(0xFFEFF6FF),
        onTap: () => CustomModals.showAddStudentDialog(context),
      ),
      QuickActionItem(
        label: 'Mark Attendance',
        icon: Icons.fact_check_rounded,
        color: const Color(0xFF10B981),
        bgColor: const Color(0xFFECFDF5),
        onTap: () => nav.setModule(AppModule.attendance),
      ),
      QuickActionItem(
        label: 'Send Notice',
        icon: Icons.campaign_rounded,
        color: const Color(0xFF8B5CF6),
        bgColor: const Color(0xFFF5F3FF),
        onTap: () => CustomModals.showSendNoticeDialog(context),
      ),
      QuickActionItem(
        label: 'Generate Report',
        icon: Icons.analytics_rounded,
        color: const Color(0xFF0EA5E9),
        bgColor: const Color(0xFFF0F9FF),
        onTap: () => CustomModals.showGenerateReportDialog(context),
      ),
      QuickActionItem(
        label: 'Manage Fees',
        icon: Icons.payments_rounded,
        color: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFFFBEB),
        onTap: () => CustomModals.showCollectFeeDialog(context),
      ),
      QuickActionItem(
        label: 'Add Teacher',
        icon: Icons.school_rounded,
        color: const Color(0xFFEC4899),
        bgColor: const Color(0xFFFDF2F8),
        onTap: () => CustomModals.showAddTeacherDialog(context),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
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
