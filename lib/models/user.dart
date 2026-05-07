class User {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String gender;
  final String? profileImageUrl;
  final String role;
  final bool isActive;
  final DateTime? dateOfBirth; 
  
  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.gender,
    this.profileImageUrl,
    required this.role,
    required this.isActive,
    this.dateOfBirth, 
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      role: json['role'] ?? 'user',
      isActive: json['isActive'] ?? true,
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : null,
    );
  }
  
  bool get isAdmin => role.toLowerCase().trim() == 'admin';
}