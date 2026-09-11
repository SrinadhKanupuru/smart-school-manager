import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../screens/principal/principal_navigation_provider.dart';

class PrincipalSidebar extends StatelessWidget {
  final bool isDrawer;

  const PrincipalSidebar({super.key, this.isDrawer = false});

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<PrincipalNavigationProvider>(context);

    final navItems = [
      _PrincipalNavItemData(PrincipalModule.dashboard, 'Dashboard', Icons.grid_view_rounded),
      _PrincipalNavItemData(PrincipalModule.teachers, 'Teachers', Icons.school_outlined),
      _PrincipalNavItemData(PrincipalModule.students, 'Students', Icons.groups_outlined),
      _PrincipalNavItemData(PrincipalModule.attendance, 'Attendance', Icons.fact_check_outlined),
      _PrincipalNavItemData(PrincipalModule.leaveManagement, 'Leave Management', Icons.event_busy_outlined),
      _PrincipalNavItemData(PrincipalModule.academics, 'Academics', Icons.menu_book_outlined),
      _PrincipalNavItemData(PrincipalModule.account, 'Account & Fees', Icons.account_balance_wallet_outlined),
      _PrincipalNavItemData(PrincipalModule.reports, 'Reports', Icons.analytics_outlined),
      _PrincipalNavItemData(PrincipalModule.notices, 'Notices', Icons.campaign_outlined),
      _PrincipalNavItemData(PrincipalModule.settings, 'Settings', Icons.settings_outlined),
    ];

    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Top Logo & Tagline
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Smart School',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'Principal Desk',
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF8B5CF6),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Academic Leadership & Oversight',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Navigation List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = nav.currentModule == item.module;

                return _PrincipalSidebarItemTile(
                  data: item,
                  isSelected: isSelected,
                  onTap: () {
                    nav.setModule(item.module);
                    if (isDrawer) Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),

          // Bottom Principal Info & Role Switcher
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_rounded, size: 16, color: Color(0xFF8B5CF6)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Principal Portal\nMain City Campus',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF5B21B6),
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'v1.0.0 | Principal',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrincipalNavItemData {
  final PrincipalModule module;
  final String label;
  final IconData icon;

  _PrincipalNavItemData(this.module, this.label, this.icon);
}

class _PrincipalSidebarItemTile extends StatefulWidget {
  final _PrincipalNavItemData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _PrincipalSidebarItemTile({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PrincipalSidebarItemTile> createState() => _PrincipalSidebarItemTileState();
}

class _PrincipalSidebarItemTileState extends State<_PrincipalSidebarItemTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final isSelected = widget.isSelected;

    Color bgColor = Colors.transparent;
    Color textColor = AppColors.sidebarInactiveText;
    Color iconColor = AppColors.sidebarInactiveText;

    if (isSelected) {
      bgColor = const Color(0xFFF5F3FF);
      textColor = const Color(0xFF7C3AED);
      iconColor = const Color(0xFF7C3AED);
    } else if (_isHovered) {
      bgColor = AppColors.sidebarHoverBg;
      textColor = AppColors.textPrimary;
      iconColor = AppColors.textPrimary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9.5),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.2), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  d.icon,
                  size: 19,
                  color: iconColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    d.label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: Color(0xFF7C3AED),
                      shape: BoxShape.circle,
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
