import 'CategoryData.dart';


class Type2 {
  final String? heading;
  final List<CategoryData>? data;

  Type2({this.heading, this.data});

  factory Type2.fromJson(Map<String, dynamic> json) {
    return Type2(
      heading: json['heading'] as String?,
      data: (json['data'] as List<dynamic>?)?.map((e) => CategoryData.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heading': heading,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}