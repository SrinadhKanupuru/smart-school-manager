import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../data/principal_mock_data.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/custom_modal.dart';

class PrincipalNoticesScreen extends StatefulWidget {
  const PrincipalNoticesScreen({super.key});

  @override
  State<PrincipalNoticesScreen> createState() => _PrincipalNoticesScreenState();
}

class _PrincipalNoticesScreenState extends State<PrincipalNoticesScreen> {
  @override
  Widget build(BuildContext context) {
    final notices = PrincipalMockData.principalNotices;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          PageHeader(
            title: 'School Circulars & Official Notices',
            subtitle: 'Broadcast official directives, exam protocols, and campus notifications from Principal desk',
            trailing: ElevatedButton.icon(
              onPressed: () => CustomModals.showSendNoticeDialog(context),
              icon: const Icon(Icons.campaign_rounded, size: 18),
              label: const Text('Issue New Notice'),
            ),
          ),

          // Notices List Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppDecorations.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Active Circulars (${notices.length})', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                    Text('Academic Year 2026–27', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 18),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: notices.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final notice = notices[index];
                    final isHigh = notice['priority'] == 'High';

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isHigh ? AppColors.dangerLight : const Color(0xFFF5F3FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.campaign_rounded,
                                  color: isHigh ? AppColors.danger : const Color(0xFF8B5CF6),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(notice['title'], style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 2),
                                    Text('Target Audience: ${notice['audience']} • Date: ${notice['date']}', style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isHigh ? AppColors.dangerLight : AppColors.successLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  notice['priority'] == 'High' ? 'High Priority' : 'Normal',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isHigh ? AppColors.danger : AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(notice['content'], style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textPrimary, height: 1.35)),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
