// In SalonServicesCategorizedResponse.dart
import 'HomePageResponse.dart'; // Assuming this contains Service and Deal models

class SalonServicesCategorizedResponse {
  int? statusCode;
  ResponseData? response;

  SalonServicesCategorizedResponse({
    this.statusCode,
    this.response,
  });

  factory SalonServicesCategorizedResponse.fromJson(Map<String, dynamic> json) {
    return SalonServicesCategorizedResponse(
      statusCode: json['statusCode'] as int?,
      response: json['response'] != null
          ? ResponseData.fromJson(json['response'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'response': response?.toJson(),
    };
  }
}

class ResponseData {
  List<Category>? data;
  String? message;
  bool? status;
  List<dynamic>? errors;

  ResponseData({
    this.data,
    this.message,
    this.status,
    this.errors,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      data: json['data'] != null
          ? (json['data'] as List<dynamic>)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList()
          : null,
      message: json['message'] as String?,
      status: json['status'] as bool?,
      errors: json['errors'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.map((e) => e.toJson()).toList(),
      'message': message,
      'status': status,
      'errors': errors,
    };
  }
}

class Category {
  int? id;
  String? name;
  String? description;
  int? status;
  bool? isServices;
  List<dynamic>? items; // Single array to hold either Service or Deal objects

  Category({
    this.id,
    this.name,
    this.description,
    this.status,
    this.isServices,
    this.items,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final isServices = json['is_services'] as bool?;
    List<dynamic>? items;

    if (isServices == true && json['services'] != null) {
      items = (json['services'] as List<dynamic>)
          .map((e) => Service.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (isServices == false && json['deals'] != null) {
      items = (json['deals'] as List<dynamic>)
          .map((e) => Deal.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return Category(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      status: json['status'] as int?,
      isServices: isServices,
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'is_services': isServices,
      if (isServices == true && items != null) 'services': items,
      if (isServices == false && items != null) 'deals': items,
    };
  }
}