class ParentModel {
  final String id;
  final String parentName;
  final String studentName;
  final String studentId;
  final String studentClass;
  final String relationship; // Father, Mother, Guardian
  final String phone;
  final String email;
  final String status; // Active, Connected, Pending
  final String occupation;
  final String address;

  const ParentModel({
    required this.id,
    required this.parentName,
    required this.studentName,
    required this.studentId,
    required this.studentClass,
    required this.relationship,
    required this.phone,
    required this.email,
    required this.status,
    required this.occupation,
    required this.address,
  });

  factory ParentModel.fromJson(Map<String, dynamic> json) {
    final userObj = json['user'] is Map ? json['user'] as Map<String, dynamic> : json;
    String sName = 'Student';
    String sId = 'STU-001';
    String sClass = 'Class 10-A';

    if (json['students'] != null && json['students'] is List && (json['students'] as List).isNotEmpty) {
      final firstRel = json['students'][0];
      if (firstRel is Map && firstRel['student'] != null && firstRel['student'] is Map) {
        final stu = firstRel['student'] as Map<String, dynamic>;
        sName = stu['fullName']?.toString() ?? sName;
        sId = stu['rollNo'] != null ? 'STU-${stu['rollNo']}' : sId;
        if (stu['classSection'] != null && stu['classSection'] is Map) {
          final cs = stu['classSection'] as Map<String, dynamic>;
          final cName = cs['class'] != null && cs['class'] is Map ? cs['class']['name']?.toString() : 'Class 10';
          sClass = '$cName-${cs['name'] ?? 'A'}';
        }
      }
    }

    return ParentModel(
      id: json['id']?.toString() ?? userObj['id']?.toString() ?? '',
      parentName: userObj['fullName']?.toString() ?? json['parentName']?.toString() ?? 'Parent Guardian',
      studentName: json['studentName']?.toString() ?? sName,
      studentId: json['studentId']?.toString() ?? sId,
      studentClass: json['studentClass']?.toString() ?? sClass,
      relationship: json['relation']?.toString() ?? json['relationship']?.toString() ?? 'Father',
      phone: userObj['phoneNumber']?.toString() ?? json['phone']?.toString() ?? '+91 98765 00000',
      email: userObj['email']?.toString() ?? json['email']?.toString() ?? 'parent@smartschool.edu',
      status: json['status']?.toString() ?? 'Active',
      occupation: json['occupation']?.toString() ?? 'Professional',
      address: json['address']?.toString() ?? 'New Delhi, India',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentName': parentName,
      'studentName': studentName,
      'studentId': studentId,
      'studentClass': studentClass,
      'relationship': relationship,
      'phone': phone,
      'email': email,
      'status': status,
      'occupation': occupation,
      'address': address,
    };
  }
}
