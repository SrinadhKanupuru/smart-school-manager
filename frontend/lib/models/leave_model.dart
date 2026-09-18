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

  factory LeaveApplication.fromJson(Map<String, dynamic> json) {
    String name = json['applicantName']?.toString() ?? '';
    String roleName = json['role']?.toString() ?? 'Faculty';
    if (json['user'] != null && json['user'] is Map) {
      name = json['user']['fullName']?.toString() ?? name;
      roleName = json['user']['role']?.toString() == 'PARENT' ? 'Parent' : 'Faculty';
    } else if (json['student'] != null && json['student'] is Map) {
      name = json['student']['fullName']?.toString() ?? name;
      roleName = 'Student';
    }

    String fDate = json['fromDate'] != null ? json['fromDate'].toString().split('T')[0] : 'Today';
    String tDate = json['toDate'] != null ? json['toDate'].toString().split('T')[0] : 'Today';
    String aDate = json['createdAt'] != null ? json['createdAt'].toString().split('T')[0] : 'Today';

    return LeaveApplication(
      id: json['id']?.toString() ?? '',
      applicantName: name.isNotEmpty ? name : 'Applicant',
      role: roleName,
      targetClassOrDept: json['targetClassOrDept']?.toString() ?? (json['leaveTypeRel']?['name'] ?? 'Faculty Dept'),
      leaveType: json['leaveType']?.toString() ?? 'Casual Leave',
      fromDate: fDate,
      toDate: tDate,
      days: (json['daysCount'] as num?)?.toInt() ?? (json['days'] as num?)?.toInt() ?? 1,
      reason: json['reason']?.toString() ?? 'Personal leave',
      status: json['status']?.toString() ?? 'Pending',
      appliedDate: aDate,
      adminRemarks: json['rejectionReason']?.toString() ?? json['adminRemarks']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'applicantName': applicantName,
      'role': role,
      'targetClassOrDept': targetClassOrDept,
      'leaveType': leaveType,
      'fromDate': fromDate,
      'toDate': toDate,
      'days': days,
      'reason': reason,
      'status': status,
      'appliedDate': appliedDate,
      'adminRemarks': adminRemarks,
    };
  }
}
