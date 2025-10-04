import 'SalonDetailsData.dart';

class ResponseData {
  final SalonDetailsData? data;
  final String? message;
  final bool? status;
  final List<String>? errors;

  ResponseData({this.data, this.message, this.status, this.errors});

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      data: json['data'] != null ? SalonDetailsData.fromJson(json['data'] as Map<String, dynamic>) : null,
      message: json['message'] as String?,
      status: json['status'] as bool?,
      errors: (json['errors'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
      'message': message,
      'status': status,
      'errors': errors,
    };
  }
}