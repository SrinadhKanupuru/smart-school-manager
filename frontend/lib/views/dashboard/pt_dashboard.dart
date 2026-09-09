import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/school_provider.dart';
import '../../core/theme.dart';

class PtDashboard extends StatelessWidget {
  const PtDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);
    final user = provider.currentUser ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('PT Cockpit')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good Morning,', style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor)),
                        Text(user['fullName'] ?? 'PT Sir', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const CircleAvatar(radius: 28, backgroundColor: AppTheme.primaryColor, child: Icon(Icons.sports, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.people, color: AppTheme.primaryColor, size: 28),
                            const SizedBox(height: 8),
                            Text('130', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                            Text('Sports Roster', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.done_all, color: Colors.green, size: 28),
                            const SizedBox(height: 8),
                            Text('96%', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                            Text('PT Attendance', style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor)),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Text('Quick Actions', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickActionBtn(context, Icons.sick_outlined, 'Apply Leave', () {
                    Navigator.pushNamed(context, '/leave-application');
                  }),
                  _buildQuickActionBtn(context, Icons.report_problem_outlined, 'Complaints', () {
                    Navigator.pushNamed(context, '/complaints-list');
                  }),
                ],
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 24),
              Text('Today\'s Schedule', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildScheduleCard('05:00 AM', 'Morning Practice', 'School Ground'),
              _buildScheduleCard('07:05 AM', 'Yoga Session', 'Class 8 - Indoor Hall'),
              _buildScheduleCard('04:00 PM', 'Sports Practice', 'Cricket Nets'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  provider.logout();
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(String time, String title, String loc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
          child: Text(time, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        ),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        subtitle: Text(loc, style: GoogleFonts.outfit(fontSize: 12)),
      ),
    );
  }

  Widget _buildQuickActionBtn(BuildContext context, IconData icon, String label, VoidCallback onTap) {
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
