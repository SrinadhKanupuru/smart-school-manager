import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../app/navigation_provider.dart';
import '../../models/student_model.dart';
import '../../models/teacher_model.dart';

class CustomModals {
  // Add Student Dialog
  static void showAddStudentDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final classCtrl = TextEditingController(text: 'Grade 9');
    final sectionCtrl = TextEditingController(text: 'A');
    final rollCtrl = TextEditingController();
    final parentCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Text('Add New Student', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 17)),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Student Full Name *', hintText: 'e.g. Aryan Sharma'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: classCtrl,
                        decoration: const InputDecoration(labelText: 'Class', hintText: 'Grade 9'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: sectionCtrl,
                        decoration: const InputDecoration(labelText: 'Section', hintText: 'A'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: rollCtrl,
                        decoration: const InputDecoration(labelText: 'Roll No', hintText: '915'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: parentCtrl,
                  decoration: const InputDecoration(labelText: 'Parent / Guardian Name', hintText: 'e.g. Rajesh Sharma'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Parent Phone Number (10 digits)',
                    hintText: '9876543210',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              final newStudent = StudentModel(
                id: 'STD-${DateTime.now().millisecondsSinceEpoch}',
                studentId: 'STU-2026-${(100 + (DateTime.now().millisecond % 899))}',
                name: nameCtrl.text.trim(),
                className: classCtrl.text.trim(),
                section: sectionCtrl.text.trim(),
                rollNo: rollCtrl.text.trim().isEmpty ? '101' : rollCtrl.text.trim(),
                parentName: parentCtrl.text.trim().isEmpty ? 'Parent Guardian' : parentCtrl.text.trim(),
                parentPhone: phoneCtrl.text.trim().isEmpty ? '+91 98765 00000' : phoneCtrl.text.trim(),
                attendancePercentage: 100.0,
                feeStatus: 'Pending',
                pendingFeeAmount: 35000,
                status: 'Active',
                gender: 'Male',
                dob: '15 Aug 2011',
                bloodGroup: 'B+',
                address: 'Bangalore Campus Area',
                admissionDate: '11 Sep 2026',
                academicGrades: [],
              );
              Provider.of<NavigationProvider>(context, listen: false).addStudent(newStudent);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.success,
                  content: Text('Student "${newStudent.name}" enrolled successfully!'),
                ),
              );
            },
            child: const Text('Enroll Student'),
          ),
        ],
      ),
    );
  }

  // Add Teacher Dialog
  static void showAddTeacherDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final subjectCtrl = TextEditingController(text: 'Mathematics');
    final classCtrl = TextEditingController(text: 'Grade 10-A');
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school_rounded, color: Color(0xFF8B5CF6), size: 20),
            ),
            const SizedBox(width: 10),
            Text('Add Faculty Member', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 17)),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Teacher Full Name *', hintText: 'e.g. Dr. Meera Nambiar'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: subjectCtrl,
                        decoration: const InputDecoration(labelText: 'Primary Subject', hintText: 'e.g. Physics'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: classCtrl,
                        decoration: const InputDecoration(labelText: 'Assigned Class', hintText: 'Grade 9-A'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Official Email ID', hintText: 'meera.n@smartschool.edu'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Phone Number (10 digits)',
                    hintText: '9876543210',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              final newTeacher = TeacherModel(
                id: 'TCH-${DateTime.now().millisecondsSinceEpoch}',
                employeeId: 'EMP-${(1010 + (DateTime.now().millisecond % 50))}',
                name: nameCtrl.text.trim(),
                subject: subjectCtrl.text.trim(),
                handledClass: classCtrl.text.trim(),
                attendancePercentage: 100.0,
                presentDays: 22,
                absentDays: 0,
                leaveDays: 0,
                status: 'Present',
                email: emailCtrl.text.trim().isEmpty ? 'teacher@smartschool.edu' : emailCtrl.text.trim(),
                phone: phoneCtrl.text.trim().isEmpty ? '+91 98765 00000' : phoneCtrl.text.trim(),
                qualification: 'M.Sc., B.Ed',
                experience: '5 Years',
                joiningDate: '11 Sep 2026',
                subjectsTaught: [subjectCtrl.text.trim()],
                assignedClasses: [classCtrl.text.trim()],
                leaveHistory: [],
              );
              Provider.of<NavigationProvider>(context, listen: false).addTeacher(newTeacher);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.success,
                  content: Text('Teacher "${newTeacher.name}" added successfully!'),
                ),
              );
            },
            child: const Text('Add Teacher'),
          ),
        ],
      ),
    );
  }

  // Send Notice Modal
  static void showSendNoticeDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    String recipient = 'All Parents & Students';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.campaign_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text('Broadcast School Notice', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 17)),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: recipient,
                  decoration: const InputDecoration(labelText: 'Select Recipients'),
                  items: const [
                    DropdownMenuItem(value: 'All Parents & Students', child: Text('All Parents & Students')),
                    DropdownMenuItem(value: 'All Teachers & Staff', child: Text('All Teachers & Staff')),
                    DropdownMenuItem(value: 'Grade 10 Only (Exam Notice)', child: Text('Grade 10 Only (Exam Notice)')),
                    DropdownMenuItem(value: 'Only Parents with Pending Fees', child: Text('Only Parents with Pending Fees')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => recipient = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Notice Title', hintText: 'e.g. Schedule for Mid-Term Exams'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: msgCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notice Content / Announcement',
                    hintText: 'Type your message here...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppColors.primary,
                    content: Text('Notice dispatched instantly via App Notification & SMS!'),
                  ),
                );
              },
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Broadcast Notice'),
            ),
          ],
        ),
      ),
    );
  }

  // Manage Fees Modal
  static void showCollectFeeDialog(BuildContext context) {
    final studentCtrl = TextEditingController(text: 'Rahul Varma (Grade 8-A)');
    final amountCtrl = TextEditingController(text: '25,000');
    String paymentMode = 'UPI (Instant)';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.payments_rounded, color: Color(0xFF10B981), size: 20),
              ),
              const SizedBox(width: 10),
              Text('Record Fee Payment', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 17)),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: studentCtrl,
                  decoration: const InputDecoration(labelText: 'Student Name & Class'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Payment Amount (₹)',
                    prefixText: '₹ ',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: paymentMode,
                  decoration: const InputDecoration(labelText: 'Payment Mode'),
                  items: const [
                    DropdownMenuItem(value: 'UPI (Instant)', child: Text('UPI (Instant)')),
                    DropdownMenuItem(value: 'Net Banking / NEFT', child: Text('Net Banking / NEFT')),
                    DropdownMenuItem(value: 'Credit / Debit Card', child: Text('Credit / Debit Card')),
                    DropdownMenuItem(value: 'Cash at Counter', child: Text('Cash at Counter')),
                    DropdownMenuItem(value: 'Cheque / DD', child: Text('Cheque / DD')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => paymentMode = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xFF10B981),
                    content: Text('Payment recorded & E-Receipt sent to parent!'),
                  ),
                );
              },
              child: const Text('Generate Receipt'),
            ),
          ],
        ),
      ),
    );
  }

  // Generate Report Modal
  static void showGenerateReportDialog(BuildContext context) {
    String reportType = 'Student Attendance Report';
    String classRange = 'All Classes';
    String format = 'PDF Document (.pdf)';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text('Export Super Admin Report', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 17)),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: reportType,
                  decoration: const InputDecoration(labelText: 'Report Type'),
                  items: const [
                    DropdownMenuItem(value: 'Student Attendance Report', child: Text('Student Attendance Report')),
                    DropdownMenuItem(value: 'Teacher Attendance Report', child: Text('Teacher Attendance Report')),
                    DropdownMenuItem(value: 'Fee Collection & Dues Report', child: Text('Fee Collection & Dues Report')),
                    DropdownMenuItem(value: 'Pending Fee Follow-up Report', child: Text('Pending Fee Follow-up Report')),
                    DropdownMenuItem(value: 'Academic Performance Report', child: Text('Academic Performance Report')),
                    DropdownMenuItem(value: 'Student Strength & Demographics', child: Text('Student Strength & Demographics')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => reportType = val);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: classRange,
                  decoration: const InputDecoration(labelText: 'Target Grade / Class'),
                  items: const [
                    DropdownMenuItem(value: 'All Classes', child: Text('All Classes (Grades 1 to 12)')),
                    DropdownMenuItem(value: 'Grade 10', child: Text('Grade 10 Only')),
                    DropdownMenuItem(value: 'Grade 9', child: Text('Grade 9 Only')),
                    DropdownMenuItem(value: 'Grade 8', child: Text('Grade 8 Only')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => classRange = val);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: format,
                  decoration: const InputDecoration(labelText: 'Export Format'),
                  items: const [
                    DropdownMenuItem(value: 'PDF Document (.pdf)', child: Text('PDF Document (.pdf)')),
                    DropdownMenuItem(value: 'Excel Spreadsheet (.xlsx)', child: Text('Excel Spreadsheet (.xlsx)')),
                    DropdownMenuItem(value: 'CSV File (.csv)', child: Text('CSV File (.csv)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => format = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.primary,
                    content: Text('$reportType generated successfully! Download started.'),
                  ),
                );
              },
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Download Report'),
            ),
          ],
        ),
      ),
    );
  }
}
