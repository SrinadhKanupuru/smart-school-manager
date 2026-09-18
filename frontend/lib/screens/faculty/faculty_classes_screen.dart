import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';

class FacultyClassesScreen extends StatefulWidget {
  final bool showStudentsOnly;

  const FacultyClassesScreen({super.key, this.showStudentsOnly = false});

  @override
  State<FacultyClassesScreen> createState() => _FacultyClassesScreenState();
}

class _FacultyClassesScreenState extends State<FacultyClassesScreen> {
  String _selectedClass = 'Grade 9-A';
  String _searchFilter = '';

  final List<Map<String, dynamic>> _myClasses = [
    {
      'name': 'Grade 9-A',
      'subject': 'Physics (Main)',
      'role': 'Class Teacher & Subject Teacher',
      'studentsCount': 40,
      'attendanceToday': '95.0%',
      'room': 'Room 204 (Science Block)',
      'timing': 'Mon, Wed, Fri (09:00 AM)',
    },
    {
      'name': 'Grade 10-B',
      'subject': 'Physics (Board Prep)',
      'role': 'Subject Teacher',
      'studentsCount': 44,
      'attendanceToday': '95.5%',
      'room': 'Room 302',
      'timing': 'Tue, Thu, Sat (09:50 AM)',
    },
    {
      'name': 'Grade 8-C',
      'subject': 'General Science',
      'role': 'Subject Teacher',
      'studentsCount': 36,
      'attendanceToday': '94.4%',
      'room': 'Room 108',
      'timing': 'Daily (11:00 AM)',
    },
    {
      'name': 'Physics Lab',
      'subject': 'Practical Experiments',
      'role': 'Lab Instructor',
      'studentsCount': 22,
      'attendanceToday': '100.0%',
      'room': 'Senior Lab 1',
      'timing': 'Thu (11:50 AM)',
    },
  ];

  final List<Map<String, dynamic>> _studentsRoster = [
    {
      'roll': '01',
      'name': 'Aarav Patel',
      'class': 'Grade 9-A',
      'gender': 'Male',
      'attendance': '98.5%',
      'status': 'Present',
      'guardian': 'Rajesh Patel (+91 98200 11223)',
      'performance': 'A+ (94%)',
    },
    {
      'roll': '02',
      'name': 'Ananya Sharma',
      'class': 'Grade 9-A',
      'gender': 'Female',
      'attendance': '96.0%',
      'status': 'Present',
      'guardian': 'Sunil Sharma (+91 98200 44556)',
      'performance': 'A (88%)',
    },
    {
      'roll': '03',
      'name': 'Devansh Gupta',
      'class': 'Grade 9-A',
      'gender': 'Male',
      'attendance': '91.2%',
      'status': 'Absent',
      'guardian': 'Mahesh Gupta (+91 98200 77889)',
      'performance': 'B+ (79%)',
    },
    {
      'roll': '04',
      'name': 'Ishita Nair',
      'class': 'Grade 9-A',
      'gender': 'Female',
      'attendance': '99.0%',
      'status': 'Present',
      'guardian': 'Suresh Nair (+91 98200 99001)',
      'performance': 'A+ (96%)',
    },
    {
      'roll': '05',
      'name': 'Kabir Khan',
      'class': 'Grade 9-A',
      'gender': 'Male',
      'attendance': '94.0%',
      'status': 'Present',
      'guardian': 'Zaid Khan (+91 98200 22334)',
      'performance': 'B (74%)',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.showStudentsOnly ? 'My Students' : 'My Classes & Assigned Batches',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage classroom rosters, student details, and academic performance.',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Class Cards Grid
            if (!widget.showStudentsOnly) ...[
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 900;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 4 : 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      mainAxisExtent: 155,
                    ),
                    itemCount: _myClasses.length,
                    itemBuilder: (context, index) {
                      final c = _myClasses[index];
                      final isSelected = _selectedClass == c['name'];

                      return InkWell(
                        onTap: () => setState(() => _selectedClass = c['name'] as String),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryTint : AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: isSelected ? 1.8 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    c['name'] as String,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${c['studentsCount']} Std',
                                      style: GoogleFonts.inter(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? Colors.white : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                c['subject'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                c['room'] as String,
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Attendance: ${c['attendanceToday']}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
            ],

            // Student Roster for Selected Class
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppDecorations.cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Student Roster • $_selectedClass (40 Enrolled)',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      // Search Filter
                      SizedBox(
                        width: 220,
                        height: 38,
                        child: TextField(
                          onChanged: (val) => setState(() => _searchFilter = val),
                          decoration: const InputDecoration(
                            hintText: 'Filter students...',
                            prefixIcon: Icon(Icons.search_rounded, size: 16),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Data Table
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppColors.surfaceMuted),
                      columns: const [
                        DataColumn(label: Text('Roll No')),
                        DataColumn(label: Text('Student Name')),
                        DataColumn(label: Text('Class & Section')),
                        DataColumn(label: Text('Status Today')),
                        DataColumn(label: Text('Term Attendance')),
                        DataColumn(label: Text('Academic Grade')),
                        DataColumn(label: Text('Parent Contact')),
                      ],
                      rows: _studentsRoster
                          .where((s) => s['name']
                              .toString()
                              .toLowerCase()
                              .contains(_searchFilter.toLowerCase()))
                          .map((s) {
                        final isPresent = s['status'] == 'Present';

                        return DataRow(
                          cells: [
                            DataCell(Text(s['roll'] as String, style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: AppColors.primaryTint,
                                  child: Text(
                                    (s['name'] as String).substring(0, 1),
                                    style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(s['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            )),
                            DataCell(Text(s['class'] as String)),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isPresent ? AppColors.successLight : AppColors.dangerLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                s['status'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isPresent ? AppColors.success : AppColors.danger,
                                ),
                              ),
                            )),
                            DataCell(Text(s['attendance'] as String, style: const TextStyle(fontWeight: FontWeight.w600))),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                s['performance'] as String,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            )),
                            DataCell(Text(s['guardian'] as String)),
                          ],
                        );
                      }).toList(),
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
}
