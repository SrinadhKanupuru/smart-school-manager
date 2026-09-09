import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/academic_provider.dart';
import '../../core/theme.dart';

class LearningDiaryScreen extends StatefulWidget {
  const LearningDiaryScreen({super.key});

  @override
  State<LearningDiaryScreen> createState() => _LearningDiaryScreenState();
}

class _LearningDiaryScreenState extends State<LearningDiaryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSectionId;
  final _subjectCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  final _dateCtrl = TextEditingController(text: DateFormat('dd MMM, yyyy').format(DateTime.now()));
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _detailsCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text = DateFormat('dd MMM, yyyy').format(picked);
      });
    }
  }

  void _submit(AcademicProvider provider) async {
    if (!_formKey.currentState!.validate() || _selectedSectionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select class and fill details')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final success = await provider.addDiary(
      classSectionId: _selectedSectionId!,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      subject: _subjectCtrl.text.trim(),
      details: _detailsCtrl.text.trim(),
    );

    if (mounted) {
      Navigator.pop(context); // Dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Diary entry added successfully!' : 'Failed to save diary'),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
      if (success) Navigator.pop(context);
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
        });
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Diary Entry')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedSectionId,
                  hint: const Text('Select Class & Section'),
                  items: sections.map((sec) {
                    return DropdownMenuItem(value: sec['id'] as String, child: Text(sec['displayName']));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedSectionId = val),
                  validator: (val) => val == null ? 'Select class & section' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateCtrl,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subjectCtrl,
                  decoration: const InputDecoration(labelText: 'Subject', hintText: 'e.g. Science, English'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter subject' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _detailsCtrl,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Learning Progress / Details', hintText: 'Explain what topic was covered...'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter progress details' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _submit(academic),
                  child: const Text('Add New Entry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
