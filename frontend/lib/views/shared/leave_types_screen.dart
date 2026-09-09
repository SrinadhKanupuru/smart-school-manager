import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/admin_provider.dart';
import '../../core/theme.dart';

class LeaveTypesScreen extends StatefulWidget {
  const LeaveTypesScreen({super.key});

  @override
  State<LeaveTypesScreen> createState() => _LeaveTypesScreenState();
}

class _LeaveTypesScreenState extends State<LeaveTypesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchLeaveTypes();
    });
  }

  void _showLeaveTypeDialog({Map<String, dynamic>? leaveType}) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: leaveType?['name'] ?? '');
    final codeCtrl = TextEditingController(text: leaveType?['code'] ?? '');
    final maxDaysCtrl = TextEditingController(text: leaveType?['maxDays']?.toString() ?? '12');
    final maxDaysMidCtrl = TextEditingController(text: leaveType?['maxDaysMid']?.toString() ?? '');
    final maxDaysSeniorCtrl = TextEditingController(text: leaveType?['maxDaysSenior']?.toString() ?? '');
    String period = leaveType?['period'] ?? 'YEARLY';
    bool isPaid = leaveType?['isPaid'] ?? true;
    bool isUnpaid = leaveType?['isUnpaid'] ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                leaveType == null ? 'Add Leave Type' : 'Edit Leave Type',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Name*',
                          hintText: 'e.g. Sick Leave, Unpaid Leave',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter name';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: codeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Short Code*',
                          hintText: 'e.g. SICK, UNPAID, CASUAL',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter code';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: period,
                        decoration: const InputDecoration(
                          labelText: 'Limit Period*',
                        ),
                        items: const [
                          DropdownMenuItem(value: 'YEARLY', child: Text('Yearly Limit')),
                          DropdownMenuItem(value: 'MONTHLY', child: Text('Monthly Limit')),
                        ],
                        onChanged: (val) {
                          setState(() {
                            period = val!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: maxDaysCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: period == 'YEARLY' ? 'Max Days Limit (Annual)*' : 'Max Days Limit (Monthly)*',
                          hintText: period == 'YEARLY' ? 'e.g. 12' : 'e.g. 2',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter limit';
                          if (int.tryParse(value) == null) return 'Please enter a valid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: maxDaysMidCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Max Days (Mid-Level 2-5 yrs exp)',
                          hintText: 'Leave empty for same as base',
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty && int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: maxDaysSeniorCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Max Days (Senior >5 yrs exp)',
                          hintText: 'Leave empty for same as base',
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty && int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: Text('Is Paid?', style: GoogleFonts.outfit(fontSize: 14)),
                        subtitle: Text('Salary will not be deducted', style: GoogleFonts.outfit(fontSize: 11)),
                        value: isPaid,
                        onChanged: (val) {
                          setState(() {
                            isPaid = val;
                            if (isPaid) isUnpaid = false;
                          });
                        },
                      ),
                      SwitchListTile(
                        title: Text('Is Unpaid / Loss of Pay?', style: GoogleFonts.outfit(fontSize: 14)),
                        subtitle: Text('Deducted from salary directly', style: GoogleFonts.outfit(fontSize: 11)),
                        value: isUnpaid,
                        onChanged: (val) {
                          setState(() {
                            isUnpaid = val;
                            if (isUnpaid) isPaid = false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final provider = Provider.of<AdminProvider>(context, listen: false);
                    bool success;

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (c) => const Center(child: CircularProgressIndicator()),
                    );

                    final parsedMaxDays = int.parse(maxDaysCtrl.text.trim());
                    final parsedMaxDaysMid = maxDaysMidCtrl.text.trim().isNotEmpty ? int.parse(maxDaysMidCtrl.text.trim()) : null;
                    final parsedMaxDaysSenior = maxDaysSeniorCtrl.text.trim().isNotEmpty ? int.parse(maxDaysSeniorCtrl.text.trim()) : null;

                    if (leaveType == null) {
                      success = await provider.createLeaveType(
                        name: nameCtrl.text.trim(),
                        code: codeCtrl.text.trim(),
                        isPaid: isPaid,
                        isUnpaid: isUnpaid,
                        maxDays: parsedMaxDays,
                        period: period,
                        maxDaysMid: parsedMaxDaysMid,
                        maxDaysSenior: parsedMaxDaysSenior,
                      );
                    } else {
                      success = await provider.updateLeaveType(
                        leaveType['id'],
                        name: nameCtrl.text.trim(),
                        code: codeCtrl.text.trim(),
                        isPaid: isPaid,
                        isUnpaid: isUnpaid,
                        maxDays: parsedMaxDays,
                        period: period,
                        maxDaysMid: parsedMaxDaysMid,
                        maxDaysSenior: parsedMaxDaysSenior,
                      );
                    }

                    if (context.mounted) {
                      Navigator.pop(context); // Pop loading dialog
                      Navigator.pop(context); // Pop alert dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Leave type saved!' : 'Failed to save leave type'),
                          backgroundColor: success ? Colors.green : Colors.redAccent,
                        ),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteLeaveType(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Leave Type'),
        content: const Text('Are you sure you want to delete this leave type? Approved leaves of this type will lose their links.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      final success = await Provider.of<AdminProvider>(context, listen: false).deleteLeaveType(id);

      if (mounted) {
        Navigator.pop(context); // Pop loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Leave type deleted!' : 'Failed to delete leave type'),
            backgroundColor: success ? Colors.green : Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Leave Types Configuration',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppTheme.textPrimaryColor),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.leaveTypes.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }

          if (provider.leaveTypes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No custom leave types configured yet.',
                    style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Standard Casual & Sick limits will be used.',
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.leaveTypes.length,
            itemBuilder: (context, index) {
              final lt = provider.leaveTypes[index];
              final isPaid = lt['isPaid'] ?? true;
              final isUnpaid = lt['isUnpaid'] ?? false;
              final code = lt['code'] ?? '';
              final name = lt['name'] ?? '';

              Color typeColor = isPaid ? Colors.green : (isUnpaid ? Colors.redAccent : Colors.grey);
              String typeText = isPaid ? 'PAID' : (isUnpaid ? 'UNPAID / LOP' : 'STANDARD');

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 1,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          typeText,
                          style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: typeColor),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Code: $code • Limit: ${lt['maxDays'] ?? 12} days/${(lt['period'] ?? 'YEARLY').toString().toLowerCase() == 'yearly' ? 'year' : 'month'}',
                          style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                        ),
                        if (lt['maxDaysMid'] != null || lt['maxDaysSenior'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              'Exp Limits - Mid (2-5 yrs): ${lt['maxDaysMid'] ?? lt['maxDays']} • Sr (>5 yrs): ${lt['maxDaysSenior'] ?? lt['maxDays']}',
                              style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.primaryColor.withOpacity(0.8), fontWeight: FontWeight.w500),
                            ),
                          ),
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
                        onPressed: () => _showLeaveTypeDialog(leaveType: lt),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        onPressed: () => _deleteLeaveType(lt['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLeaveTypeDialog(),
        backgroundColor: AppTheme.primaryColor,
        label: Text('Add Leave Type', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
