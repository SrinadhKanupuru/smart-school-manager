import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_provider.dart';
import '../../core/theme.dart';

class LeaveApprovalScreen extends StatefulWidget {
  const LeaveApprovalScreen({super.key});

  @override
  State<LeaveApprovalScreen> createState() => _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState extends State<LeaveApprovalScreen> {
  int _activeTab = 0; // 0 = Pending, 1 = Approved, 2 = Rejected

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchLeaves();
    });
  }

  void _updateStatus(String id, String status) async {
    final admin = Provider.of<AdminProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final success = await admin.updateLeaveStatus(id, status);

    if (mounted) {
      Navigator.pop(context); // Dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Leave request status updated!' : 'Failed to update leave request'),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);

    final pendingList = admin.leaves.where((l) => l['status'] == 'PENDING').toList();
    final approvedList = admin.leaves.where((l) => l['status'] == 'APPROVED').toList();
    final rejectedList = admin.leaves.where((l) => l['status'] == 'REJECTED').toList();

    final currentList = _activeTab == 0
        ? pendingList
        : (_activeTab == 1 ? approvedList : rejectedList);

    return Scaffold(
      appBar: AppBar(title: const Text('Leave Requests')),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Tab Indicator
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  _buildTabBtn(0, 'Pending (${pendingList.length})'),
                  _buildTabBtn(1, 'Approved (${approvedList.length})'),
                  _buildTabBtn(2, 'Rejected (${rejectedList.length})'),
                ],
              ),
            ),
            Expanded(
              child: currentList.isEmpty
                  ? Center(
                      child: Text('No leave applications in this section', style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: currentList.length,
                      itemBuilder: (context, index) {
                        final leave = currentList[index];
                        final isChildLeave = leave['student'] != null;
                        
                        final String name;
                        final String subtitle;
                        if (isChildLeave) {
                          name = leave['student']?['fullName'] ?? 'Student';
                          final cls = leave['student']?['classSection']?['class']?['name'] ?? '';
                          final sec = leave['student']?['classSection']?['name'] ?? '';
                          final roll = leave['student']?['rollNo'] ?? '';
                          subtitle = 'Student • Class $cls-$sec • Roll No: $roll';
                        } else {
                          final user = leave['user'] ?? {};
                          name = user['fullName'] ?? 'Staff';
                          subtitle = user['role'] ?? 'TEACHER';
                        }

                        final from = DateFormat('dd MMM').format(DateTime.parse(leave['fromDate']));
                        final to = DateFormat('dd MMM, yyyy').format(DateTime.parse(leave['toDate']));

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppTheme.primaryColor.withOpacity(0.08),
                                      child: Text(name.isNotEmpty ? name[0] : 'S', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                                          Text(subtitle, style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondaryColor)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        leave['leaveType'] ?? 'Leave',
                                        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Text(
                                  'Duration: $from - $to',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppTheme.textPrimaryColor),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Reason: ${leave['reason'] ?? ''}',
                                  style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondaryColor),
                                ),
                                if (leave['status'] == 'PENDING') ...[
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () => _updateStatus(leave['id'], 'REJECTED'),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Colors.redAccent),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        ),
                                        child: Text('Reject', style: GoogleFonts.outfit(color: Colors.redAccent)),
                                      ),
                                      const SizedBox(width: 12),
                                      ElevatedButton(
                                        onPressed: () => _updateStatus(leave['id'], 'APPROVED'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        ),
                                        child: const Text('Approve'),
                                      ),
                                    ],
                                  )
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBtn(int index, String label) {
    final isSelected = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
