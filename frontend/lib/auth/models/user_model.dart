enum UserRole {
  faculty,
  principal,
  superAdmin,
  parent,
}

class UserModel {
  final String id;
  final String employeeId;
  final String name;
  final String email;
  final UserRole role;
  final String department;
  final String designation;
  final String? phone;
  final String? avatarUrl;
  final String qualification;
  final String experience;
  final String joiningDate;
  final List<String> assignedClasses;
  final List<String> subjectsTaught;

  const UserModel({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.designation,
    this.phone,
    this.avatarUrl,
    this.qualification = 'M.Sc. Applied Physics, B.Ed',
    this.experience = '7 Years',
    this.joiningDate = '10 Jun 2019',
    this.assignedClasses = const ['Grade 9-A', 'Grade 10-B', 'Grade 8-C'],
    this.subjectsTaught = const ['Physics', 'General Science'],
  });

  bool get isFaculty => role == UserRole.faculty;
  bool get isPrincipal => role == UserRole.principal;
  bool get isSuperAdmin => role == UserRole.superAdmin;
  bool get isParent => role == UserRole.parent;

  String get roleDisplayName {
    switch (role) {
      case UserRole.faculty:
        return 'Faculty';
      case UserRole.principal:
        return 'Principal';
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.parent:
        return 'Parent';
    }
  }

  factory UserModel.facultyDefault() {
    return const UserModel(
      id: 'TCH-01',
      employeeId: 'FAC001',
      name: 'Ms. Kavya Sharma',
      email: 'faculty@smartschool.com',
      role: UserRole.faculty,
      department: 'Department of Science',
      designation: 'Senior Physics Faculty',
      phone: '+91 98765 43210',
      qualification: 'M.Sc. Applied Physics, B.Ed',
      experience: '7 Years',
      joiningDate: '10 Jun 2019',
      assignedClasses: [
        'Grade 9-A (Class Teacher)',
        'Grade 10-B (Physics)',
        'Grade 8-C (Science)',
      ],
      subjectsTaught: [
        'Physics (Grade 9 & 10)',
        'General Science (Grade 8)',
        'Physics Practical Lab',
      ],
    );
  }

  factory UserModel.principalDefault() {
    return const UserModel(
      id: 'PR-01',
      employeeId: 'PRN001',
      name: 'Dr. Evelyn Vance',
      email: 'principal.main@smartschool.edu',
      role: UserRole.principal,
      department: 'Academic Administration',
      designation: 'Campus Principal',
      phone: '+91 98450 12345',
      qualification: 'Ph.D. Educational Leadership, M.Ed',
      experience: '18 Years',
      joiningDate: '01 Jun 2018',
    );
  }

  factory UserModel.superAdminDefault() {
    return const UserModel(
      id: 'ADM-01',
      employeeId: 'ADM001',
      name: 'Srinadh Kanupuru',
      email: 'admin.srinadh@smartschool.edu',
      role: UserRole.superAdmin,
      department: 'System Management',
      designation: 'Universal Super Administrator',
      phone: '+91 98111 22334',
    );
  }

  factory UserModel.parentDefault() {
    return const UserModel(
      id: 'PAR-01',
      employeeId: 'PAR001',
      name: 'Mr. Rajesh Varma',
      email: 'parent.rajesh@smartschool.edu',
      role: UserRole.parent,
      department: 'Parent Community',
      designation: 'Guardian / Parent',
      phone: '+91 98450 67890',
      qualification: 'B.Tech Computer Science',
      experience: 'Father of 2 Wards',
      joiningDate: '15 May 2021',
    );
  }
}
