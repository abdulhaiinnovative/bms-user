// Model for completing profile (Social Auth)
class CompleteProfileModel {
  final String email;
  final String? firstName;
  final String? lastName;
  final String? name;
  final String? deviceId;
  final String? provider;
  final String? providerId;
  final String? phone;
  final String? dob;
  final String? gender;
  final String? country;
  final String? state;
  final String? city;
  final String? address;
  final int? appointment;
  final bool? emailMarketing;
  final bool? marketingNotification;
  final String? image; // Can be file path or URL

  CompleteProfileModel({
    required this.email,
    this.firstName,
    this.lastName,
    this.name,
    this.deviceId,
    this.provider,
    this.providerId,
    this.phone,
    this.dob,
    this.gender,
    this.country,
    this.state,
    this.city,
    this.address,
    this.appointment,
    this.emailMarketing,
    this.marketingNotification,
    this.image,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
    };

    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (name != null) data['name'] = name;
    if (deviceId != null) data['device_id'] = deviceId;
    if (provider != null) data['provider'] = provider;
    if (providerId != null) data['provider_id'] = providerId;
    if (phone != null) data['phone'] = phone;
    if (dob != null) data['dob'] = dob;
    if (gender != null) data['gender'] = gender;
    if (country != null) data['country'] = country;
    if (state != null) data['state'] = state;
    if (city != null) data['city'] = city;
    if (address != null) data['address'] = address;
    if (appointment != null) data['appointment'] = appointment;
    if (emailMarketing != null) data['email_marketing'] = emailMarketing;
    if (marketingNotification != null) {
      data['marketing_notification'] = marketingNotification;
    }
    if (image != null) data['image'] = image;

    return data;
  }
}
