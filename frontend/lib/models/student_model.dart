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

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    // Extract class and section from nested classSection object if present
    String clsName = json['className']?.toString() ?? '';
    String secName = json['section']?.toString() ?? '';
    if (json['classSection'] != null && json['classSection'] is Map) {
      secName = json['classSection']['name']?.toString() ?? secName;
      if (json['classSection']['class'] != null && json['classSection']['class'] is Map) {
        clsName = json['classSection']['class']['name']?.toString() ?? clsName;
      }
    }
    if (clsName.isEmpty) clsName = 'Class 10';
    if (secName.isEmpty) secName = 'A';

    // Extract parent details
    String pName = json['parentName']?.toString() ?? '';
    String pPhone = json['parentPhone']?.toString() ?? '';
    if (json['parents'] != null && json['parents'] is List && (json['parents'] as List).isNotEmpty) {
      final firstParent = json['parents'][0];
      if (firstParent is Map && firstParent['parent'] != null && firstParent['parent']['user'] != null) {
        pName = firstParent['parent']['user']['fullName']?.toString() ?? pName;
        pPhone = firstParent['parent']['user']['phoneNumber']?.toString() ?? pPhone;
      }
    }

    // Extract fee info
    String fStatus = json['feeStatus']?.toString() ?? 'Paid';
    double pFee = (json['pendingFeeAmount'] as num?)?.toDouble() ?? 0.0;
    if (json['feeRecords'] != null && json['feeRecords'] is List) {
      final fees = json['feeRecords'] as List;
      double totalPending = 0.0;
      for (var f in fees) {
        if (f is Map) {
          final amt = (f['amount'] as num?)?.toDouble() ?? 0.0;
          final paid = (f['paidAmount'] as num?)?.toDouble() ?? 0.0;
          if (amt > paid) totalPending += (amt - paid);
        }
      }
      pFee = totalPending;
      fStatus = totalPending > 0 ? (totalPending > 5000 ? 'Overdue' : 'Pending') : 'Paid';
    }

    return StudentModel(
      id: json['id']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? (json['rollNo'] != null ? 'STU-${json['rollNo']}' : 'STU-001'),
      name: json['name']?.toString() ?? json['fullName']?.toString() ?? 'Student',
      className: clsName,
      section: secName,
      rollNo: json['rollNo']?.toString() ?? '01',
      parentName: pName.isNotEmpty ? pName : 'Parent Guardian',
      parentPhone: pPhone.isNotEmpty ? pPhone : '+91 98765 00000',
      attendancePercentage: (json['attendancePercentage'] as num?)?.toDouble() ?? 95.0,
      feeStatus: fStatus,
      pendingFeeAmount: pFee,
      status: json['status']?.toString() ?? (json['isActive'] == false ? 'Inactive' : 'Active'),
      gender: json['gender']?.toString() ?? 'Male',
      dob: json['dob']?.toString() ?? (json['dateOfBirth'] != null ? json['dateOfBirth'].toString().split('T')[0] : '15 Aug 2011'),
      bloodGroup: json['bloodGroup']?.toString() ?? 'B+',
      address: json['address']?.toString() ?? 'New Delhi, India',
      admissionDate: json['admissionDate']?.toString() ?? '01 Jun 2024',
      academicGrades: json['academicGrades'] != null && json['academicGrades'] is List
          ? List<Map<String, dynamic>>.from(json['academicGrades'])
          : [
              {'subject': 'Mathematics', 'grade': 'A+', 'score': 94},
              {'subject': 'Science', 'grade': 'A', 'score': 88},
              {'subject': 'English', 'grade': 'A+', 'score': 91},
            ],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'fullName': name,
      'className': className,
      'section': section,
      'rollNo': rollNo,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'attendancePercentage': attendancePercentage,
      'feeStatus': feeStatus,
      'pendingFeeAmount': pendingFeeAmount,
      'status': status,
      'gender': gender,
      'dob': dob,
      'bloodGroup': bloodGroup,
      'address': address,
      'admissionDate': admissionDate,
      'academicGrades': academicGrades,
    };
  }
}
