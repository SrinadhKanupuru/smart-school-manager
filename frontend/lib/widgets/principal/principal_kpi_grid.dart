import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';

class PrincipalKpiGrid extends StatelessWidget {
  const PrincipalKpiGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final kpis = [
      _PrincipalKpiData(
        title: 'Total Students',
        value: '1,248',
        subtext: 'Enrolled across Grades 1–12',
        badge: '+5.2% YoY',
        isPositive: true,
        icon: Icons.school_rounded,
        color: const Color(0xFF2563EB),
        bgColor: const Color(0xFFEFF6FF),
      ),
      _PrincipalKpiData(
        title: 'Students Present',
        value: '1,203',
        subtext: '96.4% attendance today',
        badge: 'High Turnout',
        isPositive: true,
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF10B981),
        bgColor: const Color(0xFFECFDF5),
      ),
      _PrincipalKpiData(
        title: 'Students Absent',
        value: '45',
        subtext: '3.6% absentees today',
        badge: 'SMS Dispatched',
        isPositive: false,
        icon: Icons.cancel_rounded,
        color: const Color(0xFFEF4444),
        bgColor: const Color(0xFFFEF2F2),
      ),
      _PrincipalKpiData(
        title: 'Total Teachers',
        value: '86',
        subtext: 'Active teaching faculty',
        badge: '100% Allocated',
        isPositive: true,
        icon: Icons.groups_rounded,
        color: const Color(0xFF8B5CF6),
        bgColor: const Color(0xFFF5F3FF),
      ),
      _PrincipalKpiData(
        title: 'Teachers Present',
        value: '82',
        subtext: '95.3% faculty on duty',
        badge: 'Classes Covered',
        isPositive: true,
        icon: Icons.fact_check_rounded,
        color: const Color(0xFF059669),
        bgColor: const Color(0xFFF0FDF4),
      ),
      _PrincipalKpiData(
        title: 'Teachers Absent',
        value: '4',
        subtext: 'Substitutes assigned',
        badge: 'Arranged',
        isPositive: false,
        icon: Icons.person_off_rounded,
        color: const Color(0xFFDC2626),
        bgColor: const Color(0xFFFEF2F2),
      ),
      _PrincipalKpiData(
        title: 'Teachers On Leave',
        value: '2',
        subtext: 'Sanctioned medical leaves',
        badge: 'Approved',
        isPositive: true,
        icon: Icons.event_busy_rounded,
        color: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFFFBEB),
      ),
      _PrincipalKpiData(
        title: 'Pending Leaves',
        value: '8',
        subtext: 'Requires Principal sanction',
        badge: 'Action Needed',
        isPositive: false,
        icon: Icons.pending_actions_rounded,
        color: const Color(0xFFD97706),
        bgColor: const Color(0xFFFEF3C7),
      ),
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
              child: _buildKpiCard(kpi),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildKpiCard(_PrincipalKpiData data) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Title + Icon Box
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data.title,
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
                decoration: BoxDecoration(
                  color: data.bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, size: 18, color: data.color),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Large Number
          Text(
            data.value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Subtext + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data.subtext,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: data.bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  data.badge,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: data.color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrincipalKpiData {
  final String title;
  final String value;
  final String subtext;
  final String badge;
  final bool isPositive;
  final IconData icon;
  final Color color;
  final Color bgColor;

  _PrincipalKpiData({
    required this.title,
    required this.value,
    required this.subtext,
    required this.badge,
    required this.isPositive,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}
