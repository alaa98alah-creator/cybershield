class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phoneNumber;
  final String gender;
  final String dateOfBirth;
  final String residence;
  final String password;

  const RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    required this.dateOfBirth,
    required this.residence,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'username': username,
    'email': email,
    'phone_number': phoneNumber,
    'gender': gender,
    'date_of_birth': dateOfBirth,
    'residence': residence,
    'password': password,
  };
}

class AuthResponse {
  final String token;
  final String userId;
  final String email;

  const AuthResponse({
    required this.token,
    required this.userId,
    required this.email,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      userId: json['user_id'] as String,
      email: json['email'] as String,
    );
  }
}

class ScanResultResponse {
  final Map<String, dynamic> scan;
  final Map<String, dynamic>? vtResult;
  final Map<String, dynamic>? aiAnalysis;

  const ScanResultResponse({
    required this.scan,
    this.vtResult,
    this.aiAnalysis,
  });

  factory ScanResultResponse.fromJson(Map<String, dynamic> json) {
    return ScanResultResponse(
      scan: json['scan'] as Map<String, dynamic>? ?? {},
      vtResult: json['vt_result'] as Map<String, dynamic>?,
      aiAnalysis: json['ai_analysis'] as Map<String, dynamic>?,
    );
  }
}
