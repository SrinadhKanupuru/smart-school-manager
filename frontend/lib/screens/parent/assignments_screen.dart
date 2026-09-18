import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../widgets/parent/parent_ui_components.dart';
import 'parent_data_provider.dart';
import '../../models/parent_portal_models.dart';

class ParentAssignmentsScreen extends StatefulWidget {
  const ParentAssignmentsScreen({super.key});

  @override
  State<ParentAssignmentsScreen> createState() => _ParentAssignmentsScreenState();
}

class _ParentAssignmentsScreenState extends State<ParentAssignmentsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<ParentDataProvider>(context);
    final child = data.selectedChild;
    final allAssignments = data.currentAssignments;

    final filtered = allAssignments.where((a) {
      if (_selectedFilter == 'Pending') return a.isPending;
      if (_selectedFilter == 'Submitted') return a.isSubmitted;
      if (_selectedFilter == 'Graded') return a.isGraded;
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
                        'Projects & Assignments',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: ParentDesignTokens.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Term projects, lab submissions and assessments for ${child.name} (${child.grade} - ${child.section})',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: ParentDesignTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Filter Segmented Buttons
                Container(
                  decoration: BoxDecoration(
                    color: ParentDesignTokens.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ParentDesignTokens.border),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: ['All', 'Pending', 'Submitted', 'Graded'].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      final count = filter == 'All'
                          ? allAssignments.length
                          : filter == 'Pending'
                              ? allAssignments.where((a) => a.isPending).length
                              : filter == 'Submitted'
                                  ? allAssignments.where((a) => a.isSubmitted).length
                                  : allAssignments.where((a) => a.isGraded).length;

                      return InkWell(
                        onTap: () => setState(() => _selectedFilter = filter),
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isSelected ? ParentDesignTokens.brandTint : ParentDesignTokens.borderSubtle,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$count',
                                  style: GoogleFonts.inter(
                                    fontSize: 9.5,
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

          const SizedBox(height: 24),

          // Assignments List
          if (filtered.isEmpty)
            ParentAnimatedEntrance(
              index: 1,
              child: ParentEmptyState(
                icon: Icons.assignment_turned_in_outlined,
                title: 'No assignments found',
                description: 'No projects or term assignments match your selected filter.',
                iconColor: ParentDesignTokens.brand,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final asg = filtered[index];
                return ParentAnimatedEntrance(
                  index: index + 1,
                  child: _buildAssignmentCard(context, asg),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(BuildContext context, ChildAssignment asg) {
    double progressPercent;
    Color progressColor;
    if (asg.isGraded) {
      progressPercent = 1.0;
      progressColor = ParentDesignTokens.emerald;
    } else if (asg.isSubmitted) {
      progressPercent = 0.8;
      progressColor = ParentDesignTokens.brand;
    } else {
      progressPercent = 0.3;
      progressColor = ParentDesignTokens.warmAccentDark;
    }

    return ParentCard(
      padding: const EdgeInsets.all(22),
      onTap: () => _showAssignmentDetailsDialog(context, asg),
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
                      asg.subject,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: ParentDesignTokens.brand,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (asg.isGraded)
                    ParentBadge.success(label: 'Graded', icon: Icons.stars_rounded)
                  else if (asg.isSubmitted)
                    ParentBadge.info(label: 'Submitted for Review', icon: Icons.task_alt_rounded)
                  else
                    ParentBadge.danger(label: 'Pending Submission', icon: Icons.hourglass_top_rounded),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: 14,
                    color: asg.isPending ? ParentDesignTokens.rose : ParentDesignTokens.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${asg.dueDate.day} Sep 2026',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: asg.isPending ? ParentDesignTokens.rose : ParentDesignTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            asg.title,
            style: GoogleFonts.inter(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: ParentDesignTokens.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            asg.description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: ParentDesignTokens.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Visual Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Submission Progress',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: ParentDesignTokens.textSecondary,
                    ),
                  ),
                  Text(
                    '${(progressPercent * 100).toInt()}% • ${asg.submissionStatus}',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: progressColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progressPercent,
                  minHeight: 8,
                  backgroundColor: ParentDesignTokens.surfaceMuted,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
            ],
          ),

          // Graded Score and Teacher Remarks
          if (asg.isGraded && asg.marksObtained != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ParentDesignTokens.emeraldLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ParentDesignTokens.emeraldBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: ParentDesignTokens.emerald,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Score: ${asg.marksObtained} / ${asg.maxMarks}',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Teacher Evaluation: "${asg.feedback ?? 'Excellent submission and rigorous research.'}"',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: ParentDesignTokens.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1, color: ParentDesignTokens.borderSubtle),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Faculty Reviewer: ${asg.teacherName}',
                style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textMuted),
              ),
              Text(
                'Assigned: ${asg.assignedDate.day} Sep 2026',
                style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAssignmentDetailsDialog(BuildContext context, ChildAssignment asg) {
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
                          asg.subject,
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
                    asg.title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: ParentDesignTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      asg.isGraded
                          ? ParentBadge.success(label: 'Score: ${asg.marksObtained}/${asg.maxMarks}')
                          : asg.isSubmitted
                              ? ParentBadge.info(label: 'Status: Submitted')
                              : ParentBadge.danger(label: 'Status: Pending Submission'),
                      const SizedBox(width: 12),
                      Text(
                        'Due: ${asg.dueDate.day} Sep 2026',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: ParentDesignTokens.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: ParentDesignTokens.border),
                  const SizedBox(height: 14),
                  Text(
                    'Rubrics & Assessment Details:',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: ParentDesignTokens.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    asg.description,
                    style: GoogleFonts.inter(fontSize: 13, color: ParentDesignTokens.textSecondary, height: 1.5),
                  ),
                  if (asg.feedback != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ParentDesignTokens.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: ParentDesignTokens.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Teacher Notes:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: ParentDesignTokens.textPrimary)),
                          const SizedBox(height: 4),
                          Text(asg.feedback!, style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Faculty: ${asg.teacherName}', style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textMuted)),
                      ParentButton(
                        label: 'Close',
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
