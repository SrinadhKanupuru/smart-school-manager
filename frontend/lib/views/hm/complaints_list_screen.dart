import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/admin_provider.dart';
import '../../core/theme.dart';

class ComplaintsListScreen extends StatefulWidget {
  const ComplaintsListScreen({super.key});

  @override
  State<ComplaintsListScreen> createState() => _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends State<ComplaintsListScreen> {
  int _activeTab = 0; // 0 = All, 1 = Pending, 2 = Resolved

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchComplaints();
    });
  }

  void _resolve(AdminProvider admin, String id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final success = await admin.resolveComplaint(id);

    if (mounted) {
      Navigator.pop(context); // Dismiss loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Complaint resolved!' : 'Failed to update complaint status'),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);

    final pendingList = admin.complaints.where((c) => c['status'] == 'PENDING').toList();
    final resolvedList = admin.complaints.where((c) => c['status'] == 'RESOLVED').toList();

    final currentList = _activeTab == 0
        ? admin.complaints
        : (_activeTab == 1 ? pendingList : resolvedList);

    return Scaffold(
      appBar: AppBar(title: const Text('Complaints & Grievances')),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  _buildTabBtn(0, 'All (${admin.complaints.length})'),
                  _buildTabBtn(1, 'Pending (${pendingList.length})'),
                  _buildTabBtn(2, 'Resolved (${resolvedList.length})'),
                ],
              ),
            ),
            Expanded(
              child: currentList.isEmpty
                  ? Center(child: Text('No complaints registered.', style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: currentList.length,
                      itemBuilder: (context, index) {
                        final item = currentList[index];
                        final creator = item['creator'] ?? {};
                        final isResolved = item['status'] == 'RESOLVED';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppTheme.primaryColor.withOpacity(0.08),
                                      child: const Icon(Icons.report_problem, color: AppTheme.primaryColor),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            creator['fullName'] ?? 'Anonymous',
                                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          Text(
                                            'Role: ${creator['role'] ?? ''} • Cat: ${item['category'] ?? ''}',
                                            style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isResolved ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        item['status'] ?? 'PENDING',
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isResolved ? Colors.green : Colors.orange,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const Divider(height: 24),
                                Text(
                                  item['description'] ?? '',
                                  style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textPrimaryColor),
                                ),
                                if (!isResolved) ...[
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () => _resolve(admin, item['id']),
                                        icon: const Icon(Icons.check, size: 16),
                                        label: const Text('Mark Resolved'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
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
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/submit-complaint').then((_) {
            if (context.mounted) {
              Provider.of<AdminProvider>(context, listen: false).fetchComplaints();
            }
          });
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
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
