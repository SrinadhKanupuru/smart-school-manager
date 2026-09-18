import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';

class FacultyTimetableScreen extends StatelessWidget {
  const FacultyTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

    final Map<String, List<Map<String, String>>> schedule = {
      'Monday': [
        {'time': '09:00 - 09:45', 'subject': 'Physics', 'class': 'Grade 9-A', 'room': 'Room 204'},
        {'time': '09:50 - 10:35', 'subject': 'Physics', 'class': 'Grade 10-B', 'room': 'Room 302'},
        {'time': '11:00 - 11:45', 'subject': 'Gen Science', 'class': 'Grade 8-C', 'room': 'Room 108'},
        {'time': '11:50 - 12:35', 'subject': 'Physics Lab', 'class': 'Grade 9-A', 'room': 'Lab 1'},
      ],
      'Tuesday': [
        {'time': '09:00 - 09:45', 'subject': 'Physics', 'class': 'Grade 10-B', 'room': 'Room 302'},
        {'time': '10:00 - 10:45', 'subject': 'Gen Science', 'class': 'Grade 8-C', 'room': 'Room 108'},
        {'time': '11:50 - 12:35', 'subject': 'Doubt Session', 'class': 'Grade 9-A', 'room': 'Room 204'},
      ],
      'Wednesday': [
        {'time': '09:00 - 09:45', 'subject': 'Physics', 'class': 'Grade 9-A', 'room': 'Room 204'},
        {'time': '10:00 - 10:45', 'subject': 'Physics', 'class': 'Grade 10-B', 'room': 'Room 302'},
        {'time': '11:50 - 12:35', 'subject': 'Lab Practicals', 'class': 'Grade 10-B', 'room': 'Lab 2'},
      ],
      'Thursday': [
        {'time': '09:00 - 09:45', 'subject': 'Gen Science', 'class': 'Grade 8-C', 'room': 'Room 108'},
        {'time': '09:50 - 10:35', 'subject': 'Physics', 'class': 'Grade 9-A', 'room': 'Room 204'},
        {'time': '11:00 - 11:45', 'subject': 'Physics', 'class': 'Grade 10-B', 'room': 'Room 302'},
      ],
      'Friday': [
        {'time': '09:00 - 09:45', 'subject': 'Physics', 'class': 'Grade 9-A', 'room': 'Room 204'},
        {'time': '09:50 - 10:35', 'subject': 'Physics', 'class': 'Grade 10-B', 'room': 'Room 302'},
        {'time': '11:00 - 11:45', 'subject': 'Weekly Quiz', 'class': 'Grade 9-A', 'room': 'Room 204'},
      ],
      'Saturday': [
        {'time': '09:00 - 10:00', 'subject': 'Faculty Academic Meeting', 'class': 'Staff', 'room': 'Conf Hall'},
        {'time': '10:15 - 11:15', 'subject': 'PTM / Student Counseling', 'class': 'All Grades', 'room': 'Faculty Desk'},
      ],
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Master Timetable',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Complete weekly period allocation and classroom lecture schedule.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWide ? 3 : 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 280,
                  ),
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    final day = days[index];
                    final periods = schedule[day] ?? [];

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppDecorations.cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTint,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              day,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: periods.length,
                              separatorBuilder: (_, __) => const Divider(height: 12, color: AppColors.border),
                              itemBuilder: (context, pIndex) {
                                final p = periods[pIndex];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          p['subject']!,
                                          style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          p['time']!,
                                          style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textMuted),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${p['class']} • ${p['room']}',
                                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
