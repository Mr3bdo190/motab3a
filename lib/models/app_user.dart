class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final bool isActive;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
  });

  factory AppUser.fromMap(String uid, Map<dynamic, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] ?? 'بدون اسم',
      email: map['email'] ?? '',
      role: map['role'] ?? 'driver',
      isActive: map['is_active'] ?? false,
    );
  }
}
