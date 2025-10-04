import 'package:app/models/create_user/ResponseData.dart';

class CreateUserResponse {
  final ResponseData? data;

  CreateUserResponse({this.data});

  factory CreateUserResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CreateUserResponse(data: null);
    }
    // Check for 'response.data' or 'data' structure
    final dataJson = json['response'] is Map<String, dynamic>?
        ? json['response']['data'] as Map<String, dynamic>?
        : json['data'] as Map<String, dynamic>?;
    return CreateUserResponse(
      data: dataJson != null ? ResponseData.fromJson(dataJson) : null,
    );
  }

  Map<String, dynamic>? toJson() {
    return {
      'data': data?.toJson(),
    };
  }
}