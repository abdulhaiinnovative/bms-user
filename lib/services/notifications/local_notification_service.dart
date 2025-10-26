import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'notification_models.dart';
import 'notification_config.dart';
import 'notification_handler.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  bool _isInitialized = false;

  /// Initialize the local notification service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      // Android initialization
      const AndroidInitializationSettings androidInitializationSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      const DarwinInitializationSettings iosInitializationSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Initialization settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      );

      // Initialize with settings
      final bool? initialized =
          await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

      if (initialized == true) {
        await _createNotificationChannels();
        await _requestPermissions();
        _isInitialized = true;
        log('LocalNotificationService: Initialized successfully');
        return true;
      } else {
        log('LocalNotificationService: Initialization failed');
        return false;
      }
    } catch (e) {
      log('LocalNotificationService: Initialization error - $e');
      return false;
    }
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    try {
      // Create default notification channel
      const AndroidNotificationChannel defaultChannel =
          AndroidNotificationChannel(
        NotificationConfig.defaultChannelId,
        NotificationConfig.defaultChannelName,
        description: NotificationConfig.defaultChannelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      // Create appointment notification channel
      const AndroidNotificationChannel appointmentChannel =
          AndroidNotificationChannel(
        NotificationConfig.appointmentChannelId,
        NotificationConfig.appointmentChannelName,
        description: NotificationConfig.appointmentChannelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      // Create promotion notification channel
      const AndroidNotificationChannel promotionChannel =
          AndroidNotificationChannel(
        NotificationConfig.promoChannelId,
        NotificationConfig.promoChannelName,
        description: NotificationConfig.promoChannelDescription,
        importance: Importance.defaultImportance,
        playSound: true,
        enableVibration: false,
      );

      // Create system notification channel
      const AndroidNotificationChannel systemChannel =
          AndroidNotificationChannel(
        NotificationConfig.systemChannelId,
        NotificationConfig.systemChannelName,
        description: NotificationConfig.systemChannelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      // Register channels with the system
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(defaultChannel);

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(appointmentChannel);

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(promotionChannel);

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(systemChannel);

      log('LocalNotificationService: Notification channels created');
    } catch (e) {
      log('LocalNotificationService: Error creating channels - $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      // Request Android permissions
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      // Request iOS permissions
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      log('LocalNotificationService: Permissions requested');
    } catch (e) {
      log('LocalNotificationService: Error requesting permissions - $e');
    }
  }

  /// Show immediate notification
  Future<void> showNotification(LocalNotificationModel notification) async {
    if (!_isInitialized) {
      log('LocalNotificationService: Service not initialized');
      return;
    }

    try {
      await _flutterLocalNotificationsPlugin.show(
        notification.id,
        notification.title,
        notification.body,
        _getNotificationDetails(notification),
        payload: notification.payload,
      );

      log('LocalNotificationService: Notification shown - ${notification.title}');
    } catch (e) {
      log('LocalNotificationService: Error showing notification - $e');
    }
  }

  /// Schedule notification
  Future<void> scheduleNotification(
      ScheduledNotificationModel notification) async {
    if (!_isInitialized) {
      log('LocalNotificationService: Service not initialized');
      return;
    }

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notification.id,
        notification.title,
        notification.body,
        notification.scheduledDate,
        _getNotificationDetails(notification),
        payload: notification.payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      log('LocalNotificationService: Notification scheduled - ${notification.title}');
    } catch (e) {
      log('LocalNotificationService: Error scheduling notification - $e');
    }
  }

  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      log('LocalNotificationService: Notification cancelled - $id');
    } catch (e) {
      log('LocalNotificationService: Error cancelling notification - $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      log('LocalNotificationService: All notifications cancelled');
    } catch (e) {
      log('LocalNotificationService: Error cancelling all notifications - $e');
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      log('LocalNotificationService: Error checking permissions - $e');
      return false;
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      log('LocalNotificationService: Error requesting permissions - $e');
      return false;
    }
  }

  /// Get notification details for the platform
  NotificationDetails _getNotificationDetails(NotificationModel notification) {
    // Android notification details
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      notification is LocalNotificationModel
          ? notification.channelId
          : NotificationConfig.defaultChannelId,
      notification is LocalNotificationModel
          ? notification.channelName
          : NotificationConfig.defaultChannelName,
      channelDescription: notification is LocalNotificationModel
          ? notification.channelDescription
          : NotificationConfig.defaultChannelDescription,
      importance: _getAndroidImportance(notification),
      priority: _getAndroidPriority(notification),
      playSound: notification is LocalNotificationModel
          ? notification.playSound
          : true,
      enableVibration: notification is LocalNotificationModel
          ? notification.enableVibration
          : true,
      autoCancel: notification is LocalNotificationModel
          ? notification.autoCancel
          : true,
      ongoing:
          notification is LocalNotificationModel ? notification.ongoing : false,
      silent:
          notification is LocalNotificationModel ? notification.silent : false,
    );

    // iOS notification details
    DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: notification is LocalNotificationModel
          ? notification.presentAlert
          : true,
      presentBadge: notification is LocalNotificationModel
          ? notification.presentBadge
          : true,
      presentSound: notification is LocalNotificationModel
          ? notification.playSound
          : true,
      badgeNumber: notification is LocalNotificationModel
          ? notification.badgeNumber
          : null,
      subtitle:
          notification is LocalNotificationModel ? notification.subtitle : null,
      threadIdentifier: notification is LocalNotificationModel
          ? notification.threadIdentifier
          : null,
      categoryIdentifier: notification is LocalNotificationModel
          ? notification.categoryIdentifier
          : null,
      interruptionLevel: _getIOSInterruptionLevel(notification),
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Get Android importance from notification priority
  Importance _getAndroidImportance(NotificationModel notification) {
    if (notification is! LocalNotificationModel)
      return Importance.defaultImportance;

    switch (notification.priority) {
      case NotificationPriority.min:
        return Importance.min;
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.normal:
      case NotificationPriority.defaultPriority:
        return Importance.defaultImportance;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.max:
        return Importance.max;
    }
  }

  /// Get Android priority from notification priority
  Priority _getAndroidPriority(NotificationModel notification) {
    if (notification is! LocalNotificationModel)
      return Priority.defaultPriority;

    switch (notification.priority) {
      case NotificationPriority.min:
        return Priority.min;
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.normal:
      case NotificationPriority.defaultPriority:
        return Priority.defaultPriority;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.max:
        return Priority.max;
    }
  }

  /// Get iOS interruption level from notification priority
  InterruptionLevel _getIOSInterruptionLevel(NotificationModel notification) {
    if (notification is! LocalNotificationModel)
      return InterruptionLevel.active;

    switch (notification.priority) {
      case NotificationPriority.min:
      case NotificationPriority.low:
        return InterruptionLevel.passive;
      case NotificationPriority.normal:
      case NotificationPriority.defaultPriority:
        return InterruptionLevel.active;
      case NotificationPriority.high:
      case NotificationPriority.max:
        return InterruptionLevel.timeSensitive;
    }
  }

  /// Handle notification tap
  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    log('LocalNotificationService: Notification tapped - ${response.payload}');
    NotificationHandler.handleNotificationTap(response);
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Static access methods for compatibility
  static LocalNotificationService get instance => _instance;

  static Future<bool> staticInitialize() async {
    return await _instance.initialize();
  }

  static Future<void> staticShowNotification(
      LocalNotificationModel notification) async {
    await _instance.showNotification(notification);
  }

  static Future<void> staticScheduleNotification(
      ScheduledNotificationModel notification) async {
    await _instance.scheduleNotification(notification);
  }

  static Future<void> staticCancelNotification(int id) async {
    await _instance.cancelNotification(id);
  }

  static Future<void> staticCancelAllNotifications() async {
    await _instance.cancelAllNotifications();
  }

  static Future<bool> staticAreNotificationsEnabled() async {
    return await _instance.areNotificationsEnabled();
  }

  static Future<bool> staticRequestPermissions() async {
    return await _instance.requestPermissions();
  }

  static bool get staticIsInitialized => _instance._isInitialized;
}
