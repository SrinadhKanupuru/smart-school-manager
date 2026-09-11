import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/custom_modal.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedClass = 'All Classes';
  String _selectedRange = 'Current Academic Term';

  final List<Map<String, dynamic>> _reportCards = [
    {
      'title': 'Student Attendance Report',
      'description': 'Daily, weekly, and monthly attendance percentages, absentees list, and late attendance audit.',
      'icon': Icons.fact_check_rounded,
      'color': Color(0xFF2563EB),
      'bgColor': Color(0xFFEFF6FF),
      'records': '1,248 Records',
      'lastGenerated': 'Today, 08:30 AM',
    },
    {
      'title': 'Faculty Attendance & Leaves',
      'description': 'Biometric punch-in times, casual and medical leaves history, and substitute teacher logs.',
      'icon': Icons.groups_rounded,
      'color': Color(0xFF8B5CF6),
      'bgColor': Color(0xFFF5F3FF),
      'records': '86 Records',
      'lastGenerated': 'Yesterday',
    },
    {
      'title': 'Fee Collection & Revenue Report',
      'description': 'Term fee collections, payment gateway reconciliation, payment modes, and daily ledger.',
      'icon': Icons.account_balance_wallet_rounded,
      'color': Color(0xFF10B981),
      'bgColor': Color(0xFFECFDF5),
      'records': '₹18,76,200',
      'lastGenerated': 'Today, 09:15 AM',
    },
    {
      'title': 'Pending Fee & Defaulters List',
      'description': 'Class-wise pending fee dues, overdue penalty calculations, and parent contact information.',
      'icon': Icons.pending_actions_rounded,
      'color': Color(0xFFEF4444),
      'bgColor': Color(0xFFFEF2F2),
      'records': '₹4,32,600 Dues',
      'lastGenerated': '09 Sep 2026',
    },
    {
      'title': 'Student Strength & Demographics',
      'description': 'Total class enrollment, gender distribution, new admissions, and section capacities.',
      'icon': Icons.bar_chart_rounded,
      'color': Color(0xFF0EA5E9),
      'bgColor': Color(0xFFF0F9FF),
      'records': '12 Grades',
      'lastGenerated': '01 Sep 2026',
    },
    {
      'title': 'Academic Performance & Grades',
      'description': 'Subject-wise grade distribution, GPA analysis, pass percentage, and topper rosters.',
      'icon': Icons.school_rounded,
      'color': Color(0xFFF59E0B),
      'bgColor': Color(0xFFFFFBEB),
      'records': 'Quarterly Assessment',
      'lastGenerated': '14 Aug 2026',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          PageHeader(
            title: 'Reports & Business Intelligence',
            subtitle: 'Super Admin central reporting hub with instant export to PDF, Excel, and institutional dashboards',
            trailing: ElevatedButton.icon(
              onPressed: () => CustomModals.showGenerateReportDialog(context),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Export Custom Report'),
            ),
          ),

          // Filters Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.cardDecoration(),
            child: Row(
              children: [
                Text('Filter Parameters:', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(width: 14),
                // Class Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedClass,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                      items: const [
                        DropdownMenuItem(value: 'All Classes', child: Text('All Classes (Grade 1 - 12)')),
                        DropdownMenuItem(value: 'Grade 10', child: Text('Grade 10 Only')),
                        DropdownMenuItem(value: 'Grade 9', child: Text('Grade 9 Only')),
                        DropdownMenuItem(value: 'Grade 8', child: Text('Grade 8 Only')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedClass = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Date Range Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRange,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                      items: const [
                        DropdownMenuItem(value: 'Current Academic Term', child: Text('Current Academic Term (Term 1)')),
                        DropdownMenuItem(value: 'This Month', child: Text('This Month (September 2026)')),
                        DropdownMenuItem(value: 'Full Academic Year', child: Text('Full Year 2026–27')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRange = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Reports Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final double cardWidth = constraints.maxWidth > 850
                  ? (constraints.maxWidth - 20) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: _reportCards.map((report) {
                  return SizedBox(
                    width: cardWidth,
                    child: _buildReportTile(context, report),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportTile(BuildContext context, Map<String, dynamic> report) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: report['bgColor'] as Color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(report['icon'] as IconData, color: report['color'] as Color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report['title'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report['description'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Scope: ${report['records']}', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  Text('Generated: ${report['lastGenerated']}', style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textMuted)),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Downloading ${report['title']} in Excel format...')),
                      );
                    },
                    icon: const Icon(Icons.table_chart_outlined, size: 15),
                    label: const Text('Excel'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.primary,
                          content: Text('Downloading ${report['title']} PDF...'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 15),
                    label: const Text('PDF'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
