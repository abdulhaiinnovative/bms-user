class MyAccountResponse {
  final int statusCode;
  final String message;
  final bool status;
  final List<String> errors; // Changed to List<String> assuming errors are strings
  final UserProfileData? response;

  MyAccountResponse({
    required this.statusCode,
    required this.message,
    required this.status,
    required this.errors,
    this.response,
  });

  factory MyAccountResponse.fromJson(Map<String, dynamic> json) {
    return MyAccountResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      status: json['status'] as bool? ?? false,
      errors: (json['errors'] as List<dynamic>?)?.cast<String>() ?? [],
      response: json['response'] != null
          ? UserProfileData.fromJson(json['response'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'message': message,
      'status': status,
      'errors': errors,
      'response': response?.toJson(),
    };
  }
}

class UserProfileData {
  final UserData? user;
  final List<dynamic> loyaltyTransactions; // Use List<LoyaltyTransaction> if structure is known

  UserProfileData({
    this.user,
    required this.loyaltyTransactions,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      user: json['data']?['user'] != null
          ? UserData.fromJson(json['data']['user'] as Map<String, dynamic>)
          : null,
      loyaltyTransactions: (json['data']?['loyaltyTransactions'] as List<dynamic>?) ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'user': user?.toJson(),
        'loyaltyTransactions': loyaltyTransactions,
      },
    };
  }
}

class UserData {
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
  final String? provider;
  final String? providerId;
  final String? phone;
  final String? dob;
  final String? gender;
  final String? country;
  final String? state;
  final String? city;
  final String? address;
  final String? latitude;
  final String? longitude;
  final int? loyalty;
  final String? image;
  final int? appointment;
  final int? emailMarketing;
  final int? marketingNotification;
  final int? status;
  final int? cancelCount;
  final int? isRestricted;
  final String? emailVerificationCode;
  final String? passwordResetCode;
  final int? completeStatus;

  UserData({
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
    this.provider,
    this.providerId,
    this.phone,
    this.dob,
    this.gender,
    this.country,
    this.state,
    this.city,
    this.address,
    this.latitude,
    this.longitude,
    this.loyalty,
    this.image,
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

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as int?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      appleUniqueId: json['apple_unique_id'] as String?,
      appleEmail: json['apple_email'] as String?,
      googleUniqueId: json['google_unique_id'] as String?,
      facebookUniqueId: json['facebook_unique_id'] as String?,
      deviceId: json['device_id'] as String?,
      emailVerifiedAt: json['email_verified_at'] as String?,
      provider: json['provider'] as String?,
      providerId: json['provider_id'] as String?,
      phone: json['phone'] as String?,
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      loyalty: json['loyalty'] as int?,
      image: json['image'] as String?,
      appointment: json['appointment'] as int?,
      emailMarketing: json['email_marketing'] as int?,
      marketingNotification: json['marketing_notification'] as int?,
      status: json['status'] as int?,
      cancelCount: json['cancel_count'] as int?,
      isRestricted: json['is_restricted'] as int?,
      emailVerificationCode: json['email_verification_code'] as String?,
      passwordResetCode: json['password_reset_code'] as String?,
      completeStatus: json['complete_status'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'name': name,
      'email': email,
      'apple_unique_id': appleUniqueId,
      'apple_email': appleEmail,
      'google_unique_id': googleUniqueId,
      'facebook_unique_id': facebookUniqueId,
      'device_id': deviceId,
      'email_verified_at': emailVerifiedAt,
      'provider': provider,
      'provider_id': providerId,
      'phone': phone,
      'dob': dob,
      'gender': gender,
      'country': country,
      'state': state,
      'city': city,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'loyalty': loyalty,
      'image': image,
      'appointment': appointment,
      'email_marketing': emailMarketing,
      'marketing_notification': marketingNotification,
      'status': status,
      'cancel_count': cancelCount,
      'is_restricted': isRestricted,
      'email_verification_code': emailVerificationCode,
      'password_reset_code': passwordResetCode,
      'complete_status': completeStatus,
    };
  }
}