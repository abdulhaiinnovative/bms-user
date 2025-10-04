
import 'ResponseData.dart';

class HomeApiResponse {
  final int? statusCode;
  final ResponseData? response;

  HomeApiResponse({this.statusCode, this.response});

  factory HomeApiResponse.fromJson(Map<String, dynamic> json) {
    return HomeApiResponse(
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