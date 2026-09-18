import '../models/user_model.dart';

class AuthResult {
  final bool isSuccess;
  final UserModel? user;
  final String? errorMessage;

  const AuthResult({
    required this.isSuccess,
    this.user,
    this.errorMessage,
  });

  factory AuthResult.success(UserModel user) => AuthResult(
        isSuccess: true,
        user: user,
      );

  factory AuthResult.failure(String message) => AuthResult(
        isSuccess: false,
        errorMessage: message,
      );
}

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Authenticates user with email or employee ID and password
  Future<AuthResult> authenticate({
    required String identifier,
    required String password,
  }) async {
    final cleanId = identifier.trim().toLowerCase();
    final cleanPass = password.trim();

    // 1. Validation checks
    if (cleanId.isEmpty) {
      return AuthResult.failure('Please enter your Email or User ID.');
    }
    if (cleanPass.isEmpty) {
      return AuthResult.failure('Please enter your password.');
    }

    // Simulate realistic network delay for smooth UI feedback
    await Future.delayed(const Duration(milliseconds: 250));

    // 2. Parent Mock Credentials Check
    final isParentId = cleanId == 'par001' ||
        cleanId == 'parent@smartschool.com' ||
        cleanId == 'parent.rajesh@smartschool.edu' ||
        cleanId.startsWith('par') ||
        cleanId.contains('parent');

    if (isParentId &&
        (cleanPass == 'parent123' || cleanPass == '••••••••••••' || cleanPass == 'password123')) {
      return AuthResult.success(UserModel.parentDefault());
    }

    // 3. Faculty Mock Credentials Check
    final isFacultyId = cleanId == 'fac001' ||
        cleanId == 'emp-1001' ||
        cleanId == 'faculty@smartschool.com' ||
        cleanId == 'kavya.sharma@smartschool.edu' ||
        cleanId.startsWith('fac') ||
        cleanId.contains('faculty');

    if (isFacultyId &&
        (cleanPass == 'faculty123' || cleanPass == '••••••••••••' || cleanPass == 'password123')) {
      return AuthResult.success(UserModel.facultyDefault());
    }

    // 4. Principal Mock Credentials Check
    final isPrincipalId = cleanId == 'prn001' ||
        cleanId == 'principal.main@smartschool.edu' ||
        cleanId.contains('principal');

    if (isPrincipalId &&
        (cleanPass == 'principal123' || cleanPass == '••••••••••••' || cleanPass == 'password123')) {
      return AuthResult.success(UserModel.principalDefault());
    }

    // 5. Super Admin Mock Credentials Check
    final isAdminId = cleanId == 'adm001' ||
        cleanId == 'admin.srinadh@smartschool.edu' ||
        cleanId.contains('admin');

    if (isAdminId &&
        (cleanPass == 'admin123' || cleanPass == '••••••••••••' || cleanPass == 'password123')) {
      return AuthResult.success(UserModel.superAdminDefault());
    }

    // 6. Generic Invalid Credentials Error
    return AuthResult.failure('Invalid ID or password.');
  }

  /// Sends password reset instructions
  Future<String> sendPasswordResetLink(String identifier) async {
    final cleanId = identifier.trim();
    if (cleanId.isEmpty) {
      throw Exception('Please enter your Email or User ID.');
    }

    await Future.delayed(const Duration(milliseconds: 300));
    return 'If the account exists, password reset instructions will be sent.';
  }
}
