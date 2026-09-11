class LeaveApplication {
  final String id;
  final String applicantName;
  final String role; // Teacher or Student
  final String targetClassOrDept;
  final String leaveType; // Casual, Medical, Sick, Planned, Urgent
  final String fromDate;
  final String toDate;
  final int days;
  final String reason;
  String status; // Pending, Approved, Rejected
  final String appliedDate;
  String? adminRemarks;

  LeaveApplication({
    required this.id,
    required this.applicantName,
    required this.role,
    required this.targetClassOrDept,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.days,
    required this.reason,
    required this.status,
    required this.appliedDate,
    this.adminRemarks,
  });
}
