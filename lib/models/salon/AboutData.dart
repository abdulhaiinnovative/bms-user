import '../home/ActiveDay.dart';

class AboutData {
  final String? desc;
  final List<ActiveDay>? opening_timings;
  final String? address;
  final String? lat_long;

  AboutData({this.desc, this.opening_timings, this.address, this.lat_long});

  factory AboutData.fromJson(Map<String, dynamic> json) {
    return AboutData(
      desc: json['desc'] as String?,
      opening_timings: (json['opening_timings'] as List<dynamic>?)?.map((e) => ActiveDay.fromJson(e as Map<String, dynamic>)).toList(),
      address: json['address'] as String?,
      lat_long: json['lat_long'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'desc': desc,
      'opening_timings': opening_timings?.map((e) => e.toJson()).toList(),
      'address': address,
      'lat_long': lat_long,
    };
  }
}