import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/academic_provider.dart';
import '../../providers/admin_provider.dart';
import '../../core/theme.dart';

class FeeManagementScreen extends StatefulWidget {
  const FeeManagementScreen({super.key});

  @override
  State<FeeManagementScreen> createState() => _FeeManagementScreenState();
}

class _FeeManagementScreenState extends State<FeeManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AcademicProvider>(context, listen: false).fetchStudents();
    });
  }

  void _showAddFeeDialog(String studentId, String studentName) {
    final amountCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 30))));
    String category = 'TUITION';

    final academic = Provider.of<AcademicProvider>(context, listen: false);
    final admin = Provider.of<AdminProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Assign Fee for $studentName', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Fee Category'),
                  items: const [
                    DropdownMenuItem(value: 'TUITION', child: Text('Tuition Fee')),
                    DropdownMenuItem(value: 'VAN', child: Text('Transportation Fee')),
                    DropdownMenuItem(value: 'OTHER', child: Text('Other / Extra Fee')),
                  ],
                  onChanged: (val) {
                    if (val != null) setStateDialog(() => category = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fee Amount (₹)*',
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dateCtrl,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Due Date*',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (picked != null) {
                      setStateDialog(() {
                        dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountCtrl.text.trim());
                  if (amount == null || amount <= 0 || dateCtrl.text.isEmpty) {
                    return;
                  }

                  Navigator.pop(ctx);
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => const Center(child: CircularProgressIndicator()),
                  );

                  final success = await admin.createFeeRecord(
                    studentId: studentId,
                    category: category,
                    amount: amount,
                    dueDate: dateCtrl.text.trim(),
                  );

                  if (mounted) {
                    Navigator.pop(context); // Dismiss loader
                    academic.fetchStudents(); // Refresh student records
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Fee assigned successfully!' : 'Failed to assign fee'),
                        backgroundColor: success ? Colors.green : Colors.redAccent,
                      ),
                    );
                  }
                },
                child: const Text('Assign Fee'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRecordPaymentDialog(Map<String, dynamic> record, String studentName) {
    final paidAmountCtrl = TextEditingController(text: ((record['paidAmount'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(0));
    final totalAmount = (record['amount'] as num?)?.toDouble() ?? 0.0;
    final currentlyPaid = (record['paidAmount'] as num?)?.toDouble() ?? 0.0;
    final remaining = totalAmount - currentlyPaid;

    final academic = Provider.of<AcademicProvider>(context, listen: false);
    final admin = Provider.of<AdminProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Record Fee Payment', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Student: $studentName', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Fee Category: ${record['category']}', style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor, fontSize: 13)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildInvoiceRow('Total Fee Due', '₹${totalAmount.toStringAsFixed(0)}'),
                  _buildInvoiceRow('Currently Paid', '₹${currentlyPaid.toStringAsFixed(0)}'),
                  _buildInvoiceRow('Pending Balance', '₹${remaining.toStringAsFixed(0)}', isHighlight: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: paidAmountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Total Paid Amount (₹)*',
                prefixIcon: Icon(Icons.payment),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newPaidAmount = double.tryParse(paidAmountCtrl.text.trim());
              if (newPaidAmount == null || newPaidAmount < 0 || newPaidAmount > totalAmount) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount not exceeding the total due.')),
                );
                return;
              }

              Navigator.pop(ctx);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => const Center(child: CircularProgressIndicator()),
              );

              final success = await admin.updateFeeRecord(
                feeRecordId: record['id'],
                paidAmount: newPaidAmount,
              );

              if (mounted) {
                Navigator.pop(context); // Dismiss loader
                academic.fetchStudents(); // Refresh
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Payment recorded successfully!' : 'Failed to update payment'),
                    backgroundColor: success ? Colors.green : Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Submit Payment'),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor)),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  void _sendPaymentReminder(BuildContext context, String studentId, String studentName, double outstanding) {
    final titleCtrl = TextEditingController(text: 'Payment Reminder: Outstanding Fees');
    final contentCtrl = TextEditingController(
      text: 'Dear Parent, this is a gentle reminder that ₹${outstanding.toStringAsFixed(0)} is pending for your child $studentName. Please clear the dues at the earliest. Thank you.',
    );

    final admin = Provider.of<AdminProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Send Payment Reminder', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Message Content'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty || contentCtrl.text.trim().isEmpty) {
                return;
              }
              Navigator.pop(ctx);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => const Center(child: CircularProgressIndicator()),
              );

              final success = await admin.sendMessageToParents(
                studentId: studentId,
                title: titleCtrl.text.trim(),
                content: contentCtrl.text.trim(),
                type: 'REMINDER',
              );

              if (mounted) {
                Navigator.pop(context); // Dismiss loader
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Payment reminder sent successfully!' : 'Failed to send reminder. Make sure student has registered parents.'),
                    backgroundColor: success ? Colors.green : Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Send Reminder'),
          ),
        ],
      ),
    );
  }

  void _sendCustomMessage(BuildContext context, String studentId, String studentName) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    final admin = Provider.of<AdminProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Send Message to Parents of $studentName', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Message Title*',
                hintText: 'Enter title',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message Content*',
                hintText: 'Type your message details...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty || contentCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }
              Navigator.pop(ctx);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => const Center(child: CircularProgressIndicator()),
              );

              final success = await admin.sendMessageToParents(
                studentId: studentId,
                title: titleCtrl.text.trim(),
                content: contentCtrl.text.trim(),
                type: 'GENERAL',
              );

              if (mounted) {
                Navigator.pop(context); // Dismiss loader
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Message sent successfully!' : 'Failed to send message. Make sure student has registered parents.'),
                    backgroundColor: success ? Colors.green : Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Send Message'),
          ),
        ],
      ),
    );
  }

  void _sendBulkFeeRemindersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Send Bulk Reminders', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to send automatic fee reminders to the parents of all students with outstanding dues in this school?',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => const Center(child: CircularProgressIndicator()),
              );

              final admin = Provider.of<AdminProvider>(context, listen: false);
              final result = await admin.sendBulkFeeReminders();

              if (mounted) {
                Navigator.pop(context); // Dismiss loader
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? 'Reminders sent successfully!'),
                    backgroundColor: result['success'] ? Colors.green : Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800),
            child: const Text('Send to All', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final academic = Provider.of<AcademicProvider>(context);

    // Calculate overall school statistics
    double totalFeesDue = 0.0;
    double totalFeesPaid = 0.0;
    for (var s in academic.students) {
      for (var record in s['feeRecords'] ?? []) {
        totalFeesDue += ((record['amount'] as num?)?.toDouble() ?? 0.0);
        totalFeesPaid += ((record['paidAmount'] as num?)?.toDouble() ?? 0.0);
      }
    }
    final totalOutstanding = totalFeesDue - totalFeesPaid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Student Fee Tracker',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Overview Board
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Paid Collections', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '₹${totalFeesPaid.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.white24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pending Dues', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '₹${totalOutstanding.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            if (totalOutstanding > 0)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Outstanding Collections:',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _sendBulkFeeRemindersDialog(context),
                      icon: const Icon(Icons.notifications_active, size: 16),
                      label: Text('Notify All Outstanding', style: GoogleFonts.outfit(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: academic.isLoading && academic.students.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : academic.students.isEmpty
                      ? Center(child: Text('No students registered.', style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: academic.students.length,
                          itemBuilder: (context, index) {
                            final student = academic.students[index];
                            final name = student['fullName'] ?? 'Student';
                            final studentId = student['id'] as String;
                            final rollNo = student['rollNo'] ?? '';
                            
                            final className = student['classSection']?['class']?['name'] ?? 'Unassigned';
                            final secName = student['classSection']?['name'] ?? '';
                            final classLabel = className != 'Unassigned' ? '$className-$secName' : 'No Class';

                            final List<dynamic> feeRecords = student['feeRecords'] ?? [];

                            // Calculate individual outstanding
                            double studentOutstanding = 0.0;
                            for (var r in feeRecords) {
                              studentOutstanding += (((r['amount'] as num?)?.toDouble() ?? 0.0) - ((r['paidAmount'] as num?)?.toDouble() ?? 0.0));
                            }

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.shade100),
                              ),
                              child: ExpansionTile(
                                shape: const Border(),
                                title: Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                                subtitle: Text(
                                  'Class: $classLabel • Roll: $rollNo',
                                  style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor, fontSize: 12),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${studentOutstanding.toStringAsFixed(0)}',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: studentOutstanding > 0 ? Colors.redAccent : Colors.green,
                                      ),
                                    ),
                                    Text(
                                      studentOutstanding > 0 ? 'Pending' : 'No Dues',
                                      style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.textSecondaryColor),
                                    )
                                  ],
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Fee Logs', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                                        TextButton.icon(
                                          onPressed: () => _showAddFeeDialog(studentId, name),
                                          icon: const Icon(Icons.add, size: 14),
                                          label: const Text('Add Fee', style: TextStyle(fontSize: 12)),
                                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (feeRecords.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        'No fee records assigned. Tap Add Fee.',
                                        style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor, fontStyle: FontStyle.italic),
                                      ),
                                    )
                                  else
                                    ...feeRecords.map((record) {
                                      final isPaid = record['status'] == 'PAID';
                                      final isPartial = record['status'] == 'PARTIAL';
                                      
                                      final statusColor = isPaid
                                          ? Colors.green
                                          : isPartial
                                              ? Colors.orange
                                              : Colors.redAccent;

                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          border: Border(top: BorderSide(color: Colors.grey.shade50)),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        record['category'] ?? '',
                                                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: statusColor.withOpacity(0.08),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Text(
                                                          record['status'] ?? 'PENDING',
                                                          style: GoogleFonts.outfit(
                                                            fontSize: 9,
                                                            fontWeight: FontWeight.bold,
                                                            color: statusColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Paid: ₹${record['paidAmount'].toStringAsFixed(0)} / Due: ₹${record['amount'].toStringAsFixed(0)}',
                                                    style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor, fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            TextButton.icon(
                                              onPressed: () => _showRecordPaymentDialog(record, name),
                                              icon: const Icon(Icons.edit, size: 14),
                                              label: const Text('Update'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  const Divider(height: 1),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (studentOutstanding > 0) ...[
                                          OutlinedButton.icon(
                                            onPressed: () => _sendPaymentReminder(context, studentId, name, studentOutstanding),
                                            icon: const Icon(Icons.notification_important_outlined, size: 16),
                                            label: Text('Send Reminder', style: GoogleFonts.outfit(fontSize: 12)),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.orange.shade800,
                                              side: BorderSide(color: Colors.orange.shade300),
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        OutlinedButton.icon(
                                          onPressed: () => _sendCustomMessage(context, studentId, name),
                                          icon: const Icon(Icons.mail_outline, size: 16),
                                          label: Text('Send Message', style: GoogleFonts.outfit(fontSize: 12)),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppTheme.primaryColor,
                                            side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.5)),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
}
