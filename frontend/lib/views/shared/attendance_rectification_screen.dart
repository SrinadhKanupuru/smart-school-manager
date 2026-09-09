import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_provider.dart';
import '../../providers/school_provider.dart';
import '../../core/theme.dart';

class AttendanceRectificationScreen extends StatefulWidget {
  const AttendanceRectificationScreen({super.key});

  @override
  State<AttendanceRectificationScreen> createState() => _AttendanceRectificationScreenState();
}

class _AttendanceRectificationScreenState extends State<AttendanceRectificationScreen> {
  int _activeTab = 0; // Regular staff: 0 = Pending, 1 = Approved, 2 = Rejected
  // Manager: 0 = Pending Approvals, 1 = Resolved, 2 = My Requests (Pending), 3 = My Requests (History)
  bool _isManager = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final school = Provider.of<SchoolProvider>(context, listen: false);
      final role = school.currentUser?['role'];
      setState(() {
        _isManager = role == 'CORRESPONDENT' || role == 'PRINCIPAL' || role == 'HM';
      });
      Provider.of<AdminProvider>(context, listen: false).fetchRectifications();
      Provider.of<AdminProvider>(context, listen: false).fetchHolidays();
    });
  }

  Future<void> _refresh() async {
    await Provider.of<AdminProvider>(context, listen: false).fetchRectifications();
  }

  void _handleStatusUpdate(String id, String status) async {
    String? rejectionReason;
    if (status == 'REJECTED') {
      rejectionReason = await _showRejectionDialog();
      if (rejectionReason == null) return; // cancelled
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final admin = Provider.of<AdminProvider>(context, listen: false);
    final success = await admin.updateRectificationStatus(id, status, rejectionReason: rejectionReason);

    if (mounted) {
      Navigator.pop(context); // Dismiss loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Request updated successfully!' : 'Failed to update request.'),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
      if (success) {
        _refresh();
      }
    }
  }

  Future<String?> _showRejectionDialog() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reject Rectification', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            hintText: 'Enter reason...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text('Cancel', style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = ctrl.text.trim();
              Navigator.pop(ctx, val.isNotEmpty ? val : 'No reason provided');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text('Reject', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);
    final school = Provider.of<SchoolProvider>(context);
    final currentUserId = school.currentUser?['id'] ?? '';

    // Filter list
    final List<dynamic> allList = admin.rectifications;

    List<dynamic> pendingApprovals = [];
    List<dynamic> resolvedApprovals = [];
    List<dynamic> myPending = [];
    List<dynamic> myApproved = [];
    List<dynamic> myRejected = [];

    for (var r in allList) {
      final isOwnRequest = r['userId'] == currentUserId;
      if (_isManager) {
        if (isOwnRequest) {
          if (r['status'] == 'PENDING') {
            myPending.add(r);
          } else {
            myApproved.add(r); // Add both approved and rejected to own history
          }
        } else {
          if (r['status'] == 'PENDING') {
            pendingApprovals.add(r);
          } else {
            resolvedApprovals.add(r);
          }
        }
      } else {
        if (r['status'] == 'PENDING') {
          myPending.add(r);
        } else if (r['status'] == 'APPROVED') {
          myApproved.add(r);
        } else if (r['status'] == 'REJECTED') {
          myRejected.add(r);
        }
      }
    }

    final List<dynamic> currentDisplayList;
    if (_isManager) {
      if (_activeTab == 0) {
        currentDisplayList = pendingApprovals;
      } else if (_activeTab == 1) {
        currentDisplayList = resolvedApprovals;
      } else if (_activeTab == 2) {
        currentDisplayList = myPending;
      } else {
        currentDisplayList = myApproved;
      }
    } else {
      if (_activeTab == 0) {
        currentDisplayList = myPending;
      } else if (_activeTab == 1) {
        currentDisplayList = myApproved;
      } else {
        currentDisplayList = myRejected;
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Attendance Rectification', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: admin.isLoading && allList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // Tab selector
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: _isManager
                        ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildTabBtn(0, 'Approvals (${pendingApprovals.length})'),
                                const SizedBox(width: 8),
                                _buildTabBtn(1, 'Resolved (${resolvedApprovals.length})'),
                                const SizedBox(width: 8),
                                _buildTabBtn(2, 'My Pending (${myPending.length})'),
                                const SizedBox(width: 8),
                                _buildTabBtn(3, 'My History (${myApproved.length})'),
                              ],
                            ),
                          )
                        : Row(
                            children: [
                              _buildTabBtn(0, 'Pending (${myPending.length})'),
                              _buildTabBtn(1, 'Approved (${myApproved.length})'),
                              _buildTabBtn(2, 'Rejected (${myRejected.length})'),
                            ],
                          ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: currentDisplayList.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                                Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.history_toggle_off, size: 48, color: Colors.grey.shade300),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No requests found in this section.',
                                        style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: currentDisplayList.length,
                              itemBuilder: (context, index) {
                                final r = currentDisplayList[index];
                                final isOwn = r['userId'] == currentUserId;
                                final dateFormatted = DateFormat('dd MMM yyyy').format(DateTime.parse(r['date']));
                                final checkIn = r['checkInTime'] ?? '--:--';
                                final checkOut = r['checkOutTime'] ?? '--:--';
                                final applicantName = r['user']?['fullName'] ?? 'Staff';
                                final applicantRole = r['user']?['role'] ?? 'TEACHER';

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: Colors.grey.shade200),
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
                                              dateFormatted,
                                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimaryColor),
                                            ),
                                            _buildStatusBadge(r['status']),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        if (!_isManager || isOwn)
                                          Text(
                                            'Requested Times - In: $checkIn  •  Out: $checkOut',
                                            style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                                          )
                                        else
                                          Text(
                                            'By $applicantName ($applicantRole) • In: $checkIn  •  Out: $checkOut',
                                            style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                                          ),
                                        const Divider(height: 24),
                                        Text(
                                          'Reason: ${r['reason'] ?? ''}',
                                          style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondaryColor),
                                        ),
                                        if (r['status'] == 'REJECTED' && r['rejectionReason'] != null) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            'Rejection Reason: ${r['rejectionReason']}',
                                            style: GoogleFonts.outfit(fontSize: 13, color: Colors.redAccent, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                        if (r['approvedBy'] != null) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            'Processed By: ${r['approvedBy']['fullName'] ?? ''} (${r['approvedBy']['role'] ?? ''})',
                                            style: GoogleFonts.outfit(fontSize: 13, color: Colors.blueGrey, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                        if (_isManager && !isOwn && r['status'] == 'PENDING') ...[
                                          const Divider(height: 24),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              OutlinedButton(
                                                onPressed: () => _handleStatusUpdate(r['id'], 'REJECTED'),
                                                style: OutlinedButton.styleFrom(
                                                  side: const BorderSide(color: Colors.redAccent),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                ),
                                                child: Text('Reject', style: GoogleFonts.outfit(color: Colors.redAccent)),
                                              ),
                                              const SizedBox(width: 12),
                                              ElevatedButton(
                                                onPressed: () => _handleStatusUpdate(r['id'], 'APPROVED'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                ),
                                                child: Text('Approve', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ApplyRectificationFormScreen()),
          );
          if (result == true) {
            _refresh();
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Request Correction', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildTabBtn(int index, String label) {
    final isSelected = _activeTab == index;
    return _isManager
        ? ChoiceChip(
            label: Text(label, style: GoogleFonts.outfit(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : AppTheme.textPrimaryColor)),
            selected: isSelected,
            selectedColor: AppTheme.primaryColor,
            onSelected: (val) {
              if (val) setState(() => _activeTab = index);
            },
          )
        : Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                  ),
                ),
              ),
            ),
          );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = Colors.orange.withOpacity(0.08);
    Color fg = Colors.orange;
    if (status == 'APPROVED') {
      bg = Colors.green.withOpacity(0.08);
      fg = Colors.green;
    } else if (status == 'REJECTED') {
      bg = Colors.red.withOpacity(0.08);
      fg = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(
        status,
        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}

class ApplyRectificationFormScreen extends StatefulWidget {
  const ApplyRectificationFormScreen({super.key});

  @override
  State<ApplyRectificationFormScreen> createState() => _ApplyRectificationFormScreenState();
}

class _ApplyRectificationFormScreenState extends State<ApplyRectificationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateCtrl = TextEditingController();
  final _checkInCtrl = TextEditingController();
  final _checkOutCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedCheckIn;
  TimeOfDay? _selectedCheckOut;

  @override
  void dispose() {
    _dateCtrl.dispose();
    _checkInCtrl.dispose();
    _checkOutCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  void _pickDate(List<int> offs, List<dynamic> holidays) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 90)),
      lastDate: now,
      selectableDayPredicate: (date) {
        final mappedIndex = date.weekday == 7 ? 0 : date.weekday;
        if (offs.contains(mappedIndex)) return false;

        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        for (var holiday in holidays) {
          final holidayDateStr = holiday['date']?.toString().split('T')[0];
          if (holidayDateStr == dateStr) return false;
        }
        return true;
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _pickCheckIn() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedCheckIn ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _selectedCheckIn = picked;
        if (context.mounted) {
          _checkInCtrl.text = picked.format(context);
        }
      });
    }
  }

  void _pickCheckOut() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedCheckOut ?? const TimeOfDay(hour: 17, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _selectedCheckOut = picked;
        if (context.mounted) {
          _checkOutCtrl.text = picked.format(context);
        }
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null || _selectedCheckIn == null || _selectedCheckOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select times.')),
      );
      return;
    }

    final double inDouble = _selectedCheckIn!.hour + _selectedCheckIn!.minute / 60.0;
    final double outDouble = _selectedCheckOut!.hour + _selectedCheckOut!.minute / 60.0;
    if (outDouble <= inDouble) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-out time must be after check-in time.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final admin = Provider.of<AdminProvider>(context, listen: false);
    final errorMsg = await admin.applyRectification(
      date: _dateCtrl.text,
      checkInTime: _checkInCtrl.text,
      checkOutTime: _checkOutCtrl.text,
      reason: _reasonCtrl.text.trim(),
    );

    if (mounted) {
      Navigator.pop(context); // Dismiss loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg == null ? 'Correction request submitted successfully!' : errorMsg),
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
      appBar: AppBar(title: const Text('Request Correction')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _dateCtrl,
                  readOnly: true,
                  onTap: () => _pickDate(offs, holidays),
                  decoration: const InputDecoration(
                    labelText: 'Date to Rectify',
                    hintText: 'Select date',
                    suffixIcon: Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Select date' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _checkInCtrl,
                  readOnly: true,
                  onTap: _pickCheckIn,
                  decoration: const InputDecoration(
                    labelText: 'Actual Check-in Time',
                    hintText: 'Select time',
                    suffixIcon: Icon(Icons.access_time, color: AppTheme.primaryColor),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Select check-in time' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _checkOutCtrl,
                  readOnly: true,
                  onTap: _pickCheckOut,
                  decoration: const InputDecoration(
                    labelText: 'Actual Check-out Time',
                    hintText: 'Select time',
                    suffixIcon: Icon(Icons.access_time, color: AppTheme.primaryColor),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Select check-out time' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reasonCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Reason for correction',
                    hintText: 'Explain why you are requesting correction (e.g. forgot check-out)...',
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Please provide a reason' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text('Submit Request', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
