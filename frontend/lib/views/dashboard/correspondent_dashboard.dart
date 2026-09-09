import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/school_provider.dart';
import '../../providers/admin_provider.dart';
import '../../core/theme.dart';

class CorrespondentDashboard extends StatefulWidget {
  const CorrespondentDashboard({super.key});

  @override
  State<CorrespondentDashboard> createState() => _CorrespondentDashboardState();
}

class _CorrespondentDashboardState extends State<CorrespondentDashboard> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SchoolProvider>(context, listen: false).fetchSchools();
      Provider.of<AdminProvider>(context, listen: false).fetchNotices();
    });
  }

  void _showSchoolsListSheet(SchoolProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Switch School',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 16),
              ...provider.schools.map((school) {
                final isCurrent = school['id'] == provider.currentSchool?['id'];
                return ListTile(
                  leading: const Icon(Icons.school, color: AppTheme.primaryColor),
                  title: Text(school['name'] ?? '', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  subtitle: Text(school['code'] ?? '', style: GoogleFonts.outfit()),
                  trailing: isCurrent ? const Icon(Icons.check_circle, color: Colors.green) : null,
                  onTap: () {
                    provider.switchSchool(school);
                    Provider.of<AdminProvider>(context, listen: false).fetchNotices();
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/register-school');
                },
                child: const Text('Register A New School'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFinanceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Finance Dashboard',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.monetization_on_outlined, color: Colors.green),
                title: Text('Student Fees & Payments', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                subtitle: Text('Manage and track student dues and collections', style: GoogleFonts.outfit(fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/fees-management');
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined, color: Colors.redAccent),
                title: Text('Teacher Salaries', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                subtitle: Text('Review payrolls and disburse salaries', style: GoogleFonts.outfit(fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/salary-management');
                },
              ),
              ListTile(
                leading: const Icon(Icons.currency_exchange_outlined, color: Colors.amber),
                title: Text('Loans & Advances', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                subtitle: Text('Approve or reject staff salary advances', style: GoogleFonts.outfit(fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/loans');
                },
              ),
            ],
          ),
        );
      },
    );
  }


  void _deleteSchoolConfirm(SchoolProvider provider, String schoolId, String schoolName) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Delete School', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.redAccent)),
          content: Text('Are you sure you want to delete "$schoolName"?\nThis will permanently delete all associated data.', style: GoogleFonts.outfit()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );
                final success = await provider.deleteSchool(schoolId);
                if (mounted) {
                  Navigator.pop(context); // Pop loader
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'School deleted successfully!' : 'Failed to delete school'),
                      backgroundColor: success ? Colors.green : Colors.redAccent,
                    ),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSchoolsView(SchoolProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manage Schools',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/register-school');
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add School'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: provider.schools.isEmpty
              ? Center(
                  child: Text(
                    'No schools registered yet.',
                    style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                  ),
                )
              : ListView.builder(
                  itemCount: provider.schools.length,
                  itemBuilder: (context, index) {
                    final sch = provider.schools[index];
                    final isCurrent = sch['id'] == provider.currentSchool?['id'];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isCurrent ? AppTheme.primaryColor : Colors.grey.shade200,
                          width: isCurrent ? 2 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    sch['name'] ?? '',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                ),
                                if (isCurrent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Active',
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Code: ${sch['code'] ?? ''} • ${sch['board'] ?? ''} • ${sch['type'] ?? ''}',
                              style: GoogleFonts.outfit(
                                color: AppTheme.textSecondaryColor,
                                fontSize: 13,
                              ),
                            ),
                            const Divider(height: 24),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${sch['address'] ?? ''}, ${sch['city'] ?? ''}, ${sch['state'] ?? ''}',
                                    style: GoogleFonts.outfit(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  sch['contactNumber'] ?? '',
                                  style: GoogleFonts.outfit(fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (!isCurrent)
                                  TextButton.icon(
                                    onPressed: () {
                                      provider.switchSchool(sch);
                                      Provider.of<AdminProvider>(context, listen: false).fetchNotices();
                                    },
                                    icon: const Icon(Icons.swap_horiz, size: 16),
                                    label: const Text('Switch To'),
                                  ),
                                TextButton.icon(
                                  onPressed: () {
                                    if (!isCurrent) {
                                      provider.switchSchool(sch);
                                      Provider.of<AdminProvider>(context, listen: false).fetchNotices();
                                    }
                                    Navigator.pushNamed(context, '/school-settings');
                                  },
                                  icon: const Icon(Icons.edit, size: 16, color: AppTheme.primaryColor),
                                  label: const Text('Edit'),
                                ),
                                TextButton.icon(
                                  onPressed: () => _deleteSchoolConfirm(provider, sch['id'], sch['name'] ?? ''),
                                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                                  label: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                ),
                              ],
                            )
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

  void _showAddNoticeDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

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
                    'Post School Notice',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Notice Title*',
                      prefixIcon: Icon(Icons.campaign, color: AppTheme.primaryColor),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description*',
                      prefixIcon: Icon(Icons.description, color: AppTheme.primaryColor),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Please enter description details' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      final success = await Provider.of<AdminProvider>(context, listen: false).createNotice(
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notice posted successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to post notice.'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Post Notice'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoticesView() {
    final admin = Provider.of<AdminProvider>(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Notifications',
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: admin.isLoading && admin.notices.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : admin.notices.isEmpty
                    ? Center(
                        child: Text(
                          'No notices posted yet.',
                          style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => admin.fetchNotices(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: admin.notices.length,
                          itemBuilder: (context, index) {
                            final notice = admin.notices[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
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
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                          child: const Icon(Icons.campaign, color: AppTheme.primaryColor),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            notice['title'] ?? '',
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: AppTheme.textPrimaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    Text(
                                      notice['description'] ?? '',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                    ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoticeDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);
    final school = provider.currentSchool ?? {};
    final user = provider.currentUser ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _navIndex == 0
              ? (school['name'] ?? 'Sunrise International School')
              : _navIndex == 1
                  ? 'Manage Schools'
                  : 'Notifications',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz, color: AppTheme.primaryColor),
            onPressed: () => _showSchoolsListSheet(provider),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _navIndex == 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome Box (Mockup style purple gradient banner)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome,',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user['fullName'] ?? 'Mr. Ramesh Kumar',
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Correspondent',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.white30,
                            child: Icon(Icons.person, size: 40, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Menu Grid
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        children: [
                          _buildGridCard(Icons.school, 'School Profile', Colors.purple, () {
                            _showProfileDialog(school);
                          }),
                          _buildGridCard(Icons.settings, 'School Settings', Colors.purple, () {
                            Navigator.pushNamed(context, '/school-settings');
                          }),
                          _buildGridCard(Icons.verified_user, 'Users & Roles', Colors.indigo, () {
                            Navigator.pushNamed(context, '/school-insights');
                          }),
                          _buildGridCard(Icons.swap_horiz, 'Schools', Colors.blue, () {
                            _showSchoolsListSheet(provider);
                          }),
                          _buildGridCard(Icons.people, 'Teachers', Colors.teal, () {
                            Navigator.pushNamed(context, '/school-insights');
                          }),
                          _buildGridCard(Icons.class_outlined, 'Classes & Sections', Colors.blueGrey, () {
                            Navigator.pushNamed(context, '/class-management');
                          }),
                          _buildGridCard(Icons.calendar_month, 'Timetables', Colors.deepPurple, () {
                            Navigator.pushNamed(context, '/timetable-management');
                          }),
                          _buildGridCard(Icons.person_add_alt, 'Add Principal/HM', Colors.orange, () {
                            Navigator.pushNamed(context, '/add-principal-hm');
                          }),
                          _buildGridCard(Icons.group_add, 'Add Teacher/Staff', Colors.teal, () {
                            Navigator.pushNamed(context, '/add-teacher');
                          }),
                          _buildGridCard(Icons.school_outlined, 'Add Student', Colors.cyan, () {
                            Navigator.pushNamed(context, '/add-student');
                          }),
                          _buildGridCard(Icons.group_add_outlined, 'Add Parent', Colors.pink, () {
                            Navigator.pushNamed(context, '/add-parent');
                          }),
                          _buildGridCard(Icons.bus_alert, 'Transport', Colors.amber, () {
                            Navigator.pushNamed(context, '/bus-route-management');
                          }),
                          _buildGridCard(Icons.monetization_on, 'Finance', Colors.red, () {
                            _showFinanceSheet();
                          }),
                          _buildGridCard(Icons.report, 'Complaints', Colors.deepOrange, () {
                            Navigator.pushNamed(context, '/complaints-list');
                          }),
                          _buildGridCard(Icons.assignment_turned_in_outlined, 'Leave Approval', Colors.green, () {
                            Navigator.pushNamed(context, '/leave-approval');
                          }),
                          _buildGridCard(Icons.face_retouching_natural, 'Self Attendance', Colors.teal, () {
                            Navigator.pushNamed(context, '/staff-attendance');
                          }),
                          _buildGridCard(Icons.history_toggle_off, 'Attendance Logs', Colors.indigo, () {
                            Navigator.pushNamed(context, '/staff-attendance-history');
                          }),
                          _buildGridCard(Icons.edit_calendar_outlined, 'Rectifications', Colors.teal, () {
                            Navigator.pushNamed(context, '/attendance-rectification');
                          }),
                          _buildGridCard(Icons.date_range, 'School Calendar', Colors.deepOrange, () {
                            Navigator.pushNamed(context, '/holiday-calendar');
                          }),
                          _buildGridCard(Icons.power_settings_new, 'Logout', Colors.grey, () async {
                            await provider.logout();
                            Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
                          }),
                        ],
                      ),
                    ),
                  ],
                )
              : _navIndex == 1
                  ? _buildSchoolsView(provider)
                  : _buildNoticesView(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (idx) {
          setState(() => _navIndex = idx);
          if (idx == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Schools'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildGridCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileDialog(Map<String, dynamic> school) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(school['name'] ?? 'School Details', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code: ${school['code'] ?? ''}', style: GoogleFonts.outfit()),
            Text('Board: ${school['board'] ?? ''}', style: GoogleFonts.outfit()),
            Text('Type: ${school['type'] ?? ''}', style: GoogleFonts.outfit()),
            Text('Contact: ${school['contactNumber'] ?? ''}', style: GoogleFonts.outfit()),
            Text('Location: ${school['address'] ?? ''}, ${school['city'] ?? ''}, ${school['state'] ?? ''}', style: GoogleFonts.outfit()),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}
