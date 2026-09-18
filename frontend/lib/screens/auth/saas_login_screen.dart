import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/principal_mock_data.dart';
import '../../data/parent_mock_data.dart';
import '../../app/auth_role_provider.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';

class SaasLoginScreen extends StatefulWidget {
  final Function(AppActiveRole role)? onLoginSuccess;

  const SaasLoginScreen({super.key, this.onLoginSuccess});

  @override
  State<SaasLoginScreen> createState() => _SaasLoginScreenState();
}

class _SaasLoginScreenState extends State<SaasLoginScreen> {
  AppActiveRole _selectedRole = AppActiveRole.principal; // Principal pre-selected by default
  final TextEditingController _emailController = TextEditingController(text: 'principal.main@smartschool.edu');
  final TextEditingController _passwordController = TextEditingController(text: '••••••••••••');
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  void _onRoleChanged(AppActiveRole role) {
    setState(() {
      _selectedRole = role;
      if (role == AppActiveRole.principal) {
        _emailController.text = 'principal.main@smartschool.edu';
        _passwordController.text = '••••••••••••';
      } else if (role == AppActiveRole.faculty) {
        _emailController.text = 'faculty@smartschool.com';
        _passwordController.text = '••••••••••••';
      } else if (role == AppActiveRole.parent) {
        _emailController.text = 'parent@smartschool.com';
        _passwordController.text = '••••••••••••';
      } else {
        _emailController.text = 'admin.srinadh@smartschool.edu';
        _passwordController.text = '••••••••••••';
      }
    });
  }

