import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../data/mock_data.dart';
import '../../models/academic_model.dart';
import '../../widgets/common/section_header.dart';

class AcademicsScreen extends StatefulWidget {
  const AcademicsScreen({super.key});

  @override
  State<AcademicsScreen> createState() => _AcademicsScreenState();
}

class _AcademicsScreenState extends State<AcademicsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          PageHeader(
            title: 'Academics & Curriculum Framework',
            subtitle: 'Manage classes, curriculum subjects, master school timetables, and academic exam schedules',
            trailing: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add New Class / Subject Section modal opened')),
                );
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Academic Unit'),
            ),
          ),

          // Sub Navigation Tabs
          Container(
            padding: const EdgeInsets.all(12),
            decoration: AppDecorations.cardDecoration(),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              onTap: (_) => setState(() {}),
              indicator: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
              tabs: const [
                Tab(icon: Icon(Icons.class_outlined, size: 18), text: 'Classes & Sections'),
                Tab(icon: Icon(Icons.menu_book_outlined, size: 18), text: 'Subjects & Curriculum'),
                Tab(icon: Icon(Icons.calendar_view_week_rounded, size: 18), text: 'Master Timetable (Grade 10)'),
                Tab(icon: Icon(Icons.assignment_turned_in_outlined, size: 18), text: 'Exams & Assessment'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sub-Tab Content
          IndexedStack(
            index: _tabController.index,
            children: [
              _buildClassesTab(),
              _buildSubjectsTab(),
              _buildTimetableTab(),
              _buildExamsTab(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassesTab() {
    final classes = MockData.classSections;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: classes.map((cls) {
                final double width = constraints.maxWidth > 900
                    ? (constraints.maxWidth - 32) / 3
                    : (constraints.maxWidth > 600 ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth);

                return Container(
                  width: width,
                  padding: const EdgeInsets.all(20),
                  decoration: AppDecorations.cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTint,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${cls.className} - Section ${cls.section}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                          Text(
                            cls.roomNo,
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            'Class Teacher: ',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          Text(
                            cls.classTeacher,
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Enrolled: ${cls.totalStudents} / ${cls.capacity} seats', style: GoogleFonts.inter(fontSize: 11.5)),
                          Text('${((cls.totalStudents / cls.capacity) * 100).toInt()}% Capacity', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.success)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: cls.totalStudents / cls.capacity,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubjectsTab() {
    final subjects = MockData.subjects;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Curriculum Subjects & Department Leads', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.surfaceMuted),
              columnSpacing: 28,
              columns: [
                DataColumn(label: Text('Subject Code', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Subject Name', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Department', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Weekly Periods', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Subject Coordinator / Lead', style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
              ],
              rows: subjects.map((sub) {
                return DataRow(
                  cells: [
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.primaryTint, borderRadius: BorderRadius.circular(6)),
                        child: Text(sub.code, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 11.5, color: AppColors.primary)),
                      ),
                    ),
                    DataCell(Text(sub.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13))),
                    DataCell(Text(sub.department, style: GoogleFonts.inter(fontSize: 12.5))),
                    DataCell(Text('${sub.weeklyPeriods} Hours/Wk', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600))),
                    DataCell(Text(sub.leadTeacher, style: GoogleFonts.inter(fontSize: 12.5))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableTab() {
    final slots = MockData.timetableGrade10A;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Timetable Schedule (Grade 10 - Section A)', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Timetable exported as PDF!')));
                },
                icon: const Icon(Icons.print_outlined, size: 16),
                label: const Text('Print Schedule'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: slots.length,
            separatorBuilder: (c, i) => const Divider(height: 12),
            itemBuilder: (context, index) {
              final slot = slots[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 90,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        slot.period,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: 130,
                      child: Text(slot.time, style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondary)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: Text(slot.subject, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('Instructor: ${slot.teacher}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                      child: Text(slot.room, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExamsTab() {
    final exams = MockData.exams;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Assessment & Examination Calendar 2026–27', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exams.length,
            separatorBuilder: (c, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final exam = exams[index];
              final isPublished = exam.status == 'Results Published';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isPublished ? AppColors.successLight : AppColors.primaryTint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPublished ? Icons.fact_check_rounded : Icons.quiz_outlined,
                        color: isPublished ? AppColors.success : AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(exam.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('Duration: ${exam.startDate} to ${exam.endDate} • Applicable: ${exam.applicableClasses}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPublished ? AppColors.successLight : AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        exam.status,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isPublished ? AppColors.success : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
