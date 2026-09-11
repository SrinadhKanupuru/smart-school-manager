import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../data/mock_data.dart';
import '../../models/fee_data.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/custom_modal.dart';
import '../../widgets/charts/fee_donut_chart.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _feeStatusFilter = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final transactions = MockData.feeTransactions.where((t) {
      final matchesSearch = t.studentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.receiptNo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.studentClass.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _feeStatusFilter == 'All' || t.status == _feeStatusFilter;
      return matchesSearch && matchesStatus;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          PageHeader(
            title: 'Fee Collection & Financial Accounts',
            subtitle: 'Super Admin billing oversight, fee ledger records, pending dues collection, and transaction audit',
            trailing: ElevatedButton.icon(
              onPressed: () => CustomModals.showCollectFeeDialog(context),
              icon: const Icon(Icons.add_card_rounded, size: 18),
              label: const Text('Record Fee Payment'),
            ),
          ),

          // 5 Financial KPI Metric Cards in Row
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 920) {
                return Row(
                  children: [
                    Expanded(child: _buildAccountCard("Today's Collection", '₹85,000', Icons.today_rounded, AppColors.primary, AppColors.primaryTint)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildAccountCard('This Month', '₹18,76,200', Icons.calendar_month_rounded, const Color(0xFF0EA5E9), const Color(0xFFF0F9FF))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildAccountCard('Total Collected', '₹18,76,200 (76.4%)', Icons.check_circle_rounded, AppColors.success, AppColors.successLight)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildAccountCard('Pending Dues', '₹4,32,600 (17.6%)', Icons.pending_actions_rounded, AppColors.warning, AppColors.warningLight)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildAccountCard('Overdue Dues', '₹1,47,300 (6.0%)', Icons.error_outline_rounded, AppColors.danger, AppColors.dangerLight)),
                  ],
                );
              } else {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(width: (constraints.maxWidth - 12) / 2, child: _buildAccountCard("Today's Collection", '₹85,000', Icons.today_rounded, AppColors.primary, AppColors.primaryTint)),
                    SizedBox(width: (constraints.maxWidth - 12) / 2, child: _buildAccountCard('This Month', '₹18,76,200', Icons.calendar_month_rounded, const Color(0xFF0EA5E9), const Color(0xFFF0F9FF))),
                    SizedBox(width: (constraints.maxWidth - 12) / 2, child: _buildAccountCard('Total Collected', '₹18,76,200', Icons.check_circle_rounded, AppColors.success, AppColors.successLight)),
                    SizedBox(width: (constraints.maxWidth - 12) / 2, child: _buildAccountCard('Pending Dues', '₹4,32,600', Icons.pending_actions_rounded, AppColors.warning, AppColors.warningLight)),
                    SizedBox(width: constraints.maxWidth, child: _buildAccountCard('Overdue Dues', '₹1,47,300', Icons.error_outline_rounded, AppColors.danger, AppColors.dangerLight)),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24),

          // Fee Analytics Donut Card + Collection Summary
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      flex: 42,
                      child: FeeDonutChartCard(),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 58,
                      child: _buildFeeSummaryCard(),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    const FeeDonutChartCard(),
                    const SizedBox(height: 20),
                    _buildFeeSummaryCard(),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24),

          // Transactions & Payments Table
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppDecorations.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: TextField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search_rounded),
                            hintText: 'Search receipt no, student name...',
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
                          value: _feeStatusFilter,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                          items: const [
                            DropdownMenuItem(value: 'All', child: Text('All Transactions')),
                            DropdownMenuItem(value: 'Paid', child: Text('Paid Fully')),
                            DropdownMenuItem(value: 'Pending', child: Text('Pending Dues')),
                            DropdownMenuItem(value: 'Overdue', child: Text('Overdue')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _feeStatusFilter = val);
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
                    columnSpacing: 24,
                    columns: [
                      DataColumn(label: Text('Receipt / TXN', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Student', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Class', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Fee Type', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Total Amount', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Paid Amount', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Pending Dues', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Due Date', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Status', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                      DataColumn(label: Text('Receipt', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                    ],
                    rows: transactions.map((t) {
                      Color statusBg = AppColors.successLight;
                      Color statusColor = AppColors.success;
                      if (t.status == 'Pending') {
                        statusBg = AppColors.warningLight;
                        statusColor = AppColors.warning;
                      } else if (t.status == 'Overdue') {
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
                                Text(t.receiptNo, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                Text(t.paymentMode, style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          DataCell(Text(t.studentName, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13))),
                          DataCell(Text(t.studentClass, style: GoogleFonts.inter(fontSize: 12))),
                          DataCell(Text(t.feeType, style: GoogleFonts.inter(fontSize: 12.5))),
                          DataCell(Text(MockData.formatInr(t.totalAmount), style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600))),
                          DataCell(Text(MockData.formatInr(t.paidAmount), style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.success))),
                          DataCell(Text(MockData.formatInr(t.pendingAmount), style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: t.pendingAmount > 0 ? AppColors.danger : AppColors.textMuted))),
                          DataCell(Text(t.dueDate, style: GoogleFonts.inter(fontSize: 12))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(t.status, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.download_rounded, size: 18, color: AppColors.primary),
                              tooltip: 'Download Official Invoice PDF',
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Invoice ${t.receiptNo} downloaded!')),
                                );
                              },
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

  Widget _buildAccountCard(String title, String value, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildFeeSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Academic Year 2026–27 Fee Insights', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('Total Annual Budget Projection: ₹24,56,100', style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          _buildProgressItem('Tuition Fees Collection', 0.82, '82%', const Color(0xFF10B981)),
          const SizedBox(height: 12),
          _buildProgressItem('Laboratory & Science Fees', 0.74, '74%', const Color(0xFF3B82F6)),
          const SizedBox(height: 12),
          _buildProgressItem('Transport / Bus Route Fees', 0.68, '68%', const Color(0xFFF59E0B)),
          const SizedBox(height: 12),
          _buildProgressItem('Annual Sports & Activity Dues', 0.90, '90%', const Color(0xFF8B5CF6)),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, double value, String percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500)),
            Text(percent, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
