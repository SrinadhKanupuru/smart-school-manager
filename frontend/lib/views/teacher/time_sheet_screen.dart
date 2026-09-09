import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class TimeSheetScreen extends StatefulWidget {
  const TimeSheetScreen({super.key});

  @override
  State<TimeSheetScreen> createState() => _TimeSheetScreenState();
}

class _TimeSheetScreenState extends State<TimeSheetScreen> {
  final String _workStart = '08:30 AM';
  final String _workEnd = '03:30 PM';
  final String _totalHours = '07:10';
  bool _isSubmitted = false;

  void _submit() {
    setState(() => _isSubmitted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Timesheet submitted successfully!'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time Sheet')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Today\'s Entry',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 24),
                      _buildTimeRow('Work Start', _workStart, Icons.login),
                      const Divider(height: 32),
                      _buildTimeRow('Work End', _workEnd, Icons.logout),
                      const Divider(height: 32),
                      _buildTimeRow('Total Working Hours', _totalHours, Icons.hourglass_bottom, isHighlight: true),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isSubmitted ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: Text(_isSubmitted ? 'Already Submitted' : 'Submit Timesheet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRow(String label, String value, IconData icon, {bool isHighlight = false}) {
    return Row(
      children: [
        Icon(icon, color: isHighlight ? AppTheme.primaryColor : AppTheme.textSecondaryColor),
        const SizedBox(width: 16),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            color: isHighlight ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isHighlight ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
          ),
        ),
      ],
    );
  }
}
