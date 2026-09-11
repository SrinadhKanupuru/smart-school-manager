import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../data/mock_data.dart';
import '../../models/leave_model.dart';
import '../../app/navigation_provider.dart';
import '../../widgets/common/section_header.dart';

class LeaveManagementScreen extends StatefulWidget {
  const LeaveManagementScreen({super.key});

  @override
  State<LeaveManagementScreen> createState() => _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends State<LeaveManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _statusFilter = 'All Status';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationProvider>(context);

    // Filter by role (Teacher vs Student) and status (Pending, Approved, Rejected)
    final targetRole = _tabController.index == 0 ? 'Teacher' : 'Student';
    final leaves = MockData.leaves.where((l) {
      final matchesRole = l.role == targetRole;
      final matchesStatus = _statusFilter == 'All Status' || l.status == _statusFilter;
      return matchesRole && matchesStatus;
    }).toList();

    final pendingCount = MockData.leaves.where((l) => l.role == targetRole && l.status == 'Pending').length;
    final approvedCount = MockData.leaves.where((l) => l.role == targetRole && l.status == 'Approved').length;
    final rejectedCount = MockData.leaves.where((l) => l.role == targetRole && l.status == 'Rejected').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const PageHeader(
            title: 'Leave Approvals & Sanctions',
            subtitle: 'Super Admin central portal for review, approval, and audit of staff and student leaves',
          ),

          // Role Tabs (Teacher Leaves / Student Leaves) + Status Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.cardDecoration(),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  width: 300,
                  height: 40,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    onTap: (_) => setState(() {}),
                    indicator: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                    tabs: const [
                      Tab(text: 'Faculty Leaves'),
                      Tab(text: 'Student Leaves'),
                    ],
                  ),
                ),

                // Status Filter Pills
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFilterChip('All Status', 'All Status'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Pending ($pendingCount)', 'Pending', color: AppColors.warning),
                    const SizedBox(width: 8),
                    _buildFilterChip('Approved ($approvedCount)', 'Approved', color: AppColors.success),
                    const SizedBox(width: 8),
                    _buildFilterChip('Rejected ($rejectedCount)', 'Rejected', color: AppColors.danger),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Leaves Table Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppDecorations.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$targetRole Leave Requests (${leaves.length})',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Showing ${leaves.length} records',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (leaves.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No leave applications found for the selected filter.',
                        style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppColors.surfaceMuted),
                      dataRowMaxHeight: 68,
                      columnSpacing: 22,
                      columns: [
                        DataColumn(label: Text('Applicant Name', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Dept / Class', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Leave Type', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Duration (From – To)', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Days', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Reason', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Status', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                        DataColumn(label: Text('Action / Decision', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      ],
                      rows: leaves.map((l) {
                        Color statusBg = AppColors.warningLight;
                        Color statusColor = AppColors.warning;
                        if (l.status == 'Approved') {
                          statusBg = AppColors.successLight;
                          statusColor = AppColors.success;
                        } else if (l.status == 'Rejected') {
                          statusBg = AppColors.dangerLight;
                          statusColor = AppColors.danger;
                        }

                        return DataRow(
                          cells: [
                            DataCell(
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l.applicantName, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                                  Text('Applied: ${l.appliedDate}', style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                            DataCell(Text(l.targetClassOrDept, style: GoogleFonts.inter(fontSize: 12))),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryTint,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(l.leaveType, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
                              ),
                            ),
                            DataCell(Text('${l.fromDate} – ${l.toDate}', style: GoogleFonts.inter(fontSize: 12))),
                            DataCell(Text('${l.days} Day${l.days > 1 ? 's' : ''}', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12))),
                            DataCell(
                              Container(
                                constraints: const BoxConstraints(maxWidth: 220),
                                child: Text(
                                  l.reason,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(l.status, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  if (l.status == 'Pending') ...[
                                    IconButton(
                                      icon: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
                                      tooltip: 'Approve Request',
                                      onPressed: () {
                                        nav.approveLeave(l.id, 'Approved by Super Admin.');
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(backgroundColor: AppColors.success, content: Text('Leave request approved for ${l.applicantName}')),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.cancel_rounded, color: AppColors.danger, size: 22),
                                      tooltip: 'Reject Request',
                                      onPressed: () {
                                        nav.rejectLeave(l.id, 'Rejected due to academic schedule.');
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(backgroundColor: AppColors.danger, content: Text('Leave request rejected for ${l.applicantName}')),
                                        );
                                      },
                                    ),
                                  ],
                                  IconButton(
                                    icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                                    tooltip: 'View Application Details',
                                    onPressed: () => _showLeaveDetail(context, l),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, {Color? color}) {
    final isSelected = _statusFilter == value;

    return InkWell(
      onTap: () => setState(() => _statusFilter = value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppColors.primary).withValues(alpha: 0.12)
              : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? (color ?? AppColors.primary) : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? (color ?? AppColors.primary) : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  void _showLeaveDetail(BuildContext context, LeaveApplication l) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Leave Application - ${l.applicantName}', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 17)),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Role / Department: ${l.role} • ${l.targetClassOrDept}', style: GoogleFonts.inter(fontSize: 13)),
              const SizedBox(height: 8),
              Text('Leave Type: ${l.leaveType}', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('Duration: ${l.fromDate} to ${l.toDate} (${l.days} days)', style: GoogleFonts.inter(fontSize: 12.5)),
              const SizedBox(height: 8),
              Text('Reason for Leave:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(8)),
                child: Text(l.reason, style: GoogleFonts.inter(fontSize: 12)),
              ),
              if (l.adminRemarks != null) ...[
                const SizedBox(height: 10),
                Text('Admin Remarks: ${l.adminRemarks}', style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.primary)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
