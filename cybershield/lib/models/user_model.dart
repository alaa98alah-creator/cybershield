enum Gender { male, female, unspecified }

class UserModel {
  final String userId;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phoneNumber;
  final Gender gender;
  final DateTime dateOfBirth;
  final String residence;
  final String? passwordHash;
  final DateTime createdAt;

  const UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    required this.dateOfBirth,
    required this.residence,
    this.passwordHash,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String,
      gender: Gender.values.firstWhere(
        (e) => e.name == (json['gender'] as String).toLowerCase(),
      ),
      dateOfBirth: DateTime.parse(json['date_of_birth'] as String),
      residence: json['residence'] as String,
      passwordHash: json['password_hash'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      'gender': gender.name,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'residence': residence,
      'password_hash': passwordHash,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get displayName => '$firstName $lastName';
}
