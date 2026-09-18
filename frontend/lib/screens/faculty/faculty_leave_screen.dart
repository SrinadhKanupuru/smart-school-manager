import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';

class FacultyLeaveScreen extends StatefulWidget {
  const FacultyLeaveScreen({super.key});

  @override
  State<FacultyLeaveScreen> createState() => _FacultyLeaveScreenState();
}

class _FacultyLeaveScreenState extends State<FacultyLeaveScreen> {
  final List<Map<String, dynamic>> _leaveHistory = [
    {
      'type': 'Casual Leave',
      'dates': '02 Sep 2026 (1 Day)',
      'reason': 'Family function / Sister wedding reception',
      'appliedOn': '28 Aug 2026',
      'status': 'Approved',
      'sanctionedBy': 'Dr. Evelyn Vance (Principal)',
    },
    {
      'type': 'Medical Leave',
      'dates': '14 Jul 2026 (2 Days)',
      'reason': 'Severe seasonal flu & medical rest',
      'appliedOn': '13 Jul 2026',
      'status': 'Approved',
      'sanctionedBy': 'Dr. Evelyn Vance (Principal)',
    },
  ];

  void _showApplyLeaveModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Apply for Leave', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: 'Casual Leave',
                decoration: const InputDecoration(labelText: 'Leave Type'),
                items: ['Casual Leave', 'Medical Leave', 'Earned Leave', 'Maternity Leave', 'Special Duty Leave']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (_) {},
              ),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(labelText: 'Dates (From - To)', hintText: 'e.g. 20 Sep 2026 - 21 Sep 2026'),
              ),
              const SizedBox(height: 12),
              const TextField(
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Reason for Leave', hintText: 'Provide brief explanation for Principal review'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Leave application submitted to Principal for sanction.')),
              );
            },
            child: const Text('Submit Application'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      'Faculty Leave Management',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Submit leave applications and review approval status from the Principal.',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _showApplyLeaveModal,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Apply for Leave'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Leave Balances Cards
            Row(
              children: [
                Expanded(child: _buildBalanceCard('Casual Leave', '11 / 12', 'Days Remaining', AppColors.primary)),
                const SizedBox(width: 14),
                Expanded(child: _buildBalanceCard('Medical Leave', '8 / 10', 'Days Remaining', const Color(0xFF10B981))),
                const SizedBox(width: 14),
                Expanded(child: _buildBalanceCard('Earned Leave', '15 / 15', 'Days Remaining', const Color(0xFF8B5CF6))),
              ],
            ),
            const SizedBox(height: 24),

            // Leave History Table
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppDecorations.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Leave Application History',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _leaveHistory.length,
                    separatorBuilder: (_, __) => const Divider(height: 16, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final item = _leaveHistory[index];
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTint,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.event_available_rounded, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item['type']} • ${item['dates']}',
                                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['reason'] as String,
                                  style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Applied on ${item['appliedOn']} • Sanctioned by ${item['sanctionedBy']}',
                                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['status'] as String,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String title, String value, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(sub, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
