import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/principal_mock_data.dart';
import '../../screens/principal/principal_navigation_provider.dart';
import '../../app/auth_role_provider.dart';
import '../common/search_dialog.dart';
import '../common/notification_modal.dart';

class PrincipalHeader extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  final bool showMenuButton;
  final VoidCallback? onSwitchToSuperAdmin;

  const PrincipalHeader({
    super.key,
    this.onMenuPressed,
    this.showMenuButton = false,
    this.onSwitchToSuperAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<PrincipalNavigationProvider>(context);
    final auth = Provider.of<AuthRoleProvider>(context, listen: false);
    final String currentDate = DateFormat('EEE, d MMM yyyy').format(DateTime.now());

    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Mobile / Tablet Menu Button
          if (showMenuButton) ...[
            IconButton(
              onPressed: onMenuPressed,
              icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
              tooltip: 'Toggle Navigation',
            ),
            const SizedBox(width: 8),
          ],

          // Search Box with Ctrl + K
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => GlobalSearchDialog.show(context),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 380),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Search student, teacher, class...',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'Ctrl + K',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Date Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF8B5CF6)),
                const SizedBox(width: 6),
                Text(
                  currentDate,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Fast Switch to Super Admin Button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                if (onSwitchToSuperAdmin != null) {
                  onSwitchToSuperAdmin!();
                } else {
                  auth.loginAsSuperAdmin();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Super Admin View',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Notification Bell
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => NotificationModal.show(context),
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
                tooltip: 'School Circulars & Alerts',
              ),
              if (nav.unreadNotificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B5CF6),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        '${nav.unreadNotificationCount}',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 8),
          Container(height: 28, width: 1, color: AppColors.border),
          const SizedBox(width: 12),

          // Principal Profile Avatar + Menu
          PopupMenuButton<String>(
            offset: const Offset(0, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'switch_super_admin',
                child: Row(
                  children: [
                    const Icon(Icons.switch_account_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text('Switch to Super Admin View', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 18),
                    const SizedBox(width: 10),
                    Text('Principal Profile', style: GoogleFonts.inter(fontSize: 13)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings_outlined, size: 18),
                    const SizedBox(width: 10),
                    Text('Campus Settings', style: GoogleFonts.inter(fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, size: 18, color: AppColors.danger),
                    const SizedBox(width: 10),
                    Text('Log Out to Portal Login', style: GoogleFonts.inter(fontSize: 13, color: AppColors.danger, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
            onSelected: (val) {
              if (val == 'switch_super_admin') {
                if (onSwitchToSuperAdmin != null) {
                  onSwitchToSuperAdmin!();
                } else {
                  auth.loginAsSuperAdmin();
                }
              } else if (val == 'settings') {
                nav.setModule(PrincipalModule.settings);
              } else if (val == 'logout') {
                auth.logout();
              }
            },
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFDDD6FE), width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      'RR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PrincipalMockData.principalName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Principal',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF8B5CF6),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• Main Campus',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
