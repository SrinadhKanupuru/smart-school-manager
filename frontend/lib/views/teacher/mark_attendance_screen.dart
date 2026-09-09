import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/academic_provider.dart';
import '../../core/theme.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  String? _selectedSectionId;
  DateTime _selectedDate = DateTime.now();
  Map<String, String> _studentAttendance = {}; // studentId -> status (PRESENT, ABSENT, LEAVE)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AcademicProvider>(context, listen: false).fetchClasses();
    });
  }

  void _save(AcademicProvider academic) async {
    if (_selectedSectionId == null || _studentAttendance.isEmpty) return;

    final list = _studentAttendance.entries
        .map((e) => {'studentId': e.key, 'status': e.value})
        .toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final success = await academic.markAttendance(
      DateFormat('yyyy-MM-dd').format(_selectedDate),
      list,
    );

    if (mounted) {
      Navigator.pop(context); // Dismiss loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Attendance saved successfully!' : 'Failed to save attendance'),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final academic = Provider.of<AcademicProvider>(context);

    // Get flat list of sections from classes
    final List<Map<String, dynamic>> sections = [];
    for (var cls in academic.classes) {
      final className = cls['name'] ?? '';
      for (var sec in cls['sections'] ?? []) {
        sections.add({
          'id': sec['id'],
          'displayName': '$className - ${sec['name']}',
          'students': sec['students'] ?? [],
        });
      }
    }

    // Load students for active section
    final activeSection = sections.firstWhere(
      (s) => s['id'] == _selectedSectionId,
      orElse: () => {},
    );
    final students = activeSection['students'] as List<dynamic>? ?? [];

    // Prepopulate attendance dictionary if not done
    if (_selectedSectionId != null && _studentAttendance.length != students.length) {
      for (var stud in students) {
        final id = stud['id'];
        if (!_studentAttendance.containsKey(id)) {
          _studentAttendance[id] = 'PRESENT';
        }
      }
    }

    final presentCount = _studentAttendance.values.where((v) => v == 'PRESENT').length;
    final absentCount = _studentAttendance.values.where((v) => v == 'ABSENT').length;
    final leaveCount = _studentAttendance.values.where((v) => v == 'LEAVE').length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mark Attendance', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Dropdown & Date selectors
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedSectionId,
                    hint: const Text('Select Class & Section'),
                    items: sections.map((sec) {
                      return DropdownMenuItem<String>(
                        value: sec['id'],
                        child: Text(sec['displayName']),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedSectionId = val;
                        _studentAttendance.clear();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date: ${DateFormat('dd MMM, yyyy').format(_selectedDate)}',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _selectedDate = picked);
                          }
                        },
                        icon: const Icon(Icons.edit_calendar),
                        label: const Text('Change Date'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (_selectedSectionId != null) ...[
              // Summary counter strip
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                color: AppTheme.backgroundColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCountBadge('PRESENT', presentCount, Colors.green),
                    _buildCountBadge('ABSENT', absentCount, Colors.red),
                    _buildCountBadge('LEAVE', leaveCount, Colors.orange),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final stud = students[index];
                    final id = stud['id'];
                    final status = _studentAttendance[id] ?? 'PRESENT';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.primaryColor.withOpacity(0.08),
                              child: Text(
                                stud['rollNo'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stud['fullName'] ?? '',
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text('Roll No: ${stud['rollNo'] ?? ''}', style: GoogleFonts.outfit(fontSize: 12)),
                                ],
                              ),
                            ),
                            // Toggle Buttons matching mockup
                            Row(
                              children: [
                                _buildToggleButton('P', status == 'PRESENT', Colors.green, () {
                                  setState(() => _studentAttendance[id] = 'PRESENT');
                                }),
                                const SizedBox(width: 6),
                                _buildToggleButton('A', status == 'ABSENT', Colors.red, () {
                                  setState(() => _studentAttendance[id] = 'ABSENT');
                                }),
                                const SizedBox(width: 6),
                                _buildToggleButton('L', status == 'LEAVE', Colors.orange, () {
                                  setState(() => _studentAttendance[id] = 'LEAVE');
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                color: Colors.white,
                child: ElevatedButton(
                  onPressed: () => _save(academic),
                  child: const Text('Save Attendance'),
                ),
              ),
            ] else
              Expanded(
                child: Center(
                  child: Text('Select class and section to load roster', style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountBadge(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondaryColor),
        )
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}
