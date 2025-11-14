import 'dart:developer';
import 'package:app/core/base/base_view_model.dart';
import 'package:app/data/repositories/notifications_repository.dart';
import 'package:app/models/notification/notification_model.dart';

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

    log('NotificationsViewModel: Loading notifications - Page: $_currentPage');

    await executeAsync(
      operation: () async {
        final response = await _repository.getNotifications(page: _currentPage);

        log('NotificationsViewModel: Response received - Success: ${response.success}');

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

          log('NotificationsViewModel: Loaded ${_notifications.length} notifications');
          log('  - Current Page: $_currentPage');
          log('  - Last Page: $_lastPage');
          log('  - Total: $_totalNotifications');
        } else {
          final errorMsg = response.message ?? 'Failed to load notifications';
          log('NotificationsViewModel: Load failed - $errorMsg');
          throw Exception(errorMsg);
        }

        notifyListeners();
      },
    );

    _isRefreshing = false;
  }

  /// Load next page of notifications
  Future<void> loadNextPage() async {
    if (!hasMorePages || isLoading) {
      log('NotificationsViewModel: No more pages or already loading');
      return;
    }

    _currentPage++;
    log('NotificationsViewModel: Loading next page: $_currentPage');
    await loadNotifications();
  }

  /// Refresh notifications list
  Future<void> refresh() async {
    log('NotificationsViewModel: Refreshing notifications');
    await loadNotifications(refresh: true);
    await loadUnreadCount();
  }

  /// Load unread notification count
  Future<void> loadUnreadCount() async {
    log('NotificationsViewModel: Loading unread count');

    try {
      final response = await _repository.getUnreadCount();

      if (response.success == true) {
        _unreadCount = response.unreadCount ?? 0;
        log('NotificationsViewModel: Unread count: $_unreadCount');
        notifyListeners();
      } else {
        log('NotificationsViewModel: Failed to load unread count');
      }
    } catch (e) {
      log('NotificationsViewModel: Unread count error - $e');
      // Don't throw, just log - unread count is not critical
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(int notificationId) async {
    log('NotificationsViewModel: Marking notification $notificationId as read');

    try {
      final response = await _repository.markAsRead(notificationId);

      if (response.success == true) {
        // Update local state
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(readAt: DateTime.now().toString());
          _unreadCount = (_unreadCount - 1).clamp(0, _totalNotifications);
          notifyListeners();
          log('NotificationsViewModel: Notification $notificationId marked as read locally');
        }

        // Refresh unread count from server
        await loadUnreadCount();
      } else {
        log('NotificationsViewModel: Failed to mark notification as read');
      }
    } catch (e) {
      log('NotificationsViewModel: Mark as read error - $e');
      // Don't show error to user, just log it
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    log('NotificationsViewModel: Marking all notifications as read');

    await executeAsyncSilent(
      operation: () async {
        final response = await _repository.markAllAsRead();

        if (response.success == true) {
          // Update local state
          _notifications = _notifications.map((n) {
            return n.copyWith(readAt: DateTime.now().toString());
          }).toList();
          _unreadCount = 0;

          log('NotificationsViewModel: Marked ${response.updatedCount} notifications as read');
          notifyListeners();

          // Refresh unread count from server
          await loadUnreadCount();
        } else {
          log('NotificationsViewModel: Failed to mark all as read');
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
