import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';

class FacultyExamsScreen extends StatelessWidget {
  final bool isResultsTab;

  const FacultyExamsScreen({super.key, this.isResultsTab = false});

  @override
  Widget build(BuildContext context) {
    final exams = [
      {
        'title': 'Mid-Term Examination 2026',
        'subject': 'Physics (Theory & Numerical)',
        'class': 'Grade 9-A',
        'date': '15 Sep 2026',
        'time': '09:30 AM – 12:30 PM (3 Hours)',
        'room': 'Hall 2',
        'maxMarks': 100,
        'status': 'Upcoming',
      },
      {
        'title': 'Mid-Term Examination 2026',
        'subject': 'Physics (Advanced Board Prep)',
        'class': 'Grade 10-B',
        'date': '17 Sep 2026',
        'time': '09:30 AM – 12:30 PM (3 Hours)',
        'room': 'Hall 3',
        'maxMarks': 100,
        'status': 'Upcoming',
      },
      {
        'title': 'Unit Test 2 (Optics & Sound)',
        'subject': 'General Science',
        'class': 'Grade 8-C',
        'date': '02 Sep 2026',
        'time': '10:00 AM – 11:30 AM',
        'room': 'Room 108',
        'maxMarks': 50,
        'status': 'Graded (Avg: 84.2%)',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isResultsTab ? 'Examination Results & Grade Book' : 'Examination Timetable & Duty Roster',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage subject exam schedules, invigilation duties, and student grading.',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Grade entry portal opened for Grade 9-A Physics.')),
                    );
                  },
                  icon: const Icon(Icons.grade_rounded, size: 16),
                  label: const Text('Enter Marks / Grades'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exams.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final e = exams[index];
                final isUpcoming = e['status'] == 'Upcoming';

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppDecorations.cardDecoration(),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isUpcoming ? AppColors.primaryTint : AppColors.successLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isUpcoming ? Icons.event_note_rounded : Icons.check_circle_rounded,
                          color: isUpcoming ? AppColors.primary : AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e['subject'] as String,
                              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${e['title']} • ${e['class']} • Max Marks: ${e['maxMarks']}',
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Date: ${e['date']} • Time: ${e['time']} • Venue: ${e['room']}',
                              style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isUpcoming ? const Color(0xFFEFF6FF) : AppColors.successLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          e['status'] as String,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: isUpcoming ? AppColors.primary : AppColors.success,
                          ),
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
    );
  }
}
