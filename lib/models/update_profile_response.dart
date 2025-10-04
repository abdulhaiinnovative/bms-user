class UpdateProfileResponse {
  final int? statusCode;
  final ResponseData? response;
  final String? message;
  final bool? status;
  final List<dynamic>? errors;

  UpdateProfileResponse({
    this.statusCode,
    this.response,
    this.message,
    this.status,
    this.errors,
  });

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      statusCode: json['statusCode'],
      response: json['response'] != null ? ResponseData.fromJson(json['response']) : null,
      message: json['message'],
      status: json['status'],
      errors: json['errors'] ?? [],
    );
  }
}

class ResponseData {
  final UserProfile? data;

  ResponseData({this.data});

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      data: json['data'] != null ? UserProfile.fromJson(json['data']) : null,
    );
  }
}

class UserProfile {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? name;
  final String? email;
  final String? appleUniqueId;
  final String? appleEmail;
  final String? googleUniqueId;
  final String? facebookUniqueId;
  final String? deviceId;
  final String? emailVerifiedAt;
  final int? loyalty;
  final String? provider;
  final String? providerId;
  final String? image;
  final String? phone;
  final String? dob;
  final String? gender;
  final String? country;
  final String? state;
  final String? latitude;
  final String? longitude;
  final String? city;
  final String? address;
  final int? appointment;
  final int? emailMarketing;
  final int? marketingNotification;
  final int? status;
  final int? cancelCount;
  final int? isRestricted;
  final String? emailVerificationCode;
  final String? passwordResetCode;
  final int? completeStatus;

  UserProfile({
    this.id,
    this.firstName,
    this.lastName,
    this.name,
    this.email,
    this.appleUniqueId,
    this.appleEmail,
    this.googleUniqueId,
    this.facebookUniqueId,
    this.deviceId,
    this.emailVerifiedAt,
    this.loyalty,
    this.provider,
    this.providerId,
    this.image,
    this.phone,
    this.dob,
    this.gender,
    this.country,
    this.state,
    this.latitude,
    this.longitude,
    this.city,
    this.address,
    this.appointment,
    this.emailMarketing,
    this.marketingNotification,
    this.status,
    this.cancelCount,
    this.isRestricted,
    this.emailVerificationCode,
    this.passwordResetCode,
    this.completeStatus,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      name: json['name'],
      email: json['email'],
      appleUniqueId: json['apple_unique_id'],
      appleEmail: json['apple_email'],
      googleUniqueId: json['google_unique_id'],
      facebookUniqueId: json['facebook_unique_id'],
      deviceId: json['device_id'],
      emailVerifiedAt: json['email_verified_at'],
      loyalty: json['loyalty'],
      provider: json['provider'],
      providerId: json['provider_id'],
      image: json['image'],
      phone: json['phone'],
      dob: json['dob'],
      gender: json['gender'],
      country: json['country'],
      state: json['state'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      city: json['city'],
      address: json['address'],
      appointment: json['appointment'],
      emailMarketing: json['email_marketing'],
      marketingNotification: json['marketing_notification'],
      status: json['status'],
      cancelCount: json['cancel_count'],
      isRestricted: json['is_restricted'],
      emailVerificationCode: json['email_verification_code'],
      passwordResetCode: json['password_reset_code'],
      completeStatus: json['complete_status'],
    );
  }
}
