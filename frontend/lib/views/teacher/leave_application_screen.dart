import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/admin_provider.dart';
import '../../providers/school_provider.dart';
import '../../core/theme.dart';

class LeaveApplicationScreen extends StatefulWidget {
  const LeaveApplicationScreen({super.key});

  @override
  State<LeaveApplicationScreen> createState() => _LeaveApplicationScreenState();
}

class _LeaveApplicationScreenState extends State<LeaveApplicationScreen> {
  int _activeTab = 0; // 0 = Pending, 1 = Approved, 2 = Rejected

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = Provider.of<AdminProvider>(context, listen: false);
      p.fetchMyLeaveSummary();
      p.fetchLeaves();
    });
  }

  Future<void> _refresh() async {
    final p = Provider.of<AdminProvider>(context, listen: false);
    await p.fetchMyLeaveSummary();
    await p.fetchLeaves();
  }

  void _confirmWithdraw(BuildContext context, String leaveId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Withdraw Leave Request', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to withdraw this pending leave request?', style: GoogleFonts.outfit()),
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
                    content: Text(errorMsg == null ? 'Leave request withdrawn successfully!' : errorMsg),
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
    final summary = admin.myLeaveSummary;

    // Filter leaves for this teacher (staff leave has studentId == null)
    final teacherLeaves = admin.leaves.where((l) => l['student'] == null).toList();
    final pendingList = teacherLeaves.where((l) => l['status'] == 'PENDING').toList();
    final approvedList = teacherLeaves.where((l) => l['status'] == 'APPROVED').toList();
    final rejectedList = teacherLeaves.where((l) => l['status'] == 'REJECTED').toList();

    final currentHistoryList = _activeTab == 0
        ? pendingList
        : (_activeTab == 1 ? approvedList : rejectedList);

    final stats = summary != null ? summary['summary'] : {'pending': 0, 'approved': 0, 'rejected': 0};
    final balances = summary != null ? summary['balances'] as List<dynamic>? ?? [] : [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Management', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          )
        ],
      ),
      body: admin.isLoading && summary == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // KPI Counter Cards
                      Row(
                        children: [
                          Expanded(child: _buildKpiCard('Pending', '${stats['pending']}', Colors.orange)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildKpiCard('Approved', '${stats['approved']}', Colors.green)),
                          const SizedBox(width: 8),
                          Expanded(child: _buildKpiCard('Rejected', '${stats['rejected']}', Colors.redAccent)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Leave Policies and Balances Section
                      Text(
                        'Leave Balances',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
                      ),
                      const SizedBox(height: 10),
                      balances.isEmpty
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: Text(
                                'No active leave policies configured.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                              ),
                            )
                          : SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: balances.length,
                                itemBuilder: (context, index) {
                                  final b = balances[index];
                                  return _buildBalanceCard(b);
                                },
                              ),
                            ),
                      const SizedBox(height: 24),

                      // History Tabs & List
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Applications',
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Custom Segmented Control
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
                      const SizedBox(height: 12),

                      // Leaves History List
                      currentHistoryList.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.assignment_turned_in_outlined, size: 48, color: Colors.grey.shade300),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No leave applications here.',
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
                                final from = DateFormat('dd MMM').format(DateTime.parse(leave['fromDate']));
                                final to = DateFormat('dd MMM, yyyy').format(DateTime.parse(leave['toDate']));
                                final appliedDate = DateFormat('dd MMM yyyy').format(DateTime.parse(leave['createdAt']));
                                
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
                                              leave['leaveType'] ?? 'Leave Request',
                                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryColor),
                                            ),
                                            Text(
                                              'Applied on: $appliedDate',
                                              style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondaryColor),
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 20),
                                        Text(
                                          'Duration: $from - $to',
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimaryColor),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Reason: ${leave['reason'] ?? ''}',
                                          style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                                        ),
                                        if (leave['status'] == 'PENDING') ...[
                                          const Divider(height: 24),
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
            MaterialPageRoute(builder: (context) => const ApplyLeaveFormScreen()),
          );
          if (result == true) {
            _refresh();
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Apply Leave', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildKpiCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15), width: 1),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(dynamic b) {
    final leaveType = b['leaveType'] ?? 'Leave';
    final maxDays = b['maxDays'] ?? 0;
    final usedDays = b['usedDays'] ?? 0;
    final balance = b['balance'] ?? 0;
    final isUnpaid = b['isUnpaid'] ?? false;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            leaveType,
            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            isUnpaid ? 'Unpaid' : '$balance Available',
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isUnpaid ? Colors.orange : AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          if (!isUnpaid) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: maxDays > 0 ? (usedDays / maxDays) : 0.0,
                backgroundColor: Colors.grey.shade100,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Used: $usedDays / $maxDays days',
              style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.textSecondaryColor),
            ),
          ] else
            Text(
              'No hard limit',
              style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.textSecondaryColor),
            ),
        ],
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

