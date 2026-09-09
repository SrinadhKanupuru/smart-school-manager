import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_provider.dart';
import '../../providers/school_provider.dart';
import '../../core/theme.dart';

class LoanAdvancesScreen extends StatefulWidget {
  const LoanAdvancesScreen({super.key});

  @override
  State<LoanAdvancesScreen> createState() => _LoanAdvancesScreenState();
}

class _LoanAdvancesScreenState extends State<LoanAdvancesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      provider.fetchLoans();
      provider.fetchLoanSkips();
      provider.fetchLoanForeclosures();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isAdmin(String role) {
    return role == 'CORRESPONDENT' || role == 'PRINCIPAL' || role == 'HM';
  }

  void _showApplyLoanSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final amountCtrl = TextEditingController();
    final installmentsCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Apply for Salary Advance / Loan',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Loan Amount (₹)*',
                      prefixIcon: Icon(Icons.currency_rupee, color: AppTheme.primaryColor),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Please enter loan amount';
                      final amt = double.tryParse(value);
                      if (amt == null || amt <= 0) return 'Please enter a positive amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: installmentsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Deduction Installments (Months)*',
                      prefixIcon: Icon(Icons.date_range, color: AppTheme.primaryColor),
                      hintText: 'e.g. 6 (deducted monthly)',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Please enter installments count';
                      final inst = int.tryParse(value);
                      if (inst == null || inst <= 0) return 'Please enter at least 1 month';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: reasonCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Reason for Advance*',
                      hintText: 'Describe medical, tuition fee, home rent reasons...',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Please describe the reason';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      
                      final amount = double.parse(amountCtrl.text.trim());
                      final installments = int.parse(installmentsCtrl.text.trim());
                      final reason = reasonCtrl.text.trim();

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => const Center(child: CircularProgressIndicator()),
                      );

                      final success = await Provider.of<AdminProvider>(context, listen: false).applyLoan(
                        amount: amount,
                        installments: installments,
                        reason: reason,
                      );

                      if (context.mounted) {
                        Navigator.pop(context); // Pop loading dialog
                        Navigator.pop(context); // Pop bottom sheet
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Loan application submitted!' : 'Failed to submit application'),
                            backgroundColor: success ? Colors.green : Colors.redAccent,
                          ),
                        );
                      }
                    },
                    child: const Text('Submit Application'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRequestSkipSheet(BuildContext context, String loanId) {
    final formKey = GlobalKey<FormState>();
    int fromMonth = DateTime.now().month;
    int fromYear = DateTime.now().year;
    int toMonth = DateTime.now().month;
    int toYear = DateTime.now().year;
    final reasonCtrl = TextEditingController();

    final currentYear = DateTime.now().year;
    final years = List.generate(3, (i) => currentYear + i);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Request EMI Pause (Skip)',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: fromMonth,
                              decoration: const InputDecoration(labelText: 'From Month'),
                              items: List.generate(12, (index) {
                                return DropdownMenuItem(
                                  value: index + 1,
                                  child: Text(_months[index]),
                                );
                              }),
                              onChanged: (val) {
                                if (val != null) setModalState(() => fromMonth = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: fromYear,
                              decoration: const InputDecoration(labelText: 'From Year'),
                              items: years.map((y) {
                                return DropdownMenuItem(
                                  value: y,
                                  child: Text(y.toString()),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setModalState(() => fromYear = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: toMonth,
                              decoration: const InputDecoration(labelText: 'To Month'),
                              items: List.generate(12, (index) {
                                return DropdownMenuItem(
                                  value: index + 1,
                                  child: Text(_months[index]),
                                );
                              }),
                              onChanged: (val) {
                                if (val != null) setModalState(() => toMonth = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: toYear,
                              decoration: const InputDecoration(labelText: 'To Year'),
                              items: years.map((y) {
                                return DropdownMenuItem(
                                  value: y,
                                  child: Text(y.toString()),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setModalState(() => toYear = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: reasonCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Reason for pause*',
                          hintText: 'e.g. Festival expenses, Medical emergency...',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Please enter a reason';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          
                          if ((toYear * 12 + toMonth) < (fromYear * 12 + fromMonth)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('End month/year must be after or equal to start month/year'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => const Center(child: CircularProgressIndicator()),
                          );

                          final success = await Provider.of<AdminProvider>(context, listen: false).applyLoanSkip(
                            loanId: loanId,
                            fromMonth: fromMonth,
                            fromYear: fromYear,
                            toMonth: toMonth,
                            toYear: toYear,
                            reason: reasonCtrl.text.trim(),
                          );

                          if (context.mounted) {
                            Navigator.pop(context); // Pop loading dialog
                            Navigator.pop(context); // Pop sheet
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success ? 'EMI Skip request submitted!' : 'Failed to submit request'),
                                backgroundColor: success ? Colors.green : Colors.redAccent,
                              ),
                            );
                          }
                        },
                        child: const Text('Submit Request'),
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

  void _showRequestForeclosureSheet(BuildContext context, String loanId, double outstanding) {
    final formKey = GlobalKey<FormState>();
    final feeCtrl = TextEditingController(text: '0');
    String deductionMethod = 'SALARY_DEDUCTION';
    String deductionMonth = _months[DateTime.now().month - 1];
    int deductionYear = DateTime.now().year;

    final currentYear = DateTime.now().year;
    final years = List.generate(3, (i) => currentYear + i);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Request Loan Foreclosure',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Outstanding Principal Balance: ₹${outstanding.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: feeCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Processing / Foreclosure Fee (₹)',
                          prefixIcon: Icon(Icons.percent, color: AppTheme.primaryColor),
                        ),
                        validator: (value) {
                          if (value != null && value.trim().isNotEmpty) {
                            final fee = double.tryParse(value);
                            if (fee == null || fee < 0) return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: deductionMethod,
                        decoration: const InputDecoration(labelText: 'Settlement Method'),
                        items: const [
                          DropdownMenuItem(value: 'SALARY_DEDUCTION', child: Text('Salary Deduction (Next Payslip)')),
                          DropdownMenuItem(value: 'MANUAL_SETTLEMENT', child: Text('Manual Settlement (UPI / Cheque)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => deductionMethod = val);
                          }
                        },
                      ),
                      if (deductionMethod == 'SALARY_DEDUCTION') ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: deductionMonth,
                                decoration: const InputDecoration(labelText: 'Deduction Month'),
                                items: _months.map((m) {
                                  return DropdownMenuItem(value: m, child: Text(m));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setModalState(() => deductionMonth = val);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: deductionYear,
                                decoration: const InputDecoration(labelText: 'Deduction Year'),
                                items: years.map((y) {
                                  return DropdownMenuItem(value: y, child: Text(y.toString()));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setModalState(() => deductionYear = val);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          final fee = double.tryParse(feeCtrl.text.trim()) ?? 0.0;

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => const Center(child: CircularProgressIndicator()),
                          );

                          final success = await Provider.of<AdminProvider>(context, listen: false).initiateLoanForeclosure(
                            loanId: loanId,
                            processingFee: fee,
                            deductionMethod: deductionMethod,
                            salaryDeductionMonth: deductionMethod == 'SALARY_DEDUCTION' ? deductionMonth : null,
                            salaryDeductionYear: deductionMethod == 'SALARY_DEDUCTION' ? deductionYear : null,
                          );

                          if (context.mounted) {
                            Navigator.pop(context); // Pop loading dialog
                            Navigator.pop(context); // Pop sheet
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success ? 'Foreclosure request submitted!' : 'Failed to submit foreclosure request'),
                                backgroundColor: success ? Colors.green : Colors.redAccent,
                              ),
                            );
                          }
                        },
                        child: const Text('Submit Foreclosure Request'),
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

  void _updateStatus(AdminProvider provider, String id, String status) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final success = await provider.updateLoanStatus(id, status);

    if (mounted) {
      Navigator.pop(context); // Dismiss loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Request marked as $status!' : 'Failed to update request'),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
    }
  }

  void _showSkipActionDialog(BuildContext context, AdminProvider provider, String id, bool approve) {
    final commentCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(approve ? 'Approve EMI Skip' : 'Reject EMI Skip'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(approve 
                ? 'Are you sure you want to approve this pause request? You can leave an optional comment below:'
                : 'Please specify the rejection reason below:'),
              const SizedBox(height: 12),
              TextField(
                controller: commentCtrl,
                decoration: InputDecoration(
                  labelText: approve ? 'Approval Comment (Optional)' : 'Rejection Reason*',
                  hintText: approve ? 'Enjoy your break!' : 'Insufficient balance / history...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final txt = commentCtrl.text.trim();
                if (!approve && txt.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rejection reason is required')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (c) => const Center(child: CircularProgressIndicator()),
                );

                bool success;
                if (approve) {
                  success = await provider.approveLoanSkip(id, approvalComment: txt.isNotEmpty ? txt : null);
                } else {
                  success = await provider.rejectLoanSkip(id, rejectionReason: txt);
                }

                if (context.mounted) {
                  Navigator.pop(context); // Pop loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'EMI Skip status updated!' : 'Failed to update status'),
                      backgroundColor: success ? Colors.green : Colors.redAccent,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: approve ? Colors.green : Colors.redAccent,
              ),
              child: Text(approve ? 'Approve' : 'Reject'),
            ),
          ],
        );
      },
    );
  }

  void _showSettleForeclosureDialog(BuildContext context, AdminProvider provider, String foreclosureId) {
    final refCtrl = TextEditingController();
    final remarkCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Record Manual Settlement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please capture the payment references (UPI, Cheque No, Cash receipt reference) to complete this settlement:'),
              const SizedBox(height: 12),
              TextField(
                controller: refCtrl,
                decoration: const InputDecoration(
                  labelText: 'Transaction Ref ID / Cheque No*',
                  hintText: 'UPI: 27129837912, Cheque: 127923',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: remarkCtrl,
                decoration: const InputDecoration(
                  labelText: 'Settlement Remarks (Optional)',
                  hintText: 'Received cash in office / UPI payment direct',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final refId = refCtrl.text.trim();
                if (refId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaction Ref ID is required')),
                  );
                  return;
                }
                Navigator.pop(ctx);

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (c) => const Center(child: CircularProgressIndicator()),
                );

                final success = await provider.settleManualLoanForeclosure(
                  foreclosureId,
                  referenceId: refId,
                  remarks: remarkCtrl.text.trim().isNotEmpty ? remarkCtrl.text.trim() : null,
                );

                if (context.mounted) {
                  Navigator.pop(context); // Pop loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Loan Foreclosed and Settled!' : 'Failed to record settlement'),
                      backgroundColor: success ? Colors.green : Colors.redAccent,
                    ),
                  );
                }
              },
              child: const Text('Record & Settle'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<SchoolProvider>(context).currentUser?['role'] ?? '';
    final isAdminUser = _isAdmin(userRole);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Loans & Advances',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppTheme.textPrimaryColor),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Active & Applications'),
            Tab(text: 'EMI Pauses'),
            Tab(text: 'Foreclosures'),
          ],
        ),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildLoansTab(provider, isAdminUser),
              _buildSkipsTab(provider, isAdminUser),
              _buildForeclosuresTab(provider, isAdminUser),
            ],
          );
        },
      ),
      floatingActionButton: !isAdminUser
          ? FloatingActionButton.extended(
              onPressed: () => _showApplyLoanSheet(context),
              backgroundColor: AppTheme.primaryColor,
              label: Text('Apply Loan', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
              icon: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildLoansTab(AdminProvider provider, bool isAdminUser) {
    final activeLoans = provider.loans.where((l) => l['status'] == 'APPROVED' && (l['repaidAmount'] as num? ?? 0) < (l['amount'] as num? ?? 0)).toList();
    final double totalOutstanding = activeLoans.fold(0.0, (sum, item) => sum + ((item['amount'] as num) - (item['repaidAmount'] as num)));

    if (provider.isLoading && provider.loans.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    return Column(
      children: [
        if (!isAdminUser) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Outstanding Advance', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  '₹${totalOutstanding.toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                if (activeLoans.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Deductions will apply to your monthly payslip automatically.',
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ],
        Expanded(
          child: provider.loans.isEmpty
              ? Center(
                  child: Text(
                    'No advances or loans found.',
                    style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: provider.loans.length,
                  itemBuilder: (context, index) {
                    final loan = provider.loans[index];
                    final amount = (loan['amount'] as num?)?.toDouble() ?? 0.0;
                    final repaid = (loan['repaidAmount'] as num?)?.toDouble() ?? 0.0;
                    final remaining = amount - repaid;
                    final installments = loan['installments'] ?? 1;
                    final reason = loan['reason'] ?? '';
                    final status = loan['status'] ?? 'PENDING';
                    final dateStr = loan['createdAt'] != null
                        ? DateFormat('dd MMM yyyy').format(DateTime.parse(loan['createdAt']))
                        : '';
                    
                    final teacher = loan['user'] ?? {};
                    final teacherName = teacher['fullName'] ?? 'Staff Member';
                    final isPaused = loan['isPaused'] as bool? ?? false;

                    final double progress = amount > 0 ? (repaid / amount) : 0.0;

                    Color statusColor;
                    if (status == 'APPROVED') statusColor = Colors.green;
                    else if (status == 'REJECTED') statusColor = Colors.redAccent;
                    else statusColor = Colors.orange;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '₹${amount.toStringAsFixed(0)}',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (isPaused) ...[
                                      Container(
                                        margin: const EdgeInsets.only(right: 6),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'PAUSED',
                                          style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue),
                                        ),
                                      ),
                                    ],
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        status,
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (isAdminUser) ...[
                              Text(
                                'Staff: $teacherName',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                            ],
                            Text(
                              'Reason: $reason',
                              style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textPrimaryColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Repayment: $installments Months EMI | Applied: $dateStr',
                              style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondaryColor),
                            ),
                            if (status == 'APPROVED') ...[
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Repaid: ₹${repaid.toStringAsFixed(0)} / ₹${amount.toStringAsFixed(0)}',
                                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    '${(progress * 100).toStringAsFixed(0)}%',
                                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.grey.shade100,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                                  minHeight: 6,
                                ),
                              ),
                              if (!isAdminUser && remaining > 0) ...[
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () => _showRequestSkipSheet(context, loan['id']),
                                      icon: const Icon(Icons.pause, size: 14),
                                      label: const Text('Pause EMI'),
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () => _showRequestForeclosureSheet(context, loan['id'], remaining),
                                      icon: const Icon(Icons.rocket_launch, size: 14, color: Colors.white),
                                      label: const Text('Foreclose', style: TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ],
                            if (isAdminUser && status == 'PENDING') ...[
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => _updateStatus(provider, loan['id'], 'REJECTED'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.redAccent,
                                      side: const BorderSide(color: Colors.redAccent),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Reject'),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: () => _updateStatus(provider, loan['id'], 'APPROVED'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Approve'),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSkipsTab(AdminProvider provider, bool isAdminUser) {
    if (provider.isLoading && provider.loanSkips.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    if (provider.loanSkips.isEmpty) {
      return Center(
        child: Text(
          'No EMI pause requests found.',
          style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.loanSkips.length,
      itemBuilder: (context, index) {
        final skip = provider.loanSkips[index];
        final id = skip['id'];
        final status = skip['status'] ?? 'PENDING';
        final fromM = skip['fromMonth'];
        final fromY = skip['fromYear'];
        final toM = skip['toMonth'];
        final toY = skip['toYear'];
        final count = skip['numberOfMonths'] ?? 1;
        final reason = skip['reason'] ?? '';
        final comment = skip['approvalComment'] ?? '';
        final rejectReason = skip['rejectionReason'] ?? '';
        
        final user = skip['user'] ?? {};
        final applicantName = user['fullName'] ?? 'Staff Member';

        Color statusColor = Colors.orange;
        if (status == 'APPROVED') statusColor = Colors.green;
        else if (status == 'COMPLETED') statusColor = Colors.blue;
        else if (status == 'REJECTED' || status == 'CANCELLED') statusColor = Colors.redAccent;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$count Months Pause',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                if (isAdminUser) ...[
                  Text(
                    'Staff: $applicantName',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  'Range: ${_months[fromM - 1]} $fromY - ${_months[toM - 1]} $toY',
                  style: GoogleFonts.outfit(fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reason: $reason',
                  style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                ),
                if (comment.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Approver comment: "$comment"',
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.green.shade700, fontStyle: FontStyle.italic),
                  ),
                ],
                if (rejectReason.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Rejection reason: "$rejectReason"',
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.red.shade700, fontStyle: FontStyle.italic),
                  ),
                ],
                if (status == 'PENDING') ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!isAdminUser) ...[
                        OutlinedButton(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (c) => const Center(child: CircularProgressIndicator()),
                            );
                            final success = await provider.cancelLoanSkip(id);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(success ? 'Pause request cancelled!' : 'Failed to cancel request')),
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
                          child: const Text('Cancel Request'),
                        )
                      ] else ...[
                        OutlinedButton(
                          onPressed: () => _showSkipActionDialog(context, provider, id, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Reject'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _showSkipActionDialog(context, provider, id, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Approve'),
                        ),
                      ]
                    ],
                  )
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildForeclosuresTab(AdminProvider provider, bool isAdminUser) {
    if (provider.isLoading && provider.loanForeclosures.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    if (provider.loanForeclosures.isEmpty) {
      return Center(
        child: Text(
          'No foreclosure requests found.',
          style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.loanForeclosures.length,
      itemBuilder: (context, index) {
        final fc = provider.loanForeclosures[index];
        final id = fc['id'];
        final status = fc['status'] ?? 'REQUESTED';
        final outstanding = (fc['outstandingBalance'] as num?)?.toDouble() ?? 0.0;
        final fee = (fc['processingFee'] as num?)?.toDouble() ?? 0.0;
        final total = (fc['totalPayableAmount'] as num?)?.toDouble() ?? 0.0;
        final method = fc['deductionMethod'] ?? 'SALARY_DEDUCTION';
        final month = fc['salaryDeductionMonth'] ?? '';
        final year = fc['salaryDeductionYear'];

        final user = fc['user'] ?? {};
        final applicantName = user['fullName'] ?? 'Staff Member';

        Color statusColor = Colors.orange;
        if (status == 'APPROVED') statusColor = Colors.green;
        else if (status == 'SETTLEMENT_PENDING') statusColor = Colors.blue;
        else if (status == 'SETTLED') statusColor = Colors.teal;
        else if (status == 'REJECTED' || status == 'CANCELLED') statusColor = Colors.redAccent;

        final isSalaryDeduction = method == 'SALARY_DEDUCTION';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${total.toStringAsFixed(0)} Foreclosure',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                if (isAdminUser) ...[
                  Text(
                    'Staff: $applicantName',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                ],
                Text('Principal Balance: ₹${outstanding.toStringAsFixed(2)}'),
                Text('Foreclosure Fee: ₹${fee.toStringAsFixed(2)}'),
                const SizedBox(height: 4),
                Text(
                  'Method: ${isSalaryDeduction ? "Salary Deduction ($month $year)" : "Manual Settlement"}',
                  style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                ),
                if (status == 'REQUESTED' && isAdminUser) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (c) => const Center(child: CircularProgressIndicator()),
                          );
                          final success = await provider.rejectLoanForeclosure(id);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(success ? 'Foreclosure rejected!' : 'Failed to reject foreclosure')),
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Reject'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (c) => const Center(child: CircularProgressIndicator()),
                          );
                          final success = await provider.approveLoanForeclosure(id);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success 
                                  ? (isSalaryDeduction ? 'Approved for payroll deduction!' : 'Approved! Pending manual payment.') 
                                  : 'Failed to approve foreclosure'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Approve'),
                      ),
                    ],
                  )
                ],
                if (status == 'SETTLEMENT_PENDING' && isAdminUser && !isSalaryDeduction) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showSettleForeclosureDialog(context, provider, id),
                        icon: const Icon(Icons.check, size: 14, color: Colors.white),
                        label: const Text('Record Settlement', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
