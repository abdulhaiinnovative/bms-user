import 'package:flutter/cupertino.dart';

/// Model for notification from API
class NotificationItem {
  final int id;
  final String subject;
  final String message;
  final bool isRead;
  final String? readAt;
  final String createdAt;
  final String category;
  final String sender;
  final String? url;
  final String? appRoute;
  final int? routeId;

  NotificationItem({
    required this.id,
    required this.subject,
    required this.message,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    required this.category,
    required this.sender,
    this.url,
    this.appRoute,
    this.routeId,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    try {
      final item = NotificationItem(
        id: json['id'] ?? 0,
        subject: json['subject']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        isRead: json['is_read'] ?? false,
        readAt: json['read_at']?.toString(),
        createdAt: json['created_at']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        sender: json['sender']?.toString() ?? '',
        url: json['url']?.toString(),
        appRoute: json['app_route']?.toString(),
        routeId: (json['route_id'] ?? json['appointment_id'] ?? json['booking_id'] ?? 
                   json['appointmentId'] ?? json['bookingId'] ?? json['booking_detail_id'] ??
                   json['object_id'] ?? json['target_id']) is String
            ? int.tryParse((json['route_id'] ?? json['appointment_id'] ?? json['booking_id'] ?? 
                          json['appointmentId'] ?? json['bookingId'] ?? json['booking_detail_id'] ??
                          json['object_id'] ?? json['target_id']).toString())
            : (json['route_id'] ?? json['appointment_id'] ?? json['booking_id'] ?? 
               json['appointmentId'] ?? json['bookingId'] ?? json['booking_detail_id'] ??
               json['object_id'] ?? json['target_id']),
      );

      // If routeId is still null but we have a URL, try to extract it from the URL
      if (item.routeId == null && item.url != null && item.url!.isNotEmpty) {
        try {
          final uri = Uri.parse(item.url!);
          // Check all path segments for a numeric ID
          for (final segment in uri.pathSegments) {
            final id = int.tryParse(segment);
            if (id != null && id > 0) {
              debugPrint('NotificationItem: Found ID in URL segment: $segment');
              return item.copyWith(routeId: id);
            }
          }
          
          // Check common query parameters for ID
          final queryKeys = ['id', 'booking_id', 'appointment_id', 'bookingId', 'appointmentId', 'booking_detail_id', 'route_id', 'notification_id', 'object_id', 'target_id'];
          for (final key in queryKeys) {
            final queryVal = uri.queryParameters[key];
            if (queryVal != null) {
              final id = int.tryParse(queryVal);
              if (id != null && id > 0) {
                debugPrint('NotificationItem: Found ID in query parameter ($key): $queryVal');
                return item.copyWith(routeId: id);
              }
            }
          }
        } catch (e) {
          debugPrint('NotificationItem: URL parsing error: $e');
        }
      }
      return item;
    } catch (e) {
      print("❌ NotificationItem Parsing Error: $e");
      print("📦 JSON: $json");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'message': message,
      'is_read': isRead,
      'read_at': readAt,
      'created_at': createdAt,
      'category': category,
      'sender': sender,
      'url': url,
      'app_route': appRoute,
      'route_id': routeId,
    };
  }

  /// Get time ago string
  String getTimeAgo() {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '${weeks}w ago';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '${months}mo ago';
      } else {
        final years = (difference.inDays / 365).floor();
        return '${years}y ago';
      }
    } catch (e) {
      return '';
    }
  }

  /// Get category icon
  String getCategoryIcon() {
    switch (category.toLowerCase()) {
      case 'booking':
        return '📅';
      case 'wellcome':
      case 'welcome':
        return '👋';
      case 'promotion':
        return '🎁';
      case 'reminder':
        return '⏰';
      case 'payment':
        return '💳';
      default:
        return '🔔';
    }
  }

  NotificationItem copyWith({
    int? id,
    String? subject,
    String? message,
    bool? isRead,
    String? readAt,
    String? createdAt,
    String? category,
    String? sender,
    String? url,
    String? appRoute,
    int? routeId,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      sender: sender ?? this.sender,
      url: url ?? this.url,
      appRoute: appRoute ?? this.appRoute,
      routeId: routeId ?? this.routeId,
    );
  }
}

/// Model for paginated notifications response
class NotificationsResponse {
  final int currentPage;
  final List<NotificationItem> data;
  final String? firstPageUrl;
  final int from;
  final int lastPage;
  final String? lastPageUrl;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  NotificationsResponse({
    required this.currentPage,
    required this.data,
    this.firstPageUrl,
    required this.from,
    required this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    final responseData = json['response']?['data'];

    if (responseData == null) {
      throw Exception("Invalid notification response structure");
    }

    return NotificationsResponse(
      currentPage: responseData['current_page'] ?? 1,
      data: (responseData['data'] as List? ?? [])
          .map((item) => NotificationItem.fromJson(item))
          .toList(),
      firstPageUrl: responseData['first_page_url']?.toString(),
      from: responseData['from'] ?? 0,
      lastPage: responseData['last_page'] ?? 1,
      lastPageUrl: responseData['last_page_url']?.toString(),
      nextPageUrl: responseData['next_page_url']?.toString(),
      path: responseData['path']?.toString() ?? '',
      perPage: responseData['per_page'] ?? 15,
      prevPageUrl: responseData['prev_page_url']?.toString(),
      to: responseData['to'] ?? 0,
      total: responseData['total'] ?? 0,
    );
  }

  bool get hasNextPage => nextPageUrl != null;
  bool get hasPrevPage => prevPageUrl != null;
}

/// Model for unread count response
class UnreadCountResponse {
  final int unreadCount;

  UnreadCountResponse({required this.unreadCount});

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return UnreadCountResponse(
      unreadCount: data['unread_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unread_count': unreadCount,
    };
  }
}

/// Model for mark as read response
class MarkReadResponse {
  final String notificationId;
  final bool isRead;
  final String readAt;

  MarkReadResponse({
    required this.notificationId,
    required this.isRead,
    required this.readAt,
  });

  factory MarkReadResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return MarkReadResponse(
      notificationId: data['notification_id']?.toString() ?? '',
      isRead: data['is_read'] ?? false,
      readAt: data['read_at']?.toString() ?? '',
    );
  }
}

/// Model for mark all as read response
class MarkAllReadResponse {
  final int updatedCount;

  MarkAllReadResponse({required this.updatedCount});

  factory MarkAllReadResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return MarkAllReadResponse(
      updatedCount: data['updated_count'] ?? 0,
    );
  }
}
