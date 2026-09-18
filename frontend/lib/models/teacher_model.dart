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

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    // Check if user is nested inside TeacherProfile or flat User object
    final userObj = json['user'] is Map ? json['user'] as Map<String, dynamic> : json;
    final name = userObj['fullName']?.toString() ?? json['name']?.toString() ?? 'Faculty Member';
    final email = userObj['email']?.toString() ?? json['email']?.toString() ?? 'teacher@smartschool.edu';
    final phone = userObj['phoneNumber']?.toString() ?? json['phone']?.toString() ?? '+91 98765 00000';
    final qual = json['qualification']?.toString() ?? 'M.Sc., B.Ed';
    final exp = json['experienceYears'] != null ? '${json['experienceYears']} Years' : (json['experience']?.toString() ?? '5 Years');
    final handledCls = json['handledClass']?.toString() ?? json['permanentAddress']?.toString() ?? 'Grade 10-A';
    final subj = json['subject']?.toString() ?? 'Physics';

    return TeacherModel(
      id: json['id']?.toString() ?? userObj['id']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? 'EMP-${userObj['id']?.toString().substring(0, 4).toUpperCase() ?? '101'}',
      name: name,
      subject: subj,
      handledClass: handledCls,
      attendancePercentage: (json['attendancePercentage'] as num?)?.toDouble() ?? 96.2,
      presentDays: (json['presentDays'] as num?)?.toInt() ?? 22,
      absentDays: (json['absentDays'] as num?)?.toInt() ?? 1,
      leaveDays: (json['leaveDays'] as num?)?.toInt() ?? 1,
      status: json['status']?.toString() ?? (json['workingStatus']?.toString() == 'ACTIVE' ? 'Present' : 'Absent'),
      email: email,
      phone: phone,
      qualification: qual,
      experience: exp,
      joiningDate: json['joiningDate']?.toString() ?? (userObj['createdAt'] != null ? userObj['createdAt'].toString().split('T')[0] : '15 Jul 2021'),
      subjectsTaught: json['subjectsTaught'] != null && json['subjectsTaught'] is List
          ? List<String>.from(json['subjectsTaught'])
          : [subj],
      assignedClasses: json['assignedClasses'] != null && json['assignedClasses'] is List
          ? List<String>.from(json['assignedClasses'])
          : [handledCls],
      leaveHistory: json['leaveHistory'] != null && json['leaveHistory'] is List
          ? List<Map<String, dynamic>>.from(json['leaveHistory'])
          : [
              {'type': 'Casual Leave', 'from': '10 Aug 2026', 'to': '11 Aug 2026', 'days': 2, 'status': 'Approved'},
            ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'fullName': name,
      'subject': subject,
      'handledClass': handledClass,
      'attendancePercentage': attendancePercentage,
      'presentDays': presentDays,
      'absentDays': absentDays,
      'leaveDays': leaveDays,
      'status': status,
      'email': email,
      'phoneNumber': phone,
      'qualification': qualification,
      'experience': experience,
      'joiningDate': joiningDate,
      'subjectsTaught': subjectsTaught,
      'assignedClasses': assignedClasses,
      'leaveHistory': leaveHistory,
    };
  }
}
