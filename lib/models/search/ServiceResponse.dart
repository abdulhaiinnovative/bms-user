
import 'package:app/models/home/ServiceData.dart';

class ServiceResponse {
  final int? statusCode;
  final ResponseData? response;
  final String? message;
  final bool? status;
  final List<dynamic>? errors;

  ServiceResponse({
    this.statusCode,
    this.response,
    this.message,
    this.status,
    this.errors,
  });

  factory ServiceResponse.fromJson(Map<String, dynamic> json) {
    return ServiceResponse(
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
  final XServiceData? data;

  ResponseData({this.data});

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      data: json['data'] != null
          ? XServiceData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
    };
  }
}

class XServiceData {
  final Services? services;

  XServiceData({this.services});

  factory XServiceData.fromJson(Map<String, dynamic> json) {
    return XServiceData(
      services: json['services'] != null
          ? Services.fromJson(json['services'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'services': services?.toJson(),
    };
  }
}

class Services {
  final int? currentPage;
  final List<ServiceData>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<Link>? links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  Services({
    this.currentPage,
    this.data,
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory Services.fromJson(Map<String, dynamic> json) {
    return Services(
      currentPage: json['current_page'] as int?,
      data: json['data'] != null
          ? (json['data'] as List<dynamic>)
          .map((item) => ServiceData.fromJson(item as Map<String, dynamic>))
          .toList()
          : null,
      firstPageUrl: json['first_page_url'] as String?,
      from: json['from'] as int?,
      lastPage: json['last_page'] as int?,
      lastPageUrl: json['last_page_url'] as String?,
      links: json['links'] != null
          ? (json['links'] as List<dynamic>)
          .map((item) => Link.fromJson(item as Map<String, dynamic>))
          .toList()
          : null,
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
      'data': data?.map((service) => service.toJson()).toList(),
      'first_page_url': firstPageUrl,
      'from': from,
      'last_page': lastPage,
      'last_page_url': lastPageUrl,
      'links': links?.map((link) => link.toJson()).toList(),
      'next_page_url': nextPageUrl,
      'path': path,
      'per_page': perPage,
      'prev_page_url': prevPageUrl,
      'to': to,
      'total': total,
    };
  }
}

class Link {
  final String? url;
  final String? label;
  final bool? active;

  Link({this.url, this.label, this.active});

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      url: json['url'] as String?,
      label: json['label'] as String?,
      active: json['active'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'label': label,
      'active': active,
    };
  }
}