class ApplyLeaveFormScreen extends StatefulWidget {
  const ApplyLeaveFormScreen({super.key});

  @override
  State<ApplyLeaveFormScreen> createState() => _ApplyLeaveFormScreenState();
}

class _ApplyLeaveFormScreenState extends State<ApplyLeaveFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedLeaveTypeId;
  final _reasonCtrl = TextEditingController();
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  DateTime? _selectedFrom;
  DateTime? _selectedTo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = Provider.of<AdminProvider>(context, listen: false);
      p.fetchHolidays();
      p.fetchMyLeaveSummary(); // fetch summary to populate types & balances
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
    // Cannot apply for past dates
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
      firstDate: now.subtract(const Duration(days: 1)), // allow only today and future
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

  void _submit(AdminProvider admin, List<int> offs, List<dynamic> holidays, List<dynamic> leaveTypesList) async {
    if (!_formKey.currentState!.validate() || _selectedFrom == null || _selectedTo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date range and fill all fields')),
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

    final selectedType = leaveTypesList.firstWhere(
      (e) {
        final String valueId = e['leaveTypeId']?.toString() ?? e['code']?.toString() ?? e['leaveType']?.toString() ?? '';
        return valueId == _selectedLeaveTypeId;
      },
      orElse: () => leaveTypesList.first,
    );
    final String lName = selectedType['leaveType'] ?? selectedType['name'] ?? 'Casual Leave';
    final String? lId = selectedType['leaveTypeId']?.toString();

    final errorMsg = await admin.applyLeave(
      leaveType: lName,
      leaveTypeId: lId,
      fromDate: DateFormat('yyyy-MM-dd').format(_selectedFrom!),
      toDate: DateFormat('yyyy-MM-dd').format(_selectedTo!),
      reason: _reasonCtrl.text.trim(),
    );

    if (mounted) {
      Navigator.pop(context); // Dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg == null ? 'Leave request filed successfully!' : errorMsg),
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

    final summary = admin.myLeaveSummary;
    final List<dynamic> leaveTypesList = (summary != null && summary['balances'] != null)
        ? summary['balances']
        : [
            {'leaveTypeId': null, 'leaveType': 'Casual Leave', 'code': 'CASUAL', 'maxDays': 12, 'balance': 12},
            {'leaveTypeId': null, 'leaveType': 'Sick Leave', 'code': 'SICK', 'maxDays': 10, 'balance': 10},
          ];

    if (_selectedLeaveTypeId == null && leaveTypesList.isNotEmpty) {
      final firstItem = leaveTypesList.first;
      _selectedLeaveTypeId = firstItem['leaveTypeId']?.toString() ?? firstItem['code']?.toString() ?? firstItem['leaveType']?.toString();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Apply Leave')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedLeaveTypeId,
                  decoration: const InputDecoration(labelText: 'Leave Type'),
                  items: leaveTypesList.map<DropdownMenuItem<String>>((item) {
                    final String valueId = item['leaveTypeId']?.toString() ?? item['code']?.toString() ?? item['leaveType']?.toString() ?? '';
                    final limit = item['maxDays'] ?? (item['code'] == 'CASUAL' ? 12 : 10);
                    final balance = item['balance'] ?? limit;
                    final isUnpaid = item['isUnpaid'] ?? false;
                    return DropdownMenuItem<String>(
                      value: valueId,
                      child: Text(isUnpaid 
                          ? '${item['leaveType']} (Unpaid)'
                          : '${item['leaveType']} (Bal: $balance / $limit days)'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedLeaveTypeId = val),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fromCtrl,
                  readOnly: true,
                  onTap: () => _pickFrom(offs, holidays),
                  decoration: const InputDecoration(
                    labelText: 'From Date',
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
                    labelText: 'To Date',
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
                    labelText: 'Reason',
                    hintText: 'Enter reason for leave...',
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Enter reason details' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _submit(admin, offs, holidays, leaveTypesList),
                  child: const Text('Submit Application'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
