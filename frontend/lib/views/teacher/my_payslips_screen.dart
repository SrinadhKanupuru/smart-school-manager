import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/admin_provider.dart';
import '../../core/theme.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';

class MyPayslipsScreen extends StatefulWidget {
  const MyPayslipsScreen({super.key});

  @override
  State<MyPayslipsScreen> createState() => _MyPayslipsScreenState();
}

class _MyPayslipsScreenState extends State<MyPayslipsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final admin = Provider.of<AdminProvider>(context, listen: false);
      await admin.fetchSalaries();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);
    final salaries = admin.salaries;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Payslips',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: salaries.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: salaries.length,
                        itemBuilder: (context, index) {
                          final record = salaries[index];
                          return _buildPayslipCard(record);
                        },
                      ),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        const Center(
          child: Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'No payslips generated yet',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Check back once the school payroll is processed.',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayslipCard(Map<String, dynamic> record) {
    final month = record['month'] ?? 'N/A';
    final year = record['year']?.toString() ?? 'N/A';
    final amount = record['amount'] ?? 0.0;
    final status = (record['status'] ?? 'PENDING').toString().toUpperCase();

    Color statusColor;
    switch (status) {
      case 'PAID':
        statusColor = Colors.green;
        break;
      case 'APPROVED':
        statusColor = Colors.blue;
        break;
      case 'PROCESSED':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.08),
          child: const Icon(Icons.receipt, color: AppTheme.primaryColor),
        ),
        title: Text(
          '$month $year',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          'Net Salary: ₹${amount.toStringAsFixed(2)}',
          style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: GoogleFonts.outfit(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        onTap: () => _showPayslipDetails(context, record),
      ),
    );
  }

  void _showPayslipDetails(BuildContext context, Map<String, dynamic> record) {
    final name = record['teacher']?['user']?['fullName'] ?? 'Teacher';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Payslip Details',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.08),
                    child: Text(name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                  ),
                  title: Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  subtitle: Text('Month: ${record['month']} ${record['year']}', style: GoogleFonts.outfit(fontSize: 12)),
                ),
                const Divider(),
                _buildPayslipRow('Base Salary', '₹${(record['baseSalary'] ?? 0.0).toStringAsFixed(2)}'),
                _buildPayslipRow('Working Days', '${record['workingDays'] ?? 0} Days'),
                const SizedBox(height: 8),
                Text('Attendance Breakdown', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryColor)),
                const SizedBox(height: 4),
                _buildPayslipRow('  • Present Days', '${record['presentDays'] ?? 0.0} Days'),
                _buildPayslipRow('  • Half-Days Worked', '${record['halfDays'] ?? 0.0} Days'),
                _buildPayslipRow('  • Absent Days', '${record['absentDays'] ?? 0.0} Days'),
                _buildPayslipRow('  • Paid Leave Days', '${record['leaveDays'] ?? 0.0} Days'),
                const Divider(),
                if (record['components'] != null && (record['components'] as List).isNotEmpty) ...[
                  if ((record['components'] as List).any((c) => !c['category'].toString().contains('DEDUCTION'))) ...[
                    Text('Earnings', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                    const SizedBox(height: 4),
                    ...(record['components'] as List)
                        .where((c) => !c['category'].toString().contains('DEDUCTION'))
                        .map((c) => _buildPayslipRow('  • ${c['name']}', '₹${(c['amount'] ?? 0.0).toStringAsFixed(2)}', isAddition: true)),
                    const Divider(),
                  ],
                  if ((record['components'] as List).any((c) => c['category'].toString().contains('DEDUCTION'))) ...[
                    Text('Deductions', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.redAccent)),
                    const SizedBox(height: 4),
                    ...(record['components'] as List)
                        .where((c) => c['category'].toString().contains('DEDUCTION'))
                        .map((c) => _buildPayslipRow('  • ${c['name']}', '₹${(c['amount'] ?? 0.0).toStringAsFixed(2)}', isDeduction: true)),
                    const Divider(),
                  ],
                ] else ...[
                  Text('Deductions', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.redAccent)),
                  const SizedBox(height: 4),
                  _buildPayslipRow('  • Loss of Pay (LOP)', '₹${(record['lopDeduction'] ?? 0.0).toStringAsFixed(2)}', isDeduction: true),
                  _buildPayslipRow('  • Loan Repayment EMI', '₹${(record['loanDeduction'] ?? 0.0).toStringAsFixed(2)}', isDeduction: true),
                  const Divider(),
                  Text('Additions', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                  const SizedBox(height: 4),
                  _buildPayslipRow('  • Allowances', '+₹${(record['allowances'] ?? 0.0).toStringAsFixed(2)}', isAddition: true),
                  _buildPayslipRow('  • Bonus', '+₹${(record['bonus'] ?? 0.0).toStringAsFixed(2)}', isAddition: true),
                  const Divider(),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Net Salary Paid', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(
                      '₹${(record['amount'] ?? 0.0).toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor),
                    ),
                  ],
                ),
                if (record['remarks'] != null && record['remarks'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Remarks: ${record['remarks']}', style: GoogleFonts.outfit(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade600)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => _printPayslip(record),
              icon: const Icon(Icons.print, size: 18),
              label: const Text('Print / PDF'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPayslipRow(String label, String value, {bool isDeduction = false, bool isAddition = false}) {
    Color valColor = Colors.black87;
    if (isDeduction) valColor = Colors.redAccent;
    if (isAddition) valColor = Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade700)),
          Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: valColor)),
        ],
      ),
    );
  }

  Future<void> _printPayslip(Map<String, dynamic> record) async {
    try {
      final token = ApiClient.instance.token;
      final url = Uri.parse('${ApiConstants.baseUrl}/admin/salaries/${record['id']}/print?token=$token');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open print window')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Print error: $e')),
        );
      }
    }
  }
}
