import 'DealData.dart';

class Type4 {
  final String? heading;
  final List<DealData>? data;

  Type4({this.heading, this.data});

  factory Type4.fromJson(Map<String, dynamic> json) {
    return Type4(
      heading: json['heading'] as String?,
      data: (json['data'] as List<dynamic>?)?.map((e) => DealData.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heading': heading,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}