import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../screens/parent/parent_navigation_provider.dart';
import '../../screens/parent/parent_data_provider.dart';
import '../../app/auth_role_provider.dart';
import '../../data/parent_mock_data.dart';

class ParentSidebar extends StatelessWidget {
  final bool isDrawer;

  const ParentSidebar({super.key, this.isDrawer = false});

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<ParentNavigationProvider>(context);
    final data = Provider.of<ParentDataProvider>(context);
    final auth = Provider.of<AuthRoleProvider>(context, listen: false);

    return Container(
      width: 260,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(
            color: AppColors.border,
            width: isDrawer ? 0 : 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Logo area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706), // Warm Amber / Ochre for Parent Portal
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD97706).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.family_restroom_rounded, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart School',
                        style: GoogleFonts.inter(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Text(
                          'PARENT PORTAL',
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFB45309),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              children: [
                _buildNavItem(
                  context,
                  title: 'Dashboard',
                  icon: Icons.dashboard_rounded,
                  module: ParentModule.dashboard,
                  isActive: nav.currentModule == ParentModule.dashboard,
                ),
                _buildNavItem(
                  context,
                  title: 'My Children',
                  icon: Icons.people_alt_rounded,
                  module: ParentModule.children,
                  isActive: nav.currentModule == ParentModule.children,
                  badge: '${data.children.length} Students',
                ),
                _buildNavItem(
                  context,
                  title: 'Attendance',
                  icon: Icons.fact_check_rounded,
                  module: ParentModule.attendance,
                  isActive: nav.currentModule == ParentModule.attendance,
                ),
                _buildNavItem(
                  context,
                  title: 'Homework',
                  icon: Icons.menu_book_rounded,
                  module: ParentModule.homework,
                  isActive: nav.currentModule == ParentModule.homework,
                  badge: '${data.currentHomeworks.where((h) => h.isPending).length} Pending',
                  badgeColor: const Color(0xFFF59E0B),
                ),
                _buildNavItem(
                  context,
                  title: 'Assignments',
                  icon: Icons.assignment_rounded,
                  module: ParentModule.assignments,
                  isActive: nav.currentModule == ParentModule.assignments,
                ),
                _buildNavItem(
                  context,
                  title: 'Exams & Results',
                  icon: Icons.emoji_events_rounded,
                  module: ParentModule.exams,
                  isActive: nav.currentModule == ParentModule.exams,
                ),
                _buildNavItem(
                  context,
                  title: 'Fees',
                  icon: Icons.account_balance_wallet_rounded,
                  module: ParentModule.fees,
                  isActive: nav.currentModule == ParentModule.fees,
                  badge: data.currentFeeSummary.pendingFees > 0 ? 'Due' : 'Paid',
                  badgeColor: data.currentFeeSummary.pendingFees > 0
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981),
                ),
                _buildNavItem(
                  context,
                  title: 'Timetable',
                  icon: Icons.table_chart_rounded,
                  module: ParentModule.timetable,
                  isActive: nav.currentModule == ParentModule.timetable,
                ),
                _buildNavItem(
                  context,
                  title: 'Notices',
                  icon: Icons.campaign_rounded,
                  module: ParentModule.notices,
                  isActive: nav.currentModule == ParentModule.notices,
                ),
                _buildNavItem(
                  context,
                  title: 'Messages',
                  icon: Icons.chat_bubble_outline_rounded,
                  module: ParentModule.messages,
                  isActive: nav.currentModule == ParentModule.messages,
                  badge: data.unreadMessagesCount > 0 ? '${data.unreadMessagesCount}' : null,
                  badgeColor: const Color(0xFF3B82F6),
                ),
                _buildNavItem(
                  context,
                  title: 'Leave',
                  icon: Icons.event_busy_rounded,
                  module: ParentModule.leave,
                  isActive: nav.currentModule == ParentModule.leave,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: AppColors.border),
                ),
                _buildNavItem(
                  context,
                  title: 'Profile',
                  icon: Icons.person_rounded,
                  module: ParentModule.profile,
                  isActive: nav.currentModule == ParentModule.profile,
                ),
                _buildNavItem(
                  context,
                  title: 'Settings',
                  icon: Icons.settings_rounded,
                  module: ParentModule.settings,
                  isActive: nav.currentModule == ParentModule.settings,
                ),
              ],
            ),
          ),

          // User Footer Profile Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
              color: AppColors.surfaceMuted,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFD97706),
                  child: Text(
                    'RV',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ParentMockData.parentName,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'ID: ${ParentMockData.parentId}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Logout',
                  icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.danger),
                  onPressed: () {
                    if (isDrawer) {
                      Navigator.of(context).pop();
                    }
                    auth.logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required ParentModule module,
    required bool isActive,
    String? badge,
    Color? badgeColor,
  }) {
    final nav = Provider.of<ParentNavigationProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            nav.setModule(module);
            if (isDrawer) {
              Navigator.of(context).pop();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFFEF3C7) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isActive ? const Color(0xFFFDE68A) : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: isActive ? const Color(0xFFB45309) : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? const Color(0xFF92400E) : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor?.withValues(alpha: 0.15) ?? AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: badgeColor?.withValues(alpha: 0.3) ?? AppColors.border,
                      ),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: badgeColor ?? AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
