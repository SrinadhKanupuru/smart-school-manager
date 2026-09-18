import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../app/auth_role_provider.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
import 'forgot_password_screen.dart';

class FacultyLoginScreen extends StatefulWidget {
  final VoidCallback? onSwitchToAdminLogin;

  const FacultyLoginScreen({
    super.key,
    this.onSwitchToAdminLogin,
  });

  @override
  State<FacultyLoginScreen> createState() => _FacultyLoginScreenState();
}

class _FacultyLoginScreenState extends State<FacultyLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController =
      TextEditingController(text: 'FAC001');
  final TextEditingController _passwordController =
      TextEditingController(text: 'faculty123');

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;
  String? _inlineError;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _autofillFacultyCreds(String id, String pass) {
    setState(() {
      _identifierController.text = id;
      _passwordController.text = pass;
      _inlineError = null;
    });
  }

  Future<void> _performLogin() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() => _inlineError = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    final authService = AuthService();
    final result = await authService.authenticate(
      identifier: identifier,
      password: password,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess && result.user != null) {
      // 1. Update AuthProvider state
      final authProv = Provider.of<AuthProvider>(context, listen: false);
      authProv.setMockUser(result.user!);

      // 2. Update Global App Active Role
      final roleProv = Provider.of<AuthRoleProvider>(context, listen: false);

      if (result.user!.role == UserRole.faculty) {
        roleProv.loginAsFaculty(result.user);
      } else if (result.user!.role == UserRole.principal) {
        roleProv.loginAsPrincipal();
      } else {
        roleProv.loginAsSuperAdmin();
      }

      // Show welcome toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('Welcome back, ${result.user!.name}!'),
            ],
          ),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Invalid credentials handling
      final errorMsg = result.errorMessage ?? 'Invalid Employee ID or password.';
      setState(() {
        _inlineError = errorMsg;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(errorMsg)),
            ],
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _openForgotPassword() {
    ForgotPasswordScreen.showModal(
      context,
      initialIdentifier: _identifierController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1040),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                    blurRadius: 36,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 760;

                  if (isWide) {
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left Brand & Educational Hero Banner
                          Expanded(
                            flex: 48,
                            child: _buildLeftHero(isCompact: false),
                          ),
                          // Right Faculty Login Card
                          Expanded(
                            flex: 52,
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
      ),
    );
  }

  /// Left Side Educational Hero Banner
  Widget _buildLeftHero({required bool isCompact}) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 28 : 44),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0F172A), // Slate 900
            Color(0xFF1E3A8A), // Royal Navy
            Color(0xFF2563EB), // Blue 600
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & School Name Header
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
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.school_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 14),
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
            const SizedBox(height: 32),

            // Hero Badge & Illustration Graphic Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: Color(0xFFFDE047),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FACULTY PORTAL',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: const Color(0xFFFDE047),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Teacher Academic Workspace',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Main Slogan & Subtitle
            Text(
              'Empowering Teachers.\nInspiring Students.',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Manage your classes, attendance, homework and academic activities in one place.',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: const Color(0xFFBFDBFE),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),

            // Feature Highlights Bullets
            _buildFeatureBullet(Icons.check_circle_rounded, 'Period-wise Timetable & Class Attendance'),
            const SizedBox(height: 10),
            _buildFeatureBullet(Icons.check_circle_rounded, 'Homework Assignment & Submission Review'),
            const SizedBox(height: 10),
            _buildFeatureBullet(Icons.check_circle_rounded, 'Exam Schedules & Student Grade Book'),
            const SizedBox(height: 10),
            _buildFeatureBullet(Icons.check_circle_rounded, 'Instant Leave Application & Tracking'),
            const SizedBox(height: 32),
          ],

          // Footer Quote / Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: Color(0xFF6EE7B7), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Academic Session 2026–27 • Secure SSL',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                Text(
                  'v1.0.0',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF93C5FD),
                  ),
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

  /// Right Side Faculty Login Form
  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 38),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Faculty Portal Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.badge_rounded, size: 13, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'FACULTY AUTHENTICATION',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Title & Subtitle
            Text(
              'Welcome Back!',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sign in to your Faculty account',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Quick Test Credentials Chips
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.key_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Demo Faculty Credentials (Click to fill):',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildTestCredChip('FAC001', 'faculty123', 'Employee ID'),
                      _buildTestCredChip('faculty@smartschool.com', 'faculty123', 'Email'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Inline Error Banner (if any)
            if (_inlineError != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.dangerBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.danger),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _inlineError!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Field 1: Email / Employee ID
            Text(
              'EMAIL / EMPLOYEE ID',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _identifierController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Enter your email or employee ID',
                prefixIcon: Icon(Icons.person_outline_rounded, size: 19),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Email/Employee ID cannot be empty.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Field 2: Password
            Text(
              'PASSWORD',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 19),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Password cannot be empty.';
                }
                return null;
              },
              onFieldSubmitted: (_) => _performLogin(),
            ),
            const SizedBox(height: 14),

            // Remember Me & Forgot Password Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _rememberMe,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) => setState(() => _rememberMe = val ?? true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Remember me',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _openForgotPassword,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot Password?',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Primary Action Button: "Sign In"
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _performLogin,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sign In',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Switch to Principal / Super Admin Login option
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Are you a Principal or Admin? ',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (widget.onSwitchToAdminLogin != null) {
                        widget.onSwitchToAdminLogin!();
                      } else {
                        Navigator.of(context).pushNamed('/login/admin');
                      }
                    },
                    child: Text(
                      'Admin Portal →',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF7C3AED), // Purple
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCredChip(String id, String pass, String label) {
    return InkWell(
      onTap: () => _autofillFacultyCreds(id, pass),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: ',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            Text(
              id,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
