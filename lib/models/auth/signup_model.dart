class SignupModel {
  final String firstName;
  final String lastName;
  final String phone;
  final String name;
  final String email;
  final String password;

  SignupModel({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.name,
    required this.email,
    required this.password,
  });

  factory SignupModel.fromJson(Map<String, dynamic> json) {
    return SignupModel(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'name': name,
      'email': email,
      'password': password,
    };
  }
}