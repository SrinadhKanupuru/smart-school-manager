import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/admin_provider.dart';
import '../../core/theme.dart';

class FeesDetailsScreen extends StatefulWidget {
  const FeesDetailsScreen({super.key});

  @override
  State<FeesDetailsScreen> createState() => _FeesDetailsScreenState();
}

class _FeesDetailsScreenState extends State<FeesDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchChildrenDashboard();
    });
  }

  void _pay(AdminProvider admin, String id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final success = await admin.payFeeSimulated(id);

    if (mounted) {
      Navigator.pop(context); // Dismiss loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Payment Successful (Simulated)!' : 'Payment transaction failed'),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);

    if (admin.childrenDashboardData.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Fee Invoices')),
        body: RefreshIndicator(
          onRefresh: () => admin.fetchChildrenDashboard(),
          child: admin.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    Center(
                      child: Text(
                        'No student records mapped.',
                        style: GoogleFonts.outfit(),
                      ),
                    ),
                  ],
                ),
        ),
      );
    }

    // Accumulating all fee records for parent's children
    final List<dynamic> feeRecords = [];
    for (var child in admin.childrenDashboardData) {
      final childName = child['fullName'] ?? 'Student';
      for (var record in child['feeRecords'] ?? []) {
        feeRecords.add({
          ...record,
          'childName': childName,
        });
      }
    }

    final double totalPending = feeRecords
        .where((r) => r['status'] != 'PAID')
        .fold(0.0, (sum, item) => sum + (item['amount'] - item['paidAmount']));

    return Scaffold(
      appBar: AppBar(title: const Text('School Fees')),
      body: SafeArea(
        child: Column(
          children: [
            // Total Pending banner
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Outstanding:', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(
                    '₹${totalPending.toStringAsFixed(0)}',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => admin.fetchChildrenDashboard(),
                child: feeRecords.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                          Center(
                            child: Text(
                              'No fee invoices issued.',
                              style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: feeRecords.length,
                        itemBuilder: (context, index) {
                          final record = feeRecords[index];
                          final category = record['category'] ?? '';
                          final childName = record['childName'] ?? '';
                          final isPaid = record['status'] == 'PAID';
                          final pendingAmount = record['amount'] - record['paidAmount'];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '$category Fee ($childName)',
                                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isPaid ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          record['status'] ?? 'PENDING',
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isPaid ? Colors.green : Colors.orange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  _buildFeeRow('Total Due', '₹${record['amount'].toStringAsFixed(0)}'),
                                  _buildFeeRow('Amount Paid', '₹${record['paidAmount'].toStringAsFixed(0)}'),
                                  _buildFeeRow('Outstanding Balance', '₹${pendingAmount.toStringAsFixed(0)}', isHighlight: true),
                                  if (!isPaid) ...[
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () => _pay(admin, record['id']),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: const Text('Pay Now'),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeRow(String label, String val, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor, fontSize: 13)),
          Text(
            val,
            style: GoogleFonts.outfit(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
              color: isHighlight ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
