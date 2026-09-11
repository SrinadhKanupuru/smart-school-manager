import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/teacher_model.dart';

class TeacherDetailDialog extends StatelessWidget {
  final TeacherModel teacher;

  const TeacherDetailDialog({super.key, required this.teacher});

  static void show(BuildContext context, TeacherModel teacher) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => TeacherDetailDialog(teacher: teacher),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  backgroundColor: const Color(0xFFF5F3FF),
                  child: Text(
                    teacher.name.split(' ').map((e) => e[0]).take(2).join(),
                    style: const TextStyle(
                      color: Color(0xFF8B5CF6),
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
                            teacher.name,
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
                              color: teacher.status == 'Present'
                                  ? AppColors.successLight
                                  : AppColors.dangerLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              teacher.status,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: teacher.status == 'Present'
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${teacher.employeeId} • ${teacher.subject} • Joined: ${teacher.joiningDate}',
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

            // Content Tabs / Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Stats Row
                    Row(
                      children: [
                        _buildStatBox('Attendance', '${teacher.attendancePercentage}%', AppColors.primary),
                        const SizedBox(width: 12),
                        _buildStatBox('Present Days', '${teacher.presentDays} Days', AppColors.success),
                        const SizedBox(width: 12),
                        _buildStatBox('Absent Days', '${teacher.absentDays} Days', AppColors.danger),
                        const SizedBox(width: 12),
                        _buildStatBox('Leave Days', '${teacher.leaveDays} Days', AppColors.warning),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Personal Information
                    _buildSectionTitle('Personal & Professional Info'),
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
                          _buildInfoRow('Email ID', teacher.email),
                          const Divider(height: 12),
                          _buildInfoRow('Phone', teacher.phone),
                          const Divider(height: 12),
                          _buildInfoRow('Qualification', teacher.qualification),
                          const Divider(height: 12),
                          _buildInfoRow('Experience', teacher.experience),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Subjects & Classes Handled
                    _buildSectionTitle('Assigned Classes & Subjects'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...teacher.assignedClasses.map((cls) => Chip(
                              label: Text(cls, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                              backgroundColor: AppColors.primaryTint,
                              side: BorderSide.none,
                              avatar: const Icon(Icons.class_outlined, size: 16, color: AppColors.primary),
                            )),
                        ...teacher.subjectsTaught.map((sub) => Chip(
                              label: Text(sub, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500)),
                              backgroundColor: const Color(0xFFF1F5F9),
                              side: BorderSide.none,
                              avatar: const Icon(Icons.menu_book_rounded, size: 16, color: AppColors.textSecondary),
                            )),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Leave History
                    _buildSectionTitle('Recent Leave History'),
                    const SizedBox(height: 10),
                    if (teacher.leaveHistory.isEmpty)
                      Text('No leaves recorded this semester.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted))
                    else
                      ...teacher.leaveHistory.map((l) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${l['type']} (${l['days']} days)', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                                    Text('Date: ${l['date']} • Reason: ${l['reason']}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.successLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('Approved', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
                                ),
                              ],
                            ),
                          )),
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
        Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }
}
