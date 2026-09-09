import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:app/models/notification/notification_model.dart';
import 'package:app/constants.dart';
import '../viewmodels/notifications_view_model.dart';
import '../widgets/notification_card.dart';
import '../../../auth/presentation/screens/auth/auth_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../services/notifications/notification_handler.dart';
import '../../../../services/notifications/notification_config.dart';

class NotificationsScreen extends StatefulWidget {
  static String routeName = "/notifications";

  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load notifications using ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<NotificationsViewModel>();
      viewModel.loadNotifications(refresh: true);
      viewModel.loadUnreadCount();
    });

    // Listen to scroll for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationsViewModel>().loadNextPage();
    }
  }

  Future<void> _handleRefresh() async {
    await context.read<NotificationsViewModel>().refresh();
  }

  void _handleMarkAllRead() async {
    final viewModel = context.read<NotificationsViewModel>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark All as Read'),
        content: const Text(
            'Are you sure you want to mark all notifications as read?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mark All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await viewModel.markAllAsRead();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            backgroundColor: kPrimaryColor,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            centerTitle: false,
            actions: [
              if (viewModel.unreadCount > 0)
                TextButton.icon(
                  onPressed: _handleMarkAllRead,
                  icon: const Icon(Icons.done_all, size: 18),
                  label: const Text('Mark All'),
                  style: TextButton.styleFrom(
                    foregroundColor: kPrimaryColor,
                  ),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: _buildBody(viewModel),
        );
      },
    );
  }

  Widget _buildBody(NotificationsViewModel viewModel) {
    // Initial loading state
    if (viewModel.isLoading && viewModel.notifications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
        ),
      );
    }

    // Error state
    if (viewModel.isError && viewModel.notifications.isEmpty) {
      final errorMessage =
          viewModel.errorMessage ?? 'Failed to load notifications';
      final isAuthError = errorMessage.contains('login') ||
          errorMessage.contains('Unauthorized');

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isAuthError ? Icons.lock_outline : Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                isAuthError
                    ? 'Authentication Required'
                    : 'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  if (isAuthError) {
                    // Navigate to login screen
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const AuthScreen()),
                      (route) => false,
                    );
                  } else {
                    // Try again
                    viewModel.refresh();
                  }
                },
                icon: Icon(isAuthError ? Icons.login : Icons.refresh),
                label: Text(isAuthError ? 'Login' : 'Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (viewModel.notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No Notifications Yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "You're all caught up!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // List of notifications
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: kPrimaryColor,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: viewModel.notifications.length +
            (viewModel.isLoading && viewModel.currentPage > 1 ? 1 : 0),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          // Loading indicator at bottom
          if (index == viewModel.notifications.length) {
            return Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                ),
              ),
            );
          }

          final notification = viewModel.notifications[index];
          return NotificationCard(
            notification: notification,
            onTap: () => _handleNotificationTap(notification),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(NotificationItem notification) async {
    final viewModel = context.read<NotificationsViewModel>();

    // Mark as read if not already read
    if (!notification.isRead) {
      await viewModel.markAsRead(notification.id);
    }

    if (!mounted) return;

    final Map<String, dynamic> data = {
      ...notification.toJson(),
      'id': notification.routeId,
      'appointmentId': notification.routeId,
      'bookingId': notification.routeId,
    };

    debugPrint('NotificationsScreen (Features): Tapped notification ID: ${notification.id}');
    debugPrint('NotificationsScreen (Features): Category: ${notification.category}');
    debugPrint('NotificationsScreen (Features): Route ID: ${notification.routeId}');
    debugPrint('NotificationsScreen (Features): App Route: ${notification.appRoute}');

    String? route = notification.appRoute;

    // Auto-detect booking route if category is booking but route is missing
    if ((route == null || route.isEmpty) &&
        notification.category.toLowerCase() == 'booking' &&
        notification.routeId != null) {
      route = NotificationConfig.appointmentScreen;
    }

    if (route != null && route.isNotEmpty) {
      if (route == '/notifications') return;
      NotificationHandler.navigateToScreen(route, data);
    } else if (notification.url != null && notification.url!.isNotEmpty) {
      final Uri url = Uri.parse(notification.url!);
      try {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening URL: $e')),
          );
        }
      }
    } else {
      _showDetailDialog(context, notification);
    }
  }



String formatReadableDate(String dateString) {
  try {
    DateTime dateTime;

    // Try normal parse
    try {
      dateTime = DateTime.parse(dateString);
    } catch (_) {
      // Fallback for custom formats
      dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateString);
    }

    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime.toLocal());
  } catch (e) {
    debugPrint("Date parse error: $e");
    return dateString;
  }
}
  String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
  void _showDetailDialog(BuildContext context, NotificationItem notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(capitalizeFirst(notification.subject)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(capitalizeFirst(notification.message)),
            const SizedBox(height: 16),
            Text(
              'Received: ${formatReadableDate(notification.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
