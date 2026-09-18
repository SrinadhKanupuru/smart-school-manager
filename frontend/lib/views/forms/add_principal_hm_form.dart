import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../shared/register_face_screen.dart';

class AddPrincipalHmForm extends StatefulWidget {
  const AddPrincipalHmForm({super.key});

  @override
  State<AddPrincipalHmForm> createState() => _AddPrincipalHmFormState();
}

class _AddPrincipalHmFormState extends State<AddPrincipalHmForm> {
  final _formKey = GlobalKey<FormState>();
  String _targetRole = 'HM';
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _qualificationCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();

  // Bank Details Controllers (Optional)
  final _bankNameCtrl = TextEditingController();
  final _bankAccountNoCtrl = TextEditingController();
  final _bankIfscCtrl = TextEditingController();
  final _bankBranchCtrl = TextEditingController();

  // Personal Details Controllers (Optional)
  final _bloodGroupCtrl = TextEditingController();
  final _aadhaarNoCtrl = TextEditingController();
  final _permanentAddressCtrl = TextEditingController();
  final _emergencyContactNameCtrl = TextEditingController();
  final _emergencyContactPhoneCtrl = TextEditingController();

  // Dynamic Previous Experience Controllers (Optional)
  final List<Map<String, TextEditingController>> _experienceControllers = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _qualificationCtrl.dispose();
    _experienceCtrl.dispose();
    _salaryCtrl.dispose();

    _bankNameCtrl.dispose();
    _bankAccountNoCtrl.dispose();
    _bankIfscCtrl.dispose();
    _bankBranchCtrl.dispose();

    _bloodGroupCtrl.dispose();
    _aadhaarNoCtrl.dispose();
    _permanentAddressCtrl.dispose();
    _emergencyContactNameCtrl.dispose();
    _emergencyContactPhoneCtrl.dispose();

    for (var controllers in _experienceControllers) {
      for (var ctrl in controllers.values) {
        ctrl.dispose();
      }
    }

