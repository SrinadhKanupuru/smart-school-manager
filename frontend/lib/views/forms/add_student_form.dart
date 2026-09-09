import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/academic_provider.dart';
import '../../core/theme.dart';

class AddStudentForm extends StatefulWidget {
  const AddStudentForm({super.key});

  @override
  State<AddStudentForm> createState() => _AddStudentFormState();
}

class _AddStudentFormState extends State<AddStudentForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _rollNoCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  String? _selectedClassSectionId;
  String _gender = 'MALE';
  final List<Map<String, dynamic>> _initialFees = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AcademicProvider>(context, listen: false).fetchClasses();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rollNoCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  void _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2015, 1, 1),
      firstDate: DateTime(2005, 1, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _addFeeDialog() {
    String category = 'TUITION';
    final amountCtrl = TextEditingController();
    final dueDateCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          void pickFeeDueDate() async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 30)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );
            if (picked != null) {
              setDialogState(() {
                dueDateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
              });
            }
          }

          return AlertDialog(
            title: Text(
              'Add Initial Fee',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(
                      labelText: 'Fee Category',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'TUITION', child: Text('Tuition Fee')),
                      DropdownMenuItem(value: 'VAN', child: Text('Transport/Van Fee')),
                      DropdownMenuItem(value: 'OTHER', child: Text('Other/Admission Fee')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => category = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount (₹)*',
                      hintText: 'Enter amount',
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: dueDateCtrl,
                    readOnly: true,
                    onTap: pickFeeDueDate,
                    decoration: const InputDecoration(
                      labelText: 'Due Date*',
                      hintText: 'YYYY-MM-DD',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: GoogleFonts.outfit()),
              ),
              ElevatedButton(
                onPressed: () {
                  final amt = double.tryParse(amountCtrl.text.trim());
                  if (amt == null || amt <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid amount')),
                    );
                    return;
                  }
                  if (dueDateCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a due date')),
                    );
                    return;
                  }
                  setState(() {
                    _initialFees.add({
                      'category': category,
                      'amount': amt,
                      'dueDate': dueDateCtrl.text,
                    });
                  });
                  Navigator.pop(context);
                },
                child: Text('Add', style: GoogleFonts.outfit()),
              ),
            ],
          );
        }
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClassSectionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class and section')),
      );
      return;
    }

    final academicProvider = Provider.of<AcademicProvider>(context, listen: false);
    final success = await academicProvider.addStudent(
      fullName: _nameCtrl.text.trim(),
      rollNo: _rollNoCtrl.text.trim(),
      classSectionId: _selectedClassSectionId!,
      gender: _gender,
      dateOfBirth: _dobCtrl.text,
      initialFees: _initialFees.isNotEmpty ? _initialFees : null,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student "${_nameCtrl.text.trim()}" added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add student. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final academicProvider = Provider.of<AcademicProvider>(context);

    // Flatten classes and sections for the dropdown
    final List<Map<String, dynamic>> sectionItems = [];
    for (var cls in academicProvider.classes) {
      final sections = cls['sections'] as List<dynamic>? ?? [];
      for (var sec in sections) {
        sectionItems.add({
          'id': sec['id'],
          'displayName': '${cls['name']} - Section ${sec['name']}',
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Student',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: academicProvider.isLoading && academicProvider.classes.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Student Details',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enroll a new student to this school.',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const Divider(height: 32),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Full Name*',
                          hintText: 'Enter student full name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Enter full name' : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _rollNoCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Roll Number*',
                          hintText: 'Enter unique roll number',
                          prefixIcon: Icon(Icons.numbers_outlined),
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Enter roll number' : null,
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedClassSectionId,
                        decoration: const InputDecoration(
                          labelText: 'Class & Section*',
                          prefixIcon: Icon(Icons.class_outlined),
                        ),
                        items: sectionItems.map((item) {
                          return DropdownMenuItem<String>(
                            value: item['id'],
                            child: Text(item['displayName']),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedClassSectionId = val);
                        },
                        validator: (val) =>
                            val == null ? 'Select class & section' : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _dobCtrl,
                        readOnly: true,
                        onTap: _pickDob,
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth*',
                          hintText: 'YYYY-MM-DD',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Enter date of birth' : null,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Gender*',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildGenderChip('MALE', 'Male'),
                          const SizedBox(width: 12),
                          _buildGenderChip('FEMALE', 'Female'),
                          const SizedBox(width: 12),
                          _buildGenderChip('OTHER', 'Other'),
                        ],
                      ),
                      const Divider(height: 48),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Initial Fees Setup',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _addFeeDialog,
                            icon: const Icon(Icons.add),
                            label: Text(
                              'Add Fee',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_initialFees.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            'No initial fees added. You can assign fees later or add them here.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 14,
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _initialFees.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final fee = _initialFees[index];
                            final catLabel = fee['category'] == 'TUITION'
                                ? 'Tuition Fee'
                                : fee['category'] == 'VAN'
                                    ? 'Transport/Van Fee'
                                    : 'Other Fee';
                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                  child: Icon(
                                    fee['category'] == 'TUITION'
                                        ? Icons.school
                                        : fee['category'] == 'VAN'
                                            ? Icons.directions_bus
                                            : Icons.payment,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                title: Text(
                                  catLabel,
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Due: ${fee['dueDate']}',
                                  style: GoogleFonts.outfit(fontSize: 12),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '₹${fee['amount']}',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppTheme.textPrimaryColor,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                      onPressed: () {
                                        setState(() {
                                          _initialFees.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 36),
                      ElevatedButton(
                        onPressed: academicProvider.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: academicProvider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Add Student'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildGenderChip(String value, String label) {
    final isSelected = _gender == value;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _gender = value);
        }
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.12),
      backgroundColor: Colors.grey.shade100,
      checkmarkColor: AppTheme.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
        ),
      ),
    );
  }
}
