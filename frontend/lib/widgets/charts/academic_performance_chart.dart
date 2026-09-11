import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../data/principal_mock_data.dart';

class AcademicPerformanceCard extends StatelessWidget {
  const AcademicPerformanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final classes = PrincipalMockData.classPerformance;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Academic Performance Overview',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Term-wise average GPA & pass rate across all secondary grades',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFDDD6FE)),
                ),
                child: Text(
                  'Academic Year 2026–27',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7C3AED),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4 Key Insight Badges
          Row(
            children: [
              _buildInsightBox('Average Performance', '84.6%', 'School-wide average', const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
              const SizedBox(width: 12),
              _buildInsightBox('Top Class', 'Grade 10-A (89.8%)', 'Highest GPA index', const Color(0xFF10B981), const Color(0xFFECFDF5)),
              const SizedBox(width: 12),
              _buildInsightBox('Need Remedial', '14 Students', '< 60% mark threshold', const Color(0xFFEF4444), const Color(0xFFFEF2F2)),
              const SizedBox(width: 12),
              _buildInsightBox('Upcoming Exam', 'Mid-Term (Sep 15)', 'Starts in 4 days', const Color(0xFF8B5CF6), const Color(0xFFF5F3FF)),
            ],
          ),
          const SizedBox(height: 24),

          // Bar Chart for Class-wise Scores
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                minY: 50,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.textPrimary,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final item = classes[group.x.toInt()];
                      return BarTooltipItem(
                        '${item['class']}\n',
                        GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                        children: [
                          TextSpan(
                            text: 'Avg Score: ${item['avgScore']}%\nPass Rate: ${item['passRate']}%',
                            style: GoogleFonts.inter(color: const Color(0xFFBFDBFE), fontSize: 10.5),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 10,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}%',
                        style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < classes.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              classes[idx]['class'],
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.borderSubtle, strokeWidth: 1, dashArray: [4, 4]),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(classes.length, (i) {
                  final c = classes[i];
                  final double score = (c['avgScore'] as num).toDouble();
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: score,
                        color: c['color'] as Color,
                        width: 22,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightBox(String label, String value, String sub, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(sub, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
