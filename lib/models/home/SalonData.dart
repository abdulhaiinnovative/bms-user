
import 'ActiveDay.dart';

class SalonData {
  final int? id;
  final int? vendor_id;
  final String? name;
  final String? logo;
  final String? image;
  final String? country;
  final String? state;
  final String? city;
  final String? area;
  final String? address;
  final String? latitude;
  final String? longitude;
  final String? min_booking_time;
  final String? max_booking_time;
  final String? min_cancellation_time;
  final String? type;
  final String? facebook;
  final String? instagram;
  final String? linkedin;
  final String? twitter;
  final String? salon_for;
  final String? map_location;
  final String? salon_policy;
  final String? additional_information;
  final String? about;
  final int? status;
  final int? suspended;
  final double? average_rating;
  final int? review_count;
  final bool? is_favourite;
  final List<ActiveDay>? active_days;
  final List<String>? images;

  SalonData({
    this.id,
    this.vendor_id,
    this.name,
    this.logo,
    this.image,
    this.country,
    this.state,
    this.city,
    this.area,
    this.address,
    this.latitude,
    this.longitude,
    this.min_booking_time,
    this.max_booking_time,
    this.min_cancellation_time,
    this.type,
    this.facebook,
    this.instagram,
    this.linkedin,
    this.twitter,
    this.salon_for,
    this.map_location,
    this.salon_policy,
    this.additional_information,
    this.about,
    this.status,
    this.suspended,
    this.average_rating,
    this.review_count,
    this.is_favourite,
    this.active_days,
    this.images,
  });

  factory SalonData.fromJson(Map<String, dynamic> json) {
    return SalonData(
      id: (json['id'] as num?)?.toInt(),
      vendor_id: (json['vendor_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      logo: json['logo'] as String?,
      image: json['image'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      area: json['area'] as String?,
      address: json['address'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      min_booking_time: json['min_booking_time'] as String?,
      max_booking_time: json['max_booking_time'] as String?,
      min_cancellation_time: json['min_cancellation_time'] as String?,
      type: json['type'] as String?,
      facebook: json['facebook'] as String?,
      instagram: json['instagram'] as String?,
      linkedin: json['linkedin'] as String?,
      twitter: json['twitter'] as String?,
      salon_for: json['salon_for'] as String?,
      map_location: json['map_location'] as String?,
      salon_policy: json['salon_policy'] as String?,
      additional_information: json['additional_information'] as String?,
      about: json['about'] as String?,
      status: (json['status'] as num?)?.toInt(),
      suspended: (json['suspended'] as num?)?.toInt(),
      average_rating: (json['average_rating'] as num?)?.toDouble(),
      review_count: (json['review_count'] as num?)?.toInt(),
      is_favourite: json['is_favourite'] as bool?,
      active_days: (json['active_days'] as List<dynamic>?)?.map((e) => ActiveDay.fromJson(e as Map<String, dynamic>)).toList(),
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_id': vendor_id,
      'name': name,
      'logo': logo,
      'image': image,
      'country': country,
      'state': state,
      'city': city,
      'area': area,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'min_booking_time': min_booking_time,
      'max_booking_time': max_booking_time,
      'min_cancellation_time': min_cancellation_time,
      'type': type,
      'facebook': facebook,
      'instagram': instagram,
      'linkedin': linkedin,
      'twitter': twitter,
      'salon_for': salon_for,
      'map_location': map_location,
      'salon_policy': salon_policy,
      'additional_information': additional_information,
      'about': about,
      'status': status,
      'suspended': suspended,
      'average_rating': average_rating,
      'review_count': review_count,
      'is_favourite': is_favourite,
      'active_days': active_days?.map((e) => e.toJson()).toList(),
      'images': images,
    };
  }
}