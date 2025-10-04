import 'SalonData.dart';

class Type3 {
  final String? heading;
  final List<SalonData>? data;

  Type3({this.heading, this.data});

  factory Type3.fromJson(Map<String, dynamic> json) {
    return Type3(
      heading: json['heading'] as String?,
      data: (json['data'] as List<dynamic>?)?.map((e) => SalonData.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heading': heading,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}