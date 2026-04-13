class LoginModel {
  final String email;
  final String password;
  final String? fcmToken;

  LoginModel({
    required this.email,
    required this.password,
    this.fcmToken,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      fcmToken: json['fcm_token'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'password': password,
    };

    if (fcmToken != null && fcmToken!.isNotEmpty) {
      data['fcm_token'] = fcmToken;
    }

    return data;
  }
}
