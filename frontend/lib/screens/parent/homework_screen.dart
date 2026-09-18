import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../widgets/parent/parent_ui_components.dart';
import 'parent_data_provider.dart';
import '../../models/parent_portal_models.dart';

class ParentHomeworkScreen extends StatefulWidget {
  const ParentHomeworkScreen({super.key});

  @override
  State<ParentHomeworkScreen> createState() => _ParentHomeworkScreenState();
}

class _ParentHomeworkScreenState extends State<ParentHomeworkScreen> {
  String _statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<ParentDataProvider>(context);
    final child = data.selectedChild;
    final allHw = data.currentHomeworks;

    final filteredHw = allHw.where((h) {
      if (_statusFilter == 'Pending') return h.isPending;
      if (_statusFilter == 'Completed') return h.isCompleted;
      return true;
    }).toList();

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
                        'Homework & Daily Diary',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: ParentDesignTokens.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Daily tasks and subject exercises assigned to ${child.name} (${child.grade} - ${child.section})',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: ParentDesignTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Filter Segmented Pill
                Container(
                  decoration: BoxDecoration(
                    color: ParentDesignTokens.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ParentDesignTokens.border),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: ['All', 'Pending', 'Completed'].map((filter) {
                      final isSelected = _statusFilter == filter;
                      final count = filter == 'All'
                          ? allHw.length
                          : filter == 'Pending'
                              ? allHw.where((h) => h.isPending).length
                              : allHw.where((h) => h.isCompleted).length;

                      return InkWell(
                        onTap: () => setState(() => _statusFilter = filter),
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSelected ? ParentDesignTokens.shadowSm : null,
                          ),
                          child: Row(
                            children: [
                              Text(
                                filter,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? ParentDesignTokens.brand : ParentDesignTokens.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: isSelected ? ParentDesignTokens.brandTint : ParentDesignTokens.borderSubtle,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$count',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? ParentDesignTokens.brand : ParentDesignTokens.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Read-Only Monitoring Banner
          ParentAnimatedEntrance(
            index: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: ParentDesignTokens.brandTint,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: ParentDesignTokens.brand),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Parent Monitoring Access: Homework entries are published directly by faculty members. Parents can review instructions, track completion status, and inspect reference exercises.',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          // Homework Cards List
          if (filteredHw.isEmpty)
            ParentAnimatedEntrance(
              index: 2,
              child: ParentEmptyState(
                icon: Icons.check_circle_outline_rounded,
                title: 'No homework in this view',
                description: _statusFilter == 'Pending'
                    ? 'Great news! All assigned homework tasks for ${child.name} are completed.'
                    : 'No homework entries found matching your selected criteria.',
                iconColor: ParentDesignTokens.emerald,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredHw.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final hw = filteredHw[index];
                return ParentAnimatedEntrance(
                  index: index + 2,
                  child: _buildHomeworkCard(context, hw),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHomeworkCard(BuildContext context, ChildHomework hw) {
    final isCompleted = hw.isCompleted;

    return ParentCard(
      padding: const EdgeInsets.all(20),
      onTap: () => _showHomeworkDetailModal(context, hw),
      border: Border.all(
        color: isCompleted ? ParentDesignTokens.border : const Color(0xFFFDE68A),
        width: isCompleted ? 1 : 1.5,
      ),
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
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Text(
                      hw.subject,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: ParentDesignTokens.brand,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isCompleted)
                    ParentBadge.success(label: 'Completed')
                  else
                    ParentBadge.warning(label: 'Pending Submission', icon: Icons.schedule_rounded),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.event_rounded,
                    size: 14,
                    color: isCompleted ? ParentDesignTokens.textMuted : ParentDesignTokens.rose,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${hw.dueDate.day} Sep 2026',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isCompleted ? ParentDesignTokens.textSecondary : ParentDesignTokens.rose,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hw.title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: ParentDesignTokens.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hw.description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: ParentDesignTokens.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: ParentDesignTokens.borderSubtle),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 14, color: ParentDesignTokens.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    'Assigned by: ${hw.teacherName}',
                    style: GoogleFonts.inter(fontSize: 11.5, color: ParentDesignTokens.textSecondary),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'View Instructions',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: ParentDesignTokens.brand,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 14, color: ParentDesignTokens.brand),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHomeworkDetailModal(BuildContext context, ChildHomework hw) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: ParentDesignTokens.brandTint,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          hw.subject,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: ParentDesignTokens.brand,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded, size: 20),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hw.title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: ParentDesignTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      hw.isCompleted
                          ? ParentBadge.success(label: 'Status: Completed')
                          : ParentBadge.warning(label: 'Status: Pending Submission'),
                      const SizedBox(width: 12),
                      Text(
                        'Due Date: ${hw.dueDate.day} September 2026',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: ParentDesignTokens.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: ParentDesignTokens.border),
                  const SizedBox(height: 16),
                  Text(
                    'Detailed Instructions & Scope:',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: ParentDesignTokens.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hw.description,
                    style: GoogleFonts.inter(fontSize: 13, color: ParentDesignTokens.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ParentDesignTokens.surfaceMuted,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ParentDesignTokens.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Teacher Reference Notes:',
                          style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: ParentDesignTokens.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Students are required to write their workings in the primary subject notebook. Cross-checked with textbook exercises at the start of tomorrow\'s period.',
                          style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Faculty: ${hw.teacherName}',
                        style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textMuted),
                      ),
                      ParentButton(
                        label: 'Got It',
                        variant: ParentButtonVariant.primary,
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
