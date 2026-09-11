class TeacherModel {
  final String id;
  final String employeeId;
  final String name;
  final String subject;
  final String handledClass;
  final double attendancePercentage;
  final int presentDays;
  final int absentDays;
  final int leaveDays;
  final String status; // Present, Absent, On Leave
  final String email;
  final String phone;
  final String qualification;
  final String experience;
  final String joiningDate;
  final List<String> subjectsTaught;
  final List<String> assignedClasses;
  final List<Map<String, dynamic>> leaveHistory;

  const TeacherModel({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.subject,
    required this.handledClass,
    required this.attendancePercentage,
    required this.presentDays,
    required this.absentDays,
    required this.leaveDays,
    required this.status,
    required this.email,
    required this.phone,
    required this.qualification,
    required this.experience,
    required this.joiningDate,
    required this.subjectsTaught,
    required this.assignedClasses,
    required this.leaveHistory,
  });
}
