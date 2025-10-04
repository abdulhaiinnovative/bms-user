import 'Section.dart';
import 'Location.dart';


class SalonDetailsData {
  final String? name;
  final int? id;
  final List<String>? images;
  final String? gender;
  final int? star;
  final Location? location;
  final List<Section>? sections;

  SalonDetailsData({this.name, this.id, this.images, this.gender, this.star, this.location, this.sections});

  factory SalonDetailsData.fromJson(Map<String, dynamic> json) {
    return SalonDetailsData(
      name: json['name'] as String?,
      id: json['id'] as int?,
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
      gender: json['gender'] as String?,
      star: json['star'] as int?,
      location: json['location'] != null ? Location.fromJson(json['location'] as Map<String, dynamic>) : null,
      sections: (json['sections'] as List<dynamic>?)?.map((e) => Section.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'images': images,
      'gender': gender,
      'star': star,
      'location': location?.toJson(),
      'sections': sections?.map((e) => e.toJson()).toList(),
    };
  }
}