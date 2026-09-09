

import 'ActiveDayMain.dart';
import 'ServiceMain.dart';

class SalonMain {
  final int id;
  final String name;
  final String image;
  final String country;
  final String city;
  final String address;
  final double latitude;
  final double longitude;
  final String about;
  final List<ServiceMain> services;
  final List<ActiveDayMain> activeDays;
  final double averageRating;
  final int reviewCount;
  final bool isFavourite;

  SalonMain({
    required this.id,
    required this.name,
    required this.image,
    required this.country,
    required this.city,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.about,
    required this.services,
    required this.activeDays,
    required this.averageRating,
    required this.reviewCount,
    required this.isFavourite,
  });

  factory SalonMain.fromJson(Map<String, dynamic> json) {
    return SalonMain(
      id: json['id'],
      name: json['name'],
      image: json['image'] ?? '',
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      latitude: double.tryParse(json['latitude'] ?? '0') ?? 0,
      longitude: double.tryParse(json['longitude'] ?? '0') ?? 0,
      about: json['about'] ?? '',
      services: (json['services'] as List?)?.map((e) => ServiceMain.fromJson(e)).toList() ?? [],
      activeDays: (json['active_days'] as List?)?.map((e) => ActiveDayMain.fromJson(e)).toList() ?? [],
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      isFavourite: json['is_favourite'] ?? false,
    );
  }
}