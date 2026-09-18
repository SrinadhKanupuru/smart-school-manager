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

  factory PrincipalModel.fromJson(Map<String, dynamic> json) {
    return PrincipalModel(
      id: json['id']?.toString() ?? '',
      name: json['fullName']?.toString() ?? json['name']?.toString() ?? 'Principal',
      email: json['email']?.toString() ?? 'principal@smartschool.edu',
      phone: json['phoneNumber']?.toString() ?? json['phone']?.toString() ?? '+91 98765 43210',
      branch: json['branch']?.toString() ?? json['school']?['name']?.toString() ?? 'Delhi Public International School',
      status: json['status']?.toString() ?? 'Active',
      joinedDate: json['joinedDate']?.toString() ?? (json['createdAt'] != null ? json['createdAt'].toString().split('T')[0] : '01 Jun 2020'),
      qualification: json['qualification']?.toString() ?? 'Ph.D., M.Ed',
      avatarUrl: json['avatarUrl']?.toString() ?? json['profileImage']?.toString() ?? '/assets/principal_hero.jpg',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': name,
      'email': email,
      'phoneNumber': phone,
      'branch': branch,
      'status': status,
      'joinedDate': joinedDate,
      'qualification': qualification,
      'avatarUrl': avatarUrl,
    };
  }
}
