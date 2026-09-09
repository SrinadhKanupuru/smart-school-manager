import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'camera_widgets.dart';
import '../../providers/school_provider.dart';
import '../../core/theme.dart';

class RegisterFaceScreen extends StatefulWidget {
  final Map<String, dynamic> employeeData;

  const RegisterFaceScreen({super.key, required this.employeeData});

  @override
  State<RegisterFaceScreen> createState() => _RegisterFaceScreenState();
}

class _RegisterFaceScreenState extends State<RegisterFaceScreen> {
  bool _isUploading = false;

  Future<void> _handleImageCaptured(XFile image) async {
    setState(() => _isUploading = true);
    try {
      final provider = Provider.of<SchoolProvider>(context, listen: false);
      final fileBytes = await image.readAsBytes();
      
      final success = await provider.addUserWithFace(
        fullName: widget.employeeData['fullName'],
        email: widget.employeeData['email'],
        password: widget.employeeData['password'] ?? 'password123',
        phoneNumber: widget.employeeData['phoneNumber'],
        role: widget.employeeData['role'],
        details: widget.employeeData['details'],
        fileBytes: fileBytes,
        filename: 'face_scan.jpg',
      );
      
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Success: User registered with biometric face profile!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to register face profile'),
            backgroundColor: Colors.redAccent,
          ),
        );
        Navigator.pop(context, false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.employeeData['fullName'] ?? 'Employee';

    return Scaffold(
      appBar: AppBar(title: Text('Register Face for $name')),
      body: _isUploading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryColor),
                  SizedBox(height: 15),
                  Text(
                    'Uploading Face Profile to Database...', 
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CameraWidget(onImageCaptured: _handleImageCaptured),
              ),
            ),
    );
  }
}
