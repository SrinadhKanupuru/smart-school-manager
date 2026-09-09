import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/school_provider.dart';
import '../../providers/academic_provider.dart';
import '../../core/theme.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<SchoolProvider>(context, listen: false).currentUser;
      final teacherProfileId = user?['teacherProfile']?['id'];
      if (teacherProfileId != null) {
        Provider.of<AcademicProvider>(context, listen: false).fetchTimetable(teacherId: teacherProfileId);
      }
      Provider.of<AcademicProvider>(context, listen: false).fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);
    final academic = Provider.of<AcademicProvider>(context);
    final user = provider.currentUser ?? {};
    final teacherProfile = user['teacherProfile'] ?? {};
    final isClassTeacher = teacherProfile['classTeacherOf'] != null;
    final assignedClass = isClassTeacher ? '${teacherProfile['classTeacherOf']?['class']?['name']} - ${teacherProfile['classTeacherOf']?['name']}' : 'Not Assigned';

    // Collect all class section IDs this teacher is associated with
    final teacherClassSectionIds = <String>{};
    if (isClassTeacher && teacherProfile['classTeacherOf']?['id'] != null) {
      teacherClassSectionIds.add(teacherProfile['classTeacherOf']?['id']);
    }
    for (var slot in academic.timetable) {
      if (slot['classSectionId'] != null) {
        teacherClassSectionIds.add(slot['classSectionId']);
      }
    }

    final myClassesCount = teacherClassSectionIds.length;
    final myStudents = academic.students.where((s) => teacherClassSectionIds.contains(s['classSectionId'])).toList();
    final myStudentsCount = myStudents.length;

    final todayWeekday = DateTime.now().weekday; // 1 = Monday, ..., 7 = Sunday
    final todaysClassesCount = academic.timetable.where((slot) => slot['dayOfWeek'] == todayWeekday).length;

    // Calculate attendance rate for these students
    double totalAttendanceSum = 0.0;
    int studentsWithAttendance = 0;
    for (var student in myStudents) {
      final attendanceList = student['attendance'] as List<dynamic>? ?? [];
      if (attendanceList.isNotEmpty) {
        final presentCount = attendanceList.where((a) => a['status'] == 'PRESENT' || a['status'] == 'LEAVE').length;
        final pct = (presentCount / attendanceList.length) * 100;
        totalAttendanceSum += pct;
        studentsWithAttendance++;
      }
    }
    final avgAttendancePct = studentsWithAttendance > 0 
        ? (totalAttendanceSum / studentsWithAttendance).round() 
        : 100;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          provider.currentSchool?['name'] ?? 'School Portal',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning,',
                          style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textSecondaryColor),
                        ),
                        Text(
                          user['fullName'] ?? 'Mrs. Sharma',
                          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
                        ),
                        if (isClassTeacher)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Class Teacher: $assignedClass',
                              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primaryColor,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Teacher stats block
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                children: [
                  _buildStatCard(Icons.class_, '$myClassesCount', 'My Classes', Colors.purple),
                  _buildStatCard(Icons.groups, '$myStudentsCount', 'Students', Colors.indigo),
                  _buildStatCard(Icons.today, '$todaysClassesCount', "Today's Classes", Colors.teal),
                  _buildStatCard(Icons.pie_chart, '$avgAttendancePct%', 'Attendance Rate', Colors.orange),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Access
              Text(
                'Quick Access',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickAccessBtn(Icons.checklist, 'Attendance', () {
                    Navigator.pushNamed(context, '/mark-attendance');
                  }),
                  _buildQuickAccessBtn(Icons.assignment_outlined, 'Homework', () {
                    Navigator.pushNamed(context, '/homework-upload');
                  }),
                  _buildQuickAccessBtn(Icons.book, 'Diary', () {
                    Navigator.pushNamed(context, '/learning-diary');
                  }),
                  _buildQuickAccessBtn(Icons.sick, 'Leave', () {
                    Navigator.pushNamed(context, '/leave-application');
                  }),
                ],
              ),
              const SizedBox(height: 24),

              Card(
                elevation: 0,
                color: AppTheme.primaryColor.withOpacity(0.04),
                child: ListTile(
                  leading: const Icon(Icons.video_library, color: AppTheme.primaryColor),
                  title: Text('Upload Class Notes & Videos', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  subtitle: Text('Publish lecture videos, PDF books or chart images.', style: GoogleFonts.outfit(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/upload-resources');
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: AppTheme.primaryColor.withOpacity(0.04),
                child: ListTile(
                  leading: const Icon(Icons.insights, color: AppTheme.primaryColor),
                  title: Text('School Insights & Registry', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  subtitle: Text('Track student/teacher records, previous attendance & marks.', style: GoogleFonts.outfit(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/school-insights');
                  },
                ),
              ),
              if (isClassTeacher) ...[
                const SizedBox(height: 8),
                Card(
                  elevation: 0,
                  color: AppTheme.primaryColor.withOpacity(0.04),
                  child: ListTile(
                    leading: const Icon(Icons.check_circle_outline, color: AppTheme.primaryColor),
                    title: Text('Student Leave Approvals', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    subtitle: Text('Approve or reject leave requests from parents.', style: GoogleFonts.outfit(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, '/leave-approval');
                    },
                  ),
                ),
              ],
              const SizedBox(height: 8),
              // Grades sheet trigger
              Card(
                elevation: 0,
                color: AppTheme.primaryColor.withOpacity(0.04),
                child: ListTile(
                  leading: const Icon(Icons.grade, color: AppTheme.primaryColor),
                  title: Text('Exam Marks Sheet', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  subtitle: Text('Enter and modify student test grades.', style: GoogleFonts.outfit(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/enter-marks');
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: AppTheme.primaryColor.withOpacity(0.04),
                child: ListTile(
                  leading: const Icon(Icons.punch_clock, color: AppTheme.primaryColor),
                  title: Text('Time Sheet Tracker', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  subtitle: Text('Log working hours and start/end times.', style: GoogleFonts.outfit(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/time-sheet');
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: AppTheme.primaryColor.withOpacity(0.04),
                child: ListTile(
                  leading: const Icon(Icons.face_retouching_natural, color: AppTheme.primaryColor),
                  title: Text('Self Face Attendance', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  subtitle: Text('Punch check-in or check-out using face and geofence verification.', style: GoogleFonts.outfit(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/staff-attendance');
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: AppTheme.primaryColor.withOpacity(0.04),
                child: ListTile(
                  leading: const Icon(Icons.history_toggle_off, color: AppTheme.primaryColor),
                  title: Text('My Attendance Logs', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  subtitle: Text('Track your face attendance entries across current & past months.', style: GoogleFonts.outfit(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/staff-attendance-history');
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: AppTheme.primaryColor.withOpacity(0.04),
                child: ListTile(
                  leading: const Icon(Icons.edit_calendar_outlined, color: AppTheme.primaryColor),
                  title: Text('Attendance Rectification', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  subtitle: Text('Request correction for missed check-ins/check-outs or wrong entries.', style: GoogleFonts.outfit(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/attendance-rectification');
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: AppTheme.primaryColor.withOpacity(0.04),
                child: ListTile(
                  leading: const Icon(Icons.calendar_month, color: AppTheme.primaryColor),
                  title: Text('School Calendar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  subtitle: Text('View upcoming school holidays and weekly off schedules.', style: GoogleFonts.outfit(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/holiday-calendar');
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: AppTheme.primaryColor.withOpacity(0.04),
                child: ListTile(
                  leading: const Icon(Icons.currency_exchange, color: AppTheme.primaryColor),
                  title: Text('Salary Advances & Loans', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  subtitle: Text('Apply for advances or track outstanding balances.', style: GoogleFonts.outfit(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/loans');
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: AppTheme.primaryColor.withOpacity(0.04),
                child: ListTile(
                  leading: const Icon(Icons.receipt_long, color: AppTheme.primaryColor),
                  title: Text('My Payslips', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  subtitle: Text('View, print, or download your monthly payslips.', style: GoogleFonts.outfit(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/my-payslips');
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: AppTheme.primaryColor.withOpacity(0.04),
                child: ListTile(
                  leading: const Icon(Icons.report_problem, color: AppTheme.primaryColor),
                  title: Text('Complaints & Grievances', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  subtitle: Text('File new complaints or view status of your complaints.', style: GoogleFonts.outfit(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/complaints-list');
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Today's schedule
              Text(
                "Today's Schedule",
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              academic.timetable.isEmpty
                  ? Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: Colors.grey.shade100),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No classes scheduled for today.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: academic.timetable.length,
                      itemBuilder: (context, index) {
                        final slot = academic.timetable[index];
                        final className = slot['classSection']?['class']?['name'] ?? '';
                        final sectionName = slot['classSection']?['name'] ?? '';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: Colors.grey.shade100),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                slot['startTime'] ?? '',
                                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                              ),
                            ),
                            title: Text(
                              '${slot['subject']} • Class $className-$sectionName',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('Room ${slot['roomNo'] ?? ''}', style: GoogleFonts.outfit(fontSize: 12)),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  provider.logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (idx) {
          setState(() => _navIndex = idx);
          if (idx == 1) {
            Navigator.pushNamed(context, '/my-timetable');
          } else if (idx == 2) {
            Navigator.pushNamed(context, '/notice-view');
          } else if (idx == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notices'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: GoogleFonts.outfit(fontSize: 9, color: AppTheme.textSecondaryColor, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessBtn(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        IconButton.filledTonal(
          onPressed: onTap,
          icon: Icon(icon, color: AppTheme.primaryColor),
          padding: const EdgeInsets.all(14),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.primaryColor.withOpacity(0.06),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textPrimaryColor),
        )
      ],
    );
  }
}
