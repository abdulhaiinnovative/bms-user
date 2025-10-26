import 'dart:developer';
import 'package:flutter/material.dart';
import '../../api_services/notification_service_api.dart';
import '../../models/notification/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationServiceAPI _notificationService = NotificationServiceAPI();

  // State
  List<NotificationItem> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  // Pagination
  int _currentPage = 1;
  int _total = 0;
  bool _hasMore = false;

  // Getters
  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get total => _total;
  bool get hasMore => _hasMore;

  /// Fetch notifications (page 1)
  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _notifications.clear();
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      log('📬 NotificationProvider: Fetching notifications (page: $_currentPage)');

      final response =
          await _notificationService.getNotifications(page: _currentPage);

      _notifications = response.data;
      _currentPage = response.currentPage;

      _total = response.total;
      _hasMore = response.hasNextPage;

      log('✅ NotificationProvider: Fetched ${_notifications.length} notifications');

      // Also fetch unread count
      await fetchUnreadCount();
    } catch (e) {
      log('❌ NotificationProvider: Error fetching notifications - $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more notifications (pagination)
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    try {
      _isLoadingMore = true;
      _errorMessage = null;
      notifyListeners();

      final nextPage = _currentPage + 1;
      log('📬 NotificationProvider: Loading more (page: $nextPage)');

      final response =
          await _notificationService.getNotifications(page: nextPage);

      _notifications.addAll(response.data);
      _currentPage = response.currentPage;

      _total = response.total;
      _hasMore = response.hasNextPage;

      log('✅ NotificationProvider: Loaded ${response.data.length} more notifications');
    } catch (e) {
      log('❌ NotificationProvider: Error loading more - $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Fetch unread count
  Future<void> fetchUnreadCount() async {
    try {
      log('🔔 NotificationProvider: Fetching unread count');

      final response = await _notificationService.getUnreadCount();
      _unreadCount = response.unreadCount;

      log('✅ NotificationProvider: Unread count: $_unreadCount');
      notifyListeners();
    } catch (e) {
      log('❌ NotificationProvider: Error fetching unread count - $e');
      // Don't set error message for unread count failure
    }
  }

  /// Mark a single notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      log('📖 NotificationProvider: Marking notification $notificationId as read');

      await _notificationService.markAsRead(notificationId);

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          isRead: true,
          readAt: DateTime.now().toIso8601String(),
        );

        // Decrease unread count if it was unread
        if (!_notifications[index].isRead && _unreadCount > 0) {
          _unreadCount--;
        }

        notifyListeners();
      }

      log('✅ NotificationProvider: Notification $notificationId marked as read');
      return true;
    } catch (e) {
      log('❌ NotificationProvider: Error marking as read - $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      log('📖 NotificationProvider: Marking all as read');

      final response = await _notificationService.markAllAsRead();

      // Update local state
      _notifications = _notifications.map((notification) {
        return notification.copyWith(
          isRead: true,
          readAt: DateTime.now().toIso8601String(),
        );
      }).toList();

      _unreadCount = 0;
      notifyListeners();

      log('✅ NotificationProvider: Marked ${response.updatedCount} notifications as read');
      return true;
    } catch (e) {
      log('❌ NotificationProvider: Error marking all as read - $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _notifications.clear();
    _unreadCount = 0;
    _currentPage = 1;

    _total = 0;
    _hasMore = false;
    _isLoading = false;
    _isLoadingMore = false;
    _errorMessage = null;
    notifyListeners();
  }
}
