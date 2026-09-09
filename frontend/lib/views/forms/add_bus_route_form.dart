import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/academic_provider.dart';
import '../../providers/admin_provider.dart';
import '../../core/theme.dart';

class AddBusRouteForm extends StatefulWidget {
  const AddBusRouteForm({super.key});

  @override
  State<AddBusRouteForm> createState() => _AddBusRouteFormState();
}

class _AddBusRouteFormState extends State<AddBusRouteForm> {
  final _formKey = GlobalKey<FormState>();
  final _routeNameCtrl = TextEditingController();
  final _busNoCtrl = TextEditingController();
  final _driverNameCtrl = TextEditingController();
  final _driverContactCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  final List<Map<String, TextEditingController>> _stopsList = [];
  final List<String> _selectedStudentIds = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AcademicProvider>(context, listen: false).fetchStudents();
    });
    // Start with 1 stop field
    _addNewStopField();
  }

  @override
  void dispose() {
    _routeNameCtrl.dispose();
    _busNoCtrl.dispose();
    _driverNameCtrl.dispose();
    _driverContactCtrl.dispose();
    _searchCtrl.dispose();
    for (var stop in _stopsList) {
      stop['name']!.dispose();
      stop['time']!.dispose();
    }
    super.dispose();
  }

  void _addNewStopField() {
    setState(() {
      _stopsList.add({
        'name': TextEditingController(),
        'time': TextEditingController(),
      });
    });
  }

  void _removeStopField(int index) {
    if (_stopsList.length <= 1) return;
    setState(() {
      final stop = _stopsList.removeAt(index);
      stop['name']!.dispose();
      stop['time']!.dispose();
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final admin = Provider.of<AdminProvider>(context, listen: false);

    // Build stops list payload
    final List<Map<String, dynamic>> stopsPayload = [];
    for (int i = 0; i < _stopsList.length; i++) {
      final name = _stopsList[i]['name']!.text.trim();
      final time = _stopsList[i]['time']!.text.trim();
      if (name.isNotEmpty && time.isNotEmpty) {
        stopsPayload.add({
          'stopName': name,
          'arrivalTime': time,
          'sequenceNo': i + 1,
        });
      }
    }

    if (stopsPayload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one stop with details.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final success = await admin.createBusRoute(
      routeName: _routeNameCtrl.text.trim(),
      busNo: _busNoCtrl.text.trim(),
      driverName: _driverNameCtrl.text.trim(),
      driverContact: _driverContactCtrl.text.trim(),
      stops: stopsPayload,
      studentIds: _selectedStudentIds,
    );

    if (mounted) {
      Navigator.pop(context); // Dismiss loading
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bus Route "${_routeNameCtrl.text.trim()}" created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Go back
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create route. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final academic = Provider.of<AcademicProvider>(context);
    final admin = Provider.of<AdminProvider>(context);

    // Filter students
    final filteredStudents = academic.students.where((student) {
      final name = (student['fullName'] ?? '').toString().toLowerCase();
      final rollNo = (student['rollNo'] ?? '').toString().toLowerCase();
      final className = (student['classSection']?['class']?['name'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || rollNo.contains(query) || className.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Bus Route',
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
                  'Route Details',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _routeNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Route Name*',
                    hintText: 'e.g. Route 3 (North City)',
                    prefixIcon: Icon(Icons.directions_bus),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Enter route name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _busNoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Bus Plate Number*',
                    hintText: 'e.g. UP32 AB 1234',
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Enter bus plate number' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _driverNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Driver Name*',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Enter driver name' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _driverContactCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Driver Mobile*',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Enter driver mobile' : null,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Villages / Stops Sequence*',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                    TextButton.icon(
                      onPressed: _addNewStopField,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Stop'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _stopsList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _stopsList[index]['name'],
                              decoration: const InputDecoration(
                                labelText: 'Stop / Village Name',
                                hintText: 'e.g. Sector 5',
                              ),
                              validator: (val) => val == null || val.isEmpty ? 'Enter stop' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _stopsList[index]['time'],
                              decoration: const InputDecoration(
                                labelText: 'Arrival Time',
                                hintText: 'e.g. 07:15 AM',
                              ),
                              validator: (val) => val == null || val.isEmpty ? 'Enter time' : null,
                            ),
                          ),
                          if (_stopsList.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _removeStopField(index),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 40),
                Text(
                  'Assign Students to this Route',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 12),
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
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: academic.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredStudents.isEmpty
                          ? Center(
                              child: Text(
                                _searchQuery.isEmpty ? 'No students found.' : 'No matching students.',
                                style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
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
                                  title: Text(student['fullName'] ?? '', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                                  subtitle: Text('$className - Sec $sectionName | Roll: $rollNo', style: GoogleFonts.outfit(fontSize: 12)),
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
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text('Save Bus Route'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
