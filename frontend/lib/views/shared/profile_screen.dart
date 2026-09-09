import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/school_provider.dart';
import '../../core/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);
    final user = provider.currentUser ?? {};
    final school = provider.currentSchool ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.08),
                      child: const Icon(Icons.person, size: 50, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user['fullName'] ?? 'User Profile',
                      style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user['role'] ?? '',
                      style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildProfileRow('Email ID', user['email'] ?? ''),
                      const Divider(height: 20),
                      _buildProfileRow('Mobile Number', user['phoneNumber'] ?? ''),
                      const Divider(height: 20),
                      _buildProfileRow('School Name', school['name'] ?? ''),
                      const Divider(height: 20),
                      _buildProfileRow('School Code', school['code'] ?? ''),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  await provider.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout Session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor, fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}
