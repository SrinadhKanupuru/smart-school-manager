class PrincipalModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String branch;
  final String status; // Active, On Leave, Inactive
  final String joinedDate;
  final String qualification;
  final String avatarUrl;

  const PrincipalModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.branch,
    required this.status,
    required this.joinedDate,
    required this.qualification,
    required this.avatarUrl,
  });
}
