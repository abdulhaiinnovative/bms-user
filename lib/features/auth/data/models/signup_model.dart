class SignupModel {
  final String firstName;
  final String lastName;
  final String phone;
  final String name;
  final String email;
  final String password;
  final String? address;
  final String? fcmToken;

  SignupModel({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.name,
    required this.email,
    required this.password,
    this.address,
    this.fcmToken,
  });

  factory SignupModel.fromJson(Map<String, dynamic> json) {
    return SignupModel(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      address: json['address'],
      fcmToken: json['fcm_token'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'name': name,
      'email': email,
      'password': password,
    };

    if (address != null) data['address'] = address;
    if (fcmToken != null) data['fcm_token'] = fcmToken;

    return data;
  }
}
