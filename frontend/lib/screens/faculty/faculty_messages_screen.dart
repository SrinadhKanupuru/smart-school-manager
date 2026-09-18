import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class FacultyMessagesScreen extends StatelessWidget {
  const FacultyMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = [
      {
        'sender': 'Dr. Evelyn Vance (Principal)',
        'title': 'Faculty Academic Review & Mid-Term Exam Roster',
        'preview': 'Please ensure that all question papers for Mid-Term examinations are submitted to the exam cell by tomorrow 5:00 PM.',
        'time': 'Today, 10:15 AM',
        'unread': true,
      },
      {
        'sender': 'Department of Science (HOD)',
        'title': 'Senior Science Lab Equipment Maintenance',
        'preview': 'The Physics practical lab apparatus inspection is scheduled for Friday morning. Kindly verify all optic benches.',
        'time': 'Yesterday, 04:30 PM',
        'unread': false,
      },
      {
        'sender': 'Exam Controller Office',
        'title': 'Invigilation Duty Schedule Published',
        'preview': 'The master duty chart for Mid-Term Exams has been uploaded. Please verify your assigned examination halls.',
        'time': '12 Sep 2026',
        'unread': false,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Faculty Messages & Notices',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Official institutional correspondence, principal memos, and department communications.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final m = messages[index];
                final unread = m['unread'] as bool;

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: unread ? const Color(0xFFEFF6FF) : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: unread ? const Color(0xFF93C5FD) : AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: unread ? AppColors.primary : const Color(0xFFE2E8F0),
                        child: Icon(Icons.mail_outline_rounded, size: 18, color: unread ? Colors.white : AppColors.textSecondary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  m['sender'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  m['time'] as String,
                                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              m['title'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: unread ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              m['preview'] as String,
                              style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSecondary),
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
    );
  }
}