    super.dispose();
  }

  void _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1985, 1, 1),
      firstDate: DateTime(1950, 1, 1),
      lastDate: DateTime(2010, 1, 1),
    );
    if (picked != null) {
      setState(() {
        _dobCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final List<Map<String, String>> experiences = [];
    for (var controllers in _experienceControllers) {
      final schoolName = controllers['schoolName']?.text.trim() ?? '';
      if (schoolName.isNotEmpty) {
        experiences.add({
          'schoolName': schoolName,
          'fromYear': controllers['fromYear']?.text.trim() ?? '',
          'toYear': controllers['toYear']?.text.trim() ?? '',
          'subject': controllers['subject']?.text.trim() ?? '',
          'reasonForLeaving': controllers['reasonForLeaving']?.text.trim() ?? '',
          'salary': controllers['salary']?.text.trim() ?? '',
        });
      }
    }

    final employeeData = {
      'fullName': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'password': 'password123', // default initial password for demo
      'phoneNumber': _phoneCtrl.text.trim(),
      'role': _targetRole,
      'details': {
        'qualification': _qualificationCtrl.text.trim(),
        'experienceYears': _experienceCtrl.text.trim(),
        'salaryAmount': _salaryCtrl.text.trim(),
        'prevExperiences': experiences.isNotEmpty ? jsonEncode(experiences) : null,
        'bankName': _bankNameCtrl.text.trim().isNotEmpty ? _bankNameCtrl.text.trim() : null,
        'bankAccountNo': _bankAccountNoCtrl.text.trim().isNotEmpty ? _bankAccountNoCtrl.text.trim() : null,
        'bankIfsc': _bankIfscCtrl.text.trim().isNotEmpty ? _bankIfscCtrl.text.trim() : null,
        'bankBranch': _bankBranchCtrl.text.trim().isNotEmpty ? _bankBranchCtrl.text.trim() : null,
        'bloodGroup': _bloodGroupCtrl.text.trim().isNotEmpty ? _bloodGroupCtrl.text.trim() : null,
        'aadhaarNo': _aadhaarNoCtrl.text.trim().isNotEmpty ? _aadhaarNoCtrl.text.trim() : null,
        'permanentAddress': _permanentAddressCtrl.text.trim().isNotEmpty ? _permanentAddressCtrl.text.trim() : null,
        'emergencyContactName': _emergencyContactNameCtrl.text.trim().isNotEmpty ? _emergencyContactNameCtrl.text.trim() : null,
        'emergencyContactPhone': _emergencyContactPhoneCtrl.text.trim().isNotEmpty ? _emergencyContactPhoneCtrl.text.trim() : null,
      },
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterFaceScreen(employeeData: employeeData),
      ),
    ).then((success) {
      if (success == true && mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Success', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            content: Text('$_targetRole profile created successfully with face registration.\nDefault password: password123'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              )
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Principal / HM')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _targetRole,
                  decoration: const InputDecoration(labelText: 'Select Role*'),
                  items: const [
                    DropdownMenuItem(value: 'PRINCIPAL', child: Text('Principal')),
                    DropdownMenuItem(value: 'HM', child: Text('Head Master / HM')),
                  ],
                  onChanged: (val) => setState(() => _targetRole = val!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name*', hintText: 'Enter full name'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter full name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email ID*', hintText: 'Enter email ID'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter email ID' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: const InputDecoration(labelText: 'Mobile Number* (10 digits)', hintText: 'Enter 10-digit mobile'),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter mobile number';
                    if (val.length != 10) return 'Mobile number must be exactly 10 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dobCtrl,
                  readOnly: true,
                  onTap: _pickDob,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth*',
                    hintText: 'DD / MM / YYYY',
                    suffixIcon: Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Enter date of birth' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _qualificationCtrl,
                  decoration: const InputDecoration(labelText: 'Qualification*', hintText: 'e.g. M.Ed., M.A. English'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter qualifications' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _experienceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Experience (Years)*', hintText: 'Enter years of experience'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter experience years' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _salaryCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Salary (per Month)*', hintText: 'Enter monthly salary amount'),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter salary amount';
                    if (double.tryParse(val) == null) return 'Enter a valid number';
                    return null;
                  },
                ),

                // Personal Details Section
                const Divider(height: 40, thickness: 1.2),
                Row(
                  children: [
                    const Icon(Icons.person_outline, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Personal Details (Optional)',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _bloodGroupCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Blood Group',
                          hintText: 'e.g. O+, A-',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _aadhaarNoCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Aadhaar Card No',
                          hintText: '12-digit number',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _permanentAddressCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Permanent Address',
                    hintText: 'Enter full permanent address',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emergencyContactNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Emergency Contact Name',
                          hintText: 'e.g. Spouse / Parent',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _emergencyContactPhoneCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Emergency Contact Phone (10 digits)',
                          hintText: '10-digit number',
                        ),
                      ),
                    ),
                  ],
                ),

                // Bank Details Section
                const Divider(height: 40, thickness: 1.2),
                Row(
                  children: [
                    const Icon(Icons.account_balance_outlined, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Bank Account Details (Optional)',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _bankNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Bank Name',
                          hintText: 'e.g. SBI, HDFC',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _bankAccountNoCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Account Number',
                          hintText: 'Bank Account No',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _bankIfscCtrl,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'IFSC Code',
                          hintText: 'e.g. SBIN0001234',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _bankBranchCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Branch Name',
                          hintText: 'Branch location',
                        ),
                      ),
                    ),
                  ],
                ),

                // Previous Experience Details (Dynamic)
                const Divider(height: 40, thickness: 1.2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.work_history_outlined, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Previous Experience(s) (Optional)',
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _experienceControllers.add({
                            'schoolName': TextEditingController(),
                            'fromYear': TextEditingController(),
                            'toYear': TextEditingController(),
                            'subject': TextEditingController(),
                            'reasonForLeaving': TextEditingController(),
                            'salary': TextEditingController(),
                          });
                        });
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(
                        'Add',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_experienceControllers.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Center(
                      child: Text(
                        'No previous experience records added.',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _experienceControllers.length,
                    itemBuilder: (context, index) {
                      final ctrls = _experienceControllers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.15), width: 1),
                        ),
                        color: AppTheme.primaryColor.withOpacity(0.02),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Experience #${index + 1}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () {
                                      setState(() {
                                        final removed = _experienceControllers.removeAt(index);
                                        for (var ctrl in removed.values) {
                                          ctrl.dispose();
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: ctrls['schoolName'],
                                decoration: const InputDecoration(
                                  labelText: 'School Name',
                                  hintText: 'Enter school name',
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: ctrls['fromYear'],
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'From Year',
                                        hintText: 'YYYY',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: ctrls['toYear'],
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'To Year',
                                        hintText: 'YYYY',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: ctrls['subject'],
                                decoration: const InputDecoration(
                                  labelText: 'Subject of Teaching',
                                  hintText: 'e.g. Science / Mathematics',
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: ctrls['reasonForLeaving'],
                                decoration: const InputDecoration(
                                  labelText: 'Reason for Leaving',
                                  hintText: 'Reason for leaving',
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: ctrls['salary'],
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Salary per Month',
                                  hintText: 'Enter monthly salary',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Add Administrator'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

