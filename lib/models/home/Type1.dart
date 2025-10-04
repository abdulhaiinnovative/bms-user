import 'SliderData.dart';


class Type1 {
  final String? heading;
  final List<SliderData>? data;

  Type1({this.heading, this.data});

  factory Type1.fromJson(Map<String, dynamic> json) {
    return Type1(
      heading: json['heading'] as String?,
      data: (json['data'] as List<dynamic>?)?.map((e) => SliderData.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heading': heading,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}