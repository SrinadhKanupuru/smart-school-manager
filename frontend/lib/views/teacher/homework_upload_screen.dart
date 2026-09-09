import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/academic_provider.dart';
import '../../core/theme.dart';

class HomeworkUploadScreen extends StatefulWidget {
  const HomeworkUploadScreen({super.key});

  @override
  State<HomeworkUploadScreen> createState() => _HomeworkUploadScreenState();
}

class _HomeworkUploadScreenState extends State<HomeworkUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSectionId;
  final _subjectCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dueDateCtrl = TextEditingController();
  DateTime? _selectedDueDate;

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _dueDateCtrl.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
        _dueDateCtrl.text = DateFormat('dd MMM, yyyy').format(picked);
      });
    }
  }

  void _submit(AcademicProvider provider) async {
    if (!_formKey.currentState!.validate() || _selectedSectionId == null || _selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select class and fill all details')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final success = await provider.uploadHomework(
      classSectionId: _selectedSectionId!,
      subject: _subjectCtrl.text.trim(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      dueDate: DateFormat('yyyy-MM-dd').format(_selectedDueDate!),
    );

    if (mounted) {
      Navigator.pop(context); // Dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Homework posted successfully!' : 'Failed to post homework'),
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
      appBar: AppBar(title: const Text('Add Homework')),
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
                  controller: _subjectCtrl,
                  decoration: const InputDecoration(labelText: 'Subject', hintText: 'e.g. Mathematics, Science'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter subject' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Fractions Chapter 5'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter title' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description', hintText: 'Solve questions from page 85...'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter details' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dueDateCtrl,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    hintText: 'Select date',
                    suffixIcon: Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Select due date' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _submit(academic),
                  child: const Text('Upload Homework'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
