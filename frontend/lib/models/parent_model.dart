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
}
