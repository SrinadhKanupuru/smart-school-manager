import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/academic_provider.dart';
import '../../providers/school_provider.dart';
import '../../core/theme.dart';

class TimetableManagementScreen extends StatefulWidget {
  const TimetableManagementScreen({super.key});

  @override
  State<TimetableManagementScreen> createState() => _TimetableManagementScreenState();
}

class _TimetableManagementScreenState extends State<TimetableManagementScreen> {
  String? _selectedSectionId;
  int _activeDay = 1; // 1 = Monday, ..., 6 = Saturday

  final List<String> _days = const [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AcademicProvider>(context, listen: false).fetchClasses();
      Provider.of<SchoolProvider>(context, listen: false).fetchUsers(role: 'TEACHER');
    });
  }

  void _loadTimetable() {
    if (_selectedSectionId != null) {
      Provider.of<AcademicProvider>(context, listen: false)
          .fetchTimetable(classSectionId: _selectedSectionId);
    }
  }

  void _showSlotDialog({Map<String, dynamic>? slot}) {
    if (_selectedSectionId == null) return;

    final academic = Provider.of<AcademicProvider>(context, listen: false);
    final school = Provider.of<SchoolProvider>(context, listen: false);

    final isEdit = slot != null;
    final subjectCtrl = TextEditingController(text: isEdit ? slot['subject'] : '');
    final roomCtrl = TextEditingController(text: isEdit ? slot['roomNo'] : '');
    
    // Convert time e.g., "08:30 AM" or "09:30 AM"
    final startCtrl = TextEditingController(text: isEdit ? slot['startTime'] : '08:30 AM');
    final endCtrl = TextEditingController(text: isEdit ? slot['endTime'] : '09:30 AM');

    String? chosenTeacherId = isEdit ? slot['teacherId'] : null;
    int chosenDay = isEdit ? slot['dayOfWeek'] : _activeDay;

    // Filter teachers who have profile
    final teachers = school.users.where((u) => u['teacherProfile'] != null).toList();
    if (!isEdit && teachers.isNotEmpty) {
      chosenTeacherId = teachers.first['teacherProfile']['id'];
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              isEdit ? 'Edit Timetable Slot' : 'Add Timetable Slot',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: chosenDay,
                    decoration: const InputDecoration(labelText: 'Day of Week'),
                    items: List.generate(_days.length, (i) {
                      return DropdownMenuItem(value: i + 1, child: Text(_days[i]));
                    }),
                    onChanged: (val) {
                      if (val != null) setStateDialog(() => chosenDay = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: chosenTeacherId,
                    decoration: const InputDecoration(labelText: 'Assigned Teacher'),
                    items: teachers.map((t) {
                      final profileId = t['teacherProfile']['id'] as String;
                      return DropdownMenuItem(
                        value: profileId,
                        child: Text(t['fullName'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setStateDialog(() => chosenTeacherId = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: subjectCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Subject*',
                      hintText: 'e.g. Mathematics, English',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: startCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Start Time*',
                            hintText: 'e.g. 08:30 AM',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: endCtrl,
                          decoration: const InputDecoration(
                            labelText: 'End Time*',
                            hintText: 'e.g. 09:30 AM',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: roomCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Room No*',
                      hintText: 'e.g. Room 102, Lab A',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (subjectCtrl.text.trim().isEmpty ||
                      startCtrl.text.trim().isEmpty ||
                      endCtrl.text.trim().isEmpty ||
                      roomCtrl.text.trim().isEmpty ||
                      chosenTeacherId == null) {
                    return;
                  }

                  Navigator.pop(ctx);
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => const Center(child: CircularProgressIndicator()),
                  );

                  String? error;
                  if (isEdit) {
                    error = await academic.updateTimetableSlot(
                      id: slot['id'],
                      classSectionId: _selectedSectionId!,
                      dayOfWeek: chosenDay,
                      startTime: startCtrl.text.trim(),
                      endTime: endCtrl.text.trim(),
                      subject: subjectCtrl.text.trim(),
                      teacherId: chosenTeacherId!,
                      roomNo: roomCtrl.text.trim(),
                    );
                  } else {
                    final success = await academic.addTimetableSlot(
                      classSectionId: _selectedSectionId!,
                      dayOfWeek: chosenDay,
                      startTime: startCtrl.text.trim(),
                      endTime: endCtrl.text.trim(),
                      subject: subjectCtrl.text.trim(),
                      teacherId: chosenTeacherId!,
                      roomNo: roomCtrl.text.trim(),
                    );
                    if (!success) {
                      error = 'Failed to register timetable slot (check server logs/conflict)';
                    }
                  }

                  if (mounted) {
                    Navigator.pop(context); // dismiss loader
                    _loadTimetable(); // refresh
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error == null
                            ? (isEdit ? 'Slot updated successfully!' : 'Slot added successfully!')
                            : 'Error: $error'),
                        backgroundColor: error == null ? Colors.green : Colors.redAccent,
                      ),
                    );
                  }
                },
                child: Text(isEdit ? 'Save Changes' : 'Add Slot'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteSlot(AcademicProvider academic, String slotId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Slot', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to remove this timetable slot?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      final success = await academic.deleteTimetableSlot(slotId);

      if (mounted) {
        Navigator.pop(context); // Dismiss loading
        _loadTimetable();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Slot deleted successfully!' : 'Failed to delete slot'),
            backgroundColor: success ? Colors.green : Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final academic = Provider.of<AcademicProvider>(context);

    // Flatten classes and sections for dropdown
    final List<Map<String, dynamic>> sectionItems = [];
    for (var cls in academic.classes) {
      final className = cls['name'] ?? '';
      for (var sec in cls['sections'] ?? []) {
        sectionItems.add({
          'id': sec['id'],
          'displayName': '$className - Section ${sec['name']}',
        });
      }
    }

    final activeSlots = academic.timetable.where((slot) => slot['dayOfWeek'] == _activeDay).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Timetable Manager',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_selectedSectionId != null)
            IconButton(
              icon: const Icon(Icons.add, color: AppTheme.primaryColor),
              onPressed: () => _showSlotDialog(),
              tooltip: 'Add Slot',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<String>(
                value: _selectedSectionId,
                decoration: const InputDecoration(
                  labelText: 'Select Class & Section to Manage',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: sectionItems.map((item) {
                  return DropdownMenuItem<String>(
                    value: item['id'],
                    child: Text(item['displayName']),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedSectionId = val;
                  });
                  _loadTimetable();
                },
              ),
            ),

            if (_selectedSectionId != null) ...[
              // Day Stepper selector
              Container(
                height: 55,
                color: Colors.white,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  itemCount: _days.length,
                  itemBuilder: (context, index) {
                    final dayIndex = index + 1;
                    final isSelected = _activeDay == dayIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _activeDay = dayIndex),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Text(
                            _days[index].substring(0, 3),
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Expanded(
                child: activeSlots.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.free_breakfast_outlined, size: 50, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              'Free / No Scheduled Classes',
                              style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () => _showSlotDialog(),
                              icon: const Icon(Icons.add),
                              label: const Text('Add First Slot'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: activeSlots.length,
                        itemBuilder: (context, index) {
                          final slot = activeSlots[index];
                          final teacherName = slot['teacher']?['user']?['fullName'] ?? 'No teacher';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey.shade100),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.alarm, color: AppTheme.primaryColor),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          slot['subject'] ?? 'Subject',
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${slot['startTime']} - ${slot['endTime']}',
                                          style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor, fontSize: 13),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Teacher: $teacherName • Room: ${slot['roomNo']}',
                                          style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                                    onPressed: () => _showSlotDialog(slot: slot),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () => _deleteSlot(academic, slot['id']),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              )
            ] else
              Expanded(
                child: Center(
                  child: Text(
                    'Select a class and section above to manage timetable slots',
                    style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
