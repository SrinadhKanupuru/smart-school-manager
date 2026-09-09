import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/school_provider.dart';
import '../../providers/admin_provider.dart';
import '../../core/theme.dart';
import 'map_picker_screen.dart';
import 'leave_types_screen.dart';

class SchoolSettingsScreen extends StatefulWidget {
  const SchoolSettingsScreen({super.key});

  @override
  State<SchoolSettingsScreen> createState() => _SchoolSettingsScreenState();
}

class _SchoolSettingsScreenState extends State<SchoolSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameCtrl;
  late TextEditingController _typeCtrl;
  late TextEditingController _boardCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _pinCodeCtrl;
  late TextEditingController _contactCtrl;
  late TextEditingController _latCtrl;
  late TextEditingController _lngCtrl;
  late TextEditingController _radiusCtrl;
  late TextEditingController _halfDayHrsCtrl;
  late TextEditingController _fullDayHrsCtrl;
  late TextEditingController _rectificationLimitCtrl;

  bool _isLocating = false;
  List<int> _selectedWeeklyOffs = [];
  bool _autoCheckoutEnabled = false;
  String _autoCheckoutTime = '18:00';

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SchoolProvider>(context, listen: false);
    final school = provider.currentSchool ?? {};

    _nameCtrl = TextEditingController(text: school['name'] ?? '');
    _typeCtrl = TextEditingController(text: school['type'] ?? '');
    _boardCtrl = TextEditingController(text: school['board'] ?? '');
    _addressCtrl = TextEditingController(text: school['address'] ?? '');
    _cityCtrl = TextEditingController(text: school['city'] ?? '');
    _stateCtrl = TextEditingController(text: school['state'] ?? '');
    _countryCtrl = TextEditingController(text: school['country'] ?? '');
    _pinCodeCtrl = TextEditingController(text: school['pinCode'] ?? '');
    _contactCtrl = TextEditingController(text: school['contactNumber'] ?? '');
    
    _latCtrl = TextEditingController(
      text: school['latitude'] != null ? school['latitude'].toString() : '',
    );
    _lngCtrl = TextEditingController(
      text: school['longitude'] != null ? school['longitude'].toString() : '',
    );
    _radiusCtrl = TextEditingController(
      text: school['geofenceRadius'] != null ? school['geofenceRadius'].toString() : '100',
    );
    _halfDayHrsCtrl = TextEditingController(
      text: school['halfDayThreshold'] != null ? school['halfDayThreshold'].toString() : '4.0',
    );
    _fullDayHrsCtrl = TextEditingController(
      text: school['fullDayThreshold'] != null ? school['fullDayThreshold'].toString() : '8.0',
    );
    _rectificationLimitCtrl = TextEditingController(
      text: school['rectificationLimit'] != null ? school['rectificationLimit'].toString() : '3',
    );
    
    final weeklyOffsStr = school['weeklyOffs'] ?? '0';
    _selectedWeeklyOffs = weeklyOffsStr
        .toString()
        .split(',')
        .where((s) => s.trim().isNotEmpty)
        .map((s) => int.parse(s.trim()))
        .toList();

    _autoCheckoutEnabled = school['autoCheckoutEnabled'] ?? false;
    _autoCheckoutTime = school['autoCheckoutTime'] ?? '18:00';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchLeaveTypes();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _typeCtrl.dispose();
    _boardCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _pinCodeCtrl.dispose();
    _contactCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _radiusCtrl.dispose();
    _halfDayHrsCtrl.dispose();
    _fullDayHrsCtrl.dispose();
    _rectificationLimitCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickOnMap() async {
    double? initialLat = double.tryParse(_latCtrl.text);
    double? initialLng = double.tryParse(_lngCtrl.text);

    final LatLng? selectedLatLng = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(
          initialLatitude: initialLat,
          initialLongitude: initialLng,
        ),
      ),
    );

    if (selectedLatLng != null) {
      setState(() {
        _latCtrl.text = selectedLatLng.latitude.toString();
        _lngCtrl.text = selectedLatLng.longitude.toString();
      });
      _showSnackBar('Location coordinates selected!', Colors.green);
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLocating = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permission denied.', Colors.redAccent);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permissions are permanently denied. Please enable them in settings.', Colors.redAccent);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latCtrl.text = position.latitude.toString();
        _lngCtrl.text = position.longitude.toString();
      });
      _showSnackBar('Current location coordinates set!', Colors.green);
    } catch (e) {
      _showSnackBar('Error getting location: $e', Colors.redAccent);
    } finally {
      setState(() {
        _isLocating = false;
      });
    }
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.outfit()),
        backgroundColor: bgColor,
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<SchoolProvider>(context, listen: false);
    final schoolId = provider.currentSchool?['id'];
    if (schoolId == null) {
      _showSnackBar('No active school context found.', Colors.redAccent);
      return;
    }

    final double? radius = double.tryParse(_radiusCtrl.text);
    if (radius != null && radius <= 0) {
      _showSnackBar('Geofencing radius must be greater than 0 meters.', Colors.redAccent);
      return;
    }

    final data = {
      'name': _nameCtrl.text.trim(),
      'type': _typeCtrl.text.trim(),
      'board': _boardCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
      'state': _stateCtrl.text.trim(),
      'country': _countryCtrl.text.trim(),
      'pinCode': _pinCodeCtrl.text.trim(),
      'contactNumber': _contactCtrl.text.trim(),
      'latitude': _latCtrl.text.isNotEmpty ? double.tryParse(_latCtrl.text.trim()) : null,
      'longitude': _lngCtrl.text.isNotEmpty ? double.tryParse(_lngCtrl.text.trim()) : null,
      'geofenceRadius': radius ?? 100.0,
      'weeklyOffs': _selectedWeeklyOffs.join(','),
      'halfDayThreshold': double.tryParse(_halfDayHrsCtrl.text.trim()) ?? 4.0,
      'fullDayThreshold': double.tryParse(_fullDayHrsCtrl.text.trim()) ?? 8.0,
      'casualLeaveLimit': 12,
      'sickLeaveLimit': 10,
      'rectificationLimit': int.tryParse(_rectificationLimitCtrl.text.trim()) ?? 3,
      'autoCheckoutEnabled': _autoCheckoutEnabled,
      'autoCheckoutTime': _autoCheckoutTime,
    };

    final success = await provider.updateSchool(schoolId, data);
    if (mounted) {
      if (success) {
        _showSnackBar('School settings updated successfully!', Colors.green);
        Navigator.pop(context);
      } else {
        _showSnackBar(provider.errorMessage ?? 'Failed to update school settings.', Colors.redAccent);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchoolProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'School Settings',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Geofencing Card
                      _buildSectionHeader('Geofencing Configuration', Icons.pin_drop),
                      Card(
                        margin: const EdgeInsets.only(bottom: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Set school boundaries for staff face attendance verification. The system will restrict attendance logging to this perimeter.',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _latCtrl,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(
                                        labelText: 'Latitude',
                                        prefixIcon: Icon(Icons.compass_calibration_outlined, size: 20),
                                        hintText: 'e.g. 12.9715',
                                      ),
                                      validator: (val) {
                                        if (val != null && val.isNotEmpty) {
                                          if (double.tryParse(val) == null) {
                                            return 'Invalid';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _lngCtrl,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(
                                        labelText: 'Longitude',
                                        prefixIcon: Icon(Icons.compass_calibration_outlined, size: 20),
                                        hintText: 'e.g. 77.5945',
                                      ),
                                      validator: (val) {
                                        if (val != null && val.isNotEmpty) {
                                          if (double.tryParse(val) == null) {
                                            return 'Invalid';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _radiusCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Geofence Radius (meters)',
                                  prefixIcon: Icon(Icons.radar_outlined, size: 20),
                                  hintText: 'Default 100',
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Geofence radius is required';
                                  }
                                  if (double.tryParse(val) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _pickOnMap,
                                      icon: const Icon(Icons.map, size: 20),
                                      label: const Text('Pick on Map'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        side: const BorderSide(color: AppTheme.primaryColor),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _isLocating ? null : _useCurrentLocation,
                                      icon: _isLocating
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Icon(Icons.my_location, size: 20),
                                      label: Text(_isLocating ? 'Locating...' : 'Use Current'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        side: const BorderSide(color: AppTheme.primaryColor),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Weekly Off Toggles Section
                      _buildSectionHeader('Weekly Off Configuration', Icons.calendar_month_outlined),
                      Card(
                        margin: const EdgeInsets.only(bottom: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Select the regular weekly off days for your school. Staff face attendance will be automatically blocked on these days.',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(7, (index) {
                                    final weekdayShort = ['S', 'M', 'T', 'W', 'T', 'F', 'S'][index];
                                    final weekdayName = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][index];
                                    final isSelected = _selectedWeeklyOffs.contains(index);
                                    
                                    return Tooltip(
                                      message: weekdayName,
                                      child: ChoiceChip(
                                        visualDensity: VisualDensity.compact,
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                                        label: Text(
                                          weekdayShort,
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                                          ),
                                        ),
                                        selected: isSelected,
                                        selectedColor: AppTheme.primaryColor,
                                        backgroundColor: Colors.white,
                                        showCheckmark: false,
                                        onSelected: (selected) {
                                          setState(() {
                                            if (selected) {
                                              _selectedWeeklyOffs.add(index);
                                            } else {
                                              _selectedWeeklyOffs.remove(index);
                                            }
                                          });
                                        },
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Attendance Rules & Leave Policies Card
                      _buildSectionHeader('Attendance Rules & Leave Policies', Icons.rule_folder_outlined),
                      Card(
                        margin: const EdgeInsets.only(bottom: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Configure parameters to automatically mark half days/absences and determine leave balance LOP (Loss of Pay) limits.',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _halfDayHrsCtrl,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(
                                        labelText: 'Half Day Threshold (hrs)*',
                                        prefixIcon: Icon(Icons.hourglass_empty_outlined, size: 20),
                                      ),
                                      validator: (val) {
                                        if (val == null || val.isEmpty) return 'Required';
                                        if (double.tryParse(val) == null) return 'Invalid';
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _fullDayHrsCtrl,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(
                                        labelText: 'Full Day Threshold (hrs)*',
                                        prefixIcon: Icon(Icons.hourglass_full_outlined, size: 20),
                                      ),
                                      validator: (val) {
                                        if (val == null || val.isEmpty) return 'Required';
                                        if (double.tryParse(val) == null) return 'Invalid';
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _rectificationLimitCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Monthly Rectification Limit*',
                                  prefixIcon: Icon(Icons.history_toggle_off, size: 20),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Required';
                                  if (int.tryParse(val) == null) return 'Must be a number';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              Consumer<AdminProvider>(
                                builder: (context, adminProv, child) {
                                  final lTypes = adminProv.leaveTypes;
                                  if (lTypes.isEmpty) {
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: Text(
                                        'No custom leave types configured yet. Click below to add.',
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Active Leave Policies:',
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...lTypes.map((lt) {
                                        final name = lt['name'] ?? '';
                                        final limit = lt['maxDays'] ?? 12;
                                        final isPaid = lt['isPaid'] ?? true;
                                        final period = (lt['period'] ?? 'YEARLY').toString().toLowerCase() == 'yearly' ? 'year' : 'month';
                                        final mid = lt['maxDaysMid'];
                                        final sr = lt['maxDaysSenior'];

                                        return Card(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          color: AppTheme.backgroundColor,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: BorderSide(color: Colors.grey.shade200),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      name,
                                                      style: GoogleFonts.outfit(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    Text(
                                                      isPaid ? 'PAID' : 'UNPAID',
                                                      style: GoogleFonts.outfit(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 10,
                                                        color: isPaid ? Colors.green : Colors.redAccent,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Junior Limit: $limit days/$period',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 12,
                                                    color: AppTheme.textSecondaryColor,
                                                  ),
                                                ),
                                                if (mid != null || sr != null)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 2.0),
                                                    child: Text(
                                                      'Mid Limit: ${mid ?? limit} days/$period • Senior Limit: ${sr ?? limit} days/$period',
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 11,
                                                        color: AppTheme.primaryColor,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LeaveTypesScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.settings_outlined, size: 18),
                                label: const Text('Configure Leave Types'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor.withOpacity(0.08),
                                  foregroundColor: AppTheme.primaryColor,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Auto Checkout Configuration Card
                      _buildSectionHeader('Auto Checkout Configuration', Icons.timer_outlined),
                      Card(
                        margin: const EdgeInsets.only(bottom: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Automatically checkout employees who forget to checkout. If they are still working, their subsequent manual check-out will overwrite this.',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SwitchListTile(
                                title: Text(
                                  'Enable Auto Checkout',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Text(
                                  _autoCheckoutEnabled
                                      ? 'System will auto checkout at $_autoCheckoutTime'
                                      : 'Disabled',
                                  style: GoogleFonts.outfit(fontSize: 13),
                                ),
                                value: _autoCheckoutEnabled,
                                activeColor: AppTheme.primaryColor,
                                onChanged: (bool val) {
                                  setState(() {
                                    _autoCheckoutEnabled = val;
                                  });
                                },
                              ),
                              if (_autoCheckoutEnabled) ...[
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.access_time, color: AppTheme.primaryColor),
                                  title: Text(
                                    'Auto Checkout Time',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                  trailing: Chip(
                                    label: Text(
                                      _autoCheckoutTime,
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                  ),
                                  onTap: () async {
                                    final TimeOfDay? picked = await showTimePicker(
                                      context: context,
                                      initialTime: _parseTime(_autoCheckoutTime),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _autoCheckoutTime = _formatTime(picked);
                                      });
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // General Information Card
                      _buildSectionHeader('General Information', Icons.info_outline),
                      Card(
                        margin: const EdgeInsets.only(bottom: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _nameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'School Name*',
                                  prefixIcon: Icon(Icons.school, size: 20),
                                ),
                                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _typeCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'School Type*',
                                        hintText: 'e.g. High School',
                                      ),
                                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _boardCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Board*',
                                        hintText: 'e.g. CBSE',
                                      ),
                                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
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
                                  prefixIcon: Icon(Icons.phone, size: 20),
                                ),
                                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _addressCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Address*',
                                  prefixIcon: Icon(Icons.location_city, size: 20),
                                ),
                                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _cityCtrl,
                                      decoration: const InputDecoration(labelText: 'City*'),
                                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _stateCtrl,
                                      decoration: const InputDecoration(labelText: 'State*'),
                                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
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
                                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _pinCodeCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'Pin Code*'),
                                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      ElevatedButton(
                        onPressed: _saveSettings,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: Text(
                          'Save Settings',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return const TimeOfDay(hour: 18, minute: 0);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
