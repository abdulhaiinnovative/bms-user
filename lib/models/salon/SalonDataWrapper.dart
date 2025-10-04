import 'Section.dart';
import 'Location.dart';

class SalonDataWrapper {
  final String? name;
  final int? id;
  final List<String>? images;
  final String? created_at;
  final String? gender;
  final String? logo;
  final int? star;
  final bool? is_favourite;
  final List<Section>? sections;
  final Location? location;

  SalonDataWrapper({
    this.name,
    this.id,
    this.images,
    this.created_at,
    this.gender,
    this.logo,
    this.star,
    this.is_favourite,
    this.sections,
    this.location,
  });

  factory SalonDataWrapper.fromJson(Map<String, dynamic> json) {
    return SalonDataWrapper(
      name: json['name'] as String?,
      id: json['id'] as int?,
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
      created_at: json['created_at'] as String?,
      gender: json['gender'] as String?,
      logo: json['logo'] as String?,
      star: json['star'] as int?,
      is_favourite: json['is_favourite'] as bool?,
      sections: (json['sections'] as List<dynamic>?)?.map((e) => Section.fromJson(e as Map<String, dynamic>)).toList(),
      location: json['location'] != null ? Location.fromJson(json['location'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'images': images,
      'created_at': created_at,
      'gender': gender,
      'logo': logo,
      'star': star,
      'is_favourite': is_favourite,
      'sections': sections?.map((e) => e.toJson()).toList(),
      'location': location?.toJson(),
    };
  }
}