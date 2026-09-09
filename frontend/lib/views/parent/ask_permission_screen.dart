import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/admin_provider.dart';
import '../../providers/school_provider.dart';
import '../../core/theme.dart';

class AskPermissionScreen extends StatefulWidget {
  const AskPermissionScreen({super.key});

  @override
  State<AskPermissionScreen> createState() => _AskPermissionScreenState();
}

class _AskPermissionScreenState extends State<AskPermissionScreen> {
  int _activeTab = 0; // 0 = Pending, 1 = Approved, 2 = Rejected

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final admin = Provider.of<AdminProvider>(context, listen: false);
      admin.fetchLeaves();
      admin.fetchChildrenDashboard();
    });
  }

  Future<void> _refresh() async {
    final admin = Provider.of<AdminProvider>(context, listen: false);
    await admin.fetchLeaves();
    await admin.fetchChildrenDashboard();
  }

  void _confirmWithdraw(BuildContext context, String leaveId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Withdraw Child Leave Request', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to withdraw this pending child leave request?', style: GoogleFonts.outfit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              
              // Show progress indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingCtx) => const Center(child: CircularProgressIndicator()),
              );

              final admin = Provider.of<AdminProvider>(context, listen: false);
              final errorMsg = await admin.withdrawLeave(leaveId);

              if (context.mounted) {
                Navigator.pop(context); // Close progress indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMsg == null ? 'Child leave request withdrawn successfully!' : errorMsg),
                    backgroundColor: errorMsg == null ? Colors.green : Colors.redAccent,
                  ),
                );
                if (errorMsg == null) {
                  _refresh();
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text('Withdraw', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);

    // Leaves applied by this parent
    final parentLeaves = admin.leaves;
    final pendingList = parentLeaves.where((l) => l['status'] == 'PENDING').toList();
    final approvedList = parentLeaves.where((l) => l['status'] == 'APPROVED').toList();
    final rejectedList = parentLeaves.where((l) => l['status'] == 'REJECTED').toList();

    final currentHistoryList = _activeTab == 0
        ? pendingList
        : (_activeTab == 1 ? approvedList : rejectedList);

    return Scaffold(
      appBar: AppBar(
        title: Text('Child Leave History', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          )
        ],
      ),
      body: admin.isLoading && admin.leaves.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Status tab selectors
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            _buildTabBtn(0, 'Pending (${pendingList.length})'),
                            _buildTabBtn(1, 'Approved (${approvedList.length})'),
                            _buildTabBtn(2, 'Rejected (${rejectedList.length})'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // History requests list
                      currentHistoryList.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 60),
                              child: Column(
                                children: [
                                  Icon(Icons.history, size: 48, color: Colors.grey.shade300),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No child leave applications here.',
                                    style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: currentHistoryList.length,
                              itemBuilder: (context, index) {
                                final leave = currentHistoryList[index];
                                final student = leave['student'] ?? {};
                                final studentName = student['fullName'] ?? 'Child';
                                final className = student['classSection']?['class']?['name'] ?? '';
                                final sectionName = student['classSection']?['name'] ?? '';
                                
                                final from = DateFormat('dd MMM').format(DateTime.parse(leave['fromDate']));
                                final to = DateFormat('dd MMM, yyyy').format(DateTime.parse(leave['toDate']));
                                final appliedDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(leave['createdAt']));

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Colors.grey.shade100),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              studentName,
                                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimaryColor),
                                            ),
                                            _buildStatusBadge(leave['status'] ?? 'PENDING'),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Class $className-$sectionName • Applied on $appliedDate',
                                          style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondaryColor),
                                        ),
                                        const Divider(height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Type: ${leave['leaveType'] == 'CHILD_SICK_LEAVE' ? 'Sick Leave' : (leave['leaveType'] ?? 'Leave')}',
                                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryColor),
                                            ),
                                            Text(
                                              '$from - $to',
                                              style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.textPrimaryColor),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Reason: ${leave['reason'] ?? ''}',
                                          style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                                        ),
                                        if (leave['status'] == 'PENDING') ...[
                                          const Divider(height: 20),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              OutlinedButton.icon(
                                                onPressed: () => _confirmWithdraw(context, leave['id']),
                                                icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                                                label: Text(
                                                  'Withdraw',
                                                  style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600),
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: Colors.redAccent,
                                                  side: const BorderSide(color: Colors.redAccent, width: 1),
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
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
                            ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ApplyChildLeaveFormScreen()),
          );
          if (result == true) {
            _refresh();
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Ask Permission', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.orange;
    if (status == 'APPROVED') color = Colors.green;
    if (status == 'REJECTED') color = Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status,
        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildTabBtn(int index, String label) {
    final isSelected = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 3, offset: const Offset(0, 1))]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

class ApplyChildLeaveFormScreen extends StatefulWidget {
  const ApplyChildLeaveFormScreen({super.key});

  @override
  State<ApplyChildLeaveFormScreen> createState() => _ApplyChildLeaveFormScreenState();
}

