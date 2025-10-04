import 'SalonDataWrapper.dart';
import 'ResponseData.dart';


class SalonResponseData {
  final int? statusCode;
  final ResponseData? response;

  SalonResponseData({this.statusCode, this.response});

  factory SalonResponseData.fromJson(Map<String, dynamic> json) {
    return SalonResponseData(
      statusCode: json['statusCode'] as int?,
      response: json['response'] != null ? ResponseData.fromJson(json['response'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'response': response?.toJson(),
    };
  }
}