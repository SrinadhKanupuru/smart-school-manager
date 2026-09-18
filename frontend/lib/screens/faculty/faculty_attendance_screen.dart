import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';

class FacultyAttendanceScreen extends StatefulWidget {
  const FacultyAttendanceScreen({super.key});

  @override
  State<FacultyAttendanceScreen> createState() => _FacultyAttendanceScreenState();
}

class _FacultyAttendanceScreenState extends State<FacultyAttendanceScreen> {
  String _selectedClass = 'Grade 9-A';

  final List<Map<String, dynamic>> _students = [
    {'id': 'STU-01', 'roll': '01', 'name': 'Aarav Patel', 'status': 'Present'},
    {'id': 'STU-02', 'roll': '02', 'name': 'Ananya Sharma', 'status': 'Present'},
    {'id': 'STU-03', 'roll': '03', 'name': 'Devansh Gupta', 'status': 'Absent'},
    {'id': 'STU-04', 'roll': '04', 'name': 'Ishita Nair', 'status': 'Present'},
    {'id': 'STU-05', 'roll': '05', 'name': 'Kabir Khan', 'status': 'Present'},
    {'id': 'STU-06', 'roll': '06', 'name': 'Meera Joshi', 'status': 'Late'},
    {'id': 'STU-07', 'roll': '07', 'name': 'Rohan Das', 'status': 'Present'},
    {'id': 'STU-08', 'roll': '08', 'name': 'Sanya Kapoor', 'status': 'Present'},
    {'id': 'STU-09', 'roll': '09', 'name': 'Tanvi Verma', 'status': 'Present'},
    {'id': 'STU-10', 'roll': '10', 'name': 'Yash Singhania', 'status': 'Present'},
  ];

  void _markAll(String status) {
    setState(() {
      for (var s in _students) {
        s['status'] = status;
      }
    });
  }

  void _saveAttendance() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Attendance for $_selectedClass successfully submitted & synced!'),
          ],
        ),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = _students.where((s) => s['status'] == 'Present').length;
    final absentCount = _students.where((s) => s['status'] == 'Absent').length;
    final lateCount = _students.where((s) => s['status'] == 'Late').length;
    final percentage = ((presentCount + (lateCount * 0.5)) / _students.length * 100).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Attendance Register',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Record and synchronize classroom attendance with the central school database.',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _saveAttendance,
                  icon: const Icon(Icons.cloud_upload_outlined, size: 16),
                  label: const Text('Save & Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Controls & Summary Row
            Container(
              padding: const EdgeInsets.all(18),
              decoration: AppDecorations.cardDecoration(),
              child: Row(
                children: [
                  // Class Dropdown
                  DropdownButton<String>(
                    value: _selectedClass,
                    underline: const SizedBox(),
                    items: ['Grade 9-A', 'Grade 10-B', 'Grade 8-C', 'Physics Lab']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontWeight: FontWeight.bold))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedClass = val);
                    },
                  ),
                  const SizedBox(width: 20),

                  // Quick Buttons
                  OutlinedButton(
                    onPressed: () => _markAll('Present'),
                    child: const Text('Mark All Present'),
                  ),
                  const Spacer(),

                  // Stats Pills
                  _buildStatPill('Present: $presentCount', AppColors.successLight, AppColors.success),
                  const SizedBox(width: 8),
                  _buildStatPill('Absent: $absentCount', AppColors.dangerLight, AppColors.danger),
                  const SizedBox(width: 8),
                  _buildStatPill('Late: $lateCount', const Color(0xFFFFFBEB), const Color(0xFFD97706)),
                  const SizedBox(width: 8),
                  _buildStatPill('Rate: $percentage%', AppColors.primaryTint, AppColors.primary),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Students Attendance Table
            Container(
              decoration: AppDecorations.cardDecoration(),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _students.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  final s = _students[index];
                  final status = s['status'] as String;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Row(
                      children: [
                        Text(
                          s['roll'] as String,
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s['name'] as String,
                                style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${s['id']} • $_selectedClass',
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        // Action buttons
                        _buildStatusChoiceButton(index, 'Present', status == 'Present', AppColors.success, AppColors.successLight),
                        const SizedBox(width: 8),
                        _buildStatusChoiceButton(index, 'Absent', status == 'Absent', AppColors.danger, AppColors.dangerLight),
                        const SizedBox(width: 8),
                        _buildStatusChoiceButton(index, 'Late', status == 'Late', const Color(0xFFD97706), const Color(0xFFFFFBEB)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChoiceButton(int index, String choice, bool isSelected, Color activeColor, Color activeBg) {
    return InkWell(
      onTap: () {
        setState(() {
          _students[index]['status'] = choice;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? activeColor : AppColors.border),
        ),
        child: Text(
          choice,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: textCol,
        ),
      ),
    );
  }
}
