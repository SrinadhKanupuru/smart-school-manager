import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/school_provider.dart';
import '../../providers/academic_provider.dart';
import '../../core/theme.dart';

class SchoolInsightsScreen extends StatefulWidget {
  const SchoolInsightsScreen({super.key});

  @override
  State<SchoolInsightsScreen> createState() => _SchoolInsightsScreenState();
}

class _SchoolInsightsScreenState extends State<SchoolInsightsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _employeeSearchController = TextEditingController();
  final TextEditingController _studentSearchController = TextEditingController();
  String _employeeQuery = "";
  String _studentQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SchoolProvider>(context, listen: false).fetchUsers();
      Provider.of<AcademicProvider>(context, listen: false).fetchStudents();
    });

    _employeeSearchController.addListener(() {
      setState(() {
        _employeeQuery = _employeeSearchController.text.trim().toLowerCase();
      });
    });

    _studentSearchController.addListener(() {
      setState(() {
        _studentQuery = _studentSearchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _employeeSearchController.dispose();
    _studentSearchController.dispose();
    super.dispose();
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
      default:
        return "Unknown";
    }
  }

  void _showEmployeeDetails(Map<String, dynamic> user) {
    final profile = user['teacherProfile'] ?? {};
    final leaves = user['leaveRequests'] as List<dynamic>? ?? [];
    final salaries = profile['salaryRecords'] as List<dynamic>? ?? [];
    final timetables = profile['timetables'] as List<dynamic>? ?? [];
    final staffAttendances = user['staffAttendances'] as List<dynamic>? ?? [];

    final approvedLeaves = leaves.where((l) => l['status'] == 'APPROVED').length;
    final totalAttendance = staffAttendances.length;
    final presentCount = staffAttendances.where((a) => a['status'] == 'PRESENT').length;
    
    final double attendanceRate = totalAttendance > 0
        ? (presentCount / totalAttendance * 100)
        : (leaves.isEmpty ? 100.0 : ((30 - approvedLeaves) / 30 * 100).clamp(0.0, 100.0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Employee Profile Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: Text(
                          (user['fullName'] ?? 'E')[0].toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['fullName'] ?? 'Unknown Name',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                user['role'] ?? 'STAFF',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Email: ${user['email'] ?? "N/A"}',
                              style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                            ),
                            Text(
                              'Phone: ${user['phoneNumber'] ?? "N/A"}',
                              style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Experience & Qualification
                  Text(
                    'Professional Details',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    color: AppTheme.backgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Experience',
                                  style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  profile['experienceYears'] != null ? '${profile['experienceYears']} Years' : 'N/A',
                                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Qualification',
                                  style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  profile['qualification'] ?? 'N/A',
                                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Basic Salary',
                                  style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  profile['salaryAmount'] != null ? '₹${profile['salaryAmount']}' : 'N/A',
                                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Attendance card
                  Text(
                    'Attendance Track (Last 30 Days)',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: CircularProgressIndicator(
                                      value: attendanceRate / 100,
                                      strokeWidth: 8,
                                      backgroundColor: Colors.grey.shade100,
                                      color: attendanceRate >= 90 ? Colors.green : (attendanceRate >= 75 ? Colors.orange : Colors.red),
                                    ),
                                  ),
                                  Text(
                                    '${attendanceRate.toStringAsFixed(0)}%',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      attendanceRate >= 90
                                          ? 'Excellent attendance'
                                          : (attendanceRate >= 75 ? 'Satisfactory attendance' : 'Needs attention'),
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Days Logged: $totalAttendance • Present: $presentCount\nApproved Leave Days: $approvedLeaves\nPending Leaves: ${leaves.where((l) => l['status'] == 'PENDING').length}',
                                      style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          if (staffAttendances.isNotEmpty) ...[
                            const Divider(height: 24),
                            Text(
                              'Previous Attendance History:',
                              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...staffAttendances.map((a) {
                              final dateStr = a['date'] ?? '';
                              String formattedDate = dateStr;
                              try {
                                formattedDate = DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr));
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

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.alarm, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(formattedDate, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500)),
                                        Text('In: $checkIn • Out: $checkOut', style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondaryColor)),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(hours, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                      child: Text(
                                        status,
                                        style: GoogleFonts.outfit(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ]
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Timetable schedule
                  Text(
                    'Class Schedule (Timetable)',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  timetables.isEmpty
                      ? Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          color: AppTheme.backgroundColor,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                'No timetable slots assigned.',
                                style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: timetables.map((slot) {
                            final classSection = slot['classSection'] ?? {};
                            final className = classSection['class']?['name'] ?? '';
                            final sectionName = classSection['name'] ?? '';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 0,
                              color: AppTheme.backgroundColor,
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getDayName(slot['dayOfWeek'] ?? 1).substring(0, 3),
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  '${slot['subject'] ?? "Subject"} • Room ${slot['roomNo'] ?? "N/A"}',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Class: $className-$sectionName • Time: ${slot['startTime']} - ${slot['endTime']}',
                                  style: GoogleFonts.outfit(fontSize: 12),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 24),

                  // Leave history
                  Text(
                    'Leaves History',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  leaves.isEmpty
                      ? Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          color: AppTheme.backgroundColor,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                'No leave requests submitted.',
                                style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: leaves.map((leave) {
                            final fromStr = leave['fromDate'] != null ? DateFormat('dd MMM').format(DateTime.parse(leave['fromDate'])) : '';
                            final toStr = leave['toDate'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(leave['toDate'])) : '';
                            final status = leave['status'] ?? 'PENDING';
                            final statusColor = status == 'APPROVED' ? Colors.green : (status == 'REJECTED' ? Colors.red : Colors.orange);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 0,
                              color: AppTheme.backgroundColor,
                              child: ListTile(
                                title: Text(
                                  '${leave['leaveType']} ($fromStr to $toStr)',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Reason: ${leave['reason']}',
                                  style: GoogleFonts.outfit(fontSize: 12),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    status,
                                    style: GoogleFonts.outfit(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 24),

                  // Salaries history
                  Text(
                    'Salary Track & Payroll',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  salaries.isEmpty
                      ? Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          color: AppTheme.backgroundColor,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                'No salary payout records generated.',
                                style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: salaries.map((sal) {
                            final status = sal['status'] ?? 'PENDING';
                            final statusColor = status == 'PAID' ? Colors.green : Colors.orange;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 0,
                              color: AppTheme.backgroundColor,
                              child: ListTile(
                                leading: const Icon(Icons.account_balance_wallet, color: AppTheme.primaryColor),
                                title: Text(
                                  '${sal['month']} ${sal['year']}',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Amount Payout: ₹${sal['amount']}',
                                  style: GoogleFonts.outfit(fontSize: 12),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    status,
                                    style: GoogleFonts.outfit(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showStudentDetails(Map<String, dynamic> student) {
    final parentRelations = student['parents'] as List<dynamic>? ?? [];
    final marks = student['marks'] as List<dynamic>? ?? [];
    final attendance = student['attendance'] as List<dynamic>? ?? [];
    final feeRecords = student['feeRecords'] as List<dynamic>? ?? [];
    final busRoute = student['busRoute'] ?? {};

    // Calculate attendance percentage
    final totalAttendance = attendance.length;
    final presentCount = attendance.where((a) => a['status'] == 'PRESENT' || a['status'] == 'LEAVE').length;
    final double attendancePercentage = totalAttendance > 0 ? (presentCount / totalAttendance * 100) : 100.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Student Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.indigo.withOpacity(0.1),
                        child: Text(
                          (student['fullName'] ?? 'S')[0].toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student['fullName'] ?? 'Unknown Name',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Roll No: ${student['rollNo'] ?? "N/A"} • Class: ${student['classSection']?['class']?['name'] ?? "N/A"}-${student['classSection']?['name'] ?? ""}',
                              style: GoogleFonts.outfit(fontSize: 13, color: AppTheme.textSecondaryColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'DOB: ${student['dateOfBirth'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(student['dateOfBirth'])) : "N/A"} • Gender: ${student['gender'] ?? "N/A"}',
                              style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Parents Information
                  Text(
                    'Parent / Guardian Contacts',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  parentRelations.isEmpty
                      ? Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          color: AppTheme.backgroundColor,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                'No parents registered or linked.',
                                style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: parentRelations.map((rel) {
                            final parent = rel['parent'] ?? {};
                            final pUser = parent['user'] ?? {};
                            final relation = parent['relation'] ?? 'FATHER';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 0,
                              color: AppTheme.backgroundColor,
                              child: ListTile(
                                leading: const Icon(Icons.people_outline, color: AppTheme.primaryColor),
                                title: Text(
                                  '${pUser['fullName'] ?? "Parent Name"} ($relation)',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Email: ${pUser['email'] ?? "N/A"} • Phone: ${pUser['phoneNumber'] ?? "N/A"}',
                                  style: GoogleFonts.outfit(fontSize: 12),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 24),

                  // Student Attendance Gauge
                  Text(
                    'Attendance Overview',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: CircularProgressIndicator(
                                      value: attendancePercentage / 100,
                                      strokeWidth: 8,
                                      backgroundColor: Colors.grey.shade100,
                                      color: attendancePercentage >= 85 ? Colors.indigo : (attendancePercentage >= 75 ? Colors.orange : Colors.red),
                                    ),
                                  ),
                                  Text(
                                    '${attendancePercentage.toStringAsFixed(0)}%',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      attendancePercentage >= 85
                                          ? 'Regular Attendance'
                                          : (attendancePercentage >= 75 ? 'Satisfactory Attendance' : 'Shortage of Attendance'),
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Days Present: $presentCount / $totalAttendance days logged\nAbsent Days: ${attendance.where((a) => a['status'] == 'ABSENT').length}',
                                      style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          if (attendance.isNotEmpty) ...[
                            const Divider(height: 24),
                            Text(
                              'Previous Attendance History:',
                              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...attendance.map((a) {
                              final dateStr = a['date'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(a['date'])) : '';
                              final status = a['status'] ?? 'PRESENT';
                              final statusColor = status == 'PRESENT' ? Colors.green : (status == 'LEAVE' ? Colors.orange : Colors.red);
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.event_note, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(dateStr, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500)),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                      child: Text(
                                        status,
                                        style: GoogleFonts.outfit(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Exam marks performance
                  Text(
                    'Academic Performance (Exam Marks)',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  marks.isEmpty
                      ? Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          color: AppTheme.backgroundColor,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                'No exam grades recorded.',
                                style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: marks.map((mark) {
                            final examName = mark['exam']?['name'] ?? 'Exam';
                            final score = mark['marksObtained'] ?? 0.0;
                            final maxScore = mark['maxMarks'] ?? 100.0;
                            final percent = maxScore > 0 ? (score / maxScore * 100) : 0.0;
                            final gradeColor = percent >= 75 ? Colors.green : (percent >= 35 ? Colors.orange : Colors.red);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 0,
                              color: AppTheme.backgroundColor,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: gradeColor.withOpacity(0.1),
                                  child: Text(
                                    percent >= 75 ? 'A' : (percent >= 50 ? 'B' : (percent >= 35 ? 'C' : 'F')),
                                    style: TextStyle(color: gradeColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  '${mark['subject'] ?? "Subject"} • $examName',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Marks: $score / $maxScore (${percent.toStringAsFixed(1)}%)',
                                  style: GoogleFonts.outfit(fontSize: 12),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 24),

                  // Homework assigned to this class section
                  Text(
                    'Assigned Homework',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  () {
                    final classSec = student['classSection'] ?? {};
                    final homeworks = classSec['homeworks'] as List<dynamic>? ?? [];
                    if (homeworks.isEmpty) {
                      return Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        color: AppTheme.backgroundColor,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'No homework assigned.',
                              style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                            ),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: homeworks.map<Widget>((hw) {
                        final dueStr = hw['dueDate'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(hw['dueDate'])) : '';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0,
                          color: AppTheme.backgroundColor,
                          child: ListTile(
                            leading: const Icon(Icons.assignment, color: AppTheme.primaryColor),
                            title: Text(
                              '${hw['subject'] ?? "Subject"} • ${hw['title'] ?? ""}',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Details: ${hw['description'] ?? "No description"}\nDue Date: $dueStr',
                              style: GoogleFonts.outfit(fontSize: 12),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }(),
                  const SizedBox(height: 24),

                  // Fee ledger status
                  Text(
                    'Fee Ledger & Dues',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  feeRecords.isEmpty
                      ? Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          color: AppTheme.backgroundColor,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                'No fee ledgers generated.',
                                style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: feeRecords.map((fee) {
                            final status = fee['status'] ?? 'PENDING';
                            final statusColor = status == 'PAID' ? Colors.green : (status == 'PARTIAL' ? Colors.orange : Colors.red);
                            final dueStr = fee['dueDate'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(fee['dueDate'])) : '';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 0,
                              color: AppTheme.backgroundColor,
                              child: ListTile(
                                leading: const Icon(Icons.receipt_long, color: AppTheme.primaryColor),
                                title: Text(
                                  '${fee['category'] ?? "Tuition Fee"} Payout',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Amount: ₹${fee['amount']} • Paid: ₹${fee['paidAmount']}\nDue: $dueStr',
                                  style: GoogleFonts.outfit(fontSize: 12),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    status,
                                    style: GoogleFonts.outfit(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 24),

                  // Bus Route Stops
                  Text(
                    'Assigned School Bus Route',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  (busRoute.isEmpty || busRoute['id'] == null)
                      ? Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          color: AppTheme.backgroundColor,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                'No school transport route assigned.',
                                style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                              ),
                            ),
                          ),
                        )
                      : Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      busRoute['routeName'] ?? 'Bus Route',
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                      child: Text(
                                        busRoute['busNo'] ?? '',
                                        style: GoogleFonts.outfit(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Driver: ${busRoute['driverName'] ?? "N/A"} • Contact: ${busRoute['driverContact'] ?? "N/A"}',
                                  style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                                ),
                                const Divider(height: 20),
                                Text(
                                  'Route Stops Sequence:',
                                  style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                if (busRoute['stops'] != null && (busRoute['stops'] as List).isNotEmpty)
                                  ...(busRoute['stops'] as List).map((stop) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 10,
                                            backgroundColor: AppTheme.primaryColor,
                                            child: Text(
                                              '${stop['sequenceNo'] ?? 0}',
                                              style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            stop['stopName'] ?? '',
                                            style: GoogleFonts.outfit(fontSize: 13),
                                          ),
                                          const Spacer(),
                                          Text(
                                            stop['arrivalTime'] ?? '',
                                            style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                                          ),
                                        ],
                                      ),
                                    );
                                  })
                                else
                                  Text('No stops registered.', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final schoolProvider = Provider.of<SchoolProvider>(context);
    final academicProvider = Provider.of<AcademicProvider>(context);
    final user = schoolProvider.currentUser ?? {};
    final userRole = user['role'] ?? 'TEACHER';
    final isTeacher = userRole == 'TEACHER';

    // Collect all class section IDs this teacher is associated with
    final teacherProfile = user['teacherProfile'] ?? {};
    final isClassTeacher = teacherProfile['classTeacherOf'] != null;
    final teacherClassSectionIds = <String>{};
    if (isClassTeacher && teacherProfile['classTeacherOf']?['id'] != null) {
      teacherClassSectionIds.add(teacherProfile['classTeacherOf']?['id']);
    }
    for (var slot in academicProvider.timetable) {
      if (slot['classSectionId'] != null) {
        teacherClassSectionIds.add(slot['classSectionId']);
      }
    }

    // Filter employees: exclude parents and correspondents
    final employees = schoolProvider.users.where((user) {
      final role = user['role'];
      final matchesQuery = user['fullName']?.toLowerCase().contains(_employeeQuery) == true ||
          user['email']?.toLowerCase().contains(_employeeQuery) == true ||
          user['role']?.toLowerCase().contains(_employeeQuery) == true;
      return matchesQuery && (role == 'TEACHER' || role == 'PT' || role == 'PRINCIPAL' || role == 'HM' || role == 'STAFF_HEAD');
    }).toList();

    // Filter students
    final students = academicProvider.students.where((student) {
      final matchesQuery = student['fullName']?.toLowerCase().contains(_studentQuery) == true ||
          student['rollNo']?.toLowerCase().contains(_studentQuery) == true ||
          student['classSection']?['class']?['name']?.toLowerCase().contains(_studentQuery) == true;
      if (isTeacher) {
        final belongsToTeacherClass = teacherClassSectionIds.contains(student['classSectionId']);
        return matchesQuery && belongsToTeacherClass;
      }
      return matchesQuery;
    }).toList();

    Widget buildStudentsList() {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _studentSearchController,
              decoration: InputDecoration(
                hintText: 'Search students by name, class, roll no...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondaryColor),
                suffixIcon: _studentQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _studentSearchController.clear(),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: academicProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : students.isEmpty
                    ? Center(
                        child: Text(
                          'No students found.',
                          style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                        ),
                      )
                    : ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final cSec = student['classSection'] ?? {};
                          final cls = cSec['class'] ?? {};
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo.withOpacity(0.1),
                                child: Text(
                                  (student['fullName'] ?? 'S')[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                student['fullName'] ?? 'Unknown',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Roll No: ${student['rollNo']} • Class: ${cls['name'] ?? ""}-${cSec['name'] ?? ""}',
                                style: GoogleFonts.outfit(fontSize: 12),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                              onTap: () => _showStudentDetails(student),
                            ),
                          );
                        },
                      ),
          ),
        ],
      );
    }

    if (isTeacher) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Students Registry'),
        ),
        body: SafeArea(
          child: buildStudentsList(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('School Registry & Insights'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.badge_outlined), text: 'Employees'),
            Tab(icon: Icon(Icons.school_outlined), text: 'Students'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // Employees Tab
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _employeeSearchController,
                    decoration: InputDecoration(
                      hintText: 'Search employees by name, role...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondaryColor),
                      suffixIcon: _employeeQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _employeeSearchController.clear(),
                            )
                          : null,
                    ),
                  ),
                ),
                Expanded(
                  child: schoolProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : employees.isEmpty
                          ? Center(
                              child: Text(
                                'No employees found.',
                                style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                              ),
                            )
                          : ListView.builder(
                              itemCount: employees.length,
                              itemBuilder: (context, index) {
                                final emp = employees[index];
                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                      child: Text(
                                        (emp['fullName'] ?? 'E')[0].toUpperCase(),
                                        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(
                                      emp['fullName'] ?? 'Unknown',
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      '${emp['role']} • ${emp['email'] ?? "No email"}',
                                      style: GoogleFonts.outfit(fontSize: 12),
                                    ),
                                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                                    onTap: () => _showEmployeeDetails(emp),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),

            // Students Tab
            buildStudentsList(),
          ],
        ),
      ),
    );
  }
}
