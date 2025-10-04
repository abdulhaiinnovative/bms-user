

class UserIsAlreadyRegisteredModel {
  String? id;
  String? name;
  String? first_name;
  String? last_name;
  String? email;
  String? profile_image;

  UserIsAlreadyRegisteredModel({
    this.id,
    this.name,
    this.first_name,
    this.last_name,
    this.email,
    this.profile_image
  });

  UserIsAlreadyRegisteredModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    first_name = json['first_name'];
    last_name = json['last_name'];
    email = json['email'];
    profile_image = json['profile_image'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    data['first_name'] = first_name;
    data['last_name'] = last_name;
    data['email'] = email;
    data['profile_image'] = profile_image;
    return data;
  }
}
