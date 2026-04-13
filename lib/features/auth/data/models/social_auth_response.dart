// Social Auth Response Model
class SocialAuthResponse {
  final bool status;
  final bool? isComplete;
  final String message;
  final SocialAuthData? data;
  final Map<String, dynamic>? errors;

  SocialAuthResponse({
    required this.status,
    this.isComplete,
    required this.message,
    this.data,
    this.errors,
  });

  factory SocialAuthResponse.fromJson(Map<String, dynamic> json) {
    return SocialAuthResponse(
      status: json['status'] ?? false,
      isComplete: json['is_complete'],
      message: json['message'] ?? '',
      data: json['data'] != null ? SocialAuthData.fromJson(json['data']) : null,
      errors: json['errors'],
    );
  }
}

class SocialAuthData {
  final SocialUserData user;
  final List<LoyaltyTransaction> loyaltyTransactions;
  final String accessToken;

  SocialAuthData({
    required this.user,
    required this.loyaltyTransactions,
    required this.accessToken,
  });

  factory SocialAuthData.fromJson(Map<String, dynamic> json) {
    return SocialAuthData(
      user: SocialUserData.fromJson(json['user']),
      loyaltyTransactions: (json['loyaltyTransactions'] as List?)
              ?.map((e) => LoyaltyTransaction.fromJson(e))
              .toList() ??
          [],
      accessToken: json['accessToken'] ?? '',
    );
  }
}

class SocialUserData {
  final int id;
  final String firstName;
  final String lastName;
  final String name;
  final String email;
  final String? provider;
  final String? providerId;
  final String? phone;
  final String? dob;
  final String? gender;
  final String? country;
  final String? city;
  final String? address;
  final int? loyalty;
  final int status;
  final int cancelCount;
  final int isRestricted;
  final String? image;
  final int appointment;
  final int emailMarketing; // Changed from bool to int
  final int marketingNotification; // Changed from bool to int
  final int completeStatus;

  SocialUserData({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.email,
    this.provider,
    this.providerId,
    this.phone,
    this.dob,
    this.gender,
    this.country,
    this.city,
    this.address,
    this.loyalty,
    required this.status,
    required this.cancelCount,
    required this.isRestricted,
    this.image,
    required this.appointment,
    required this.emailMarketing,
    required this.marketingNotification,
    required this.completeStatus,
  });

  factory SocialUserData.fromJson(Map<String, dynamic> json) {
    return SocialUserData(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      provider: json['provider'],
      providerId: json['provider_id'],
      phone: json['phone'],
      dob: json['dob'],
      gender: json['gender'],
      country: json['country'],
      city: json['city'],
      address: json['address'],
      loyalty: json['loyalty'],
      status: json['status'] ?? 0,
      cancelCount: json['cancel_count'] ?? 0,
      isRestricted: json['is_restricted'] ?? 0,
      image: json['image'],
      appointment: json['appointment'] ?? 0,
      emailMarketing: json['email_marketing'] ?? 0, // Parse as int
      marketingNotification:
          json['marketing_notification'] ?? 0, // Parse as int
      completeStatus: json['complete_status'] ?? 60,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'name': name,
      'email': email,
      'provider': provider,
      'provider_id': providerId,
      'phone': phone,
      'dob': dob,
      'gender': gender,
      'country': country,
      'city': city,
      'address': address,
      'loyalty': loyalty,
      'status': status,
      'cancel_count': cancelCount,
      'is_restricted': isRestricted,
      'image': image,
      'appointment': appointment,
      'email_marketing': emailMarketing,
      'marketing_notification': marketingNotification,
      'complete_status': completeStatus,
    };
  }
}

class LoyaltyTransaction {
  final int id;
  final String type;
  final int points;
  final String description;
  final String createdAt;

  LoyaltyTransaction({
    required this.id,
    required this.type,
    required this.points,
    required this.description,
    required this.createdAt,
  });

  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransaction(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      points: json['points'] ?? 0,
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
