import 'ServiceData.dart';

class Type5 {
  final String? heading;
  final List<ServiceData>? data;

  Type5({this.heading, this.data});

  factory Type5.fromJson(Map<String, dynamic> json) {
    return Type5(
      heading: json['heading'] as String?,
      data: (json['data'] as List<dynamic>?)?.map((e) => ServiceData.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heading': heading,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}