import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/school_provider.dart';
import '../../core/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<SchoolProvider>(context, listen: false);
    final success = await provider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      final role = provider.currentUser?['role'];
      _navigateToDashboard(role);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Login failed'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _navigateToDashboard(String? role) {
    if (role == 'CORRESPONDENT') {
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard-correspondent', (r) => false);
    } else if (role == 'HM' || role == 'PRINCIPAL') {
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard-hm', (r) => false);
    } else if (role == 'TEACHER') {
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard-teacher', (r) => false);
    } else if (role == 'PARENT') {
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard-parent', (r) => false);
    } else if (role == 'PT') {
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard-pt', (r) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unrecognized role, routing to general page')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.school,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to continue to your account',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 36),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email / Mobile Number',
                    hintText: 'Enter your email or phone',
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryColor),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppTheme.textSecondaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: provider.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: provider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login'),
                ),
                const SizedBox(height: 20),
                Card(
                  color: AppTheme.primaryColor.withOpacity(0.04),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Demo Accounts (Password: password123):',
                          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• Correspondent: correspondent@school.com\n'
                          '• HM: hm@school.com\n'
                          '• Teacher: sharma@school.com\n'
                          '• Parent: parent@school.com',
                          style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/register-school');
                      },
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.outfit(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
