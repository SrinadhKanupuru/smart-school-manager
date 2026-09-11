import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../app/navigation_provider.dart';
import '../../app/auth_role_provider.dart';
import 'search_dialog.dart';
import 'notification_modal.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  final bool showMenuButton;
  final VoidCallback? onSwitchToPrincipal;

  const AppHeader({
    super.key,
    this.onMenuPressed,
    this.showMenuButton = false,
    this.onSwitchToPrincipal,
  });

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationProvider>(context);
    final auth = Provider.of<AuthRoleProvider>(context, listen: false);
    final unreadCount = nav.unreadNotificationCount;

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
                  constraints: const BoxConstraints(maxWidth: 420),
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
                          'Search student, teacher, class, etc...',
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

          // Right Area: Fast Switch to Principal + Notifications + Super Admin Profile
          Row(
            children: [
              // Fast 1-Click Switch to Principal Button
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if (onSwitchToPrincipal != null) {
                      onSwitchToPrincipal!();
                    } else {
                      auth.loginAsPrincipal();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFDDD6FE), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.admin_panel_settings_rounded, size: 16, color: Color(0xFF7C3AED)),
                        const SizedBox(width: 6),
                        Text(
                          'Principal Portal',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF7C3AED),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF7C3AED)),
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
                    tooltip: 'Notifications',
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            '$unreadCount',
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

              // Super Admin Profile Menu
              PopupMenuButton<String>(
                offset: const Offset(0, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'switch_principal',
                    child: Row(
                      children: [
                        const Icon(Icons.admin_panel_settings_outlined, size: 18, color: Color(0xFF8B5CF6)),
                        const SizedBox(width: 10),
                        Text('Switch to Principal View', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF8B5CF6))),
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
                        Text('Profile Settings', style: GoogleFonts.inter(fontSize: 13)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        const Icon(Icons.settings_outlined, size: 18),
                        const SizedBox(width: 10),
                        Text('School Settings', style: GoogleFonts.inter(fontSize: 13)),
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
                  if (val == 'switch_principal') {
                    if (onSwitchToPrincipal != null) {
                      onSwitchToPrincipal!();
                    } else {
                      auth.loginAsPrincipal();
                    }
                  } else if (val == 'settings') {
                    nav.setModule(AppModule.settings);
                  } else if (val == 'profile') {
                    nav.setModule(AppModule.settings);
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
                          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryTint, width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          'SK',
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
                          'Srinadh Kanupuru',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Super Admin',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
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
        ],
      ),
    );
  }
}
