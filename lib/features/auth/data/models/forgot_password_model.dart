/// Model for forgot password request
class ForgotPasswordModel {
  final String email;

  ForgotPasswordModel({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

/// Model for reset password request
class ResetPasswordModel {
  final String email;
  final String code;
  final String password;
  final String confirmPassword;

  ResetPasswordModel({
    required this.email,
    required this.code,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
      'password': password,
      'confirm_password': confirmPassword,
    };
  }
}

/// Model for email verification request
class EmailVerificationModel {
  final String email;
  final String code;

  EmailVerificationModel({
    required this.email,
    required this.code,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
    };
  }
}

/// Model for resend email request
class ResendEmailModel {
  final String email;

  ResendEmailModel({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}

/// Generic response for forgot password, reset password, and verification
class PasswordResetResponse {
  final bool status;
  final String message;
  final String? data;

  PasswordResetResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory PasswordResetResponse.fromJson(Map<String, dynamic> json) {
    return PasswordResetResponse(
      status: json['status'] ?? json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }
}
