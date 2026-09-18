import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../widgets/parent/parent_ui_components.dart';
import 'parent_data_provider.dart';
import '../../models/parent_portal_models.dart';

class ParentFeesScreen extends StatelessWidget {
  const ParentFeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<ParentDataProvider>(context);
    final child = data.selectedChild;
    final fee = data.currentFeeSummary;

    final progressRatio = fee.totalFees > 0 ? (fee.paidFees / fee.totalFees).clamp(0.0, 1.0) : 1.0;

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
                        'Fee Ledger & Payments',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: ParentDesignTokens.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tuition installments, transport billing, and receipt ledger for ${child.name}',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: ParentDesignTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                if (fee.pendingFees > 0)
                  ParentButton(
                    label: 'Pay Fees (₹${fee.pendingFees.toStringAsFixed(0)})',
                    icon: Icons.payment_rounded,
                    variant: ParentButtonVariant.primary,
                    onPressed: () => _showPayFeesModal(context, data, fee, child),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4 Top KPI Cards
          ParentAnimatedEntrance(
            index: 1,
            child: Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    title: 'Total Annual Fees',
                    value: '₹${fee.totalFees.toStringAsFixed(0)}',
                    subtext: 'AY 2026-2027',
                    icon: Icons.account_balance_rounded,
                    color: ParentDesignTokens.brand,
                    bg: ParentDesignTokens.brandTint,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildKpiCard(
                    title: 'Total Paid',
                    value: '₹${fee.paidFees.toStringAsFixed(0)}',
                    subtext: 'Reconciled',
                    icon: Icons.check_circle_rounded,
                    color: ParentDesignTokens.emerald,
                    bg: ParentDesignTokens.emeraldLight,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildKpiCard(
                    title: 'Pending Dues',
                    value: '₹${fee.pendingFees.toStringAsFixed(0)}',
                    subtext: fee.pendingFees > 0 ? 'Due by ${fee.nextDueDate}' : 'Cleared',
                    icon: Icons.hourglass_top_rounded,
                    color: fee.pendingFees > 0 ? ParentDesignTokens.warmAccentDark : ParentDesignTokens.emerald,
                    bg: fee.pendingFees > 0 ? ParentDesignTokens.warmAccentLight : ParentDesignTokens.emeraldLight,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildKpiCard(
                    title: 'Overdue Fines',
                    value: '₹${fee.overdueFees.toStringAsFixed(0)}',
                    subtext: 'Zero Penalties',
                    icon: Icons.verified_user_rounded,
                    color: ParentDesignTokens.emerald,
                    bg: ParentDesignTokens.emeraldLight,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Fee Clearance Visualization Banner
          ParentAnimatedEntrance(
            index: 2,
            child: ParentCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Annual Fee Clearance Status',
                            style: GoogleFonts.inter(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: ParentDesignTokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${fee.paidFees.toStringAsFixed(0)} Paid  •  ₹${fee.pendingFees.toStringAsFixed(0)} Remaining',
                            style: GoogleFonts.inter(fontSize: 13, color: ParentDesignTokens.textSecondary),
                          ),
                        ],
                      ),
                      ParentBadge.info(label: '${(progressRatio * 100).toStringAsFixed(1)}% Reconciled'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressRatio,
                      minHeight: 12,
                      backgroundColor: const Color(0xFFFEF2F2),
                      valueColor: const AlwaysStoppedAnimation<Color>(ParentDesignTokens.emerald),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Billing: ₹${fee.totalFees.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textMuted),
                      ),
                      Text(
                        fee.pendingFees > 0 ? 'Next Due Date: ${fee.nextDueDate}' : 'All installments fully reconciled',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: fee.pendingFees > 0 ? ParentDesignTokens.warmAccentDark : ParentDesignTokens.emerald,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Installments Schedule Card
          ParentAnimatedEntrance(
            index: 3,
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
                          'Fee Installments Schedule',
                          style: GoogleFonts.inter(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: ParentDesignTokens.textPrimary,
                          ),
                        ),
                        Text(
                          'Academic Session 2026-2027',
                          style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: ParentDesignTokens.border),
                  ...fee.installments.map((inst) {
                    final isPaid = inst.status == 'Paid';

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                inst.title,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: ParentDesignTokens.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Due Date: ${inst.dueDate}',
                                style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textSecondary),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '₹${inst.amount.toStringAsFixed(0)}',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: ParentDesignTokens.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 14),
                              isPaid
                                  ? ParentBadge.success(label: 'Paid')
                                  : ParentBadge.warning(label: 'Pending Due'),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Payment Receipts History
          ParentAnimatedEntrance(
            index: 4,
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verified Payment Receipts',
                              style: GoogleFonts.inter(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: ParentDesignTokens.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Instant digital receipts with official GST compliance',
                              style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textMuted),
                            ),
                          ],
                        ),
                        ParentBadge.info(label: '${fee.receipts.length} Receipts Available'),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: ParentDesignTokens.border),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: fee.receipts.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: ParentDesignTokens.borderSubtle),
                    itemBuilder: (context, index) {
                      final r = fee.receipts[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: ParentDesignTokens.brandTint,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.receipt_long_rounded, color: ParentDesignTokens.brand, size: 20),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.receiptNo,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: ParentDesignTokens.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${r.description} • Paid on ${r.paymentDate.day}/${r.paymentDate.month}/${r.paymentDate.year} via ${r.paymentMethod}',
                                      style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textSecondary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  '₹${r.amount.toStringAsFixed(0)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: ParentDesignTokens.emerald,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(Icons.download_rounded, size: 20, color: ParentDesignTokens.brand),
                                  tooltip: 'Download Receipt PDF',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Downloading official receipt ${r.receiptNo}...'),
                                        backgroundColor: ParentDesignTokens.brand,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
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

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ParentDesignTokens.surface,
        borderRadius: ParentDesignTokens.radiusLg,
        border: Border.all(color: ParentDesignTokens.border),
        boxShadow: ParentDesignTokens.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ParentDesignTokens.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: ParentDesignTokens.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: ParentDesignTokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  void _showPayFeesModal(
    BuildContext context,
    ParentDataProvider data,
    ChildFeeSummary fee,
    ChildStudent child,
  ) {
    String selectedMethod = 'UPI';
    bool isProcessing = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: ParentDesignTokens.brandTint,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.payment_rounded, color: ParentDesignTokens.brand, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Pay School Fees',
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ParentDesignTokens.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ParentDesignTokens.border),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Student Name:', style: GoogleFonts.inter(fontSize: 13, color: ParentDesignTokens.textSecondary)),
                                Text(child.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: ParentDesignTokens.textPrimary)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Amount Due:', style: GoogleFonts.inter(fontSize: 13, color: ParentDesignTokens.textSecondary)),
                                Text(
                                  '₹${fee.pendingFees.toStringAsFixed(0)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: ParentDesignTokens.brand,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Select Payment Gateway:',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: ParentDesignTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: ['UPI', 'Credit/Debit Card', 'Net Banking'].map((method) {
                          final isSelected = selectedMethod == method;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: InkWell(
                                onTap: () => setModalState(() => selectedMethod = method),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? ParentDesignTokens.brandTint : ParentDesignTokens.surface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected ? ParentDesignTokens.brand : ParentDesignTokens.border,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      method,
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: isSelected ? ParentDesignTokens.brand : ParentDesignTokens.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      ParentButton(
                        label: isProcessing ? 'Processing Transaction...' : 'Authorize Payment of ₹${fee.pendingFees.toStringAsFixed(0)}',
                        fullWidth: true,
                        isLoading: isProcessing,
                        variant: ParentButtonVariant.primary,
                        onPressed: isProcessing
                            ? null
                            : () async {
                                setModalState(() => isProcessing = true);
                                await Future.delayed(const Duration(milliseconds: 900));
                                data.processFeePayment(
                                  amount: fee.pendingFees,
                                  paymentMethod: selectedMethod,
                                  description: 'Tuition Fee Installment Payment',
                                );
                                if (ctx.mounted) {
                                  Navigator.of(ctx).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Payment of ₹${fee.pendingFees.toStringAsFixed(0)} completed successfully!',
                                            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: ParentDesignTokens.emerald,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  );
                                }
                              },
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
