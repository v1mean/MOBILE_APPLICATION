class UserProfile {
  final String userId;
  final DateTime createdAt;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String profileImage;
  final String location;

  UserProfile({
    required this.userId,
    required this.createdAt,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.profileImage,
    required this.location,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      profileImage: json['profile_image'] as String,
      location: json['location'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profile_image': profileImage,
      'location': location,
    };
  }
}
