import 'SalonResponseData.dart';

class SalonApiResponse {
  final int? statusCode;
  final SalonResponseData? response;

  SalonApiResponse({this.statusCode, this.response});

  factory SalonApiResponse.fromJson(Map<String, dynamic> json) {
    return SalonApiResponse(
      statusCode: json['statusCode'] as int?,
      response: json['response'] != null ? SalonResponseData.fromJson(json['response'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'response': response?.toJson(),
    };
  }
}