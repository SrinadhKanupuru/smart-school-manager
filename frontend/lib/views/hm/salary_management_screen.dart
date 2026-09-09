import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/admin_provider.dart';
import '../../providers/school_provider.dart';
import '../../core/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/api_client.dart';
import '../../core/constants.dart';

class SalaryManagementScreen extends StatefulWidget {
  const SalaryManagementScreen({super.key});

  @override
  State<SalaryManagementScreen> createState() => _SalaryManagementScreenState();
}

class _SalaryManagementScreenState extends State<SalaryManagementScreen> {
  late String _selectedMonth;
  late int _selectedYear;

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final List<int> _years = [2025, 2026, 2027];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = _months[now.month - 1];
    _selectedYear = now.year;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final admin = Provider.of<AdminProvider>(context, listen: false);
      admin.fetchSalaries();
      admin.fetchSalaryTemplates();
      admin.fetchSalaryComponents();
      Provider.of<SchoolProvider>(context, listen: false).fetchUsers(role: 'TEACHER');
    });
  }

  void _generate(AdminProvider admin) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final success = await admin.generateSalaries(_selectedMonth, _selectedYear);

    if (mounted) {
      Navigator.pop(context); // Dismiss loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
              ? 'Salaries generated successfully for $_selectedMonth $_selectedYear!' 
              : 'Salaries generation failed'),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
    }
  }

  void _pay(AdminProvider admin, String id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final success = await admin.paySalary(id);

    if (mounted) {
      Navigator.pop(context); // Dismiss loading
      Navigator.pop(context); // Dismiss details dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Salary disbursed!' : 'Failed to disburse salary'),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
    }
  }

  void _showAdjustmentsDialog(BuildContext context, AdminProvider admin, Map<String, dynamic> record) {
    final formKey = GlobalKey<FormState>();
    final bonusCtrl = TextEditingController(text: (record['bonus'] ?? 0.0).toString());
    final allowancesCtrl = TextEditingController(text: (record['allowances'] ?? 0.0).toString());
    final loanCtrl = TextEditingController(text: (record['loanDeduction'] ?? 0.0).toString());
    final remarksCtrl = TextEditingController(text: record['remarks'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Adjust Payroll Details',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: bonusCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Bonus (₹)'),
                          validator: (val) => val == null || val.isEmpty || double.tryParse(val) == null ? 'Invalid' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: allowancesCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Allowances (₹)'),
                          validator: (val) => val == null || val.isEmpty || double.tryParse(val) == null ? 'Invalid' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: loanCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Custom Loan Repayment (₹)'),
                    validator: (val) => val == null || val.isEmpty || double.tryParse(val) == null ? 'Invalid' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: remarksCtrl,
                    decoration: const InputDecoration(labelText: 'Remarks / Adjustments Description'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (c) => const Center(child: CircularProgressIndicator()),
                      );

                      final success = await admin.updateSalaryRecord(
                        record['id'],
                        bonus: double.tryParse(bonusCtrl.text),
                        allowances: double.tryParse(allowancesCtrl.text),
                        loanDeduction: double.tryParse(loanCtrl.text),
                        remarks: remarksCtrl.text.trim(),
                      );

                      if (context.mounted) {
                        Navigator.pop(context); // Pop loader
                        Navigator.pop(context); // Pop bottom sheet
                        Navigator.pop(context); // Pop details dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Adjustments saved successfully!' : 'Failed to save adjustments'),
                            backgroundColor: success ? Colors.green : Colors.redAccent,
                          ),
                        );
                      }
                    },
                    child: const Text('Save Adjustments'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPayslipDetails(BuildContext context, AdminProvider admin, Map<String, dynamic> record) {
    final teacher = record['teacher'] ?? {};
    final user = teacher['user'] ?? {};
    final name = user['fullName'] ?? 'Teacher';
    final isPaid = record['status'] == 'PIAD' || record['status'] == 'PAID';

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
            if (!isPaid) ...[
              TextButton(
                onPressed: () => _showAdjustmentsDialog(context, admin, record),
                child: const Text('Adjust Details', style: TextStyle(color: Colors.orange)),
              ),
              ElevatedButton(
                onPressed: () => _pay(admin, record['id']),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Disburse Salary'),
              ),
            ] else ...[
              const Text('Paid out', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ]
          ],
        );
      },
    );
  }

  void _showCreateComponentDialog(BuildContext context, AdminProvider admin) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final categoriesList = admin.salaryCategories.isNotEmpty
        ? admin.salaryCategories
        : [
            'FIXED_EARNING',
            'VARIABLE_EARNING',
            'REIMBURSEMENT',
            'PERQUISITE',
            'PRE_TAX_DEDUCTION',
            'POST_TAX_DEDUCTION',
            'STATUTORY_DEDUCTION',
            'NON_STATUTORY_DEDUCTION',
            'EMPLOYER_CONTRIBUTION'
          ];
    String category = categoriesList.contains('FIXED_EARNING') ? 'FIXED_EARNING' : categoriesList.first;
    bool isTaxable = true;
    bool isProrated = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setStateDialog) {
          return AlertDialog(
            title: Text('New Salary Component', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Component Name', hintText: 'e.g. Special Allowance'),
                      validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: categoriesList.map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(
                              cat.replaceAll('_', ' '),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          )).toList(),
                      onChanged: (val) {
                        setStateDialog(() {
                          category = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text('Is Taxable', style: GoogleFonts.outfit(fontSize: 14)),
                      value: isTaxable,
                      onChanged: (val) {
                        setStateDialog(() {
                          isTaxable = val;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    SwitchListTile(
                      title: Text('Is Prorated', style: GoogleFonts.outfit(fontSize: 14)),
                      subtitle: Text('Reduces for LOP/absence if true', style: const TextStyle(fontSize: 11)),
                      value: isProrated,
                      onChanged: (val) {
                        setStateDialog(() {
                          isProrated = val;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final success = await admin.createSalaryComponent(
                    name: nameCtrl.text.trim(),
                    category: category,
                    isTaxable: isTaxable,
                    isProrated: isProrated,
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Component created!' : 'Failed to create component'),
                        backgroundColor: success ? Colors.green : Colors.redAccent,
                      ),
                    );
                  }
                },
                child: const Text('Create'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showCreateTemplateDialog(BuildContext context, AdminProvider admin) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final overtimeMultiplierCtrl = TextEditingController();

    // Track selections for each component
    final Map<String, bool> enabled = {};
    final Map<String, String> calcTypes = {};
    final Map<String, TextEditingController> values = {};
    final Map<String, TextEditingController> calculateOnMaxList = {};
    final Map<String, TextEditingController> activeOnlyIfGrossLessThanList = {};

    // Initialize state
    for (final comp in admin.salaryComponents) {
      final id = comp['id'].toString();
      enabled[id] = false;
      calcTypes[id] = 'FLAT_AMOUNT';
      values[id] = TextEditingController(text: '0.0');
      calculateOnMaxList[id] = TextEditingController();
      activeOnlyIfGrossLessThanList[id] = TextEditingController();
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setStateDialog) {
          return AlertDialog(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    'Create Salary Template',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    _showCreateComponentDialog(context, admin);
                    // Close this dialog to let them see component creation, then they can re-open
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add Component', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                )
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Template Name', hintText: 'e.g. Senior Teacher CTC'),
                        validator: (val) => val == null || val.isEmpty ? 'Template name is required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descCtrl,
                        decoration: const InputDecoration(labelText: 'Description', hintText: 'e.g. Standard 50/40 salary breakdown'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: overtimeMultiplierCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Overtime Multiplier (Optional)', hintText: 'e.g. 1.5'),
                      ),
                      const SizedBox(height: 16),
                      Text('Configure Components', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryColor)),
                      const SizedBox(height: 8),
                      if (admin.salaryComponents.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text('No salary components found. Add one above!', style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey)),
                          ),
                        )
                      else
                        ...admin.salaryComponents.map((comp) {
                          final id = comp['id'].toString();
                          final isEnabled = enabled[id] ?? false;
                          final categoryStr = comp['category'].toString();
                          final isDeduction = categoryStr.contains('DEDUCTION');

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  CheckboxListTile(
                                    title: Text(comp['name'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                                    subtitle: Text(
                                      categoryStr.replaceAll('_', ' '),
                                      style: TextStyle(fontSize: 11, color: isDeduction ? Colors.redAccent : Colors.green),
                                    ),
                                    value: isEnabled,
                                    onChanged: (val) {
                                      setStateDialog(() {
                                        enabled[id] = val ?? false;
                                      });
                                    },
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  if (isEnabled) ...[
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      value: calcTypes[id] ?? 'FLAT_AMOUNT',
                                      decoration: const InputDecoration(labelText: 'Calculation Type', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                                      items: const [
                                        DropdownMenuItem(value: 'FLAT_AMOUNT', child: Text('Flat Amount (₹)', overflow: TextOverflow.ellipsis, maxLines: 1)),
                                        DropdownMenuItem(value: 'PERCENTAGE_OF_CTC', child: Text('% of Monthly CTC', overflow: TextOverflow.ellipsis, maxLines: 1)),
                                        DropdownMenuItem(value: 'PERCENTAGE_OF_BASIC', child: Text('% of Basic Pay', overflow: TextOverflow.ellipsis, maxLines: 1)),
                                        DropdownMenuItem(value: 'PERCENTAGE_OF_GROSS', child: Text('% of Gross Earnings', overflow: TextOverflow.ellipsis, maxLines: 1)),
                                        DropdownMenuItem(value: 'SLAB_BASED', child: Text('Slab Based (e.g. PT)', overflow: TextOverflow.ellipsis, maxLines: 1)),
                                        DropdownMenuItem(value: 'STATUTORY_AUTO', child: Text('Statutory Auto', overflow: TextOverflow.ellipsis, maxLines: 1)),
                                      ],
                                      onChanged: (val) {
                                        setStateDialog(() {
                                          calcTypes[id] = val!;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: values[id],
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'Value (₹ or %)', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                                      validator: (val) => val == null || val.isEmpty || double.tryParse(val) == null ? 'Enter a valid number' : null,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: calculateOnMaxList[id],
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(labelText: 'Max Cap (Optional)', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextFormField(
                                            controller: activeOnlyIfGrossLessThanList[id],
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(labelText: 'Gross Limit (Optional)', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  // Build components list
                  final List<Map<String, dynamic>> selectedComps = [];
                  enabled.forEach((compId, isChecked) {
                    if (isChecked) {
                      final val = double.tryParse(values[compId]?.text ?? '0.0') ?? 0.0;
                      final maxCap = double.tryParse(calculateOnMaxList[compId]?.text ?? '');
                      final grossLimit = double.tryParse(activeOnlyIfGrossLessThanList[compId]?.text ?? '');

                      selectedComps.add({
                        'componentId': compId,
                        'calculationType': calcTypes[compId] ?? 'FLAT_AMOUNT',
                        'value': val,
                        if (maxCap != null) 'calculateOnMax': maxCap,
                        if (grossLimit != null) 'activeOnlyIfGrossLessThan': grossLimit,
                      });
                    }
                  });

                  if (selectedComps.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select at least one component to include.'), backgroundColor: Colors.redAccent),
                    );
                    return;
                  }

                  final success = await admin.createSalaryTemplate(
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : null,
                    components: selectedComps,
                    overtimeMultiplier: double.tryParse(overtimeMultiplierCtrl.text),
                  );

                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Template created successfully!' : 'Failed to create template'),
                        backgroundColor: success ? Colors.green : Colors.redAccent,
                      ),
                    );
                  }
                },
                child: const Text('Create Template'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAssignTemplateDialog(BuildContext context, AdminProvider admin, Map<String, dynamic> teacherProfile, VoidCallback onSuccess) {
    final user = teacherProfile['user'] ?? {};
    final name = user['fullName'] ?? 'Teacher';
    String? currentTemplateId = teacherProfile['salaryTemplateId'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Assign Template', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Select a payroll template to assign to $name:', style: GoogleFonts.outfit(fontSize: 14)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: currentTemplateId,
              decoration: const InputDecoration(labelText: 'Salary Template'),
              hint: const Text('Fallback Basic Salary'),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text(
                    'No Template (Fallback Basic Salary)',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                ...admin.salaryTemplates.map((t) => DropdownMenuItem<String>(
                      value: t['id'],
                      child: Text(
                        t['name'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    )),
              ],
              onChanged: (val) => currentTemplateId = val,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final success = await admin.assignSalaryTemplate(teacherProfile['id'], currentTemplateId);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Template assigned successfully!' : 'Failed to assign template'),
                    backgroundColor: success ? Colors.green : Colors.redAccent,
                  ),
                );
                if (success) {
                  onSuccess();
                }
              }
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _showMonthlyVariablesSheet(BuildContext context, AdminProvider admin, Map<String, dynamic> teacherProfile, String name) {
    final teacherId = teacherProfile['id'].toString();
    final formKey = GlobalKey<FormState>();
    final amountCtrl = TextEditingController();
    final remarksCtrl = TextEditingController();
    String? selectedComponentId;
    bool isArrear = false;

    // Fetch existing variable pays
    admin.fetchVariablePays(teacherId, month: _selectedMonth, year: _selectedYear);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Monthly Variables for $name',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '$_selectedMonth $_selectedYear',
                        style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondaryColor),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(height: 24),

                      // Existing Variable Pays List
                      Text(
                        'Configured Variables:',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 8),
                      Consumer<AdminProvider>(
                        builder: (context, provider, child) {
                          if (provider.variablePays.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'No variables added for this month.',
                                  style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey),
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: provider.variablePays.length,
                            itemBuilder: (c, idx) {
                              final vp = provider.variablePays[idx];
                              final comp = vp['component'] ?? {};
                              final amount = vp['amount'] ?? 0.0;
                              final isArr = vp['isArrear'] ?? false;
                              final isDed = comp['category']?.toString().contains('DEDUCTION') ?? false;

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  '${vp['remarks'] ?? comp['name']} ${isArr ? '(Arrear)' : ''}',
                                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  comp['category']?.toString().replaceAll('_', ' ') ?? '',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${isDed ? "-" : "+"}₹${amount.toStringAsFixed(2)}',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        color: isDed ? Colors.redAccent : Colors.green,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      onPressed: () async {
                                        final success = await provider.deleteVariablePay(
                                          vp['id'].toString(),
                                          teacherId,
                                          month: _selectedMonth,
                                          year: _selectedYear,
                                        );
                                        if (sheetCtx.mounted && success) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Variable pay item removed!'), backgroundColor: Colors.green),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),

                      const Divider(height: 24),
                      Text(
                        'Add Monthly Variable:',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 8),

                      Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: selectedComponentId,
                              decoration: const InputDecoration(labelText: 'Salary Component'),
                              hint: const Text('Select Component'),
                              items: admin.salaryComponents.map((c) {
                                return DropdownMenuItem<String>(
                                  value: c['id'].toString(),
                                  child: Text(
                                    c['name'].toString(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setSheetState(() {
                                  selectedComponentId = val;
                                });
                              },
                              validator: (val) => val == null ? 'Please select a component' : null,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: amountCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(labelText: 'Amount (₹)'),
                                    validator: (val) => val == null || val.isEmpty || double.tryParse(val) == null ? 'Enter dynamic amount' : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Row(
                                  children: [
                                    const Text('Is Arrear'),
                                    Checkbox(
                                      value: isArrear,
                                      onChanged: (val) {
                                        setSheetState(() {
                                          isArrear = val ?? false;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: remarksCtrl,
                              decoration: const InputDecoration(labelText: 'Remarks / Description (Optional)'),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;
                                final success = await admin.createVariablePay(
                                  teacherId: teacherId,
                                  componentId: selectedComponentId!,
                                  month: _selectedMonth,
                                  year: _selectedYear,
                                  amount: double.parse(amountCtrl.text),
                                  remarks: remarksCtrl.text.trim().isNotEmpty ? remarksCtrl.text.trim() : null,
                                  isArrear: isArrear,
                                );
                                if (success) {
                                  amountCtrl.clear();
                                  remarksCtrl.clear();
                                  setSheetState(() {
                                    selectedComponentId = null;
                                    isArrear = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Variable pay item added successfully!'), backgroundColor: Colors.green),
                                  );
                                }
                              },
                              child: const Text('Add Item'),
                            ),
                          ],
                        ),
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

  Widget _buildPayslipRow(String label, String value, {bool isDeduction = false, bool isAddition = false}) {
    Color valColor = AppTheme.textPrimaryColor;
    if (isDeduction) valColor = Colors.redAccent;
    if (isAddition) valColor = Colors.green;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondaryColor)),
          Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: valColor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);
    final schoolProvider = Provider.of<SchoolProvider>(context);

    // Filter salaries for selected month & year
    final selectedSalaries = admin.salaries.where((s) => s['month'] == _selectedMonth && s['year'] == _selectedYear).toList();
    final double totalAmount = selectedSalaries.fold(0.0, (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0.0));
    final int teachersCount = selectedSalaries.map((s) => s['teacherId']).toSet().length;

    // Filter teachers for Staff Mapping
    final teachers = schoolProvider.users.where((u) => u['teacherProfile'] != null).toList();
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Salary Management'),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Payroll', icon: Icon(Icons.payment)),
              Tab(text: 'Components', icon: Icon(Icons.extension_outlined)),
              Tab(text: 'Templates', icon: Icon(Icons.settings_suggest)),
              Tab(text: 'Staff Mapping', icon: Icon(Icons.people_outline)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Payroll List
            SafeArea(
              child: Column(
                children: [
                  // Month / Year selectors
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedMonth,
                            decoration: const InputDecoration(labelText: 'Month', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                            items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedMonth = val!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectedYear,
                            decoration: const InputDecoration(labelText: 'Year', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                            items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedYear = val!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Top overview box
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
                              Text('Total Staff Paid', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                '$teachersCount',
                                style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: Colors.white24,
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Amount', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                '₹${totalAmount.toStringAsFixed(0)}',
                                style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  if (selectedSalaries.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final ids = selectedSalaries.map<String>((s) => s['id'].toString()).toList();
                                final success = await admin.advanceSalaryStatus(ids, 'APPROVED');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(success ? 'Approved all salaries!' : 'Failed to approve'), backgroundColor: success ? Colors.green : Colors.redAccent),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
                              icon: const Icon(Icons.check_circle_outline, size: 16),
                              label: const Text('Approve All'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final ids = selectedSalaries.map<String>((s) => s['id'].toString()).toList();
                                final success = await admin.advanceSalaryStatus(ids, 'PAID');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(success ? 'Disbursed all salaries!' : 'Failed to disburse'), backgroundColor: success ? Colors.green : Colors.redAccent),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              icon: const Icon(Icons.payment, size: 16),
                              label: const Text('Disburse All'),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Expanded(
                    child: selectedSalaries.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'No payroll records generated for $_selectedMonth $_selectedYear.',
                                  style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => _generate(admin),
                                  icon: const Icon(Icons.rocket_launch_outlined, size: 18),
                                  label: Text('Generate for $_selectedMonth $_selectedYear'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: selectedSalaries.length,
                            itemBuilder: (context, index) {
                              final record = selectedSalaries[index];
                              final teacher = record['teacher'] ?? {};
                              final user = teacher['user'] ?? {};
                              final name = user['fullName'] ?? 'Teacher';
                              final isPaid = record['status'] == 'PIAD' || record['status'] == 'PAID';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 1,
                                child: InkWell(
                                  onTap: () => _showPayslipDetails(context, admin, record),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: AppTheme.primaryColor.withOpacity(0.08),
                                          child: Text(name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                                              Text(
                                                'Basic: ₹${(record['baseSalary'] ?? 0).toStringAsFixed(0)} | Deduction: ₹${(record['lopDeduction'] ?? 0).toStringAsFixed(0)}',
                                                style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '₹${(record['amount'] as num?)?.toDouble().toStringAsFixed(0)}',
                                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor),
                                            ),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: isPaid 
                                                    ? Colors.green.withOpacity(0.08) 
                                                    : (record['status'] == 'APPROVED' ? Colors.blue.withOpacity(0.08) : Colors.amber.withOpacity(0.08)),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                record['status'].toString(),
                                                style: GoogleFonts.outfit(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: isPaid 
                                                      ? Colors.green 
                                                      : (record['status'] == 'APPROVED' ? Colors.blue : Colors.orange),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),

            // Tab 2: Salary Components Management
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Salary Components', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showCreateComponentDialog(context, admin),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Component'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: admin.salaryComponents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.extension_outlined, size: 48, color: Colors.grey),
                                const SizedBox(height: 12),
                                Text(
                                  'No custom salary components created yet.',
                                  style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: admin.salaryComponents.length,
                            itemBuilder: (context, index) {
                              final component = admin.salaryComponents[index];
                              final isEarning = !component['category'].toString().contains('DEDUCTION');
                              final isTaxable = component['isTaxable'] ?? true;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 1,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  title: Text(
                                    component['name'] ?? 'Component',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isEarning ? Colors.green.withOpacity(0.08) : Colors.red.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            isEarning ? 'Earning' : 'Deduction',
                                            style: GoogleFonts.outfit(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isEarning ? Colors.green.shade700 : Colors.red.shade700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            isTaxable ? 'Taxable' : 'Tax Exempt',
                                            style: GoogleFonts.outfit(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () async {
                                      final deleted = await admin.deleteSalaryComponent(component['id']);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(deleted ? 'Component deleted!' : 'Failed to delete component (It might be used in a template).'),
                                            backgroundColor: deleted ? Colors.green : Colors.redAccent,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),

            // Tab 3: Salary Templates Management
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Salary Templates', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showCreateTemplateDialog(context, admin),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Template'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: admin.salaryTemplates.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.settings_suggest_outlined, size: 48, color: Colors.grey),
                                const SizedBox(height: 12),
                                Text(
                                  'No custom salary templates created yet.',
                                  style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: admin.salaryTemplates.length,
                            itemBuilder: (context, index) {
                              final template = admin.salaryTemplates[index];
                              final components = template['components'] as List? ?? [];

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              template['name'] ?? 'Template Name',
                                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                            onPressed: () async {
                                              final deleted = await admin.deleteSalaryTemplate(template['id']);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(deleted ? 'Template deleted!' : 'Failed to delete template (It might be assigned to a teacher).'),
                                                    backgroundColor: deleted ? Colors.green : Colors.redAccent,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      if (template['description'] != null) ...[
                                        Text(
                                          template['description'],
                                          style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      const Divider(),
                                      const SizedBox(height: 8),
                                      Text('Components Layout:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryColor)),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: components.map<Widget>((tc) {
                                          final comp = tc['component'] ?? {};
                                          final isPct = tc['calculationType'] == 'PERCENTAGE_OF_BASIC' || tc['calculationType'] == 'PERCENTAGE_OF_GROSS';
                                          final String typeLabel = tc['calculationType'] == 'PERCENTAGE_OF_BASIC'
                                              ? 'of Basic'
                                              : (tc['calculationType'] == 'PERCENTAGE_OF_GROSS' ? 'of Gross' : (tc['calculationType'] == 'SLAB_BASED' ? 'Slab' : 'Fixed'));
                                          final isEarning = !comp['category'].toString().contains('DEDUCTION');

                                          return Chip(
                                            label: Text(
                                              '${comp['name']}: ${tc['value']}${isPct ? '%' : ''} ($typeLabel)',
                                              style: GoogleFonts.outfit(fontSize: 11, color: isEarning ? Colors.green.shade800 : Colors.red.shade800),
                                            ),
                                            backgroundColor: isEarning ? Colors.green.withOpacity(0.08) : Colors.red.withOpacity(0.08),
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),

            // Tab 3: Staff Salary Mapping
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Assign Templates to Staff', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: teachers.isEmpty
                        ? Center(
                            child: Text(
                              'No teachers or staff members profiles found.',
                              style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: teachers.length,
                            itemBuilder: (context, index) {
                              final userObj = teachers[index];
                              final name = userObj['fullName'] ?? 'Teacher';
                              final teacherProfile = userObj['teacherProfile'] ?? {};
                              final salary = teacherProfile['salaryAmount'] ?? 0.0;
                              final template = teacherProfile['salaryTemplate'] ?? {};
                              final hasTemplate = teacherProfile['salaryTemplateId'] != null;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: AppTheme.primaryColor.withOpacity(0.08),
                                        child: Text(name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                                            const SizedBox(height: 4),
                                            Text('CTC: ₹${salary.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor)),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: hasTemplate ? AppTheme.primaryColor.withOpacity(0.08) : Colors.grey.withOpacity(0.08),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                hasTemplate ? (template['name'] ?? 'Assigned Template') : 'No Template (Fallback Basic Pay)',
                                                style: GoogleFonts.outfit(fontSize: 11, color: hasTemplate ? AppTheme.primaryColor : Colors.grey.shade700, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              _showAssignTemplateDialog(
                                                context,
                                                admin,
                                                teacherProfile,
                                                () {
                                                  // Refresh the list of teachers
                                                  schoolProvider.fetchUsers(role: 'TEACHER');
                                                },
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              minimumSize: const Size(80, 36),
                                            ),
                                            child: const Text('Assign'),
                                          ),
                                          const SizedBox(height: 8),
                                          OutlinedButton(
                                            onPressed: () {
                                              _showMonthlyVariablesSheet(
                                                context,
                                                admin,
                                                teacherProfile,
                                                name,
                                              );
                                            },
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              minimumSize: const Size(80, 36),
                                            ),
                                            child: const Text('Variables'),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
