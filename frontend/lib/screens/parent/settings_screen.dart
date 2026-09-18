import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/parent/parent_ui_components.dart';

class ParentSettingsScreen extends StatefulWidget {
  const ParentSettingsScreen({super.key});

  @override
  State<ParentSettingsScreen> createState() => _ParentSettingsScreenState();
}

class _ParentSettingsScreenState extends State<ParentSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailSummaries = true;
  bool _smsAbsenceAlerts = true;
  bool _feeReminders = true;
  bool _biometricAppLock = false;
  bool _twoFactorFeeAuth = true;
  String _selectedLanguage = 'English (US)';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          ParentAnimatedEntrance(
            index: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portal Preferences & Settings',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: ParentDesignTokens.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage alert channels, localization preferences, and account security protocols',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: ParentDesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 1. Notification Preferences Card
          ParentAnimatedEntrance(
            index: 1,
            child: ParentCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ParentDesignTokens.brandTint,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.notifications_active_outlined, size: 18, color: ParentDesignTokens.brand),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Communication & Real-time Alerts',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: ParentDesignTokens.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: ParentDesignTokens.border),
                  _buildSwitchRow(
                    'Instant Push Notifications',
                    'Receive real-time push alerts for homework submissions, exam score updates, and notices',
                    _pushNotifications,
                    (val) => setState(() => _pushNotifications = val),
                  ),
                  const Divider(height: 1, color: ParentDesignTokens.borderSubtle),
                  _buildSwitchRow(
                    'Emergency SMS Absence Alerts',
                    'Receive immediate SMS on registered mobile if child is marked absent at morning gate check-in',
                    _smsAbsenceAlerts,
                    (val) => setState(() => _smsAbsenceAlerts = val),
                  ),
                  const Divider(height: 1, color: ParentDesignTokens.borderSubtle),
                  _buildSwitchRow(
                    'Weekly Academic Digest',
                    'Summary of weekly attendance rates, homework completion progress, and upcoming syllabus tests',
                    _emailSummaries,
                    (val) => setState(() => _emailSummaries = val),
                  ),
                  const Divider(height: 1, color: ParentDesignTokens.borderSubtle),
                  _buildSwitchRow(
                    'Fee Installment Reminders',
                    'Alerts sent 5 days prior to installment due dates with 1-click payment authorization',
                    _feeReminders,
                    (val) => setState(() => _feeReminders = val),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 2. Language & Regional Formatting
          ParentAnimatedEntrance(
            index: 2,
            child: ParentCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ParentDesignTokens.brandTint,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.language_rounded, size: 18, color: ParentDesignTokens.brand),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Language & Regional Localization',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: ParentDesignTokens.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: ParentDesignTokens.border),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Display Interface Language', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: ParentDesignTokens.textPrimary)),
                            const SizedBox(height: 2),
                            Text('Choose preferred language for scorecards and circulars', style: GoogleFonts.inter(fontSize: 12, color: ParentDesignTokens.textSecondary)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: ParentDesignTokens.surfaceMuted,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: ParentDesignTokens.border),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedLanguage,
                            underline: const SizedBox(),
                            items: ['English (US)', 'Hindi (हिंदी)', 'Kannada (ಕನ್ನಡ)', 'Telugu (తెలుగు)'].map((lang) {
                              return DropdownMenuItem(value: lang, child: Text(lang, style: GoogleFonts.inter(fontSize: 13)));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedLanguage = val);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Language preference set to $val')),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 3. Security & App Privacy
          ParentAnimatedEntrance(
            index: 3,
            child: ParentCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ParentDesignTokens.brandTint,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.shield_outlined, size: 18, color: ParentDesignTokens.brand),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Security Protocols & 2-Factor Auth',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: ParentDesignTokens.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: ParentDesignTokens.border),
                  _buildSwitchRow(
                    'Multi-Factor Authorization for Payments',
                    'Require SMS OTP code confirmation prior to settling term tuition fees',
                    _twoFactorFeeAuth,
                    (val) => setState(() => _twoFactorFeeAuth = val),
                  ),
                  const Divider(height: 1, color: ParentDesignTokens.borderSubtle),
                  _buildSwitchRow(
                    'Biometric App Lock on Launch',
                    'Require biometric authentication (Face ID / Fingerprint) to open Parent Portal on mobile devices',
                    _biometricAppLock,
                    (val) => setState(() => _biometricAppLock = val),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ParentDesignTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: ParentDesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: ParentDesignTokens.brand,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
