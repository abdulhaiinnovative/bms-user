import 'package:app/core/base/base_view_model.dart';
import '../../data/repositories/notifications_repository.dart';
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

    await executeAsync(
      operation: () async {
        final response = await _repository.getNotifications(page: _currentPage)
            as NotificationsResponse;

        if (refresh) {
          _notifications = response.data;
        } else {
          if (response.data.isNotEmpty) {
            _notifications.addAll(response.data);
          }
        }

        _currentPage = response.currentPage;
        _lastPage = response.lastPage;
        _totalNotifications = response.total;

        notifyListeners();
      },
    );

    _isRefreshing = false;
  }

  /// Load next page of notifications
  Future<void> loadNextPage() async {
    if (!hasMorePages || isLoading) {
      return;
    }

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
      final response = await _repository.getUnreadCount();
      _unreadCount = response.unreadCount;
      notifyListeners();
    } catch (e) {
      // Don't throw, just log - unread count is not critical
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      final response =
          await _repository.markAsRead(notificationId) as MarkReadResponse;

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          isRead: true,
          readAt: response.readAt,
        );
        _unreadCount = (_unreadCount - 1).clamp(0, _totalNotifications);
        notifyListeners();
      }

      // Refresh unread count from server
      await loadUnreadCount();
    } catch (e) {
      // Don't show error to user, just log it
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    await executeAsyncSilent(
      operation: () async {
        final response =
            await _repository.markAllAsRead() as MarkAllReadResponse;

        // Update local state
        final now = DateTime.now().toString();
        _notifications = _notifications.map((n) {
          return n.copyWith(
            isRead: true,
            readAt: now,
          );
        }).toList();
        _unreadCount = 0;

        notifyListeners();

        // Refresh unread count from server
        await loadUnreadCount();
      },
    );
  }

  /// Get unread notifications
  List<NotificationItem> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  /// Get read notifications
  List<NotificationItem> get readNotifications =>
      _notifications.where((n) => n.isRead).toList();

  /// Check if notification is unread
  bool isUnread(NotificationItem notification) => !notification.isRead;
}
