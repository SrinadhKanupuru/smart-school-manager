import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';

class FacultyHomeworkScreen extends StatefulWidget {
  final bool isAssignmentsTab;

  const FacultyHomeworkScreen({super.key, this.isAssignmentsTab = false});

  @override
  State<FacultyHomeworkScreen> createState() => _FacultyHomeworkScreenState();
}

class _FacultyHomeworkScreenState extends State<FacultyHomeworkScreen> {
  final List<Map<String, dynamic>> _homeworkList = [
    {
      'id': 'HW-101',
      'title': 'Newton’s Second Law Numerical Problems',
      'subject': 'Physics',
      'class': 'Grade 9-A',
      'assignedDate': '12 Sep 2026',
      'dueDate': '18 Sep 2026',
      'submittedCount': 36,
      'totalStudents': 40,
      'status': 'Active',
      'description': 'Solve exercise problems 1 to 15 from Chapter 4 on momentum and force vectors.',
    },
    {
      'id': 'HW-102',
      'title': 'Electromagnetic Induction Lab Report',
      'subject': 'Physics',
      'class': 'Grade 10-B',
      'assignedDate': '10 Sep 2026',
      'dueDate': '16 Sep 2026',
      'submittedCount': 42,
      'totalStudents': 44,
      'status': 'Grading',
      'description': 'Submit formal write-up of Faraday\'s coil experiment with observational graphs.',
    },
    {
      'id': 'HW-103',
      'title': 'Ray Diagrams & Lens Equation Practice',
      'subject': 'General Science',
      'class': 'Grade 8-C',
      'assignedDate': '08 Sep 2026',
      'dueDate': '14 Sep 2026',
      'submittedCount': 36,
      'totalStudents': 36,
      'status': 'Completed',
      'description': 'Draw concave & convex mirror ray diagrams on graph sheets with focal lengths.',
    },
  ];

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.isAssignmentsTab ? 'Create New Assignment' : 'Assign New Homework',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(decoration: InputDecoration(labelText: 'Title / Topic', hintText: 'e.g. Wave Optics Project')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: 'Grade 9-A',
                decoration: const InputDecoration(labelText: 'Target Class'),
                items: ['Grade 9-A', 'Grade 10-B', 'Grade 8-C'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (_) {},
              ),
              const SizedBox(height: 12),
              const TextField(
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Instructions / Description', hintText: 'Provide details for students'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Homework assignment published to students & parents!')),
              );
            },
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isAssignmentsTab ? 'Assignments & Project Work' : 'Homework & Task Tracker',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create, distribute, and grade assignments for your assigned classrooms.',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _showCreateDialog,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(widget.isAssignmentsTab ? 'New Assignment' : 'Assign Homework'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _homeworkList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final hw = _homeworkList[index];
                final submitted = hw['submittedCount'] as int;
                final total = hw['totalStudents'] as int;
                final progress = submitted / total;

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppDecorations.cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryTint,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  hw['class'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                hw['subject'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: hw['status'] == 'Completed'
                                  ? AppColors.successLight
                                  : hw['status'] == 'Grading'
                                      ? const Color(0xFFFFFBEB)
                                      : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              hw['status'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: hw['status'] == 'Completed'
                                    ? AppColors.success
                                    : hw['status'] == 'Grading'
                                        ? const Color(0xFFD97706)
                                        : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        hw['title'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hw['description'] as String,
                        style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Submissions ($submitted/$total)',
                                        style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600)),
                                    Text('Due: ${hw['dueDate']}',
                                        style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textMuted)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 6,
                                  backgroundColor: const Color(0xFFE2E8F0),
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Opening submissions for ${hw['title']}')),
                              );
                            },
                            icon: const Icon(Icons.grading_rounded, size: 16),
                            label: const Text('Review & Grade'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