class _ApplyChildLeaveFormScreenState extends State<ApplyChildLeaveFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonCtrl = TextEditingController();
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  DateTime? _selectedFrom;
  DateTime? _selectedTo;
  String? _selectedStudentId;
  String _selectedReasonCategory = 'Sick Leave';

  final List<String> _reasonCategories = [
    'Sick Leave',
    'Family Function',
    'Personal Leave',
    'Travel / Out of Station',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchHolidays();
    });
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  bool _isDateSelectable(DateTime date, List<int> offs, List<dynamic> holidays) {
    // Block past dates
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    final checkDateOnly = DateTime(date.year, date.month, date.day);
    if (checkDateOnly.isBefore(todayDateOnly)) {
      return false;
    }

    final mappedIndex = date.weekday == 7 ? 0 : date.weekday;
    if (offs.contains(mappedIndex)) {
      return false;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    for (var holiday in holidays) {
      final holidayDateStr = holiday['date']?.toString().split('T')[0];
      if (holidayDateStr == dateStr) {
        return false;
      }
    }

    return true;
  }

  DateTime _getInitialSelectableDate(DateTime start, List<int> offs, List<dynamic> holidays) {
    DateTime temp = start;
    for (int i = 0; i < 365; i++) {
      if (_isDateSelectable(temp, offs, holidays)) {
        return temp;
      }
      temp = temp.add(const Duration(days: 1));
    }
    return start;
  }

  void _pickFrom(List<int> offs, List<dynamic> holidays) async {
    final now = DateTime.now();
    final initial = _getInitialSelectableDate(now, offs, holidays);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now.subtract(const Duration(days: 1)), // Allow today & future
      lastDate: now.add(const Duration(days: 365)),
      selectableDayPredicate: (date) => _isDateSelectable(date, offs, holidays),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedFrom = picked;
        _fromCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
        if (_selectedTo != null && _selectedTo!.isBefore(picked)) {
          _selectedTo = null;
          _toCtrl.clear();
        }
      });
    }
  }

  void _pickTo(List<int> offs, List<dynamic> holidays) async {
    final initial = _selectedFrom ?? DateTime.now();
    final initialSelectable = _getInitialSelectableDate(initial, offs, holidays);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialSelectable,
      firstDate: initial,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate: (date) => _isDateSelectable(date, offs, holidays),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTo = picked;
        _toCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  String? _validateRange(DateTime start, DateTime end, List<int> offs, List<dynamic> holidays) {
    DateTime temp = start;
    final weekdayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    while (temp.isBefore(end) || temp.isAtSameMomentAs(end)) {
      final mappedIndex = temp.weekday == 7 ? 0 : temp.weekday;
      if (offs.contains(mappedIndex)) {
        return "Cannot apply for leave on ${DateFormat('dd/MM/yyyy').format(temp)} (${weekdayNames[mappedIndex]}) because it is a weekly off.";
      }
      final dateStr = DateFormat('yyyy-MM-dd').format(temp);
      for (var holiday in holidays) {
        final holidayDateStr = holiday['date']?.toString().split('T')[0];
        if (holidayDateStr == dateStr) {
          return "Cannot apply for leave on ${DateFormat('dd/MM/yyyy').format(temp)} because it is a scheduled school holiday: ${holiday['title'] ?? 'Holiday'}.";
        }
      }
      temp = temp.add(const Duration(days: 1));
    }
    return null;
  }

  void _submit(AdminProvider admin, List<int> offs, List<dynamic> holidays) async {
    if (!_formKey.currentState!.validate() || _selectedFrom == null || _selectedTo == null || _selectedStudentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all details and select student')),
      );
      return;
    }

    final rangeError = _validateRange(_selectedFrom!, _selectedTo!, offs, holidays);
    if (rangeError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(rangeError),
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

    final errorMsg = await admin.requestChildLeave(
      studentId: _selectedStudentId!,
      fromDate: DateFormat('yyyy-MM-dd').format(_selectedFrom!),
      toDate: DateFormat('yyyy-MM-dd').format(_selectedTo!),
      reason: _reasonCtrl.text.trim(),
      leaveType: _selectedReasonCategory,
    );

    if (mounted) {
      Navigator.pop(context); // Dismiss loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg == null ? 'Leave permission requested successfully!' : errorMsg),
          backgroundColor: errorMsg == null ? Colors.green : Colors.redAccent,
        ),
      );
      if (errorMsg == null) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);
    final school = Provider.of<SchoolProvider>(context).currentSchool ?? {};
    final weeklyOffsStr = school['weeklyOffs'] ?? '0';
    final List<int> offs = weeklyOffsStr
        .toString()
        .split(',')
        .where((s) => s.trim().isNotEmpty)
        .map((s) => int.parse(s.trim()))
        .toList();
    final holidays = admin.holidays;

    return Scaffold(
      appBar: AppBar(title: const Text('Request Permission')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedStudentId,
                  hint: const Text('Select Child'),
                  items: admin.childrenDashboardData.map((child) {
                    return DropdownMenuItem<String>(
                      value: child['id'],
                      child: Text(child['fullName'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedStudentId = val),
                  validator: (val) => val == null ? 'Select student' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedReasonCategory,
                  decoration: const InputDecoration(labelText: 'Reason Category*'),
                  items: _reasonCategories.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedReasonCategory = val ?? 'Sick Leave'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fromCtrl,
                  readOnly: true,
                  onTap: () => _pickFrom(offs, holidays),
                  decoration: const InputDecoration(
                    labelText: 'Absent From*',
                    hintText: 'Select start date',
                    suffixIcon: Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Select start date' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _toCtrl,
                  readOnly: true,
                  onTap: () => _pickTo(offs, holidays),
                  decoration: const InputDecoration(
                    labelText: 'Absent To*',
                    hintText: 'Select end date',
                    suffixIcon: Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Select end date' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reasonCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Reason Details / Description*',
                    hintText: 'Describe details (e.g. Fever, family marriage details...)',
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Enter reason details' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _submit(admin, offs, holidays),
                  child: const Text('Ask Permission'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
