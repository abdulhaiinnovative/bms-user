import 'HomePageResponse.dart';

class ServicesResponse {
  final int statusCode;
  final ServicesData response;

  ServicesResponse({
    required this.statusCode,
    required this.response,
  });

  factory ServicesResponse.fromJson(Map<String, dynamic> json) {
    return ServicesResponse(
      statusCode: json['statusCode'] ?? 0,
      response: ServicesData.fromJson(json['response'] ?? {}),
    );
  }
}

class ServicesData {
  final bool success;
  final String message;
  final ServicesPaginatedData data;

  ServicesData({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ServicesData.fromJson(Map<String, dynamic> json) {
    return ServicesData(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ServicesPaginatedData.fromJson(json['data'] ?? {}),
    );
  }
}

class ServicesPaginatedData {
  final int currentPage;
  final List<Service> data;
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

  ServicesPaginatedData({
    required this.currentPage,
    required this.data,
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

  factory ServicesPaginatedData.fromJson(Map<String, dynamic> json) {
    return ServicesPaginatedData(
      currentPage: json['current_page'] ?? 1,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => Service.fromJson(item))
              .toList() ??
          [],
      firstPageUrl: json['first_page_url'] ?? '',
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'] ?? '',
      links: (json['links'] as List<dynamic>?)
              ?.map((item) => PageLink.fromJson(item))
              .toList() ??
          [],
      nextPageUrl: json['next_page_url'],
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 10,
      prevPageUrl: json['prev_page_url'],
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class PageLink {
  final String? url;
  final String label;
  final bool active;

  PageLink({
    this.url,
    required this.label,
    required this.active,
  });

  factory PageLink.fromJson(Map<String, dynamic> json) {
    return PageLink(
      url: json['url'],
      label: json['label'] ?? '',
      active: json['active'] ?? false,
    );
  }
}
