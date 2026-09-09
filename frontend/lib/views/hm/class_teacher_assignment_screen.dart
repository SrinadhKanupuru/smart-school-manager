import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/academic_provider.dart';
import '../../providers/school_provider.dart';
import '../../core/theme.dart';

class ClassTeacherAssignmentScreen extends StatefulWidget {
  const ClassTeacherAssignmentScreen({super.key});

  @override
  State<ClassTeacherAssignmentScreen> createState() => _ClassTeacherAssignmentScreenState();
}

class _ClassTeacherAssignmentScreenState extends State<ClassTeacherAssignmentScreen> {
  String? _selectedSectionId;
  String? _selectedTeacherId;
  List<dynamic> _teachers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AcademicProvider>(context, listen: false).fetchClasses();
      _fetchTeachers();
    });
  }

  void _fetchTeachers() async {
    final provider = Provider.of<SchoolProvider>(context, listen: false);
    await provider.fetchUsers(role: 'TEACHER');
    if (mounted) {
      setState(() {
        _teachers = provider.users
            .where((u) => u['teacherProfile'] != null)
            .map((u) => {
                  'id': u['teacherProfile']['id'],
                  'fullName': u['fullName'] ?? 'Teacher',
                  'subject': u['teacherProfile']['qualification'] ?? 'Teacher',
                })
            .toList();
      });
    }
  }

  void _assign() async {
    if (_selectedSectionId == null || _selectedTeacherId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final success = await Provider.of<AcademicProvider>(context, listen: false)
        .assignClassTeacher(_selectedSectionId!, _selectedTeacherId);

    if (mounted) {
      Navigator.pop(context); // Dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Class teacher assigned successfully!' : 'Failed to assign class teacher'),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final academic = Provider.of<AcademicProvider>(context);

    final List<Map<String, dynamic>> sections = [];
    for (var cls in academic.classes) {
      final className = cls['name'] ?? '';
      for (var sec in cls['sections'] ?? []) {
        sections.add({
          'id': sec['id'],
          'displayName': '$className - ${sec['name']}',
          'currentTeacher': sec['classTeacher']?['user']?['fullName'] ?? 'None Assigned',
        });
      }
    }

    final activeSection = sections.firstWhere(
      (s) => s['id'] == _selectedSectionId,
      orElse: () => {},
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Assign Class Teacher')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedSectionId,
                hint: const Text('Select Class & Section'),
                items: sections.map((sec) {
                  return DropdownMenuItem(value: sec['id'] as String, child: Text(sec['displayName']));
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedSectionId = val);
                },
              ),
              const SizedBox(height: 16),
              if (_selectedSectionId != null) ...[
                Card(
                  elevation: 0,
                  color: AppTheme.primaryColor.withOpacity(0.04),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Current Class Teacher:', style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor)),
                        Text(
                          activeSection['currentTeacher'] ?? 'None',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: _selectedTeacherId,
                  hint: const Text('Select New Teacher'),
                  items: _teachers.map((t) {
                    return DropdownMenuItem(
                      value: t['id'] as String,
                      child: Text('${t['fullName']} (${t['subject']})'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedTeacherId = val),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _selectedTeacherId == null ? null : _assign,
                  child: const Text('Assign Teacher'),
                ),
              ] else
                Expanded(
                  child: Center(
                    child: Text('Select class and section to manage teacher mapping', style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor)),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
