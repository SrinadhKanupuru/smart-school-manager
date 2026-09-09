import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/school_provider.dart';
import '../../providers/academic_provider.dart';
import '../../core/theme.dart';

class MyTimetableScreen extends StatefulWidget {
  const MyTimetableScreen({super.key});

  @override
  State<MyTimetableScreen> createState() => _MyTimetableScreenState();
}

class _MyTimetableScreenState extends State<MyTimetableScreen> {
  int _activeDay = 1; // 1 = Monday, ..., 6 = Saturday

  final List<String> _days = const [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<SchoolProvider>(context, listen: false).currentUser;
      final teacherProfileId = user?['teacherProfile']?['id'];
      if (teacherProfileId != null) {
        Provider.of<AcademicProvider>(context, listen: false).fetchTimetable(teacherId: teacherProfileId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final academic = Provider.of<AcademicProvider>(context);

    // Filter timetable slots by activeDay
    final activeSlots = academic.timetable.where((slot) => slot['dayOfWeek'] == _activeDay).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Timetable')),
      body: SafeArea(
        child: Column(
          children: [
            // Horizontal scrollable Day Stepper
            Container(
              height: 60,
              color: Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _days.length,
                itemBuilder: (context, index) {
                  final dayIndex = index + 1;
                  final isSelected = _activeDay == dayIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _activeDay = dayIndex),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
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
                          const Icon(Icons.free_breakfast, size: 50, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text('Free Period / No Classes', style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: activeSlots.length,
                      itemBuilder: (context, index) {
                        final slot = activeSlots[index];
                        final className = slot['classSection']?['class']?['name'] ?? '';
                        final sectionName = slot['classSection']?['name'] ?? '';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
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
                                        'Class $className - $sectionName',
                                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${slot['startTime']} - ${slot['endTime']}',
                                        style: GoogleFonts.outfit(color: AppTheme.textSecondaryColor),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Room: ${slot['roomNo']}',
                                        style: GoogleFonts.outfit(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    slot['subject'] ?? '',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
