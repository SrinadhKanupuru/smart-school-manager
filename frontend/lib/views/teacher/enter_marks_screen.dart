import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/academic_provider.dart';
import '../../core/theme.dart';

class EnterMarksScreen extends StatefulWidget {
  const EnterMarksScreen({super.key});

  @override
  State<EnterMarksScreen> createState() => _EnterMarksScreenState();
}

class _EnterMarksScreenState extends State<EnterMarksScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedClassId;
  String? _selectedSectionId;
  final _examNameCtrl = TextEditingController(text: 'Unit Test 1');
  final _subjectCtrl = TextEditingController(text: 'Mathematics');
  final _maxMarksCtrl = TextEditingController(text: '100');
  final Map<String, TextEditingController> _marksControllers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AcademicProvider>(context, listen: false).fetchClasses();
    });
  }

  @override
  void dispose() {
    _examNameCtrl.dispose();
    _subjectCtrl.dispose();
    _maxMarksCtrl.dispose();
    for (var ctrl in _marksControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _save(AcademicProvider academic) async {
    if (_selectedClassId == null || _marksControllers.isEmpty) return;

    final List<Map<String, dynamic>> marksData = [];
    _marksControllers.forEach((studentId, ctrl) {
      if (ctrl.text.isNotEmpty) {
        marksData.add({
          'studentId': studentId,
          'subject': _subjectCtrl.text.trim(),
          'marksObtained': double.tryParse(ctrl.text) ?? 0.0,
          'maxMarks': double.tryParse(_maxMarksCtrl.text) ?? 100.0,
        });
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final success = await academic.enterMarks(
      examName: _examNameCtrl.text.trim(),
      classId: _selectedClassId!,
      marksData: marksData,
    );

    if (mounted) {
      Navigator.pop(context); // Dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Grades entry recorded!' : 'Failed to save grades'),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final academic = Provider.of<AcademicProvider>(context);

    // Get list of sections
    final List<Map<String, dynamic>> sections = [];
    for (var cls in academic.classes) {
      final className = cls['name'] ?? '';
      for (var sec in cls['sections'] ?? []) {
        sections.add({
          'id': sec['id'],
          'classId': cls['id'],
          'displayName': '$className - ${sec['name']}',
          'students': sec['students'] ?? [],
        });
      }
    }

    final activeSection = sections.firstWhere(
      (s) => s['id'] == _selectedSectionId,
      orElse: () => {},
    );
    final students = activeSection['students'] as List<dynamic>? ?? [];

    // Reset controllers if section changes
    if (_selectedSectionId != null && _marksControllers.length != students.length) {
      _marksControllers.clear();
      for (var stud in students) {
        _marksControllers[stud['id']] = TextEditingController();
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Enter Marks')),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedSectionId,
                    hint: const Text('Select Class & Section'),
                    items: sections.map((sec) {
                      return DropdownMenuItem(value: sec['id'] as String, child: Text(sec['displayName']));
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedSectionId = val;
                        _selectedClassId = sections.firstWhere((s) => s['id'] == val)['classId'];
                        _marksControllers.clear();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _examNameCtrl,
                          decoration: const InputDecoration(labelText: 'Exam Name'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _subjectCtrl,
                          decoration: const InputDecoration(labelText: 'Subject'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 70,
                        child: TextFormField(
                          controller: _maxMarksCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Max'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_selectedSectionId != null) ...[
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final stud = students[index];
                      final ctrl = _marksControllers[stud['id']];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppTheme.primaryColor.withOpacity(0.06),
                                child: Text(stud['rollNo'] ?? ''),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(stud['fullName'] ?? '', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(
                                width: 80,
                                child: TextFormField(
                                  controller: ctrl,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: '/ ${_maxMarksCtrl.text}',
                                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  validator: (val) {
                                    if (val != null && val.isNotEmpty) {
                                      final num = double.tryParse(val);
                                      final max = double.tryParse(_maxMarksCtrl.text) ?? 100.0;
                                      if (num == null) return 'Invalid';
                                      if (num > max) return 'Over Max';
                                    }
                                    return null;
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                color: Colors.white,
                child: ElevatedButton(
                  onPressed: () => _save(academic),
                  child: const Text('Save Marks'),
                ),
              ),
            ] else
              Expanded(
                child: Center(child: Text('Select class and section to load student roster', style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor))),
              )
          ],
        ),
      ),
    );
  }
}
