import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/student_model.dart';
import '../../data/mock_data.dart';

class StudentDetailDialog extends StatelessWidget {
  final StudentModel student;

  const StudentDetailDialog({super.key, required this.student});

  static void show(BuildContext context, StudentModel student) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => StudentDetailDialog(student: student),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feeStatusColor = student.feeStatus == 'Paid'
        ? AppColors.success
        : (student.feeStatus == 'Pending' ? AppColors.warning : AppColors.danger);
    final feeStatusBg = student.feeStatus == 'Paid'
        ? AppColors.successLight
        : (student.feeStatus == 'Pending' ? AppColors.warningLight : AppColors.dangerLight);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        width: 680,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Avatar, Name, ID, Close Button
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryTint,
                  child: Text(
                    student.name.split(' ').map((e) => e[0]).take(2).join(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            student.name,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: feeStatusBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Fee: ${student.feeStatus}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: feeStatusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${student.studentId} • ${student.className}-${student.section} • Roll No: ${student.rollNo}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 12),

            // Scrollable Content Body
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Stats Row
                    Row(
                      children: [
                        _buildStatBox('Attendance', '${student.attendancePercentage}%', AppColors.primary),
                        const SizedBox(width: 12),
                        _buildStatBox('Fee Status', student.feeStatus, feeStatusColor),
                        const SizedBox(width: 12),
                        _buildStatBox('Pending Dues', MockData.formatInr(student.pendingFeeAmount), student.pendingFeeAmount > 0 ? AppColors.danger : AppColors.success),
                        const SizedBox(width: 12),
                        _buildStatBox('Academic Status', 'Enrolled', AppColors.accentPurple),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Student & Parent Information
                    _buildSectionTitle('Student & Parent Information'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow('Parent / Guardian', student.parentName),
                          const Divider(height: 12),
                          _buildInfoRow('Parent Contact', student.parentPhone),
                          const Divider(height: 12),
                          _buildInfoRow('Date of Birth', student.dob),
                          const Divider(height: 12),
                          _buildInfoRow('Blood Group', student.bloodGroup),
                          const Divider(height: 12),
                          _buildInfoRow('Address', student.address),
                          const Divider(height: 12),
                          _buildInfoRow('Admission Date', student.admissionDate),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Academic Grades & Marks
                    _buildSectionTitle('Academic Performance'),
                    const SizedBox(height: 10),
                    if (student.academicGrades.isEmpty)
                      Text('No examination grades recorded yet.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted))
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            ...student.academicGrades.map((g) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(g['subject'], style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600)),
                                      Row(
                                        children: [
                                          Text('${g['marks']}/${g['maxMarks']}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryTint,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              g['grade'],
                                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
