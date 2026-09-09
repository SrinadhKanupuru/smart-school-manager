import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/school_provider.dart';
import '../../providers/admin_provider.dart';
import '../../core/theme.dart';
import 'package:intl/intl.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _navIndex = 0;
  int _selectedChildIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchChildrenDashboard();
      Provider.of<AdminProvider>(context, listen: false).fetchNotices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);
    final admin = Provider.of<AdminProvider>(context);
    final user = provider.currentUser ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(
          provider.currentSchool?['name'] ?? 'Parent Portal',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              Provider.of<AdminProvider>(context, listen: false).fetchChildrenDashboard(),
              Provider.of<AdminProvider>(context, listen: false).fetchNotices(),
            ]);
          },
          child: admin.childrenDashboardData.isEmpty && admin.isLoading
              ? const Center(child: CircularProgressIndicator())
              : admin.childrenDashboardData.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.family_restroom, size: 60, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  'No Children Enrolled',
                                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Please contact school administration to enroll students and map your parent profile.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Welcome Banner
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
                                      user['fullName'] ?? 'Parent',
                                      style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
                                    ),
                                  ],
                                ),
                              ),
                              const CircleAvatar(
                                radius: 28,
                                backgroundColor: AppTheme.primaryColor,
                                child: Icon(Icons.face, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Child Selector (Horizontal Tab selector)
                          Text(
                            'Select Child:',
                            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSecondaryColor),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: admin.childrenDashboardData.length,
                              itemBuilder: (context, idx) {
                                final child = admin.childrenDashboardData[idx];
                                final isSelected = _selectedChildIndex == idx;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedChildIndex = idx),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppTheme.primaryColor : Colors.white,
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(color: Colors.grey.shade200, width: 1),
                                    ),
                                    child: Text(
                                      child['fullName'] ?? '',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Selected Child View
                          _buildChildDashboard(admin.childrenDashboardData[_selectedChildIndex]),
                        ],
                      ),
                    ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (idx) {
          if (idx == 0) {
            setState(() => _navIndex = idx);
          } else if (idx == 1) {
            setState(() => _navIndex = idx);
            Navigator.pushNamed(context, '/fees-details').then((_) {
              if (mounted) {
                setState(() => _navIndex = 0);
                Provider.of<AdminProvider>(context, listen: false).fetchChildrenDashboard();
              }
            });
          } else if (idx == 2) {
            setState(() => _navIndex = idx);
            Navigator.pushNamed(context, '/notice-view').then((_) {
              if (mounted) {
                setState(() => _navIndex = 0);
                Provider.of<AdminProvider>(context, listen: false).fetchChildrenDashboard();
              }
            });
          } else if (idx == 3) {
            setState(() => _navIndex = idx);
            Navigator.pushNamed(context, '/profile').then((_) {
              if (mounted) {
                setState(() => _navIndex = 0);
                Provider.of<AdminProvider>(context, listen: false).fetchChildrenDashboard();
              }
            });
          }
        },
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Fees'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notices'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildChildDashboard(Map<String, dynamic> child) {
    final pendingFees = child['feeRecords']
            ?.where((r) => r['status'] != 'PAID')
            ?.fold(0.0, (sum, item) => sum + (item['amount'] - item['paidAmount'])) ??
        0.0;

    String avgGradeStr = 'N/A';
    if (child['marks'] != null && (child['marks'] as List).isNotEmpty) {
      final marksList = child['marks'] as List;
      double totalObtained = 0;
      double totalMax = 0;
      for (var m in marksList) {
        totalObtained += (m['marksObtained'] ?? 0.0).toDouble();
        totalMax += (m['maxMarks'] ?? 100.0).toDouble();
      }
      if (totalMax > 0) {
        avgGradeStr = '${(totalObtained / totalMax * 100).toStringAsFixed(1)}%';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Summary metrics
        Row(
          children: [
            Expanded(
              child: _buildChildMetricCard(
                Icons.calendar_month,
                '${child['attendancePercentage']}%',
                'Attendance',
                Colors.green,
                onTap: () => _showChildAttendanceHistory(child),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildChildMetricCard(
                Icons.pending_actions,
                '₹${pendingFees.toStringAsFixed(0)}',
                'Pending Fees',
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildChildMetricCard(
                Icons.assignment,
                '${child['homework']?.length ?? 0}',
                'Pending Homework',
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildChildMetricCard(
                Icons.grade,
                avgGradeStr,
                'Exam Grade',
                Colors.orange,
                onTap: () => _showChildMarksHistory(child),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Quick Access menu
        Text(
          'Quick Access',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMenuIconBtn(Icons.book, 'Diary', () {
              _showDiaryDialog(child['diaries'] ?? []);
            }),
            _buildMenuIconBtn(Icons.assignment, 'Homework', () {
              _showHomeworkDialog(child['homework'] ?? []);
            }),
            _buildMenuIconBtn(Icons.credit_card, 'Pay Fees', () {
              Navigator.pushNamed(context, '/fees-details').then((_) {
                if (mounted) {
                  Provider.of<AdminProvider>(context, listen: false).fetchChildrenDashboard();
                }
              });
            }),
            _buildMenuIconBtn(Icons.directions_bus, 'Bus Route', () {
              final busId = child['busRoute']?['id']?.toString() ?? '';
              final userRole = Provider.of<SchoolProvider>(context, listen: false).currentUser?['role'] ?? 'PARENT';
              Navigator.pushNamed(
                context,
                '/bus-route-view',
                arguments: {
                  'busId': busId,
                  'userRole': userRole,
                },
              ).then((_) {
                if (mounted) {
                  Provider.of<AdminProvider>(context, listen: false).fetchChildrenDashboard();
                }
              });
            }),
          ],
        ),
        const SizedBox(height: 24),

        // Study Materials & Class Notes / Lecture Videos
        Card(
          elevation: 0,
          color: AppTheme.primaryColor.withOpacity(0.04),
          child: ListTile(
            leading: const Icon(Icons.video_library, color: AppTheme.primaryColor),
            title: Text('Study Materials & Lecture Videos', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            subtitle: Text('Download class notes, books, images, and videos.', style: GoogleFonts.outfit(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showResourcesDialog(child['resources'] ?? [], child['fullName'] ?? 'Child');
            },
          ),
        ),
        const SizedBox(height: 8),

        // Permission requests and complaints
        Card(
          elevation: 0,
          color: AppTheme.primaryColor.withOpacity(0.04),
          child: ListTile(
            leading: const Icon(Icons.sick, color: AppTheme.primaryColor),
            title: Text('Request Leave / Sick Permission', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            subtitle: Text('Inform the class teacher if your child is unwell.', style: GoogleFonts.outfit(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/ask-permission').then((_) {
                if (mounted) {
                  Provider.of<AdminProvider>(context, listen: false).fetchChildrenDashboard();
                }
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: AppTheme.primaryColor.withOpacity(0.04),
          child: ListTile(
            leading: const Icon(Icons.report, color: AppTheme.primaryColor),
            title: Text('Raise a Complaint', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            subtitle: Text('Report issues with buses, classrooms, cleanings, or staff.', style: GoogleFonts.outfit(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/submit-complaint').then((_) {
                if (mounted) {
                  Provider.of<AdminProvider>(context, listen: false).fetchChildrenDashboard();
                }
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          color: AppTheme.primaryColor.withOpacity(0.04),
          child: ListTile(
            leading: const Icon(Icons.date_range, color: AppTheme.primaryColor),
            title: Text('School Calendar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            subtitle: Text('View upcoming school holidays and weekly off schedules.', style: GoogleFonts.outfit(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/holiday-calendar').then((_) {
                if (mounted) {
                  Provider.of<AdminProvider>(context, listen: false).fetchChildrenDashboard();
                }
              });
            },
          ),
        ),
        const SizedBox(height: 24),

        // Notice Board preview
        Text(
          'School Notices',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Consumer<AdminProvider>(
          builder: (context, adminProvider, _) {
            if (adminProvider.notices.isEmpty) {
              return Card(
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('No announcements posted yet.', style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor)),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: adminProvider.notices.length > 2 ? 2 : adminProvider.notices.length,
              itemBuilder: (context, index) {
                final notice = adminProvider.notices[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.shade100),
                  ),
                  child: ListTile(
                    title: Text(notice['title'] ?? '', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    subtitle: Text(notice['description'] ?? '', style: GoogleFonts.outfit(fontSize: 12)),
                    trailing: const Icon(Icons.notifications_active, size: 16, color: AppTheme.primaryColor),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            Provider.of<SchoolProvider>(context, listen: false).logout();
            Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
          },
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildChildMetricCard(IconData icon, String value, String label, Color color, {VoidCallback? onTap}) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onTap != null)
                    const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.textSecondaryColor),
                ],
              ),
              Text(label, style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondaryColor)),
            ],
          ),
        ),
      ),
    );
  }

  void _showChildAttendanceHistory(Map<String, dynamic> child) {
    final attendance = child['attendance'] as List<dynamic>? ?? [];
    final double attendancePercentage = (child['attendancePercentage'] ?? 100).toDouble();
    final totalAttendance = child['attendanceCount'] ?? attendance.length;
    final absentDays = attendance.where((a) => a['status'] == 'ABSENT').length;
    final presentDays = attendance.where((a) => a['status'] == 'PRESENT' || a['status'] == 'LEAVE').length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
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
                  Text(
                    '${child['fullName'] ?? "Child"}\'s Attendance History',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
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
                      child: Row(
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
                                  color: attendancePercentage >= 85 ? Colors.green : (attendancePercentage >= 75 ? Colors.orange : Colors.red),
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
                                  'Days Present: $presentDays / $totalAttendance days logged\nAbsent Days: $absentDays',
                                  style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Previous Attendance Log',
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (attendance.isEmpty)
                    Card(
                      elevation: 0,
                      color: AppTheme.backgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            'No attendance records found.',
                            style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                          ),
                        ),
                      ),
                    )
                  else
                    ...attendance.map((a) {
                      final dateStr = a['date'] != null
                          ? DateFormat('dd MMM yyyy').format(DateTime.parse(a['date']))
                          : 'Unknown Date';
                      final status = a['status'] ?? 'PRESENT';
                      final statusColor = status == 'PRESENT'
                          ? Colors.green
                          : (status == 'LEAVE' ? Colors.orange : Colors.red);
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        color: AppTheme.backgroundColor,
                        child: ListTile(
                          leading: const Icon(Icons.event_note, color: Colors.grey),
                          title: Text(dateStr, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: GoogleFonts.outfit(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showChildMarksHistory(Map<String, dynamic> child) {
    final marks = child['marks'] as List<dynamic>? ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
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
                  Text(
                    '${child['fullName'] ?? "Child"}\'s Academic Performance',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (marks.isEmpty)
                    Card(
                      elevation: 0,
                      color: AppTheme.backgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            'No exam marks recorded.',
                            style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                          ),
                        ),
                      ),
                    )
                  else
                    ...marks.map((mark) {
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
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMenuIconBtn(IconData icon, String label, VoidCallback onTap) {
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

  void _showDiaryDialog(List<dynamic> diaries) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Learning Diary Logs', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(height: 24),
              Expanded(
                child: diaries.isEmpty
                    ? Center(child: Text('No logs recorded.', style: GoogleFonts.outfit()))
                    : ListView.builder(
                        itemCount: diaries.length,
                        itemBuilder: (context, index) {
                          final item = diaries[index];
                          return ListTile(
                            title: Text('${item['subject']} - Daily Entry', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                            subtitle: Text(item['details'] ?? ''),
                            leading: const Icon(Icons.bookmark, color: AppTheme.primaryColor),
                          );
                        },
                      ),
              )
            ],
          ),
        );
      },
    );
  }

  void _showHomeworkDialog(List<dynamic> homework) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Pending Homeworks', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(height: 24),
              Expanded(
                child: homework.isEmpty
                    ? Center(child: Text('No homework pending.', style: GoogleFonts.outfit()))
                    : ListView.builder(
                        itemCount: homework.length,
                        itemBuilder: (context, index) {
                          final item = homework[index];
                          return ListTile(
                            title: Text(item['title'] ?? '', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                            subtitle: Text('${item['subject']} • Due: ${item['dueDate'].toString().substring(0,10)}'),
                            trailing: const Icon(Icons.assignment_outlined, color: Colors.blue),
                          );
                        },
                      ),
              )
            ],
          ),
        );
      },
    );
  }

  void _showResourcesDialog(List<dynamic> resources, String childName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  Text(
                    'Study Materials - $childName',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Download notes, diagrams, and lecture videos shared by class teachers.',
                    style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: resources.isEmpty
                        ? Center(
                            child: Text(
                              'No study materials uploaded yet.',
                              style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: resources.length,
                            itemBuilder: (context, index) {
                              final item = resources[index];
                              final type = item['resourceType'] ?? 'PDF';
                              final subject = item['subject'] ?? 'Subject';
                              final title = item['title'] ?? 'Title';
                              
                              IconData typeIcon = Icons.insert_drive_file;
                              Color iconColor = Colors.blue;
                              if (type == 'IMAGE') {
                                typeIcon = Icons.image;
                                iconColor = Colors.orange;
                              } else if (type == 'VIDEO') {
                                typeIcon = Icons.video_library;
                                iconColor = Colors.red;
                              }

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 0,
                                color: AppTheme.backgroundColor,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: iconColor.withOpacity(0.1),
                                    child: Icon(typeIcon, color: iconColor),
                                  ),
                                  title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                                  subtitle: Text(
                                    '$subject • ${item['description'] ?? "No description provided"}',
                                    style: GoogleFonts.outfit(fontSize: 12),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.download_for_offline, color: AppTheme.primaryColor),
                                    onPressed: () {
                                      _simulateDownload(context, title, type);
                                    },
                                  ),
                                  onTap: () {
                                    _openResourceViewer(context, item);
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _simulateDownload(BuildContext ctx, String title, String type) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('Downloading $title ($type)...'),
        duration: const Duration(seconds: 1),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('$title saved successfully to downloads directory!')),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _openResourceViewer(BuildContext ctx, Map<String, dynamic> resource) {
    final type = resource['resourceType'] ?? 'PDF';
    final title = resource['title'] ?? 'Viewer';
    final url = resource['fileUrl'] ?? '';

    showDialog(
      context: ctx,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450, maxHeight: 600),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),
                
                // Content based on type
                Expanded(
                  child: type == 'IMAGE'
                      ? _buildImageMockViewer(url)
                      : (type == 'VIDEO' ? _buildVideoMockViewer(url) : _buildPdfMockViewer(url)),
                ),
                
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _simulateDownload(ctx, title, type);
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Download Offline File'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPdfMockViewer(String url) {
    final isLocalBackend = url.contains('/uploads/');
    final isMock = url.startsWith('mock://') || isLocalBackend;
    String fileName = 'Page 1 of 8 (Trigonometry Formulas)';
    if (isMock) {
      final baseName = Uri.decodeComponent(url.split('/').last);
      final firstDashIndex = baseName.indexOf('-');
      if (firstDashIndex != -1 && firstDashIndex < baseName.length - 1) {
        final prefix = baseName.substring(0, firstDashIndex);
        if (int.tryParse(prefix) != null) {
          fileName = baseName.substring(firstDashIndex + 1);
        } else {
          fileName = baseName;
        }
      } else {
        fileName = baseName;
      }
    }

    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.picture_as_pdf, size: 70, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            isMock ? 'Local Device PDF Document' : 'PDF Document Reader',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            fileName,
            style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Divider(height: 24),
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                child: Text(
                  'Formula 1: sin²θ + cos²θ = 1\n\n'
                  'Formula 2: 1 + tan²θ = sec²θ\n\n'
                  'Formula 3: 1 + cot²θ = cosec²θ\n\n'
                  'Formula 4: sin(2θ) = 2sinθcosθ\n\n'
                  'Formula 5: cos(2θ) = cos²θ - sin²θ\n\n'
                  'Formula 6: tan(2θ) = (2tanθ) / (1 - tan²θ)',
                  style: GoogleFonts.courierPrime(fontSize: 12),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImageMockViewer(String url) {
    final isMock = url.startsWith('mock://');
    final isLocalBackend = url.contains('/uploads/');
    String fileName = 'Preview Image';
    if (isMock || isLocalBackend) {
      final baseName = Uri.decodeComponent(url.split('/').last);
      final firstDashIndex = baseName.indexOf('-');
      if (firstDashIndex != -1 && firstDashIndex < baseName.length - 1) {
        final prefix = baseName.substring(0, firstDashIndex);
        if (int.tryParse(prefix) != null) {
          fileName = baseName.substring(firstDashIndex + 1);
        } else {
          fileName = baseName;
        }
      } else {
        fileName = baseName;
      }
    }

    return Container(
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: url.startsWith('mock://')
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image, size: 80, color: AppTheme.primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    'Local Device Image Preview',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      fileName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              )
            : Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text('Image Preview unavailable offline', style: GoogleFonts.outfit(fontSize: 12)),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _buildVideoMockViewer(String url) {
    final isLocalBackend = url.contains('/uploads/');
    final isMock = url.startsWith('mock://') || isLocalBackend;
    String fileName = '';
    if (isMock) {
      final baseName = Uri.decodeComponent(url.split('/').last);
      final firstDashIndex = baseName.indexOf('-');
      if (firstDashIndex != -1 && firstDashIndex < baseName.length - 1) {
        final prefix = baseName.substring(0, firstDashIndex);
        if (int.tryParse(prefix) != null) {
          fileName = baseName.substring(firstDashIndex + 1);
        } else {
          fileName = baseName;
        }
      } else {
        fileName = baseName;
      }
    }

    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.video_library, size: 60, color: Colors.white24),
              const SizedBox(height: 12),
              Text(
                isMock ? 'Playing picked local video...' : 'Playing Lecture Video (00:45 / 15:20)',
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
              if (isMock && fileName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    fileName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          
          // Playback controls overlay
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: 0.08,
                    onChanged: (val) {},
                    activeColor: Colors.red,
                    inactiveColor: Colors.white24,
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.pause, color: Colors.white, size: 18),
                    Text(
                      '00:45 / 15:20',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    Icon(Icons.fullscreen, color: Colors.white, size: 18),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
