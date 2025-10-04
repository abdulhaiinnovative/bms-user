class UserResponse {
  final String id;
  final String name;
  final String email;
  final String password;
  final String status;
  final String role;
  final String? phoneNumber;
  final String? countryCode;
  final String? profilePicture;
  final bool isNumberVerified;
  // final String createdAt;
  // final String updatedAt;
  final String deviceToken;
  final int v;

  UserResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.status,
    required this.role,
    required this.phoneNumber,
    required this.countryCode,
    required this.profilePicture,
    required this.isNumberVerified,
    // required this.createdAt,
    // required this.updatedAt,
    required this.deviceToken,
    required this.v,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      status: json['status'],
      role: json['role'],
      phoneNumber: json['phoneNumber'],
      countryCode: json['countryCode'],
      profilePicture: json['profilePicture'],
      isNumberVerified: json['isNumberVerified'],
      // createdAt: json['createdAt'],
      // updatedAt: json['updatedAt'],
      deviceToken: json['deviceToken'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "email": email,
      "password": password,
      "status": status,
      "role": role,
      "phoneNumber": phoneNumber,
      "countryCode": countryCode,
      "profilePicture": profilePicture,
      "isNumberVerified": isNumberVerified,
      // "createdAt": createdAt,
      // "updatedAt": updatedAt,
      "deviceToken": deviceToken,

      "__v": v,
    };
  }
}
