import 'CategoryDetailsData.dart';

class ResponseData {
  final CategoryDetailsData? data;

  ResponseData({this.data});

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      data: json['data'] != null
          ? CategoryDetailsData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
    };
  }
}