import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../providers/academic_provider.dart';
import '../../core/theme.dart';

class UploadResourcesScreen extends StatefulWidget {
  const UploadResourcesScreen({super.key});

  @override
  State<UploadResourcesScreen> createState() => _UploadResourcesScreenState();
}

class _UploadResourcesScreenState extends State<UploadResourcesScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSectionId;
  String _selectedType = 'PDF'; // PDF, IMAGE, VIDEO
  String _sourceOption = 'LOCAL'; // LOCAL, URL
  PlatformFile? _pickedFile;
  
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  final _subjectCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _fileUrlCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateMockUrl();
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _fileUrlCtrl.dispose();
    super.dispose();
  }

  void _updateMockUrl() {
    if (_sourceOption == 'URL') {
      if (_selectedType == 'PDF') {
        _fileUrlCtrl.text = 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
      } else if (_selectedType == 'IMAGE') {
        _fileUrlCtrl.text = 'https://images.unsplash.com/photo-1509062522246-3755977927d7?q=80&w=1000';
      } else {
        _fileUrlCtrl.text = 'https://assets.mixkit.co/videos/preview/mixkit-dramatic-school-bus-shot-in-slow-motion-44445-large.mp4';
      }
    }
  }

  void _pickLocalFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'mp4', 'avi', 'mov'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final extension = file.extension?.toLowerCase() ?? '';
        
        String autoType = 'PDF';
        if (['jpg', 'jpeg', 'png'].contains(extension)) {
          autoType = 'IMAGE';
        } else if (['mp4', 'avi', 'mov'].contains(extension)) {
          autoType = 'VIDEO';
        }

        setState(() {
          _pickedFile = file;
          _selectedType = autoType;
          // Set simulated uploader URL path
          _fileUrlCtrl.text = 'mock://local-device/uploads/${file.name}';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  void _selectSamplePreset(String title, String subject, String type, String url) {
    setState(() {
      _sourceOption = 'URL';
      _titleCtrl.text = title;
      _subjectCtrl.text = subject;
      _selectedType = type;
      _fileUrlCtrl.text = url;
      _pickedFile = null;
    });
  }

  void _submit(AcademicProvider provider) async {
    if (!_formKey.currentState!.validate() || _selectedSectionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select class and fill all details')),
      );
      return;
    }

    if (_sourceOption == 'LOCAL' && _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a local file to upload')),
      );
      return;
    }

    String finalUrl = _fileUrlCtrl.text.trim();

    if (_sourceOption == 'LOCAL' && _pickedFile != null) {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.1;
      });

      try {
        List<int> fileBytes;
        if (kIsWeb) {
          if (_pickedFile!.bytes == null) {
            throw Exception('File bytes are not available');
          }
          fileBytes = _pickedFile!.bytes!;
        } else {
          if (_pickedFile!.path == null) {
            throw Exception('File path is not available');
          }
          fileBytes = await File(_pickedFile!.path!).readAsBytes();
        }

        setState(() {
          _uploadProgress = 0.4;
        });

        final uploadedUrl = await provider.uploadFile(fileBytes, _pickedFile!.name);
        
        setState(() {
          _uploadProgress = 0.8;
        });

        if (uploadedUrl == null) {
          setState(() {
            _isUploading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload file to the server')),
            );
          }
          return;
        }

        finalUrl = uploadedUrl;

        setState(() {
          _uploadProgress = 1.0;
          _isUploading = false;
        });
      } catch (e) {
        setState(() {
          _isUploading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading file: $e')),
          );
        }
        return;
      }
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final success = await provider.uploadResource(
      classSectionId: _selectedSectionId!,
      subject: _subjectCtrl.text.trim(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      resourceType: _selectedType,
      fileUrl: finalUrl,
    );

    if (mounted) {
      Navigator.pop(context); // Dismiss loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Resource uploaded successfully!' : 'Failed to upload resource'),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );
      if (success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final academic = Provider.of<AcademicProvider>(context);

    final List<Map<String, dynamic>> sections = [];
    for (var cls in academic.classes) {
      final className = cls['name'] ?? '';
      for (var sec in cls['sections'] ?? []) {
        sections.add({
          'id': sec['id'],
          'displayName': '$className - ${sec['name']}',
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Study Materials'),
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
                  'Share Study Material, Notes, or Lecture Videos',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose a local file or paste a web link. Uploaded files will be immediately available to parents and students.',
                  style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                ),
                const SizedBox(height: 24),

                DropdownButtonFormField<String>(
                  value: _selectedSectionId,
                  hint: const Text('Select Class & Section'),
                  items: sections.map((sec) {
                    return DropdownMenuItem(value: sec['id'] as String, child: Text(sec['displayName']));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedSectionId = val),
                  validator: (val) => val == null ? 'Select class & section' : null,
                ),
                const SizedBox(height: 16),

                // Source Option Selector (Local vs URL)
                Text(
                  'Resource Source',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSecondaryColor),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Center(
                          child: Text(
                            '📁 Local File',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: _sourceOption == 'LOCAL' ? Colors.white : AppTheme.textPrimaryColor,
                            ),
                          ),
                        ),
                        selected: _sourceOption == 'LOCAL',
                        selectedColor: AppTheme.primaryColor,
                        backgroundColor: Colors.white,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _sourceOption = 'LOCAL';
                              _pickedFile = null;
                              _fileUrlCtrl.clear();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: Center(
                          child: Text(
                            '🔗 Web URL',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: _sourceOption == 'URL' ? Colors.white : AppTheme.textPrimaryColor,
                            ),
                          ),
                        ),
                        selected: _sourceOption == 'URL',
                        selectedColor: AppTheme.primaryColor,
                        backgroundColor: Colors.white,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _sourceOption = 'URL';
                              _updateMockUrl();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // File picking box OR Web url input
                if (_sourceOption == 'LOCAL') ...[
                  Text(
                    'Select File',
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSecondaryColor),
                  ),
                  const SizedBox(height: 8),
                  if (_pickedFile != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _pickedFile!.name,
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Size: ${(_pickedFile!.size / 1024).toStringAsFixed(1)} KB • Type: $_selectedType',
                                  style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondaryColor),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: _pickLocalFile,
                            child: const Text('Change'),
                          )
                        ],
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _pickLocalFile,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_upload_outlined, size: 40, color: AppTheme.primaryColor),
                            const SizedBox(height: 8),
                            Text(
                              'Click to select PDF, Image, or Video',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimaryColor),
                            ),
                            Text(
                              'Supports up to 50MB files',
                              style: GoogleFonts.outfit(fontSize: 11, color: AppTheme.textSecondaryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                ] else ...[
                  // Resource Type selector (Segmented style)
                  Text(
                    'Resource Type',
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textSecondaryColor),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: ['PDF', 'IMAGE', 'VIDEO'].map((type) {
                      final isSelected = _selectedType == type;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedType = type;
                              _updateMockUrl();
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                type,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                  }).toList(),
                ),
              ],
                const SizedBox(height: 20),

                TextFormField(
                  controller: _subjectCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    hintText: 'e.g. Mathematics, General Science, English',
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Enter subject name' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Topic Title',
                    hintText: 'e.g. Trigonometry Basics, Photosynthesis Lecture',
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Enter title' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description / Instructions',
                    hintText: 'Optional instructions or description details...',
                  ),
                ),
                const SizedBox(height: 16),

                if (_sourceOption == 'URL')
                  TextFormField(
                    controller: _fileUrlCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Web Resource URL',
                      hintText: 'Enter direct download link or video URL',
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Enter URL' : null,
                  ),
                const SizedBox(height: 24),

                // Simulated progress animation
                if (_isUploading) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Uploading file to cloud storage...',
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _uploadProgress,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ],

                // Quick presets container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Demo Web Presets:',
                        style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildPresetChip(
                            'Math Notes PDF',
                            () => _selectSamplePreset(
                              'Linear Equations Notes',
                              'Mathematics',
                              'PDF',
                              'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
                            ),
                          ),
                          _buildPresetChip(
                            'Biology Diagram',
                            () => _selectSamplePreset(
                              'Plant Cell Diagram Chart',
                              'Biology',
                              'IMAGE',
                              'https://images.unsplash.com/photo-1509062522246-3755977927d7?q=80&w=1000',
                            ),
                          ),
                          _buildPresetChip(
                            'Bus Safety Lecture MP4',
                            () => _selectSamplePreset(
                              'Bus Safety Rules Video',
                              'General Studies',
                              'VIDEO',
                              'https://assets.mixkit.co/videos/preview/mixkit-dramatic-school-bus-shot-in-slow-motion-44445-large.mp4',
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton.icon(
                  onPressed: () => _submit(academic),
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Publish Study Material'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return ActionChip(
      onPressed: onTap,
      label: Text(label, style: GoogleFonts.outfit(fontSize: 11)),
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
