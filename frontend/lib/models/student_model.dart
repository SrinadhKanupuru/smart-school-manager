class StudentModel {
  final String id;
  final String studentId;
  final String name;
  final String className;
  final String section;
  final String rollNo;
  final String parentName;
  final String parentPhone;
  final double attendancePercentage;
  final String feeStatus; // Paid, Pending, Overdue
  final double pendingFeeAmount;
  final String status; // Active, Inactive, Transferred
  final String gender;
  final String dob;
  final String bloodGroup;
  final String address;
  final String admissionDate;
  final List<Map<String, dynamic>> academicGrades;

  const StudentModel({
    required this.id,
    required this.studentId,
    required this.name,
    required this.className,
    required this.section,
    required this.rollNo,
    required this.parentName,
    required this.parentPhone,
    required this.attendancePercentage,
    required this.feeStatus,
    required this.pendingFeeAmount,
    required this.status,
    required this.gender,
    required this.dob,
    required this.bloodGroup,
    required this.address,
    required this.admissionDate,
    required this.academicGrades,
  });
}
