import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/school_provider.dart';
import '../../core/theme.dart';

class StaffAttendanceHistoryScreen extends StatefulWidget {
  const StaffAttendanceHistoryScreen({super.key});

  @override
  State<StaffAttendanceHistoryScreen> createState() => _StaffAttendanceHistoryScreenState();
}

class _StaffAttendanceHistoryScreenState extends State<StaffAttendanceHistoryScreen> {
  String? _selectedMonthKey; // Format: "MMMM yyyy" (e.g. "June 2026")

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SchoolProvider>(context, listen: false).fetchMyAttendanceHistory().then((_) {
        _initializeDefaultMonth();
      });
    });
  }

  void _initializeDefaultMonth() {
    final history = Provider.of<SchoolProvider>(context, listen: false).myAttendanceHistory;
    if (history.isNotEmpty) {
      // Collect all available month/year options
      final months = _getAvailableMonths(history);
      if (months.isNotEmpty) {
        // Find if current month exists in available options
        final currentMonthStr = DateFormat('MMMM yyyy').format(DateTime.now());
        if (months.contains(currentMonthStr)) {
          setState(() {
            _selectedMonthKey = currentMonthStr;
          });
        } else {
          setState(() {
            _selectedMonthKey = months.first;
          });
        }
      }
    } else {
      setState(() {
        _selectedMonthKey = DateFormat('MMMM yyyy').format(DateTime.now());
      });
    }
  }

  List<String> _getAvailableMonths(List<dynamic> history) {
    final Set<String> months = {};
    for (var record in history) {
      final dateStr = record['date'];
      if (dateStr != null) {
        try {
          final dt = DateTime.parse(dateStr);
          months.add(DateFormat('MMMM yyyy').format(dt));
        } catch (_) {}
      }
    }
    final sortedList = months.toList();
    // Sort months descending (newest first)
    sortedList.sort((a, b) {
      final dtA = DateFormat('MMMM yyyy').parse(a);
      final dtB = DateFormat('MMMM yyyy').parse(b);
      return dtB.compareTo(dtA);
    });
    return sortedList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'My Attendance Logs',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppTheme.textPrimaryColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_toggle_off, color: AppTheme.primaryColor),
            tooltip: 'Attendance Rectification',
            onPressed: () {
              Navigator.pushNamed(context, '/attendance-rectification');
            },
          ),
        ],
      ),
      body: Consumer<SchoolProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          final history = provider.myAttendanceHistory;

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No face attendance logs recorded yet.',
                    style: GoogleFonts.outfit(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final availableMonths = _getAvailableMonths(history);
          if (_selectedMonthKey == null && availableMonths.isNotEmpty) {
            _selectedMonthKey = availableMonths.first;
          }

          // Filter history by selected month
          final filteredHistory = history.where((record) {
            final dateStr = record['date'];
            if (dateStr == null) return false;
            try {
              final dt = DateTime.parse(dateStr);
              final monthStr = DateFormat('MMMM yyyy').format(dt);
              return monthStr == _selectedMonthKey;
            } catch (_) {
              return false;
            }
          }).toList();

          // Calculations for selected month
          final presentDays = filteredHistory.where((a) => a['status'] == 'PRESENT').length;
          final totalHours = filteredHistory.fold<double>(0.0, (sum, a) => sum + (a['totalHours'] ?? 0.0));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Month Selector Dropdown
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMonthKey,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
                      items: (availableMonths.isEmpty
                              ? [DateFormat('MMMM yyyy').format(DateTime.now())]
                              : availableMonths)
                          .map((m) {
                        return DropdownMenuItem<String>(
                          value: m,
                          child: Text(
                            m,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.textPrimaryColor,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedMonthKey = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Statistics Cards
              Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Present Days',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AppTheme.textSecondaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$presentDays Days',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hours Worked',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AppTheme.textSecondaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${totalHours.toStringAsFixed(1)} hrs',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // History list title
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Daily Logs',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ),

              filteredHistory.isEmpty
                  ? Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            'No logs found for the selected month.',
                            style: GoogleFonts.outfit(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: filteredHistory.map((a) {
                        final dateStr = a['date'] ?? '';
                        String formattedDate = dateStr;
                        try {
                          formattedDate = DateFormat('dd EEE, MMM yyyy').format(DateTime.parse(dateStr));
                        } catch (_) {}

                        final checkIn = a['firstCheckIn'] != null
                            ? DateFormat('hh:mm a').format(DateTime.parse(a['firstCheckIn']))
                            : '--:--';
                        final checkOut = a['lastCheckOut'] != null
                            ? DateFormat('hh:mm a').format(DateTime.parse(a['lastCheckOut']))
                            : '--:--';
                        final hours = a['totalHours'] != null ? '${a['totalHours']} hrs' : 'N/A';
                        final status = a['status'] ?? 'PRESENT';
                        final statusColor = status == 'PRESENT' ? Colors.green : Colors.orange;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.fingerprint_outlined,
                                    color: AppTheme.primaryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppTheme.textPrimaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'In: $checkIn  •  Out: $checkOut',
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      hours,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        status,
                                        style: GoogleFonts.outfit(
                                          color: statusColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ],
          );
        },
      ),
    );
  }
}