  void _performLogin() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() => _isLoading = false);
        final auth = Provider.of<AuthRoleProvider>(context, listen: false);
        final authProv = Provider.of<AuthProvider>(context, listen: false);

        if (_selectedRole == AppActiveRole.principal) {
          authProv.setMockUser(UserModel.principalDefault());
          auth.loginAsPrincipal();
        } else if (_selectedRole == AppActiveRole.faculty) {
          authProv.setMockUser(UserModel.facultyDefault());
          auth.loginAsFaculty(UserModel.facultyDefault());
        } else if (_selectedRole == AppActiveRole.parent) {
          authProv.setMockUser(UserModel.parentDefault());
          auth.loginAsParent(UserModel.parentDefault());
        } else {
          authProv.setMockUser(UserModel.superAdminDefault());
          auth.loginAsSuperAdmin();
        }
        widget.onLoginSuccess?.call(_selectedRole);
      }
    });
  }

  Color get _activeThemeColor {
    switch (_selectedRole) {
      case AppActiveRole.principal:
        return const Color(0xFF7C3AED);
      case AppActiveRole.faculty:
        return const Color(0xFF059669);
      case AppActiveRole.parent:
        return const Color(0xFFD97706);
      case AppActiveRole.superAdmin:
      default:
        return AppColors.primary;
    }
  }

  IconData get _activeRoleIcon {
    switch (_selectedRole) {
      case AppActiveRole.principal:
        return Icons.admin_panel_settings_rounded;
      case AppActiveRole.faculty:
        return Icons.school_rounded;
      case AppActiveRole.parent:
        return Icons.family_restroom_rounded;
      case AppActiveRole.superAdmin:
      default:
        return Icons.shield_rounded;
    }
  }

  String get _activeLoginButtonText {
    switch (_selectedRole) {
      case AppActiveRole.principal:
        return 'Login as Principal (${PrincipalMockData.principalName})';
      case AppActiveRole.faculty:
        return 'Login as Faculty (Ms. Kavya Sharma)';
      case AppActiveRole.parent:
        return 'Login as Parent (${ParentMockData.parentName})';
      case AppActiveRole.superAdmin:
      default:
        return 'Login as Super Admin (Srinadh Kanupuru)';
    }
  }

  String get _activeTipText {
    switch (_selectedRole) {
      case AppActiveRole.principal:
        return '1-Click Access: Select "Principal" above and click Login to launch the Principal Portal instantly.';
      case AppActiveRole.faculty:
        return '1-Click Access: Select "Faculty" above and click Login to launch the Faculty Portal instantly.';
      case AppActiveRole.parent:
        return '1-Click Access: Select "Parent" above and click Login to launch the Parent Portal instantly.';
      case AppActiveRole.superAdmin:
      default:
        return '1-Click Access: Select "Super Admin" above and click Login to launch the Universal Admin Portal instantly.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1080),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;

                if (isWide) {
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left Brand / Welcome Hero Banner
                        Expanded(
                          flex: 44,
                          child: _buildLeftHero(),
                        ),
                        // Right Login Form
                        Expanded(
                          flex: 56,
                          child: _buildLoginForm(),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      _buildLeftHero(isCompact: true),
                      _buildLoginForm(),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftHero({bool isCompact = false}) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 28 : 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E3A8A), // Deep Navy
            Color(0xFF1E40AF), // Royal Blue
            Color(0xFF3B82F6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo Row
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.school_rounded, color: AppColors.primary, size: 26),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart School',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Manager',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF93C5FD),
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (!isCompact) ...[
            const SizedBox(height: 36),
            // Hero Slogan
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Unified Educational SaaS Platform 2026',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFDE047),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Simpler Schools.\nBrighter Futures.',
                  style: GoogleFonts.inter(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Unified administrative intelligence for Super Admins, Campus Principals, Faculty, and Parents.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFFBFDBFE),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Feature Highlights
                _buildFeatureBullet(Icons.check_circle_rounded, 'Real-time Institutional & Biometric Attendance'),
                const SizedBox(height: 10),
                _buildFeatureBullet(Icons.check_circle_rounded, 'Academic Performance & Exam Roster Auditing'),
                const SizedBox(height: 10),
                _buildFeatureBullet(Icons.check_circle_rounded, 'Parent-Ward Sync, Homework & Fee Settlement'),
                const SizedBox(height: 10),
                _buildFeatureBullet(Icons.check_circle_rounded, 'Instant Leave Approvals & Sanction Workflows'),
                const SizedBox(height: 10),
                _buildFeatureBullet(Icons.check_circle_rounded, 'Fee Collection Analytics & Ledger Reconciliation'),
              ],
            ),
            const SizedBox(height: 36),
          ],

          // Footer Quote
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.format_quote_rounded, color: Color(0xFFFDE047), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"Better Schools Build Brighter People"',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  'v1.0.0',
                  style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF93C5FD)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBullet(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF10B981)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Sign In to Your Portal',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select your role to access your personalized school dashboard',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Role Selection Cards (Principal, Faculty, Parent, Super Admin)
          Text(
            'SELECT ROLE TO LOG IN',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),

          // 4 Role Cards in Responsive Row
          Row(
            children: [
              // Principal Role Card
              Expanded(
                child: _buildRoleCard(
                  role: AppActiveRole.principal,
                  title: 'Principal',
                  subtitle: PrincipalMockData.principalName,
                  badge: 'Admin',
                  icon: Icons.admin_panel_settings_rounded,
                  color: const Color(0xFF8B5CF6),
                  bg: const Color(0xFFF5F3FF),
                ),
              ),
              const SizedBox(width: 6),
              // Faculty Role Card
              Expanded(
                child: _buildRoleCard(
                  role: AppActiveRole.faculty,
                  title: 'Faculty',
                  subtitle: 'Ms. Kavya',
                  badge: 'Teacher',
                  icon: Icons.school_rounded,
                  color: const Color(0xFF059669),
                  bg: const Color(0xFFECFDF5),
                ),
              ),
              const SizedBox(width: 6),
              // Parent Role Card
              Expanded(
                child: _buildRoleCard(
                  role: AppActiveRole.parent,
                  title: 'Parent',
                  subtitle: ParentMockData.parentName,
                  badge: 'Guardian',
                  icon: Icons.family_restroom_rounded,
                  color: const Color(0xFFD97706),
                  bg: const Color(0xFFFEF3C7),
                ),
              ),
              const SizedBox(width: 6),
              // Super Admin Role Card
              Expanded(
                child: _buildRoleCard(
                  role: AppActiveRole.superAdmin,
                  title: 'Super Admin',
                  subtitle: 'Srinadh K',
                  badge: 'Universal',
                  icon: Icons.shield_rounded,
                  color: AppColors.primary,
                  bg: AppColors.primaryTint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Email Input
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Official Email / User ID',
              prefixIcon: const Icon(Icons.mail_outline_rounded),
              suffixIcon: _buildRoleBadgeTag(),
            ),
          ),
          const SizedBox(height: 14),

          // Password Input
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 18,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Remember Me & Forgot Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: _activeThemeColor,
                      onChanged: (val) => setState(() => _rememberMe = val ?? true),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Remember session',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password reset link sent to registered email.')),
                  );
                },
                child: Text(
                  'Forgot password?',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _activeThemeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _activeThemeColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isLoading ? null : _performLogin,
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_activeRoleIcon, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _activeLoginButtonText,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 14),

          // Fast Switch Tip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: _activeThemeColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _activeTipText,
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Alternative Portals
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Looking for dedicated Parent sign-in? ',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pushReplacementNamed('/parent/login'),
                  child: Text(
                    'Parent Login Page →',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _activeThemeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadgeTag() {
    Color badgeColor;
    Color badgeBg;
    Color badgeBorder;
    IconData badgeIcon;
    String badgeText;

    switch (_selectedRole) {
      case AppActiveRole.principal:
        badgeColor = const Color(0xFF8B5CF6);
        badgeBg = const Color(0xFFF5F3FF);
        badgeBorder = const Color(0xFFDDD6FE);
        badgeIcon = Icons.admin_panel_settings_rounded;
        badgeText = 'Principal';
        break;
      case AppActiveRole.faculty:
        badgeColor = const Color(0xFF059669);
        badgeBg = const Color(0xFFECFDF5);
        badgeBorder = const Color(0xFFA7F3D0);
        badgeIcon = Icons.school_rounded;
        badgeText = 'Faculty';
        break;
      case AppActiveRole.parent:
        badgeColor = const Color(0xFFD97706);
        badgeBg = const Color(0xFFFEF3C7);
        badgeBorder = const Color(0xFFFDE68A);
        badgeIcon = Icons.family_restroom_rounded;
        badgeText = 'Parent';
        break;
      case AppActiveRole.superAdmin:
      default:
        badgeColor = AppColors.primary;
        badgeBg = AppColors.primaryTint;
        badgeBorder = const Color(0xFFBFDBFE);
        badgeIcon = Icons.shield_rounded;
        badgeText = 'Super Admin';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: badgeColor),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required AppActiveRole role,
    required String title,
    required String subtitle,
    required String badge,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    final isSelected = _selectedRole == role;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _onRoleChanged(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? bg : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(icon, size: 14, color: color),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isSelected ? color : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? color : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
