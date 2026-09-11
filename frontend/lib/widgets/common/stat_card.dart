import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../models/kpi_card_data.dart';
import '../charts/sparkline_mini_chart.dart';

class StatCard extends StatefulWidget {
  final KpiCardData data;

  const StatCard({
    super.key,
    required this.data,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final isPositive = d.isPositive;
    final trendColor = isPositive ? AppColors.success : AppColors.danger;
    final trendBg = isPositive ? AppColors.successLight : AppColors.dangerLight;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: _isHovered
            ? (Matrix4.identity()..translate(0, -3, 0))
            : Matrix4.identity(),
        padding: const EdgeInsets.all(18),
        decoration: AppDecorations.cardDecoration(
          hasHover: _isHovered,
          border: Border.all(
            color: _isHovered
                ? d.iconColor.withValues(alpha: 0.3)
                : AppColors.border,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Title + Icon Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    d.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: d.iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    d.icon,
                    size: 18,
                    color: d.iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Middle: Large Value Number
            Text(
              d.value,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Bottom Row: Trend Pill + Comparison Text + Mini Sparkline
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: trendBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        size: 12,
                        color: trendColor,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        d.changePercentage,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: trendColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    d.comparisonPeriod,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                SparklineMiniChart(
                  data: d.sparklineData,
                  lineColor: d.iconColor,
                  height: 26,
                  width: 54,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
