class User {
  final String id;
  final String name;
  final String email;
  final String universityId;
  final String? profileImage;
  final String? phone;
  final String? department;
  final int? yearOfStudy;
  final String? bio;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.universityId,
    this.profileImage,
    this.phone,
    this.department,
    this.yearOfStudy,
    this.bio,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'universityId': universityId,
      'profileImage': profileImage,
      'phone': phone,
      'department': department,
      'yearOfStudy': yearOfStudy,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}