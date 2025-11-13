// Model for checking if user exists (Social Auth)
class CheckUserExistsModel {
  final String email;
  final String name;
  final String firstName;
  final String lastName;

  CheckUserExistsModel({
    required this.email,
    required this.name,
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'first_name': firstName,
      'last_name': lastName,
    };
  }
}
