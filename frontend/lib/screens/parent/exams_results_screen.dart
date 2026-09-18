import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../widgets/parent/parent_ui_components.dart';
import 'parent_data_provider.dart';
import '../../models/parent_portal_models.dart';

class ParentExamsResultsScreen extends StatefulWidget {
  const ParentExamsResultsScreen({super.key});

  @override
  State<ParentExamsResultsScreen> createState() => _ParentExamsResultsScreenState();
}

class _ParentExamsResultsScreenState extends State<ParentExamsResultsScreen> {
  int _selectedTab = 0; // 0 = Results & Performance, 1 = Upcoming Exam Schedule

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<ParentDataProvider>(context);
    final child = data.selectedChild;
    final exams = data.currentUpcomingExams;
    final results = data.currentResults;
    final isDesktop = MediaQuery.of(context).size.width >= 960;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
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
                        'Exams & Academic Results',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: ParentDesignTokens.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Schedules, performance analytics and verified term scorecards for ${child.name}',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: ParentDesignTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ParentButton(
                  label: 'Download Report Card',
                  icon: Icons.picture_as_pdf_rounded,
                  variant: ParentButtonVariant.primary,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.download_done_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              'Downloading Term 1 Official Scorecard PDF for ${child.name}...',
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        backgroundColor: ParentDesignTokens.brand,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Academic Performance Hero Card (Average Score 87% + Chart)
          ParentAnimatedEntrance(
            index: 1,
            child: ParentCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ParentDesignTokens.brandTint,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.emoji_events_rounded, color: ParentDesignTokens.brand, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overall Academic Performance',
                                style: GoogleFonts.inter(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: ParentDesignTokens.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Term 1 Cumulative Score Across All Disciplines',
                                style: GoogleFonts.inter(fontSize: 12.5, color: ParentDesignTokens.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${child.academicAverage}%',
                                style: GoogleFonts.inter(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: ParentDesignTokens.brand,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ParentBadge.success(label: 'Grade A+'),
                            ],
                          ),
                          Text(
                            'Class Rank: #3 in ${child.grade}-${child.section}',
                            style: GoogleFonts.inter(fontSize: 11.5, color: ParentDesignTokens.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(height: 1, color: ParentDesignTokens.borderSubtle),
                  const SizedBox(height: 20),

                  // Subject Performance Chart
                  Text(
                    'Subject-Wise Marks Breakdown',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ParentDesignTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSubjectPerformanceBars(results),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Custom Navigation Segment
          ParentAnimatedEntrance(
            index: 2,
            child: Container(
              decoration: BoxDecoration(
                color: ParentDesignTokens.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ParentDesignTokens.border),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSegmentButton(
                      label: 'Verified Assessment Results (${results.length})',
                      icon: Icons.stars_rounded,
                      isSelected: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                  ),
                  Expanded(
                    child: _buildSegmentButton(
                      label: 'Upcoming Exam Schedule (${exams.length})',
                      icon: Icons.calendar_month_rounded,
                      isSelected: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Tab Content
          if (_selectedTab == 0)
            _buildResultsSection(results)
          else
            _buildUpcomingExamsSection(exams),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected ? ParentDesignTokens.shadowSm : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? ParentDesignTokens.brand : ParentDesignTokens.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? ParentDesignTokens.brand : ParentDesignTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectPerformanceBars(List<ChildResult> results) {
    return Column(
      children: results.map((res) {
        final percent = res.marksObtained / res.totalMarks;
        Color barColor;
        if (percent >= 0.85) {
          barColor = ParentDesignTokens.emerald;
        } else if (percent >= 0.70) {
          barColor = ParentDesignTokens.brand;
        } else {
          barColor = ParentDesignTokens.warmAccentDark;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        res.subject,
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: ParentDesignTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ParentBadge.neutral(label: 'Grade ${res.grade}'),
                    ],
                  ),
                  Text(
                    '${res.marksObtained} / ${res.totalMarks}  (${(percent * 100).toStringAsFixed(0)}%)',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: ParentDesignTokens.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 9,
                  backgroundColor: ParentDesignTokens.surfaceMuted,
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultsSection(List<ChildResult> results) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final res = results[index];
        final percent = (res.marksObtained / res.totalMarks) * 100;

        return ParentCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: ParentDesignTokens.brandTint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Center(
                  child: Text(
                    res.grade,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: ParentDesignTokens.brand,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          res.subject,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: ParentDesignTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ParentBadge.info(label: res.examName),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Teacher Remark: "${res.remarks}"',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: ParentDesignTokens.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${res.marksObtained} / ${res.totalMarks}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: ParentDesignTokens.textPrimary,
                    ),
                  ),
                  Text(
                    '${percent.toStringAsFixed(1)}%',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: ParentDesignTokens.emerald,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpcomingExamsSection(List<ChildExam> exams) {
    if (exams.isEmpty) {
      return const ParentEmptyState(
        icon: Icons.event_available_rounded,
        title: 'No upcoming exams',
        description: 'There are no active exam schedules for the current academic session.',
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exams.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final ex = exams[index];

        return ParentCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ParentDesignTokens.brandTint,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          ex.examName,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: ParentDesignTokens.brand,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ParentBadge.warning(label: 'Max Marks: ${ex.totalMarks}'),
                    ],
                  ),
                  Text(
                    '${ex.date.day} September 2026',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: ParentDesignTokens.warmAccentDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ex.subject,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: ParentDesignTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded, size: 14, color: ParentDesignTokens.textMuted),
                  const SizedBox(width: 4),
                  Text(ex.time, style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textSecondary)),
                  const SizedBox(width: 14),
                  const Icon(Icons.room_outlined, size: 14, color: ParentDesignTokens.textMuted),
                  const SizedBox(width: 4),
                  Text(ex.room, style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textSecondary)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ParentDesignTokens.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ParentDesignTokens.border),
                ),
                child: Text(
                  'Syllabus Coverage: ${ex.syllabus}',
                  style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textSecondary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
