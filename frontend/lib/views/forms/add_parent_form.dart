import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/academic_provider.dart';
import '../../providers/school_provider.dart';
import '../../core/theme.dart';

class AddParentForm extends StatefulWidget {
  const AddParentForm({super.key});

  @override
  State<AddParentForm> createState() => _AddParentFormState();
}

class _AddParentFormState extends State<AddParentForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController(text: 'password123'); // Default password
  final _phoneCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  String _relation = 'FATHER';
  final List<String> _selectedStudentIds = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AcademicProvider>(context, listen: false).fetchStudents();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one student to assign to this parent.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final success = await schoolProvider.addParentAndAssignStudents(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      phoneNumber: _phoneCtrl.text.trim(),
      relation: _relation,
      studentIds: _selectedStudentIds,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Parent "${_nameCtrl.text.trim()}" registered successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(schoolProvider.errorMessage ?? 'Failed to register parent'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final academicProvider = Provider.of<AcademicProvider>(context);
    final schoolProvider = Provider.of<SchoolProvider>(context);

    // Filter students based on search query
    final filteredStudents = academicProvider.students.where((student) {
      final name = (student['fullName'] ?? '').toString().toLowerCase();
      final rollNo = (student['rollNo'] ?? '').toString().toLowerCase();
      final className = (student['classSection']?['class']?['name'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || rollNo.contains(query) || className.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Parent',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Parent Account Details',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Register a new parent and assign their children.',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const Divider(height: 32),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Parent Full Name*',
                    hintText: 'Enter parent full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter name' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address*',
                    hintText: 'Enter parent email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter email' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password*',
                    hintText: 'Enter login password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Enter password' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number* (10 digits)',
                    hintText: 'Enter 10-digit phone number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter mobile number';
                    if (val.length != 10) return 'Phone number must be exactly 10 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _relation,
                  decoration: const InputDecoration(
                    labelText: 'Relationship*',
                    prefixIcon: Icon(Icons.family_restroom_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'FATHER', child: Text('Father')),
                    DropdownMenuItem(value: 'MOTHER', child: Text('Mother')),
                    DropdownMenuItem(value: 'GUARDIAN', child: Text('Guardian')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _relation = val);
                    }
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Assign Children (Students)*',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Student Search Bar
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    labelText: 'Search Students...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                  },
                ),
                const SizedBox(height: 12),

                // Student list box
                Container(
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: academicProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredStudents.isEmpty
                          ? Center(
                              child: Text(
                                _searchQuery.isEmpty
                                    ? 'No students found. Add students first!'
                                    : 'No matching students found.',
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredStudents.length,
                              itemBuilder: (context, index) {
                                final student = filteredStudents[index];
                                final studentId = student['id'] as String;
                                final isSelected = _selectedStudentIds.contains(studentId);
                                final rollNo = student['rollNo'] ?? '';
                                final className = student['classSection']?['class']?['name'] ?? 'Class';
                                final sectionName = student['classSection']?['name'] ?? 'Section';

                                return CheckboxListTile(
                                  value: isSelected,
                                  title: Text(
                                    student['fullName'] ?? '',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '$className - Sec $sectionName | Roll No: $rollNo',
                                    style: GoogleFonts.outfit(fontSize: 12),
                                  ),
                                  activeColor: AppTheme.primaryColor,
                                  onChanged: (checked) {
                                    setState(() {
                                      if (checked == true) {
                                        _selectedStudentIds.add(studentId);
                                      } else {
                                        _selectedStudentIds.remove(studentId);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                ),
                const SizedBox(height: 36),
                ElevatedButton(
                  onPressed: schoolProvider.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: schoolProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Add Parent'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
