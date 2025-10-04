
import 'package:app/models/home/DealData.dart';

class DealResponse {
  final int? statusCode;
  final ResponseData? response;
  final String? message;
  final bool? status;
  final List<dynamic>? errors;

  DealResponse({
    this.statusCode,
    this.response,
    this.message,
    this.status,
    this.errors,
  });

  factory DealResponse.fromJson(Map<String, dynamic> json) {
    return DealResponse(
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
  final XDealData? data;

  ResponseData({this.data});

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      data: json['data'] != null
          ? XDealData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
    };
  }
}

class XDealData {
  final XDeals? deals;

  XDealData({this.deals});

  factory XDealData.fromJson(Map<String, dynamic> json) {
    return XDealData(
      deals: json['deals'] != null
          ? XDeals.fromJson(json['deals'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deals': deals?.toJson(),
    };
  }
}

class XDeals {
  final int? currentPage;
  final List<DealData>? data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  // final List<Link>? links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  XDeals({
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

  factory XDeals.fromJson(Map<String, dynamic> json) {
    return XDeals(
      currentPage: json['current_page'] as int?,
      data: json['data'] != null
          ? (json['data'] as List<dynamic>)
          .map((item) => DealData.fromJson(item as Map<String, dynamic>))
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
      'data': data?.map((deal) => deal.toJson()).toList(),
      'first_page_url': firstPageUrl,
      'from': from,
      'last_page': lastPage,
      'last_page_url': lastPageUrl,
      //'links': links?.map((link) => link.toJson()).toList(),
      'next_page_url': nextPageUrl,
      'path': path,
      'per_page': perPage,
      'prev_page_url': prevPageUrl,
      'to': to,
      'total': total,
    };
  }
}




