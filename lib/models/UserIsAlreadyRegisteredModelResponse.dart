class UserIsAlreadyRegisteredModelResponse {
  final bool status;
  final bool isComplete;
  final String message;
  final Data data;

  UserIsAlreadyRegisteredModelResponse({
    required this.status,
    required this.isComplete,
    required this.message,
    required this.data,
  });

  factory UserIsAlreadyRegisteredModelResponse.fromJson(Map<String, dynamic> json) {
    return UserIsAlreadyRegisteredModelResponse(
      status: json['status'] ?? false,
      isComplete: json['is_complete'] ?? false,
      message: json['message'] ?? '',
      data: Data.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'is_complete': isComplete,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class Data {
  final User user;
  final List<dynamic> loyaltyTransactions;
  final String accessToken;

  Data({
    required this.user,
    required this.loyaltyTransactions,
    required this.accessToken,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      user: User.fromJson(json['user'] ?? {}),
      loyaltyTransactions: json['loyaltyTransactions'] ?? [],
      accessToken: json['accessToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'loyaltyTransactions': loyaltyTransactions,
      'accessToken': accessToken,
    };
  }
}

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String name;
  final String email;
  final String? appleUniqueId;
  final String? googleUniqueId;
  final String? facebookUniqueId;
  final String? image;
  final String? phone;
  final String? dob;
  final String? gender;
  final String? country;
  final String? city;
  final String? address;
  final int appointment;
  final int emailMarketing;
  final int marketingNotification;
  final int status;
  final int cancelCount;
  final int isRestricted;
  final int completeStatus;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.email,
    this.appleUniqueId,
    this.googleUniqueId,
    this.facebookUniqueId,
    this.image,
    this.phone,
    this.dob,
    this.gender,
    this.country,
    this.city,
    this.address,
    required this.appointment,
    required this.emailMarketing,
    required this.marketingNotification,
    required this.status,
    required this.cancelCount,
    required this.isRestricted,
    required this.completeStatus,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      appleUniqueId: json['apple_unique_id'],
      googleUniqueId: json['google_unique_id'],
      facebookUniqueId: json['facebook_unique_id'],
      image: json['image'],
      phone: json['phone'],
      dob: json['dob'],
      gender: json['gender'],
      country: json['country'],
      city: json['city'],
      address: json['address'],
      appointment: json['appointment'] ?? 0,
      emailMarketing: json['email_marketing'] ?? 0,
      marketingNotification: json['marketing_notification'] ?? 0,
      status: json['status'] ?? 0,
      cancelCount: json['cancel_count'] ?? 0,
      isRestricted: json['is_restricted'] ?? 0,
      completeStatus: json['complete_status'] ?? 0,
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
      'google_unique_id': googleUniqueId,
      'facebook_unique_id': facebookUniqueId,
      'image': image,
      'phone': phone,
      'dob': dob,
      'gender': gender,
      'country': country,
      'city': city,
      'address': address,
      'appointment': appointment,
      'email_marketing': emailMarketing,
      'marketing_notification': marketingNotification,
      'status': status,
      'cancel_count': cancelCount,
      'is_restricted': isRestricted,
      'complete_status': completeStatus,
    };
  }
}
