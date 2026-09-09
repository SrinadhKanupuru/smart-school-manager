import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class SubmitComplaintScreen extends StatefulWidget {
  const SubmitComplaintScreen({super.key});

  @override
  State<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  String _category = 'Teacher Related';

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit(AdminProvider admin) async {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final success = await admin.raiseComplaint(
      category: _category,
      description: _descCtrl.text.trim(),
    );

    if (mounted) {
      Navigator.pop(context); // Dismiss loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Grievance submitted successfully!' : 'Submission failed'),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('File Complaint')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Grievance Category*'),
                  items: const [
                    DropdownMenuItem(value: 'Teacher Related', child: Text('Teacher Related')),
                    DropdownMenuItem(value: 'Van Maintenance', child: Text('Van / Transport Upkeep')),
                    DropdownMenuItem(value: 'Facility & Cleaning', child: Text('School Facility / Cleaning')),
                    DropdownMenuItem(value: 'Other Concerns', child: Text('Other Concerns')),
                  ],
                  onChanged: (val) => setState(() => _category = val!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Description*',
                    hintText: 'Enter detailed information about the issue...',
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Please describe the concern' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _submit(admin),
                  child: const Text('Submit Complaint'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
