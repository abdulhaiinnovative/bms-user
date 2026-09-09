import 'package:app/core/base/base_view_model.dart';
import 'package:app/data/repositories/notifications_repository.dart';
import 'package:app/models/notification/notification_model.dart';
import 'package:flutter/widgets.dart';

/// ViewModel for notifications management
/// Handles notification listing, pagination, and read/unread status
class NotificationsViewModel extends BaseViewModel {
  final NotificationsRepository _repository;

  NotificationsViewModel({NotificationsRepository? repository})
      : _repository = repository ?? NotificationsRepository();

  // State
  List<NotificationItem> _notifications = [];
  int _unreadCount = 0;
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalNotifications = 0;
  bool _isRefreshing = false;

  // Getters
  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  int get totalNotifications => _totalNotifications;
  bool get hasMorePages => _currentPage < _lastPage;
  bool get isEmpty => _notifications.isEmpty && !isLoading;
  bool get hasNotifications => _notifications.isNotEmpty;
  bool get isRefreshing => _isRefreshing;

  /// Load notifications list
  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _isRefreshing = true;
      _currentPage = 1;
      notifyListeners();
    }

    await executeAsync(
      operation: () async {
        try {
          debugPrint("📡 Fetching notifications page: $_currentPage");

          final response =
              await _repository.getNotifications(page: _currentPage);

          debugPrint("📥 API RESPONSE: ${response.toJson()}");

          if (response.success == true) {
            if (refresh) {
              _notifications = response.data ?? [];
            } else {
              if (response.data != null && response.data!.isNotEmpty) {
                _notifications.addAll(response.data!);
              }
            }

            _currentPage = response.pagination?.currentPage ?? 1;
            _lastPage = response.pagination?.lastPage ?? 1;
            _totalNotifications = response.pagination?.total ?? 0;
          } else {
            throw Exception(response.message ?? 'Failed to load notifications');
          }

          notifyListeners();
        } catch (e, stack) {
          debugPrint("❌ NOTIFICATIONS VIEWMODEL ERROR: $e");
          debugPrint("📍 STACKTRACE: $stack");

          if (e is Exception) {
            debugPrint("⚠️ EXCEPTION: ${e.toString()}");
          }

          rethrow;
        }
      },
    );

    _isRefreshing = false;
  }

  /// Load next page of notifications
  Future<void> loadNextPage() async {
    if (!hasMorePages || isLoading) return;

    debugPrint("📄 Loading next page: ${_currentPage + 1}");

    _currentPage++;

    await loadNotifications();
  }

  /// Refresh notifications list
  Future<void> refresh() async {
    await loadNotifications(refresh: true);
    await loadUnreadCount();
  }

  /// Load unread notification count
  Future<void> loadUnreadCount() async {
    try {
      debugPrint("🔔 Fetching unread count");

      final response = await _repository.getUnreadCount();

      debugPrint("📥 Unread response: ${response.toJson()}");

      if (response.success == true) {
        _unreadCount = response.unreadCount ?? 0;
        notifyListeners();
      }
    } catch (e, stack) {
      debugPrint("❌ UNREAD COUNT ERROR: $e");
      debugPrint("📍 STACKTRACE: $stack");
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      debugPrint("✅ Marking as read: $notificationId");

      final response = await _repository.markAsRead(notificationId);

      debugPrint("📥 MarkRead response: ${response.toJson()}");

      if (response.success == true) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);

        if (index != -1) {
          _notifications[index] =
              _notifications[index].copyWith(readAt: DateTime.now().toString());

          _unreadCount = (_unreadCount - 1).clamp(0, _totalNotifications);
          notifyListeners();
        }

        await loadUnreadCount();
      }
    } catch (e, stack) {
      debugPrint("❌ MARK AS READ ERROR: $e");
      debugPrint("📍 STACKTRACE: $stack");
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    await executeAsyncSilent(
      operation: () async {
        final response = await _repository.markAllAsRead();

        if (response.success == true) {
          // Update local state
          _notifications = _notifications.map((n) {
            return n.copyWith(readAt: DateTime.now().toString());
          }).toList();
          _unreadCount = 0;
          notifyListeners();

          // Refresh unread count from server
          await loadUnreadCount();
        }
      },
    );
  }

  /// Get unread notifications
  List<NotificationItem> get unreadNotifications =>
      _notifications.where((n) => n.readAt == null).toList();

  /// Get read notifications
  List<NotificationItem> get readNotifications =>
      _notifications.where((n) => n.readAt != null).toList();

  /// Check if notification is unread
  bool isUnread(NotificationItem notification) => notification.readAt == null;
}
