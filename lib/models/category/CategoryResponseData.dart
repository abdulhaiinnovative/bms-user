import 'dart:developer';
import 'ResponseData.dart';


class CategoryResponseData {
  final int? statusCode;
  final ResponseData? response;
  final String? message;
  final bool? status;
  final List<String>? errors;

  CategoryResponseData({
    this.statusCode,
    this.response,
    this.message,
    this.status,
    this.errors,
  });

  factory CategoryResponseData.fromJson(Map<String, dynamic> json) {
    final responseData = json['response'] != null
        ? ResponseData.fromJson(json['response'] as Map<String, dynamic>)
        : null;
    log('CategoryResponseData.fromJson: response.data is ${responseData?.data != null ? "not null" : "null"}');
    return CategoryResponseData(
      statusCode: json['statusCode'] as int?,
      response: responseData,
      message: json['message'] as String?,
      status: json['status'] as bool?,
      errors: (json['errors'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'response': response?.toJson(),
      'message': message,
      'status': status,
      'errors': errors,
    };
  }
}