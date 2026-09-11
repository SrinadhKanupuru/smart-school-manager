import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../data/mock_data.dart';
import '../../models/parent_model.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/custom_modal.dart';

class ParentPortalScreen extends StatefulWidget {
  const ParentPortalScreen({super.key});

  @override
  State<ParentPortalScreen> createState() => _ParentPortalScreenState();
}

class _ParentPortalScreenState extends State<ParentPortalScreen> {
  String _searchQuery = '';
  String _statusFilter = 'All Status';

  @override
  Widget build(BuildContext context) {
    final parents = MockData.parents.where((p) {
      final matchesSearch = p.parentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.studentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.phone.contains(_searchQuery) ||
          p.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == 'All Status' || p.status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          PageHeader(
            title: 'Parent Portal Directory',
            subtitle: 'Super Admin directory for parent accounts, app sync status, communication channel, and linked students',
            trailing: ElevatedButton.icon(
              onPressed: () => CustomModals.showSendNoticeDialog(context),
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Broadcast Notice to Parents'),
            ),
          ),

          // 4 Parent Overview KPI Cards
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Row(
                  children: [
                    Expanded(child: _buildParentKpi('Total Parents', '1,180', Icons.family_restroom_rounded, AppColors.primary, AppColors.primaryTint)),
                    const SizedBox(width: 14),
                    Expanded(child: _buildParentKpi('Active Accounts', '1,045', Icons.check_circle_outline_rounded, AppColors.success, AppColors.successLight)),
                    const SizedBox(width: 14),
                    Expanded(child: _buildParentKpi('Connected on App', '980', Icons.phonelink_ring_rounded, const Color(0xFF0EA5E9), const Color(0xFFF0F9FF))),
                    const SizedBox(width: 14),
                    Expanded(child: _buildParentKpi('Pending Registration', '48', Icons.pending_actions_rounded, AppColors.warning, AppColors.warningLight)),
                  ],
                );
              } else {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(width: (constraints.maxWidth - 12) / 2, child: _buildParentKpi('Total Parents', '1,180', Icons.family_restroom_rounded, AppColors.primary, AppColors.primaryTint)),
                    SizedBox(width: (constraints.maxWidth - 12) / 2, child: _buildParentKpi('Active Accounts', '1,045', Icons.check_circle_outline_rounded, AppColors.success, AppColors.successLight)),
                    SizedBox(width: (constraints.maxWidth - 12) / 2, child: _buildParentKpi('Connected on App', '980', Icons.phonelink_ring_rounded, const Color(0xFF0EA5E9), const Color(0xFFF0F9FF))),
                    SizedBox(width: (constraints.maxWidth - 12) / 2, child: _buildParentKpi('Pending Registration', '48', Icons.pending_actions_rounded, AppColors.warning, AppColors.warningLight)),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24),

          // Search, Filter & Parent Table Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppDecorations.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: TextField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search_rounded),
                            hintText: 'Search parent by name, student name, or phone...',
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
                          value: _statusFilter,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                          items: const [
                            DropdownMenuItem(value: 'All Status', child: Text('All Status')),
                            DropdownMenuItem(value: 'Connected', child: Text('Connected')),
                            DropdownMenuItem(value: 'Active', child: Text('Active')),
                            DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _statusFilter = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Table
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppColors.surfaceMuted),
                    dataRowMaxHeight: 64,
                    columnSpacing: 26,
                    columns: [
                      DataColumn(label: Text('Parent Name', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Connected Student', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Relationship', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Phone Number', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Email ID', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Portal Status', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Actions', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                    ],
                    rows: parents.map((p) {
                      Color statusBg = AppColors.successLight;
                      Color statusColor = AppColors.success;
                      if (p.status == 'Pending') {
                        statusBg = AppColors.warningLight;
                        statusColor = AppColors.warning;
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
                                    p.parentName.split(' ').map((e) => e[0]).take(2).join(),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.parentName, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                                    Text(p.occupation, style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textMuted)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.studentName, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                Text(p.studentClass, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(p.relationship, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          DataCell(Text(p.phone, style: GoogleFonts.inter(fontSize: 12))),
                          DataCell(Text(p.email, style: GoogleFonts.inter(fontSize: 12))),
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
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AppColors.primary),
                                  tooltip: 'Send Instant SMS / App Ping',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Direct message sent to ${p.parentName}')),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.textSecondary),
                                  tooltip: 'View Parent Details',
                                  onPressed: () => _showParentDetailModal(context, p),
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

  Widget _buildParentKpi(String title, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(title, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  void _showParentDetailModal(BuildContext context, ParentModel p) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(p.parentName, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18)),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Child: ${p.studentName} (${p.studentClass})', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Relationship: ${p.relationship}', style: GoogleFonts.inter(fontSize: 12.5)),
              const SizedBox(height: 6),
              Text('Occupation: ${p.occupation}', style: GoogleFonts.inter(fontSize: 12.5)),
              const SizedBox(height: 6),
              Text('Phone: ${p.phone}', style: GoogleFonts.inter(fontSize: 12.5)),
              const SizedBox(height: 6),
              Text('Email: ${p.email}', style: GoogleFonts.inter(fontSize: 12.5)),
              const SizedBox(height: 6),
              Text('Address: ${p.address}', style: GoogleFonts.inter(fontSize: 12.5)),
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
