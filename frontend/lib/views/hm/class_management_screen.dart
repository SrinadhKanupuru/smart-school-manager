import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/academic_provider.dart';
import '../../core/theme.dart';

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  State<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AcademicProvider>(context, listen: false).fetchClasses();
      Provider.of<AcademicProvider>(context, listen: false).fetchStudents();
    });
  }

  void _showAddClassDialog(AcademicProvider academic) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Create Class Grade', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Class Name*',
            hintText: 'e.g. Class 6, Class 10',
            prefixIcon: Icon(Icons.school_outlined),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final success = await academic.createClass(nameCtrl.text.trim());
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Class created successfully!' : 'Failed to create class'),
                    backgroundColor: success ? Colors.green : Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddSectionDialog(AcademicProvider academic, String classId, String className) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Create Section for $className', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Section Name*',
            hintText: 'e.g. A, B, C',
            prefixIcon: Icon(Icons.class_outlined),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              final success = await academic.createClassSection(
                classId: classId,
                name: nameCtrl.text.trim(),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Section created successfully!' : 'Failed to create section'),
                    backgroundColor: success ? Colors.green : Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAssignStudentsBottomSheet(AcademicProvider academic, Map<String, dynamic> section, String sectionName) {
    final sectionId = section['id'];
    // List of student IDs currently assigned to this section
    final currentStudentIds = (section['students'] as List<dynamic>? ?? [])
        .map((s) => s['id'] as String)
        .toSet();

    // Track chosen student IDs
    final Set<String> selectedStudentIds = Set.from(currentStudentIds);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assign Students',
                              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Select students to assign to section $sectionName',
                              style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Expanded(
                    child: academic.students.isEmpty
                        ? Center(
                            child: Text(
                              'No student registry records found.',
                              style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                            ),
                          )
                        : ListView.builder(
                            itemCount: academic.students.length,
                            itemBuilder: (context, index) {
                              final student = academic.students[index];
                              final studentId = student['id'] as String;
                              final studentName = student['fullName'] ?? '';
                              final rollNo = student['rollNo'] ?? '';
                              
                              final classSec = student['classSection'];
                              final currentClassSectionId = student['classSectionId'];
                              
                              final isAssignedElsewhere = currentClassSectionId != null && currentClassSectionId != sectionId;
                              final isAssignedHere = currentClassSectionId == sectionId;

                              String subtitleText = 'Roll No: $rollNo';
                              if (isAssignedElsewhere) {
                                final currentClassName = classSec?['class']?['name'] ?? '';
                                final currentSecName = classSec?['name'] ?? '';
                                subtitleText += ' • Assigned to $currentClassName-$currentSecName';
                              } else if (isAssignedHere) {
                                subtitleText += ' • Assigned Here';
                              } else {
                                subtitleText += ' • Unassigned';
                              }

                              return CheckboxListTile(
                                value: selectedStudentIds.contains(studentId),
                                enabled: !isAssignedElsewhere,
                                activeColor: AppTheme.primaryColor,
                                secondary: CircleAvatar(
                                  backgroundColor: isAssignedElsewhere
                                      ? Colors.grey.shade100
                                      : AppTheme.primaryColor.withOpacity(0.08),
                                  child: Text(
                                    studentName.isNotEmpty ? studentName[0].toUpperCase() : 'S',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isAssignedElsewhere ? Colors.grey : AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  studentName,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w600,
                                    color: isAssignedElsewhere ? Colors.grey : AppTheme.textPrimaryColor,
                                  ),
                                ),
                                subtitle: Text(
                                  subtitleText,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: isAssignedElsewhere ? Colors.red.shade300 : AppTheme.textSecondaryColor,
                                  ),
                                ),
                                onChanged: isAssignedElsewhere
                                    ? null
                                    : (bool? checked) {
                                        setModalState(() {
                                          if (checked == true) {
                                            selectedStudentIds.add(studentId);
                                          } else {
                                            selectedStudentIds.remove(studentId);
                                          }
                                        });
                                      },
                              );
                            },
                          ),
                  ),
                  const Divider(height: 24),
                  ElevatedButton(
                    onPressed: academic.isLoading
                        ? null
                        : () async {
                            Navigator.pop(ctx);
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) => const Center(child: CircularProgressIndicator()),
                            );

                            final error = await academic.assignStudentsToClass(
                              classSectionId: sectionId,
                              studentIds: selectedStudentIds.toList(),
                            );

                            if (mounted) {
                              Navigator.pop(context); // Dismiss loader
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error == null
                                      ? 'Students assigned successfully!'
                                      : 'Error: $error'),
                                  backgroundColor: error == null ? Colors.green : Colors.redAccent,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save Assignments'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final academic = Provider.of<AcademicProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Classes & Sections',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
            onPressed: () => _showAddClassDialog(academic),
            tooltip: 'Add Class',
          ),
        ],
      ),
      body: SafeArea(
        child: academic.isLoading && academic.classes.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : academic.classes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.class_outlined, size: 60, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No classes configured yet.',
                          style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _showAddClassDialog(academic),
                          icon: const Icon(Icons.add),
                          label: const Text('Create Class'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: academic.classes.length,
                    itemBuilder: (context, index) {
                      final cls = academic.classes[index];
                      final className = cls['name'] ?? '';
                      final classId = cls['id'] ?? '';
                      final List<dynamic> sections = cls['sections'] ?? [];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade100),
                        ),
                        child: ExpansionTile(
                          shape: const Border(),
                          title: Text(
                            className,
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
                          ),
                          subtitle: Text(
                            '${sections.length} Sections configured',
                            style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor, fontSize: 13),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_box_outlined, color: AppTheme.primaryColor),
                            onPressed: () => _showAddSectionDialog(academic, classId, className),
                            tooltip: 'Add Section',
                          ),
                          children: sections.isEmpty
                              ? [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      'No sections created. Tap + to add A, B, C etc.',
                                      style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor, fontStyle: FontStyle.italic),
                                    ),
                                  )
                                ]
                              : sections.map((sec) {
                                  final secName = sec['name'] ?? '';
                                  final List<dynamic> studentsList = sec['students'] ?? [];
                                  final teacher = sec['classTeacher']?['user']?['fullName'] ?? 'None assigned';

                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(top: BorderSide(color: Colors.grey.shade50)),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                      title: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Section $secName',
                                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${studentsList.length} Students',
                                              style: GoogleFonts.outfit(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.primaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Text(
                                        'Teacher: $teacher',
                                        style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                                      ),
                                      trailing: TextButton.icon(
                                        onPressed: () => _showAssignStudentsBottomSheet(
                                          academic,
                                          sec,
                                          '$className - $secName',
                                        ),
                                        icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                                        label: const Text('Assign'),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
