

import 'ServiceMain.dart';

class SearchServiceResponse {
  final int statusCode;
  final ResponseData response;
  final String message;
  final bool status;
  final List<dynamic> errors;

  SearchServiceResponse({
    required this.statusCode,
    required this.response,
    required this.message,
    required this.status,
    required this.errors,
  });

  factory SearchServiceResponse.fromJson(Map<String, dynamic> json) {
    return SearchServiceResponse(
      statusCode: json['statusCode'],
      response: ResponseData.fromJson(json['response']),
      message: json['message'],
      status: json['status'],
      errors: json['errors'] ?? [],
    );
  }
}

class ResponseData {
  final ServiceData data;

  ResponseData({required this.data});

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      data: ServiceData.fromJson(json['data']['services']),
    );
  }
}

class ServiceData {
  final int currentPage;
  final List<ServiceMain> services;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<PageLink> links;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  ServiceData({
    required this.currentPage,
    required this.services,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory ServiceData.fromJson(Map<String, dynamic> json) {
    return ServiceData(
      currentPage: json['current_page'],
      services: (json['data'] as List).map((e) => ServiceMain.fromJson(e)).toList(),
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      links: (json['links'] as List).map((e) => PageLink.fromJson(e)).toList(),
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'],
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
