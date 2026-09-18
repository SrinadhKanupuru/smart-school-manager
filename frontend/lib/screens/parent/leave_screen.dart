import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../widgets/parent/parent_ui_components.dart';
import 'parent_data_provider.dart';
import '../../models/parent_portal_models.dart';

class ParentLeaveScreen extends StatelessWidget {
  const ParentLeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<ParentDataProvider>(context);
    final child = data.selectedChild;
    final leaves = data.leaves;

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
                        'Student Leave Applications',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: ParentDesignTokens.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Submit absence notices and track sanction approvals for ${child.name} (${child.grade} - ${child.section})',
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
                  label: '+ Apply Leave',
                  icon: Icons.add_circle_outline_rounded,
                  variant: ParentButtonVariant.primary,
                  onPressed: () => _showApplyLeaveModal(context, data, child),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Policy Banner
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
                  const Icon(Icons.verified_user_outlined, size: 18, color: ParentDesignTokens.brand),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Institutional Leave Protocol: Applications submitted by parents are routed directly to ${child.classTeacher} (Class Teacher) and the Vice Principal. Approvals reflect automatically on attendance registers.',
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

          const SizedBox(height: 24),

          // Leave History Card Table
          ParentAnimatedEntrance(
            index: 2,
            child: ParentCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Leave Application History (${leaves.length})',
                          style: GoogleFonts.inter(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: ParentDesignTokens.textPrimary,
                          ),
                        ),
                        Text(
                          'AY 2026-2027 Records',
                          style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: ParentDesignTokens.border),
                  if (leaves.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text('No leave applications recorded for this academic year.'),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: leaves.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: ParentDesignTokens.borderSubtle),
                      itemBuilder: (context, index) {
                        final lv = leaves[index];
                        return _buildLeaveRow(lv);
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveRow(ParentLeaveItem lv) {
    Widget statusBadge;
    if (lv.status == 'Approved') {
      statusBadge = ParentBadge.success(label: 'Approved');
    } else if (lv.status == 'Rejected') {
      statusBadge = ParentBadge.danger(label: 'Rejected');
    } else {
      statusBadge = ParentBadge.warning(label: 'Pending Review');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
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
                    ),
                    child: Text(
                      lv.leaveType,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: ParentDesignTokens.brand,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${lv.daysCount} Day${lv.daysCount > 1 ? 's' : ''} • (${lv.startDate.day} Sep – ${lv.endDate.day} Sep 2026)',
                    style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700, color: ParentDesignTokens.textPrimary),
                  ),
                ],
              ),
              statusBadge,
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Reason: "${lv.reason}"',
            style: GoogleFonts.inter(fontSize: 13, color: ParentDesignTokens.textSecondary),
          ),
          if (lv.approverRemarks != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ParentDesignTokens.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ParentDesignTokens.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings_outlined, size: 16, color: ParentDesignTokens.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Staff Remark: ${lv.approverRemarks}',
                      style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showApplyLeaveModal(
    BuildContext context,
    ParentDataProvider data,
    ChildStudent child,
  ) {
    String selectedType = 'Sick Leave';
    final reasonController = TextEditingController();
    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    DateTime endDate = DateTime.now().add(const Duration(days: 1));
    bool isSubmitted = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.all(26),
                  child: isSubmitted
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: ParentDesignTokens.emeraldLight,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check_circle_rounded, size: 48, color: ParentDesignTokens.emerald),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Leave Request Submitted!',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: ParentDesignTokens.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Your leave application for ${child.name} has been forwarded to ${child.classTeacher} for approval.',
                              style: GoogleFonts.inter(fontSize: 13, color: ParentDesignTokens.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ParentButton(
                              label: 'Done',
                              variant: ParentButtonVariant.primary,
                              onPressed: () => Navigator.of(ctx).pop(),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: ParentDesignTokens.brandTint,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.event_note_rounded, color: ParentDesignTokens.brand, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Apply Student Leave',
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: ParentDesignTokens.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  icon: const Icon(Icons.close_rounded, size: 20),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text('Applying for: ${child.name} (${child.grade} - Section ${child.section})',
                                style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: ParentDesignTokens.textSecondary)),
                            const SizedBox(height: 16),
                            // Leave Type dropdown
                            Text('Leave Category', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: ParentDesignTokens.textPrimary)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: selectedType,
                              decoration: InputDecoration(
                                fillColor: ParentDesignTokens.surfaceMuted,
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: ParentDesignTokens.border)),
                              ),
                              items: ['Sick Leave', 'Family Event', 'Medical Consultation', 'Personal Emergency']
                                  .map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.inter(fontSize: 13))))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setModalState(() => selectedType = val);
                              },
                            ),
                            const SizedBox(height: 16),
                            // Date pickers row
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('From Date', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: ParentDesignTokens.textPrimary)),
                                      const SizedBox(height: 6),
                                      InkWell(
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: startDate,
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime.now().add(const Duration(days: 60)),
                                          );
                                          if (picked != null) {
                                            setModalState(() {
                                              startDate = picked;
                                              if (endDate.isBefore(startDate)) endDate = startDate;
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: ParentDesignTokens.surfaceMuted,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: ParentDesignTokens.border),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.calendar_today_rounded, size: 14, color: ParentDesignTokens.textMuted),
                                              const SizedBox(width: 8),
                                              Text('${startDate.day}/${startDate.month}/${startDate.year}', style: GoogleFonts.inter(fontSize: 12.5)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('To Date', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: ParentDesignTokens.textPrimary)),
                                      const SizedBox(height: 6),
                                      InkWell(
                                        onTap: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: endDate,
                                            firstDate: startDate,
                                            lastDate: DateTime.now().add(const Duration(days: 60)),
                                          );
                                          if (picked != null) {
                                            setModalState(() => endDate = picked);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: ParentDesignTokens.surfaceMuted,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: ParentDesignTokens.border),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.calendar_today_rounded, size: 14, color: ParentDesignTokens.textMuted),
                                              const SizedBox(width: 8),
                                              Text('${endDate.day}/${endDate.month}/${endDate.year}', style: GoogleFonts.inter(fontSize: 12.5)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text('Detailed Reason', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: ParentDesignTokens.textPrimary)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: reasonController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Please state the circumstances necessitating absence...',
                                hintStyle: GoogleFonts.inter(fontSize: 12.5, color: ParentDesignTokens.textMuted),
                                fillColor: ParentDesignTokens.surfaceMuted,
                                filled: true,
                                contentPadding: const EdgeInsets.all(12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: ParentDesignTokens.border)),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ParentButton(
                                  label: 'Cancel',
                                  variant: ParentButtonVariant.secondary,
                                  onPressed: () => Navigator.of(ctx).pop(),
                                ),
                                const SizedBox(width: 12),
                                ParentButton(
                                  label: 'Submit Application',
                                  variant: ParentButtonVariant.primary,
                                  onPressed: () {
                                    final reason = reasonController.text.trim();
                                    if (reason.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please enter a reason for the leave application.')),
                                      );
                                      return;
                                    }

                                    data.submitLeaveRequest(
                                      childId: child.id,
                                      childName: child.name,
                                      leaveType: selectedType,
                                      startDate: startDate,
                                      endDate: endDate,
                                      reason: reason,
                                    );

                                    setModalState(() => isSubmitted = true);
                                  },
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
      },
    );
  }
}
