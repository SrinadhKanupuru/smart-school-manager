import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../data/mock_data.dart';
import '../../data/principal_mock_data.dart';
import '../../models/principal_model.dart';
import '../../widgets/common/section_header.dart';
import '../../app/auth_role_provider.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  String _filterBranch = 'All Campuses';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthRoleProvider>(context, listen: false);
    final principals = MockData.principals.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.branch.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesBranch = _filterBranch == 'All Campuses' || p.branch.contains(_filterBranch);
      return matchesSearch && matchesBranch;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header with Add Principal Action & Launch Portal Button
          PageHeader(
            title: 'Principal Management',
            subtitle: 'Supervise campus headmasters and campus leadership across all branches',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    auth.loginAsPrincipal();
                  },
                  icon: const Icon(Icons.admin_panel_settings_rounded, size: 18),
                  label: Text('Open Principal Portal (${PrincipalMockData.principalName})', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => _showAddPrincipalModal(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Principal'),
                ),
              ],
            ),
          ),

          // Dedicated Principal Portal Highlight Card
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E1065), Color(0xFF5B21B6), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Active Principal: ${PrincipalMockData.principalName}',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Online',
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dr. Rajeshwari Raman oversees 1,248 students, 86 teachers, 96.4% attendance rate, and campus operations at Main City Campus.',
                        style: GoogleFonts.inter(color: const Color(0xFFE9D5FF), fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6D28D9),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => auth.loginAsPrincipal(),
                  icon: const Icon(Icons.launch_rounded, size: 16, color: Color(0xFF6D28D9)),
                  label: Text('Enter Principal Dashboard', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: const Color(0xFF6D28D9))),
                ),
              ],
            ),
          ),

          // 4 Summary Metric Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              return Row(
                children: [
                  Expanded(
                    child: _buildPrincipalMetricCard(
                      'Total Principals',
                      '4',
                      Icons.admin_panel_settings_rounded,
                      AppColors.primary,
                      AppColors.primaryTint,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildPrincipalMetricCard(
                      'Active Leadership',
                      '2 Active',
                      Icons.check_circle_rounded,
                      AppColors.success,
                      AppColors.successLight,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildPrincipalMetricCard(
                      'On Leave',
                      '1 On Leave',
                      Icons.event_busy_rounded,
                      AppColors.warning,
                      AppColors.warningLight,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildPrincipalMetricCard(
                      'Inactive / Former',
                      '1 Inactive',
                      Icons.person_off_rounded,
                      AppColors.danger,
                      AppColors.dangerLight,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Filters & Search Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 380),
                        child: TextField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search_rounded),
                            hintText: 'Search principal by name, email, or branch...',
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _filterBranch,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                          items: const [
                            DropdownMenuItem(value: 'All Campuses', child: Text('All Campuses')),
                            DropdownMenuItem(value: 'Main City', child: Text('Main City Campus')),
                            DropdownMenuItem(value: 'North Valley', child: Text('North Valley Campus')),
                            DropdownMenuItem(value: 'East Tech', child: Text('East Tech Campus')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _filterBranch = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Principals DataTable
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppColors.surfaceMuted),
                    dataRowMaxHeight: 64,
                    columnSpacing: 28,
                    columns: [
                      DataColumn(label: Text('Principal Name', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Email ID', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Phone', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Assigned Branch', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Status', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Joined Date', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Actions', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                    ],
                    rows: principals.map((p) {
                      Color statusBg = AppColors.successLight;
                      Color statusColor = AppColors.success;
                      if (p.status == 'On Leave') {
                        statusBg = AppColors.warningLight;
                        statusColor = AppColors.warning;
                      } else if (p.status == 'Inactive') {
                        statusBg = AppColors.dangerLight;
                        statusColor = AppColors.danger;
                      }

                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.primaryTint,
                                  child: Text(
                                    p.name.split(' ').map((e) => e[0]).take(2).join(),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                                    Text(p.qualification, style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textMuted)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text(p.email, style: GoogleFonts.inter(fontSize: 12.5))),
                          DataCell(Text(p.phone, style: GoogleFonts.inter(fontSize: 12.5))),
                          DataCell(Text(p.branch, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w500))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                p.status,
                                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                              ),
                            ),
                          ),
                          DataCell(Text(p.joinedDate, style: GoogleFonts.inter(fontSize: 12))),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                                  tooltip: 'View Profile',
                                  onPressed: () => _showPrincipalDetail(context, p),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
                                  tooltip: 'Edit Record',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Editing principal record: ${p.name}')),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.block_rounded, size: 18, color: AppColors.danger),
                                  tooltip: 'Deactivate / Change Status',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Status updated for ${p.name}')),
                                    );
                                  },
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

  Widget _buildPrincipalMetricCard(String title, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppDecorations.cardDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(title, style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  void _showPrincipalDetail(BuildContext context, PrincipalModel p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(p.name, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18)),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Campus: ${p.branch}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Qualification: ${p.qualification}', style: GoogleFonts.inter(fontSize: 12.5)),
              const SizedBox(height: 6),
              Text('Email: ${p.email}', style: GoogleFonts.inter(fontSize: 12.5)),
              const SizedBox(height: 6),
              Text('Phone: ${p.phone}', style: GoogleFonts.inter(fontSize: 12.5)),
              const SizedBox(height: 6),
              Text('Date Joined: ${p.joinedDate}', style: GoogleFonts.inter(fontSize: 12.5)),
              const SizedBox(height: 6),
              Text('Status: ${p.status}', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showAddPrincipalModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final branchCtrl = TextEditingController(text: 'South Metropolis Campus');
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Appoint New Principal', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 17)),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Principal Full Name *')),
              const SizedBox(height: 12),
              TextField(controller: branchCtrl, decoration: const InputDecoration(labelText: 'Campus Branch Name')),
              const SizedBox(height: 12),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Official Email')),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              setState(() {
                MockData.principals.add(
                  PrincipalModel(
                    id: 'PR-${DateTime.now().millisecondsSinceEpoch}',
                    name: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim().isEmpty ? 'principal@smartschool.edu' : emailCtrl.text.trim(),
                    phone: phoneCtrl.text.trim().isEmpty ? '+91 98450 00000' : phoneCtrl.text.trim(),
                    branch: branchCtrl.text.trim(),
                    status: 'Active',
                    joinedDate: '11 Sep 2026',
                    qualification: 'M.Ed, Ph.D.',
                    avatarUrl: '',
                  ),
                );
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(backgroundColor: AppColors.success, content: Text('Principal ${nameCtrl.text} added!')),
              );
            },
            child: const Text('Confirm Appointment'),
          ),
        ],
      ),
    );
  }
}
