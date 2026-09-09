import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/school_provider.dart';
import '../../providers/admin_provider.dart';
import '../../core/theme.dart';

class HolidayCalendarScreen extends StatefulWidget {
  const HolidayCalendarScreen({super.key});

  @override
  State<HolidayCalendarScreen> createState() => _HolidayCalendarScreenState();
}

class _HolidayCalendarScreenState extends State<HolidayCalendarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchHolidays();
      Provider.of<AdminProvider>(context, listen: false).fetchEvents();
    });
  }

  bool _isAdmin(String role) {
    return role == 'CORRESPONDENT' || role == 'PRINCIPAL' || role == 'HM';
  }

  void _showAddHolidayDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    DateTime? selectedDate;
    String selectedType = 'HOLIDAY'; // Default

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Schedule School Off',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Title Field
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title / Occasion',
                          hintText: 'e.g. Independence Day, Sunday off',
                          prefixIcon: Icon(Icons.title, color: AppTheme.primaryColor),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Date Picker Field
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: AppTheme.primaryColor,
                                    onPrimary: Colors.white,
                                    onSurface: AppTheme.textPrimaryColor,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setModalState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200, width: 1),
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month, color: AppTheme.primaryColor),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  selectedDate == null
                                      ? 'Select Date'
                                      : DateFormat('dd MMMM yyyy (EEEE)').format(selectedDate!),
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    color: selectedDate == null
                                        ? AppTheme.textSecondaryColor
                                        : AppTheme.textPrimaryColor,
                                    fontWeight: selectedDate == null
                                        ? FontWeight.normal
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Submit Button
                      ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          if (selectedDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select a date')),
                            );
                            return;
                          }

                          final dateIsoStr = selectedDate!.toIso8601String();
                          final success = await Provider.of<AdminProvider>(context, listen: false).addHoliday(
                            title: titleController.text.trim(),
                            date: dateIsoStr,
                            type: selectedType,
                          );

                          if (context.mounted) {
                            Navigator.pop(context);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Holiday scheduled successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to schedule holiday (Date may be duplicated).'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Save Holiday'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String holidayId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Holiday',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to remove "$title" from the calendar?',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await Provider.of<AdminProvider>(context, listen: false).deleteHoliday(holidayId);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Holiday removed successfully.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to remove holiday.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  // Generates weekly off dates dynamically, skipping dates that already have scheduled holidays
  List<dynamic> _generateWeeklyOffs(List<int> offs, List<dynamic> scheduledHolidays) {
    if (offs.isEmpty) return [];
    
    final Set<String> scheduledDates = scheduledHolidays.map((item) {
      final dateStr = item['date'] ?? '';
      if (dateStr.isEmpty) return '';
      return dateStr.toString().split('T')[0];
    }).toSet();
    
    final List<dynamic> weeklyOffs = [];
    final now = DateTime.now();
    // Start from 30 days ago to show some past weekoffs, and project to next year June 30th
    final startDate = now.subtract(const Duration(days: 30));
    final endDate = DateTime(now.year + 1, 6, 30);
    
    final weekdayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    
    DateTime temp = startDate;
    while (temp.isBefore(endDate)) {
      final mappedIndex = temp.weekday == 7 ? 0 : temp.weekday;
      
      if (offs.contains(mappedIndex)) {
        final dateStr = '${temp.year.toString().padLeft(4, '0')}-${temp.month.toString().padLeft(2, '0')}-${temp.day.toString().padLeft(2, '0')}T00:00:00.000Z';
        final compareStr = dateStr.split('T')[0];
        
        if (!scheduledDates.contains(compareStr)) {
          weeklyOffs.add({
            'id': 'weekoff-${temp.year}-${temp.month}-${temp.day}',
            'title': '${weekdayNames[mappedIndex]} Off',
            'date': dateStr,
            'type': 'WEEKOFF',
          });
        }
      }
      temp = temp.add(const Duration(days: 1));
    }
    return weeklyOffs;
  }

  // Groups holidays by Month Year (e.g. "August 2026")
  Map<String, List<dynamic>> _groupHolidays(List<dynamic> list) {
    final Map<String, List<dynamic>> grouped = {};
    for (var item in list) {
      final dateStr = item['date'];
      if (dateStr == null) continue;
      try {
        final date = DateTime.parse(dateStr);
        final key = DateFormat('MMMM yyyy').format(date);
        if (!grouped.containsKey(key)) {
          grouped[key] = [];
        }
        grouped[key]!.add(item);
      } catch (_) {}
    }
    return grouped;
  }

  // Groups events by Month Year (e.g. "August 2026")
  Map<String, List<dynamic>> _groupEvents(List<dynamic> list) {
    final Map<String, List<dynamic>> grouped = {};
    for (var item in list) {
      final dateStr = item['date'];
      if (dateStr == null) continue;
      try {
        final date = DateTime.parse(dateStr);
        final key = DateFormat('MMMM yyyy').format(date);
        if (!grouped.containsKey(key)) {
          grouped[key] = [];
        }
        grouped[key]!.add(item);
      } catch (_) {}
    }
    return grouped;
  }

  void _showAddEventDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDate;
    String selectedType = 'EVENT'; // Default
    String selectedAudience = 'ALL'; // Default

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Schedule School Event',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Event Title*',
                            prefixIcon: Icon(Icons.event, color: AppTheme.primaryColor),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a title' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Description*',
                            prefixIcon: Icon(Icons.description, color: AppTheme.primaryColor),
                          ),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a description' : null,
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now().subtract(const Duration(days: 30)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: AppTheme.primaryColor,
                                      onPrimary: Colors.white,
                                      onSurface: AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setModalState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200, width: 1),
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month, color: AppTheme.primaryColor),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    selectedDate == null
                                        ? 'Select Date*'
                                        : DateFormat('dd MMMM yyyy (EEEE)').format(selectedDate!),
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      color: selectedDate == null ? AppTheme.textSecondaryColor : AppTheme.textPrimaryColor,
                                      fontWeight: selectedDate == null ? FontWeight.normal : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Event Type*',
                            prefixIcon: Icon(Icons.category, color: AppTheme.primaryColor),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'EVENT', child: Text('Standard Event')),
                            DropdownMenuItem(value: 'PROGRAM', child: Text('School Program')),
                            DropdownMenuItem(value: 'PARENT_MEETING', child: Text('Parent Meeting')),
                            DropdownMenuItem(value: 'TEACHER_MEETING', child: Text('Staff Meeting')),
                          ],
                          onChanged: (val) {
                            setModalState(() {
                              selectedType = val!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedAudience,
                          decoration: const InputDecoration(
                            labelText: 'Target Audience*',
                            prefixIcon: Icon(Icons.people, color: AppTheme.primaryColor),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'ALL', child: Text('All (Parents & Staff)')),
                            DropdownMenuItem(value: 'TEACHER', child: Text('Teachers & Staff Only')),
                            DropdownMenuItem(value: 'PARENT', child: Text('Parents Only')),
                          ],
                          onChanged: (val) {
                            setModalState(() {
                              selectedAudience = val!;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            if (selectedDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select an event date')),
                              );
                              return;
                            }

                            final dateIsoStr = selectedDate!.toIso8601String();
                            final success = await Provider.of<AdminProvider>(context, listen: false).createEvent(
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                              date: dateIsoStr,
                              type: selectedType,
                              targetAudience: selectedAudience,
                            );

                            if (context.mounted) {
                              Navigator.pop(context);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Event scheduled successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to schedule event.'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('Schedule Event'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteEvent(BuildContext context, String eventId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancel Event',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to cancel "$title"? This will delete the event.',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await Provider.of<AdminProvider>(context, listen: false).deleteEvent(eventId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Event cancelled successfully.' : 'Failed to cancel event.'),
                    backgroundColor: success ? Colors.green : Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<SchoolProvider>(context).currentUser?['role'] ?? '';
    final isUserAdmin = _isAdmin(userRole);
    final isCorrespondent = userRole == 'CORRESPONDENT';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(
            'School Calendar',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textPrimaryColor),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: AppTheme.textPrimaryColor),
          bottom: TabBar(
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.outfit(),
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textSecondaryColor,
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(text: 'Holidays', icon: Icon(Icons.calendar_today, size: 18)),
              Tab(text: 'School Events', icon: Icon(Icons.event, size: 18)),
            ],
          ),
        ),
        body: Consumer<AdminProvider>(
          builder: (context, provider, child) {
            return TabBarView(
              children: [
                _buildHolidaysTab(provider, isUserAdmin),
                _buildEventsTab(provider, userRole, isCorrespondent),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHolidaysTab(AdminProvider provider, bool isUserAdmin) {
    if (provider.isLoading && provider.holidays.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    final holidaysList = provider.holidays;

    // Get weekly off settings
    final school = Provider.of<SchoolProvider>(context).currentSchool ?? {};
    final weeklyOffsStr = school['weeklyOffs'] ?? '0';
    final List<int> offs = weeklyOffsStr
        .toString()
        .split(',')
        .where((s) => s.trim().isNotEmpty)
        .map((s) => int.parse(s.trim()))
        .toList();

    // Generate dynamic weekly offs
    final generatedOffs = _generateWeeklyOffs(offs, holidaysList);
    
    // Combine both list sets
    final combinedList = [...holidaysList, ...generatedOffs];

    if (combinedList.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: _buildEmptyState(
          icon: Icons.calendar_today_outlined,
          title: 'No holidays scheduled yet',
          subtitle: isUserAdmin
              ? 'Tap the button below to add holidays for this academic year.'
              : 'Holidays scheduled by administrators will appear here.',
        ),
        floatingActionButton: isUserAdmin
            ? FloatingActionButton(
                heroTag: 'add_holiday_empty',
                onPressed: () => _showAddHolidayDialog(context),
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              )
            : null,
      );
    }

    final grouped = _groupHolidays(combinedList);
    // Sort keys (months) chronologically
    final sortedMonthKeys = grouped.keys.toList();
    sortedMonthKeys.sort((a, b) {
      try {
        final dateA = DateFormat('MMMM yyyy').parse(a);
        final dateB = DateFormat('MMMM yyyy').parse(b);
        return dateA.compareTo(dateB);
      } catch (_) {
        return 0;
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchHolidays(),
        color: AppTheme.primaryColor,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: sortedMonthKeys.length,
          itemBuilder: (context, index) {
            final monthKey = sortedMonthKeys[index];
            final monthHolidays = grouped[monthKey] ?? [];

            // Sort holidays in the month by date
            monthHolidays.sort((a, b) {
              try {
                final dateA = DateTime.parse(a['date']);
                final dateB = DateTime.parse(b['date']);
                return dateA.compareTo(dateB);
              } catch (_) {
                return 0;
              }
            });

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
                  child: Text(
                    monthKey,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                ...monthHolidays.map((holiday) {
                  final title = holiday['title'] ?? '';
                  final dateStr = holiday['date'] ?? '';
                  final type = holiday['type'] ?? 'HOLIDAY';
                  final id = holiday['id'] ?? '';

                  DateTime dateVal = DateTime.now();
                  String dayStr = '';
                  String weekdayStr = '';
                  try {
                    dateVal = DateTime.parse(dateStr);
                    dayStr = DateFormat('dd').format(dateVal);
                    weekdayStr = DateFormat('EEEE').format(dateVal);
                  } catch (_) {}

                  final isWeekoff = type == 'WEEKOFF';
                  final typeBadgeColor = isWeekoff ? Colors.blue.shade600 : Colors.deepOrange.shade600;
                  final typeBadgeBg = isWeekoff ? Colors.blue.shade50 : Colors.deepOrange.shade50;
                  final cardSideBorderColor = isWeekoff ? Colors.blue.shade200 : Colors.deepOrange.shade200;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(
                            width: 76,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                              border: Border(
                                right: BorderSide(color: Colors.grey.shade200),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Text(
                                    dayStr,
                                    style: GoogleFonts.outfit(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimaryColor,
                                      height: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    weekdayStr.substring(0, 3).toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            width: 4,
                            color: cardSideBorderColor,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    title,
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: typeBadgeBg,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isWeekoff ? 'Weekly Off' : 'School Holiday',
                                      style: GoogleFonts.outfit(
                                        color: typeBadgeColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isUserAdmin && !id.toString().startsWith('weekoff-'))
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                              onPressed: () => _confirmDelete(context, id, title),
                            ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          },
        ),
      ),
      floatingActionButton: isUserAdmin
          ? FloatingActionButton(
              heroTag: 'add_holiday_list',
              onPressed: () => _showAddHolidayDialog(context),
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,
    );
  }

  Widget _buildEventsTab(AdminProvider provider, String userRole, bool isCorrespondent) {
    if (provider.isLoading && provider.events.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    final eventsList = provider.events;

    if (eventsList.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: _buildEmptyState(
          icon: Icons.event_available_outlined,
          title: 'No events scheduled yet',
          subtitle: isCorrespondent
              ? 'Tap the button below to schedule an event for parents & staff.'
              : 'School events scheduled by the correspondent will appear here.',
        ),
        floatingActionButton: isCorrespondent
            ? FloatingActionButton(
                heroTag: 'add_event_empty',
                onPressed: () => _showAddEventDialog(context),
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              )
            : null,
      );
    }

    final grouped = _groupEvents(eventsList);
    final sortedMonthKeys = grouped.keys.toList();
    sortedMonthKeys.sort((a, b) {
      try {
        final dateA = DateFormat('MMMM yyyy').parse(a);
        final dateB = DateFormat('MMMM yyyy').parse(b);
        return dateA.compareTo(dateB);
      } catch (_) {
        return 0;
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchEvents(),
        color: AppTheme.primaryColor,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: sortedMonthKeys.length,
          itemBuilder: (context, index) {
            final monthKey = sortedMonthKeys[index];
            final monthEvents = grouped[monthKey] ?? [];

            monthEvents.sort((a, b) {
              try {
                final dateA = DateTime.parse(a['date']);
                final dateB = DateTime.parse(b['date']);
                return dateA.compareTo(dateB);
              } catch (_) {
                return 0;
              }
            });

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
                  child: Text(
                    monthKey,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                ...monthEvents.map((event) {
                  final title = event['title'] ?? '';
                  final desc = event['description'] ?? '';
                  final dateStr = event['date'] ?? '';
                  final type = event['type'] ?? 'EVENT';
                  final target = event['targetAudience'] ?? 'ALL';
                  final id = event['id'] ?? '';

                  DateTime dateVal = DateTime.now();
                  String dayStr = '';
                  String weekdayStr = '';
                  try {
                    dateVal = DateTime.parse(dateStr);
                    dayStr = DateFormat('dd').format(dateVal);
                    weekdayStr = DateFormat('EEEE').format(dateVal);
                  } catch (_) {}

                  Color typeColor = Colors.purple.shade600;
                  Color typeBg = Colors.purple.shade50;
                  Color sideColor = Colors.purple.shade200;
                  String displayTypeName = 'School Event';

                  if (type == 'PROGRAM') {
                    typeColor = Colors.teal.shade600;
                    typeBg = Colors.teal.shade50;
                    sideColor = Colors.teal.shade200;
                    displayTypeName = 'Program';
                  } else if (type == 'PARENT_MEETING') {
                    typeColor = Colors.pink.shade600;
                    typeBg = Colors.pink.shade50;
                    sideColor = Colors.pink.shade200;
                    displayTypeName = 'Parent Meeting';
                  } else if (type == 'TEACHER_MEETING') {
                    typeColor = Colors.amber.shade800;
                    typeBg = Colors.amber.shade50;
                    sideColor = Colors.amber.shade200;
                    displayTypeName = 'Staff Meeting';
                  }

                  String targetLabel = 'All (Parents & Staff)';
                  if (target == 'TEACHER') {
                    targetLabel = 'Staff Only';
                  } else if (target == 'PARENT') {
                    targetLabel = 'Parents Only';
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(
                            width: 76,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                              border: Border(
                                right: BorderSide(color: Colors.grey.shade200),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dayStr,
                                  style: GoogleFonts.outfit(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimaryColor,
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  weekdayStr.substring(0, 3).toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 4,
                            color: sideColor,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    title,
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    desc,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: typeBg,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          displayTypeName,
                                          style: GoogleFonts.outfit(
                                            color: typeColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          targetLabel,
                                          style: GoogleFonts.outfit(
                                            color: Colors.grey.shade700,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isCorrespondent)
                            IconButton(
                              icon: const Icon(Icons.cancel_presentation_outlined, color: Colors.redAccent, size: 22),
                              onPressed: () => _confirmDeleteEvent(context, id, title),
                            ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          },
        ),
      ),
      floatingActionButton: isCorrespondent
          ? FloatingActionButton(
              heroTag: 'add_event_list',
              onPressed: () => _showAddEventDialog(context),
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,
    );
  }

  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
