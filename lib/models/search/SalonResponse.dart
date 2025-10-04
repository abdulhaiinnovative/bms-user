

import 'package:app/models/home/SalonData.dart';

class SalonResponse {
  final int? statusCode;
  final ResponseData? response;
  final String? message;
  final bool? status;
  final List<dynamic>? errors;

  SalonResponse({
    this.statusCode,
    this.response,
    this.message,
    this.status,
    this.errors,
  });

  factory SalonResponse.fromJson(Map<String, dynamic> json) {
    return SalonResponse(
      statusCode: json['statusCode'] as int?,
      response: json['response'] != null
          ? ResponseData.fromJson(json['response'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
      status: json['status'] as bool?,
      errors: json['errors'] as List<dynamic>?,
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

class ResponseData {
  final XSalonData? data;

  ResponseData({this.data});

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      data: json['data'] != null
          ? XSalonData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
    };
  }
}

class XSalonData {
  final Salons? salons;

  XSalonData({this.salons});

  factory XSalonData.fromJson(Map<String, dynamic> json) {
    return XSalonData(
      salons: json['salons'] != null
          ? Salons.fromJson(json['salons'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salons': salons?.toJson(),
    };
  }
}

class Salons {
  final int? currentPage;
  final List<SalonData>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  //final List<Link>? links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  Salons({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    // this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory Salons.fromJson(Map<String, dynamic> json) {
    return Salons(
      currentPage: json['current_page'] as int?,
      data: json['data'] != null
          ? (json['data'] as List<dynamic>)
          .map((item) => SalonData.fromJson(item as Map<String, dynamic>))
          .toList()
          : null,
      firstPageUrl: json['first_page_url'] as String?,
      from: json['from'] as int?,
      lastPage: json['last_page'] as int?,
      lastPageUrl: json['last_page_url'] as String?,
      // links: json['links'] != null
      //     ? (json['links'] as List<dynamic>)
      //     .map((item) => Link.fromJson(item as Map<String, dynamic>))
      //     .toList()
      //     : null,
      nextPageUrl: json['next_page_url'] as String?,
      path: json['path'] as String?,
      perPage: json['per_page'] as int?,
      prevPageUrl: json['prev_page_url'] as String?,
      to: json['to'] as int?,
      total: json['total'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'data': data?.map((salon) => salon.toJson()).toList(),
      'first_page_url': firstPageUrl,
      'from': from,
      'last_page': lastPage,
      'last_page_url': lastPageUrl,
      // 'links': links?.map((link) => link.toJson()).toList(),
      'next_page_url': nextPageUrl,
      'path': path,
      'per_page': perPage,
      'prev_page_url': prevPageUrl,
      'to': to,
      'total': total,
    };
  }
}

