import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'camera_widgets.dart';
import '../../providers/school_provider.dart';
import '../../core/theme.dart';

class StaffAttendanceScreen extends StatefulWidget {
  const StaffAttendanceScreen({super.key});

  @override
  State<StaffAttendanceScreen> createState() => _StaffAttendanceScreenState();
}

class _StaffAttendanceScreenState extends State<StaffAttendanceScreen> {
  bool _isProcessing = false;
  String _statusText = "Acquiring physical coordinates...";

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw 'Location services are disabled.';

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw 'Location permission denied.';
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied.';
    }
    
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _handleAttendance(XFile image) async {
    setState(() {
      _isProcessing = true;
      _statusText = "Authenticating location and biometrics...";
    });

    try {
      // 1. Fetch GPS location coordinates
      final position = await _determinePosition();
      
      // 2. Read image bytes
      final fileBytes = await image.readAsBytes();

      if (!mounted) return;
      
      // 3. Perform Backend face verification and coordinate range check
      final provider = Provider.of<SchoolProvider>(context, listen: false);
      final result = await provider.verifyStaffAttendance(
        fileBytes: fileBytes,
        filename: 'face_scan.jpg',
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;

      if (result != null) {
        final message = result['message'] ?? 'Attendance marked successfully!';
        final punchType = result['data']?['type'] ?? 'PUNCH';
        
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: Icon(
              punchType == 'CHECK_IN' ? Icons.login : Icons.logout,
              color: AppTheme.primaryColor,
              size: 48,
            ),
            title: Text(
              punchType == 'CHECK_IN' ? 'Checked In' : 'Checked Out',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              '$message\nTime: ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
              textAlign: TextAlign.center,
            ),
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Verification Failed'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification Failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusText = "";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Attendance Punch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Attendance History',
            onPressed: () {
              Navigator.pushNamed(context, '/staff-attendance-history');
            },
          ),
        ],
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppTheme.primaryColor),
                  const SizedBox(height: 20),
                  Text(
                    _statusText,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ],
              ),
            )
          : CameraWidget(onImageCaptured: _handleAttendance),
    );
  }
}
