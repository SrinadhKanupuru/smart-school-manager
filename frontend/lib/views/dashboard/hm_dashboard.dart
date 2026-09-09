import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/school_provider.dart';
import '../../providers/admin_provider.dart';
import '../../core/theme.dart';

class HmDashboard extends StatefulWidget {
  const HmDashboard({super.key});

  @override
  State<HmDashboard> createState() => _HmDashboardState();
}

class _HmDashboardState extends State<HmDashboard> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);
    final user = provider.currentUser ?? {};
    final school = provider.currentSchool ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(
          school['name'] ?? 'Sunrise International',
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
                          user['fullName'] ?? 'Headmaster',
                          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
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

              // Statistics grid (mockup style)
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                children: [
                  _buildStatCard(Icons.people, '46', 'Teachers', Colors.purple),
                  _buildStatCard(Icons.school, '825', 'Students', Colors.indigo),
                  _buildStatCard(Icons.class_, '24', 'Classes', Colors.teal),
                  _buildStatCard(Icons.trending_up, '92%', "Today's Attendance", Colors.orange),
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
                  _buildQuickAccessBtn(Icons.assignment_turned_in_outlined, 'Leaves', () {
                    Navigator.pushNamed(context, '/leave-approval');
                  }),
                  _buildQuickAccessBtn(Icons.calendar_today_outlined, 'Timetables', () {
                    Navigator.pushNamed(context, '/timetable-management');
                  }),
                  _buildQuickAccessBtn(Icons.class_outlined, 'Classes', () {
                    Navigator.pushNamed(context, '/class-management');
                  }),
                  _buildQuickAccessBtn(Icons.monetization_on_outlined, 'Fees', () {
                    Navigator.pushNamed(context, '/fees-management');
                  }),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickAccessBtn(Icons.account_balance_wallet_outlined, 'Salaries', () {
                    Navigator.pushNamed(context, '/salary-management');
                  }),
                  _buildQuickAccessBtn(Icons.school_outlined, 'Add Student', () {
                    Navigator.pushNamed(context, '/add-student');
                  }),
                  _buildQuickAccessBtn(Icons.group_add_outlined, 'Add Parent', () {
                    Navigator.pushNamed(context, '/add-parent');
                  }),
                  _buildQuickAccessBtn(Icons.checklist_rtl_outlined, 'T. Assign', () {
                    Navigator.pushNamed(context, '/class-teacher-assignment');
                  }),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickAccessBtn(Icons.person_add_alt_1_outlined, 'Add Teacher', () {
                    Navigator.pushNamed(context, '/add-teacher');
                  }),
                  _buildQuickAccessBtn(Icons.currency_exchange_outlined, 'Loans', () {
                    Navigator.pushNamed(context, '/loans');
                  }),
                  const SizedBox(width: 48),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),

              // Expenses & transport routing quick links
              Card(
                elevation: 0,
                color: AppTheme.primaryColor.withOpacity(0.04),
                child: ListTile(
                  leading: const Icon(Icons.analytics_outlined, color: AppTheme.primaryColor),
                  title: Text('School Insights & Registry', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  subtitle: Text('Track all students & employees, attendance, salary, performance.', style: GoogleFonts.outfit(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/school-insights');
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
                  subtitle: Text('Approve staff requests or submit your own attendance corrections.', style: GoogleFonts.outfit(fontSize: 12)),
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
                  subtitle: Text('Manage and view school holidays and weekly off schedules.', style: GoogleFonts.outfit(fontSize: 12)),
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
                  leading: const Icon(Icons.money, color: AppTheme.primaryColor),
                  title: Text('Expenses & Budget Tracking', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  subtitle: Text('Manage infrastructure, events, bus upkeep costs.', style: GoogleFonts.outfit(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/expense-tracking');
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: AppTheme.primaryColor.withOpacity(0.04),
                child: ListTile(
                  leading: const Icon(Icons.directions_bus, color: AppTheme.primaryColor),
                  title: Text('Bus Route Management', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  subtitle: Text('Modify stops, drivers, route sequences.', style: GoogleFonts.outfit(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, '/bus-route-management');
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Events list
              Text(
                'Upcoming Events',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Consumer<AdminProvider>(
                builder: (context, adminProvider, child) {
                  if (adminProvider.isLoading && adminProvider.events.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    );
                  }

                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final upcomingEvents = adminProvider.events.where((e) {
                    try {
                      final eventDate = DateTime.parse(e['date'] ?? '');
                      final compareDate = DateTime(eventDate.year, eventDate.month, eventDate.day);
                      return compareDate.isAtSameMomentAs(today) || compareDate.isAfter(today);
                    } catch (_) {
                      return false;
                    }
                  }).toList();

                  // Sort chronologically
                  upcomingEvents.sort((a, b) {
                    try {
                      return DateTime.parse(a['date']).compareTo(DateTime.parse(b['date']));
                    } catch (_) {
                      return 0;
                    }
                  });

                  if (upcomingEvents.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No upcoming school events scheduled.',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  // Show first 3 upcoming events
                  final displayEvents = upcomingEvents.take(3).toList();
                  return Column(
                    children: displayEvents.map((event) {
                      final title = event['title'] ?? '';
                      final desc = event['description'] ?? '';
                      final dateStr = event['date'] ?? '';
                      String formattedDate = '';
                      try {
                        final eventDate = DateTime.parse(dateStr);
                        formattedDate = DateFormat('dd MMM, yyyy').format(eventDate);
                      } catch (_) {
                        formattedDate = dateStr;
                      }

                      return _buildEventTile(title, formattedDate, desc);
                    }).toList(),
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
            Navigator.pushNamed(context, '/class-teacher-assignment');
          } else if (idx == 2) {
            Navigator.pushNamed(context, '/holiday-calendar');
          } else if (idx == 3) {
            Navigator.pushNamed(context, '/complaints-list');
          }
        },
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Classes'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Complaints'),
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

  Widget _buildEventTile(String title, String date, String desc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: ListTile(
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        subtitle: Text('$date • $desc', style: GoogleFonts.outfit(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          Navigator.pushNamed(context, '/holiday-calendar');
        },
      ),
    );
  }
}
