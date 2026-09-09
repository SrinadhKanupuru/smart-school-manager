import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/school_provider.dart';

class RegisterSchoolScreen extends StatefulWidget {
  const RegisterSchoolScreen({super.key});

  @override
  State<RegisterSchoolScreen> createState() => _RegisterSchoolScreenState();
}

class _RegisterSchoolScreenState extends State<RegisterSchoolScreen> {
  int _currentStep = 0;
  final _formKeySchool = GlobalKey<FormState>();
  final _formKeyCorrespondent = GlobalKey<FormState>();

  // School controllers
  final _schoolNameCtrl = TextEditingController();
  final _schoolCodeCtrl = TextEditingController();
  String _schoolType = 'High School';
  String _boardAffiliation = 'CBSE';
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'India');
  final _pinCodeCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();

  // Correspondent controllers
  final _corrNameCtrl = TextEditingController();
  final _corrEmailCtrl = TextEditingController();
  final _corrPasswordCtrl = TextEditingController();
  final _corrPhoneCtrl = TextEditingController();

  @override
  void dispose() {
    _schoolNameCtrl.dispose();
    _schoolCodeCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _pinCodeCtrl.dispose();
    _contactCtrl.dispose();
    _corrNameCtrl.dispose();
    _corrEmailCtrl.dispose();
    _corrPasswordCtrl.dispose();
    _corrPhoneCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    if (schoolProvider.isAuthenticated) {
      if (_formKeySchool.currentState!.validate()) {
        _submitRegistration();
      }
    } else {
      if (_currentStep == 0) {
        if (_formKeySchool.currentState!.validate()) {
          setState(() => _currentStep = 1);
        }
      } else {
        if (_formKeyCorrespondent.currentState!.validate()) {
          _submitRegistration();
        }
      }
    }
  }

  void _prevStep() {
    if (_currentStep == 1) {
      setState(() => _currentStep = 0);
    }
  }

  void _submitRegistration() async {
    final schoolDetails = {
      'name': _schoolNameCtrl.text.trim(),
      'code': _schoolCodeCtrl.text.trim(),
      'type': _schoolType,
      'board': _boardAffiliation,
      'address': _addressCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'state': _stateCtrl.text.trim(),
      'country': _countryCtrl.text.trim(),
      'pinCode': _pinCodeCtrl.text.trim(),
      'contactNumber': _contactCtrl.text.trim(),
    };

    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    if (schoolProvider.isAuthenticated) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final success = await schoolProvider.createSchool(schoolDetails);

      if (mounted) {
        Navigator.pop(context); // Pop loader
        if (success) {
          Navigator.pushReplacementNamed(context, '/school-added-success');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(schoolProvider.errorMessage ?? 'Failed to register school'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } else {
      final correspondentDetails = {
        'fullName': _corrNameCtrl.text.trim(),
        'email': _corrEmailCtrl.text.trim(),
        'password': _corrPasswordCtrl.text,
        'phoneNumber': _corrPhoneCtrl.text.trim(),
      };

      // Route to OTP Screen first to match screenshots!
      Navigator.pushNamed(context, '/otp-verification', arguments: {
        'schoolDetails': schoolDetails,
        'correspondentDetails': correspondentDetails,
        'phoneNumber': _corrPhoneCtrl.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Register a School',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Custom progress indicator matching screenshots
            if (!provider.isAuthenticated)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: Colors.white,
                child: Row(
                  children: [
                    _buildStepIndicator(0, 'School Details'),
                    const Expanded(
                      child: Divider(color: AppTheme.primaryColor, thickness: 2, indent: 8, endIndent: 8),
                    ),
                    _buildStepIndicator(1, 'Correspondent Details'),
                  ],
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: (provider.isAuthenticated || _currentStep == 0)
                    ? _buildSchoolForm()
                    : _buildCorrespondentForm(),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (provider.isAuthenticated) {
                          Navigator.pop(context);
                        } else {
                          if (_currentStep == 0) {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          } else {
                            _prevStep();
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Back',
                        style: GoogleFonts.outfit(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        provider.isAuthenticated
                            ? 'Register School'
                            : (_currentStep == 0 ? 'Continue' : 'Verify Mobile (OTP)'),
                      ),
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

  Widget _buildStepIndicator(int stepIndex, String title) {
    final isActive = _currentStep == stepIndex;
    final isDone = _currentStep > stepIndex;

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: isDone
              ? Colors.green
              : (isActive ? AppTheme.primaryColor : Colors.grey.shade300),
          child: isDone
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : Text(
                  '${stepIndex + 1}',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSchoolForm() {
    return Form(
      key: _formKeySchool,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _schoolNameCtrl,
            decoration: const InputDecoration(
              labelText: 'School Name*',
              hintText: 'Enter school name',
            ),
            validator: (val) => val == null || val.isEmpty ? 'Enter school name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _schoolCodeCtrl,
            decoration: const InputDecoration(
              labelText: 'School Code*',
              hintText: 'e.g. SIS12345',
            ),
            validator: (val) => val == null || val.isEmpty ? 'Enter unique school code' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _schoolType,
            decoration: const InputDecoration(labelText: 'School Type*'),
            items: ['Primary', 'Middle School', 'High School']
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (val) => setState(() => _schoolType = val!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _boardAffiliation,
            decoration: const InputDecoration(labelText: 'Board Affiliation*'),
            items: ['CBSE', 'ICSE', 'State Board']
                .map((board) => DropdownMenuItem(value: board, child: Text(board)))
                .toList(),
            onChanged: (val) => setState(() => _boardAffiliation = val!),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressCtrl,
            decoration: const InputDecoration(
              labelText: 'Address*',
              hintText: 'Enter school address',
            ),
            validator: (val) => val == null || val.isEmpty ? 'Enter address' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityCtrl,
                  decoration: const InputDecoration(labelText: 'City*'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter city' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _stateCtrl,
                  decoration: const InputDecoration(labelText: 'State*'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter state' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _countryCtrl,
                  decoration: const InputDecoration(labelText: 'Country*'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter country' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _pinCodeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Pin Code*'),
                  validator: (val) => val == null || val.isEmpty ? 'Enter pin' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _contactCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Contact Number*',
              hintText: 'School contact phone',
            ),
            validator: (val) => val == null || val.isEmpty ? 'Enter contact number' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCorrespondentForm() {
    return Form(
      key: _formKeyCorrespondent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _corrNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Correspondent Full Name*',
              hintText: 'Enter your full name',
            ),
            validator: (val) => val == null || val.isEmpty ? 'Enter name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _corrEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email ID*',
              hintText: 'Enter your email ID',
            ),
            validator: (val) => val == null || val.isEmpty ? 'Enter email' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _corrPasswordCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password*',
              hintText: 'Enter strong password',
            ),
            validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 characters' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _corrPhoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Mobile Number*',
              hintText: 'Enter 10-digit mobile number',
            ),
            validator: (val) => val == null || val.isEmpty ? 'Enter mobile number' : null,
          ),
        ],
      ),
    );
  }
}
