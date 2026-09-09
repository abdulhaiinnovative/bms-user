// Model for checking if user exists (Social Auth)
class CheckUserExistsModel {
  final String email;
  final String name;
  final String firstName;
  final String lastName;
  final String? fcmToken;

  CheckUserExistsModel({
    required this.email,
    required this.name,
    required this.firstName,
    required this.lastName,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'name': name,
      'first_name': firstName,
      'last_name': lastName,
    };
    if (fcmToken != null) {
      data['fcm_token'] = fcmToken;
    }
    return data;
  }
}
