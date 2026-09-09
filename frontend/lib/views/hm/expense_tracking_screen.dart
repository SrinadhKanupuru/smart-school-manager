import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/admin_provider.dart';
import '../../core/theme.dart';

class ExpenseTrackingScreen extends StatefulWidget {
  const ExpenseTrackingScreen({super.key});

  @override
  State<ExpenseTrackingScreen> createState() => _ExpenseTrackingScreenState();
}

class _ExpenseTrackingScreenState extends State<ExpenseTrackingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoryCtrl = TextEditingController(text: 'Infrastructure');
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchExpenses();
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  void _add(AdminProvider admin) async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final success = await admin.addExpense(
      category: _categoryCtrl.text.trim(),
      amount: double.tryParse(_amountCtrl.text.trim()) ?? 0.0,
      description: _descCtrl.text.trim(),
    );

    if (mounted) {
      Navigator.pop(context); // Dismiss loading
      if (success) {
        Navigator.pop(context); // Dismiss sheet form
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense logged successfully!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to log expense')),
        );
      }
    }
  }

  void _showAddExpenseForm(AdminProvider admin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Log School Expense', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(height: 24),
                DropdownButtonFormField<String>(
                  value: _categoryCtrl.text,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'Infrastructure', child: Text('Infrastructure')),
                    DropdownMenuItem(value: 'Transportation', child: Text('Transportation')),
                    DropdownMenuItem(value: 'Salary', child: Text('Salary')),
                    DropdownMenuItem(value: 'Event', child: Text('Event')),
                  ],
                  onChanged: (val) => setState(() => _categoryCtrl.text = val!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (₹)', hintText: 'Enter expense amount'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter amount' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Description', hintText: 'Enter expense details'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter details' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _add(admin),
                  child: const Text('Add Expense'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);

    final double totalExpenses = admin.expenses.fold(0.0, (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0.0));

    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      body: SafeArea(
        child: Column(
          children: [
            // Total display card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  Text('Total School Expenses', style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(
                    '₹${totalExpenses.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(color: AppTheme.primaryColor, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: admin.expenses.isEmpty
                  ? Center(child: Text('No expenses recorded.', style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: admin.expenses.length,
                      itemBuilder: (context, index) {
                        final item = admin.expenses[index];
                        final category = item['category'] ?? '';

                        IconData catIcon = Icons.help_outline;
                        Color catColor = Colors.grey;
                        if (category == 'Infrastructure') {
                          catIcon = Icons.home_work;
                          catColor = Colors.purple;
                        } else if (category == 'Transportation') {
                          catIcon = Icons.directions_bus;
                          catColor = Colors.blue;
                        } else if (category == 'Salary') {
                          catIcon = Icons.money;
                          catColor = Colors.green;
                        } else if (category == 'Event') {
                          catIcon = Icons.celebration;
                          catColor = Colors.orange;
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade100),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: catColor.withOpacity(0.08),
                              child: Icon(catIcon, color: catColor, size: 20),
                            ),
                            title: Text(item['description'] ?? '', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                            subtitle: Text('$category • ${item['date']?.toString().substring(0,10)}', style: GoogleFonts.outfit(fontSize: 12)),
                            trailing: Text(
                              '₹${((item['amount'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(0)}',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimaryColor),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: ElevatedButton(
                onPressed: () => _showAddExpenseForm(admin),
                child: const Text('Add Expense Entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
