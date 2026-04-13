class User {
  final int? id;
  final String? first_name;
  final String? last_name;
  final String? name;
  final String? email;
  final String? apple_unique_id;
  final String? apple_email;
  final String? google_unique_id;
  final String? facebook_unique_id;
  final String? device_id;
  final String? email_verified_at;
  final int? loyalty;
  final String? provider;
  final String? provider_id;
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
  final int? email_marketing;
  final int? marketing_notification;
  final int? status;
  final int? cancel_count;
  final int? is_restricted;
  final String? email_verification_code;
  final String? password_reset_code;
  final int? complete_status;

  User({
    this.id,
    this.first_name,
    this.last_name,
    this.name,
    this.email,
    this.apple_unique_id,
    this.apple_email,
    this.google_unique_id,
    this.facebook_unique_id,
    this.device_id,
    this.email_verified_at,
    this.loyalty,
    this.provider,
    this.provider_id,
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
    this.email_marketing,
    this.marketing_notification,
    this.status,
    this.cancel_count,
    this.is_restricted,
    this.email_verification_code,
    this.password_reset_code,
    this.complete_status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      first_name: json['first_name'] as String?,
      last_name: json['last_name'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      apple_unique_id: json['apple_unique_id'] as String?,
      apple_email: json['apple_email'] as String?,
      google_unique_id: json['google_unique_id'] as String?,
      facebook_unique_id: json['facebook_unique_id'] as String?,
      device_id: json['device_id'] as String?,
      email_verified_at: json['email_verified_at'] as String?,
      loyalty: json['loyalty'] as int?,
      provider: json['provider'] as String?,
      provider_id: json['provider_id'] as String?,
      image: json['image'] as String?,
      phone: json['phone'] as String?,
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      appointment: json['appointment'] as int?,
      email_marketing: json['email_marketing'] as int?,
      marketing_notification: json['marketing_notification'] as int?,
      status: json['status'] as int?,
      cancel_count: json['cancel_count'] as int?,
      is_restricted: json['is_restricted'] as int?,
      email_verification_code: json['email_verification_code'] as String?,
      password_reset_code: json['password_reset_code'] as String?,
      complete_status: json['complete_status'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': first_name,
      'last_name': last_name,
      'name': name,
      'email': email,
      'apple_unique_id': apple_unique_id,
      'apple_email': apple_email,
      'google_unique_id': google_unique_id,
      'facebook_unique_id': facebook_unique_id,
      'device_id': device_id,
      'email_verified_at': email_verified_at,
      'loyalty': loyalty,
      'provider': provider,
      'provider_id': provider_id,
      'image': image,
      'phone': phone,
      'dob': dob,
      'gender': gender,
      'country': country,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'address': address,
      'appointment': appointment,
      'email_marketing': email_marketing,
      'marketing_notification': marketing_notification,
      'status': status,
      'cancel_count': cancel_count,
      'is_restricted': is_restricted,
      'email_verification_code': email_verification_code,
      'password_reset_code': password_reset_code,
      'complete_status': complete_status,
    };
  }
}