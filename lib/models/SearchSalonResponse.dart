import 'dart:convert';

import 'package:app/models/SalonMain.dart';

class SearchSalonResponse {
  final int? statusCode;
  final ResponseData? response;
  final String? message;
  final bool? status;
  final List<dynamic>? errors;

  SearchSalonResponse({
    this.statusCode,
    this.response,
    this.message,
    this.status,
    this.errors,
  });

  factory SearchSalonResponse.fromJson(Map<String, dynamic> json) {
    return SearchSalonResponse(
      statusCode: json['statusCode'] as int?,
      response: json['response'] != null
          ? ResponseData.fromJson(json['response'])
          : null,
      message: json['message'] as String?,
      status: json['status'] as bool?,
      errors: json['errors'] as List<dynamic>?,
    );
  }
}


class ResponseData {
  final SalonData? data;

  ResponseData({this.data});

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      data: json['data'] != null && json['data']['salons'] != null
          ? SalonData.fromJson(json['data'])
          : null,
    );
  }
}


class SalonData {
  final int? currentPage;
  final List<SalonMain>? salons;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<PageLink>? links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  SalonData({
    this.currentPage,
    this.salons,
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

  factory SalonData.fromJson(Map<String, dynamic> json) {
    return SalonData(
      currentPage: json['current_page'] as int?,
      salons: (json['data'] as List<dynamic>?)
          ?.map((e) => SalonMain.fromJson(e))
          .toList(),
      firstPageUrl: json['first_page_url'] as String?,
      from: json['from'] as int?,
      lastPage: json['last_page'] as int?,
      lastPageUrl: json['last_page_url'] as String?,
      links: (json['links'] as List<dynamic>?)
          ?.map((e) => PageLink.fromJson(e))
          .toList(),
      nextPageUrl: json['next_page_url'] as String?,
      path: json['path'] as String?,
      perPage: json['per_page'] as int?,
      prevPageUrl: json['prev_page_url'] as String?,
      to: json['to'] as int?,
      total: json['total'] as int?,
    );
  }
}








class PageLink {
  final String? url;
  final String label;
  final bool active;

  PageLink({this.url, required this.label, required this.active});

  factory PageLink.fromJson(Map<String, dynamic> json) {
    return PageLink(
      url: json['url'],
      label: json['label'],
      active: json['active'],
    );
  }
}
