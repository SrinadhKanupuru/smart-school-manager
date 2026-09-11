import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../widgets/common/section_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Settings toggles
  bool _smsAlerts = true;
  bool _emailNotifs = true;
  bool _twoFactorAuth = true;
  bool _autoBackup = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          PageHeader(
            title: 'Institution Settings & System Configuration',
            subtitle: 'Manage school identity, user permissions, academic year sessions, security, and notification pipelines',
            trailing: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppColors.success,
                    content: Text('All configuration changes saved successfully!'),
                  ),
                );
              },
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Save Changes'),
            ),
          ),

          // Sub Tabs
          Container(
            padding: const EdgeInsets.all(12),
            decoration: AppDecorations.cardDecoration(),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              onTap: (_) => setState(() {}),
              indicator: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
              tabs: const [
                Tab(icon: Icon(Icons.account_balance_outlined, size: 18), text: 'School Profile'),
                Tab(icon: Icon(Icons.shield_outlined, size: 18), text: 'Users & Roles'),
                Tab(icon: Icon(Icons.calendar_month_outlined, size: 18), text: 'Academic Year (2026–27)'),
                Tab(icon: Icon(Icons.notifications_active_outlined, size: 18), text: 'Notification Channels'),
                Tab(icon: Icon(Icons.lock_outline_rounded, size: 18), text: 'Security & Auth'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tab View Stack
          IndexedStack(
            index: _tabController.index,
            children: [
              _buildSchoolProfileTab(),
              _buildUsersAndRolesTab(),
              _buildAcademicYearTab(),
              _buildNotificationsTab(),
              _buildSecurityTab(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolProfileTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Institutional Profile & Accreditation', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Center(
                  child: Icon(Icons.school_rounded, size: 48, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: null,
                            decoration: InputDecoration(
                              labelText: 'School Name',
                              hintText: 'Smart School International Academy',
                            ),
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: null,
                            decoration: InputDecoration(
                              labelText: 'Affiliation Board & Code',
                              hintText: 'CBSE / Affiliation No. 1930281',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: null,
                            decoration: InputDecoration(
                              labelText: 'Official Support Email',
                              hintText: 'admin@smartschool.edu',
                            ),
                          ),
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: null,
                            decoration: InputDecoration(
                              labelText: 'Campus Phone Hotline',
                              hintText: '+91 (080) 2845-9000',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const TextField(
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Campus Headquarters Address',
              hintText: 'Plot 42, Knowledge Park II, ITPL Main Road, Bangalore, Karnataka - 560066',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersAndRolesTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Role-Based Access Control (RBAC)', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Super Admin possesses universal override access across all 11 system modules.', style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 18),
          _buildRoleRow('Super Admin (Srinadh)', 'Full Read/Write, Financial Approvals, Staff Sanctions, Global Settings', AppColors.primary),
          const Divider(height: 20),
          _buildRoleRow('Principal / HM', 'Staff Leave Approval, Timetable Management, Discipline, Student Insights', Color(0xFF8B5CF6)),
          const Divider(height: 20),
          _buildRoleRow('Faculty / Teachers', 'Daily Attendance Marking, Marks Entry, Homework Posting, Leave Submissions', Color(0xFF10B981)),
          const Divider(height: 20),
          _buildRoleRow('Parents & Guardians', 'Fee Payment Portal, Child Attendance, Bus Live Tracking, Result Cards', Color(0xFF0EA5E9)),
        ],
      ),
    );
  }

  Widget _buildRoleRow(String role, String description, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 180,
          child: Text(role, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
        Expanded(
          child: Text(description, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Text('Active Role', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ),
      ],
    );
  }

  Widget _buildAcademicYearTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Academic Year Session: 2026–2027', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Current Term: Term 1 (June 2026 – October 2026)', style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSecondary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(12)),
                child: Text('ACTIVE SESSION', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.success)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: 'Term 1 Start Date', hintText: '01 June 2026'),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: 'Mid Term Exams', hintText: '15 September 2026'),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: 'Annual Term End', hintText: '30 April 2027'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Automated Notification Pipelines', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          SwitchListTile(
            title: Text('SMS Alerts for Student Absenteeism', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600)),
            subtitle: Text('Instantly notify parents via SMS at 09:30 AM if student is marked absent without prior leave.', style: GoogleFonts.inter(fontSize: 12)),
            value: _smsAlerts,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _smsAlerts = val),
          ),
          const Divider(),
          SwitchListTile(
            title: Text('Automated Fee Due Reminders', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600)),
            subtitle: Text('Send WhatsApp & Email payment link reminders 3 days before fee due date.', style: GoogleFonts.inter(fontSize: 12)),
            value: _emailNotifs,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _emailNotifs = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Security & Data Backup Protocols', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          SwitchListTile(
            title: Text('Two-Factor Authentication (2FA) for Administrators', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600)),
            subtitle: Text('Require OTP code verification on login for Super Admin and Principal accounts.', style: GoogleFonts.inter(fontSize: 12)),
            value: _twoFactorAuth,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _twoFactorAuth = val),
          ),
          const Divider(),
          SwitchListTile(
            title: Text('Nightly Automated Cloud Database Backup (02:00 AM)', style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600)),
            subtitle: Text('Secure encrypted snapshots stored in redundant Indian cloud zones.', style: GoogleFonts.inter(fontSize: 12)),
            value: _autoBackup,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _autoBackup = val),
          ),
        ],
      ),
    );
  }
}
