class AuthResponse {
  final int statusCode;
  final bool success;
  final String message;
  final AuthData? data;

  AuthResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      statusCode: json['statusCode'] ?? json['status_code'] ?? 200,
      success: json['status'] ?? json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class AuthData {
  final String? token;
  final String? refreshToken;
  final UserData? user;
  final List<dynamic>? loyaltyTransactions;

  AuthData({
    this.token,
    this.refreshToken,
    this.user,
    this.loyaltyTransactions,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['accessToken'] ?? json['token'],
      refreshToken: json['refreshToken'],
      user: json['user'] != null ? UserData.fromJson(json['user']) : null,
      loyaltyTransactions: json['loyaltyTransactions'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'user': user?.toJson(),
      'loyaltyTransactions': loyaltyTransactions,
    };
  }
}

class UserData {
  final int id;
  final String name;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? profilePicture;
  final String? role;
  final int? status;
  final bool? isNumberVerified;
  final String? deviceToken;
  final int? loyalty;
  final int? appointment;
  final int? emailMarketing;
  final int? marketingNotification;
  final int? cancelCount;
  final int? isRestricted;
  final int? completeStatus;
  final String? appleUniqueId;
  final String? appleEmail;
  final String? googleUniqueId;
  final String? facebookUniqueId;
  final String? provider;
  final String? providerId;
  final String? dob;
  final String? gender;
  final String? country;
  final String? state;
  final String? city;
  final String? address;
  final String? latitude;
  final String? longitude;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.profilePicture,
    this.role,
    this.status,
    this.isNumberVerified,
    this.deviceToken,
    this.loyalty,
    this.appointment,
    this.emailMarketing,
    this.marketingNotification,
    this.cancelCount,
    this.isRestricted,
    this.completeStatus,
    this.appleUniqueId,
    this.appleEmail,
    this.googleUniqueId,
    this.facebookUniqueId,
    this.provider,
    this.providerId,
    this.dob,
    this.gender,
    this.country,
    this.state,
    this.city,
    this.address,
    this.latitude,
    this.longitude,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] is String
          ? int.tryParse(json['id']) ?? 0
          : json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName:
          json['first_name']?.toString() ?? json['firstName']?.toString(),
      lastName: json['last_name']?.toString() ?? json['lastName']?.toString(),
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString(),
      profilePicture: json['image']?.toString() ??
          json['profile_picture']?.toString() ??
          json['profilePicture']?.toString(),
      role: json['role']?.toString(),
      status: json['status'] is String
          ? int.tryParse(json['status'])
          : json['status'],
      isNumberVerified: json['is_number_verified'] ?? json['isNumberVerified'],
      deviceToken: json['device_id']?.toString() ??
          json['device_token']?.toString() ??
          json['deviceToken']?.toString(),
      loyalty: json['loyalty'] is String
          ? int.tryParse(json['loyalty'])
          : json['loyalty'],
      appointment: json['appointment'] is String
          ? int.tryParse(json['appointment'])
          : json['appointment'],
      emailMarketing: json['email_marketing'] is String
          ? int.tryParse(json['email_marketing'])
          : json['email_marketing'],
      marketingNotification: json['marketing_notification'] is String
          ? int.tryParse(json['marketing_notification'])
          : json['marketing_notification'],
      cancelCount: json['cancel_count'] is String
          ? int.tryParse(json['cancel_count'])
          : json['cancel_count'],
      isRestricted: json['is_restricted'] is String
          ? int.tryParse(json['is_restricted'])
          : json['is_restricted'],
      completeStatus: json['complete_status'] is String
          ? int.tryParse(json['complete_status'])
          : json['complete_status'],
      appleUniqueId: json['apple_unique_id']?.toString(),
      appleEmail: json['apple_email']?.toString(),
      googleUniqueId: json['google_unique_id']?.toString(),
      facebookUniqueId: json['facebook_unique_id']?.toString(),
      provider: json['provider']?.toString(),
      providerId: json['provider_id']?.toString(),
      dob: json['dob']?.toString(),
      gender: json['gender']?.toString(),
      country: json['country']?.toString(),
      state: json['state']?.toString(),
      city: json['city']?.toString(),
      address: json['address']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'image': profilePicture,
      'role': role,
      'status': status,
      'is_number_verified': isNumberVerified,
      'device_token': deviceToken,
      'loyalty': loyalty,
      'appointment': appointment,
      'email_marketing': emailMarketing,
      'marketing_notification': marketingNotification,
      'cancel_count': cancelCount,
      'is_restricted': isRestricted,
      'complete_status': completeStatus,
      'apple_unique_id': appleUniqueId,
      'apple_email': appleEmail,
      'google_unique_id': googleUniqueId,
      'facebook_unique_id': facebookUniqueId,
      'provider': provider,
      'provider_id': providerId,
      'dob': dob,
      'gender': gender,
      'country': country,
      'state': state,
      'city': city,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
