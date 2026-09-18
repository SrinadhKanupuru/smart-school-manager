import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../widgets/parent/parent_ui_components.dart';
import 'parent_data_provider.dart';
import '../../data/parent_mock_data.dart';

class ParentProfileScreen extends StatelessWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<ParentDataProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          ParentAnimatedEntrance(
            index: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parent Profile & Account',
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: ParentDesignTokens.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Primary guardian identity, verified contacts, and linked student associations',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: ParentDesignTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    ParentButton(
                      label: 'Change Password',
                      icon: Icons.lock_reset_rounded,
                      variant: ParentButtonVariant.outline,
                      onPressed: () => _showChangePasswordDialog(context),
                    ),
                    const SizedBox(width: 10),
                    ParentButton(
                      label: 'Edit Profile',
                      icon: Icons.edit_rounded,
                      variant: ParentButtonVariant.primary,
                      onPressed: () => _showEditProfileDialog(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Main Profile Card
          ParentAnimatedEntrance(
            index: 1,
            child: ParentCard(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: ParentDesignTokens.brandTint,
                        child: Text(
                          'RV',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: ParentDesignTokens.brand,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  ParentMockData.parentName,
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: ParentDesignTokens.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ParentBadge.success(label: 'Verified Guardian Account'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Parent ID: ${ParentMockData.parentId} • Profession: ${ParentMockData.parentOccupation}',
                              style: GoogleFonts.inter(fontSize: 13, color: ParentDesignTokens.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Enrolled Wards: ${data.children.map((c) => "${c.name} (${c.grade})").join(", ")}',
                              style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: ParentDesignTokens.brand),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(height: 1, color: ParentDesignTokens.borderSubtle),
                  const SizedBox(height: 24),

                  // Contact & Demographic Info Rows
                  _buildProfileRow('Official Email Address', ParentMockData.parentEmail, Icons.mail_outline_rounded),
                  const SizedBox(height: 16),
                  _buildProfileRow('Registered Mobile Phone', ParentMockData.parentPhone, Icons.phone_android_rounded),
                  const SizedBox(height: 16),
                  _buildProfileRow('Residential Address', ParentMockData.parentAddress, Icons.home_outlined),
                  const SizedBox(height: 16),
                  _buildProfileRow('Security & Multi-Factor Auth', 'Enabled via SMS OTP for fee settlements & reports', Icons.shield_outlined),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String title, String val, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ParentDesignTokens.surfaceMuted,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ParentDesignTokens.border),
          ),
          child: Icon(icon, size: 18, color: ParentDesignTokens.brand),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                val,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ParentDesignTokens.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final phoneCtrl = TextEditingController(text: ParentMockData.parentPhone);
    final addrCtrl = TextEditingController(text: ParentMockData.parentAddress);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Contact Details', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Primary Phone Number'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addrCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Residential Address'),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ParentButton(
                      label: 'Cancel',
                      variant: ParentButtonVariant.secondary,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    const SizedBox(width: 10),
                    ParentButton(
                      label: 'Save Changes',
                      variant: ParentButtonVariant.primary,
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile contact details updated successfully.')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPass = TextEditingController();
    final newPass = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Update Portal Password', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                TextField(
                  controller: oldPass,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Current Password'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPass,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Strong Password'),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ParentButton(
                      label: 'Cancel',
                      variant: ParentButtonVariant.secondary,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    const SizedBox(width: 10),
                    ParentButton(
                      label: 'Update Password',
                      variant: ParentButtonVariant.primary,
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password changed securely.')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
