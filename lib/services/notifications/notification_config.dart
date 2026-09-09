import 'package:flutter/material.dart';

/// Notification configuration constants and settings
class NotificationConfig {
  // Default notification channels
  static const String defaultChannelId = 'default_channel';
  static const String defaultChannelName = 'Default Notifications';
  static const String defaultChannelDescription = 'General app notifications';

  static const String appointmentChannelId = 'appointment_channel';
  static const String appointmentChannelName = 'Appointment Notifications';
  static const String appointmentChannelDescription =
      'Salon appointment reminders and updates';

  static const String promoChannelId = 'promo_channel';
  static const String promoChannelName = 'Promotional Notifications';
  static const String promoChannelDescription = 'Special offers and promotions';

  static const String systemChannelId = 'system_channel';
  static const String systemChannelName = 'System Notifications';
  static const String systemChannelDescription =
      'App updates and system messages';

  // Notification IDs
  static const int appointmentReminderNotificationId = 1000;
  static const int appointmentConfirmationNotificationId = 1001;
  static const int appointmentCancellationNotificationId = 1002;
  static const int promoNotificationId = 2000;
  static const int systemNotificationId = 3000;

  // Default notification settings
  static const bool defaultEnableVibration = true;
  static const bool defaultPlaySound = true;
  static const bool defaultAutoCancel = true;
  static const bool defaultOngoing = false;
  static const bool defaultSilent = false;

  // iOS specific settings
  static const bool defaultPresentAlert = true;
  static const bool defaultPresentBadge = true;
  static const bool defaultPresentSound = true;

  // Notification colors
  static const Color primaryNotificationColor = Colors.blue;
  static const Color appointmentNotificationColor = Colors.green;
  static const Color promoNotificationColor = Colors.orange;
  static const Color systemNotificationColor = Colors.grey;

  // Notification icons
  static const String defaultNotificationIcon = '@mipmap/ic_launcher';
  static const String appointmentNotificationIcon = '@drawable/ic_appointment';
  static const String promoNotificationIcon = '@drawable/ic_promo';
  static const String systemNotificationIcon = '@drawable/ic_system';

  // Sound files (place in android/app/src/main/res/raw/)
  static const String defaultSoundFile = 'notification_sound';
  static const String appointmentSoundFile = 'appointment_sound';
  static const String promoSoundFile = 'promo_sound';

  // Payload keys for handling notification taps
  static const String payloadTypeKey = 'type';
  static const String payloadDataKey = 'data';
  static const String payloadScreenKey = 'screen';
  static const String payloadTitleKey = 'title';
  static const String payloadBodyKey = 'body';

  // Notification types
  static const String appointmentNotificationType = 'appointment';
  static const String promoNotificationType = 'promo';
  static const String systemNotificationType = 'system';
  static const String generalNotificationType = 'general';

  // Screens to navigate to
  static const String homeScreen = '/home';
  static const String appointmentScreen = '/appointment';
  static const String promoScreen = '/promo';
  static const String profileScreen = '/profile';

  /// Get notification channel configuration
  static Map<String, NotificationChannelConfig> getChannelConfigs() {
    return {
      defaultChannelId: const NotificationChannelConfig(
        id: defaultChannelId,
        name: defaultChannelName,
        description: defaultChannelDescription,
        color: primaryNotificationColor,
        icon: defaultNotificationIcon,
        soundFile: defaultSoundFile,
      ),
      appointmentChannelId: const NotificationChannelConfig(
        id: appointmentChannelId,
        name: appointmentChannelName,
        description: appointmentChannelDescription,
        color: appointmentNotificationColor,
        icon: appointmentNotificationIcon,
        soundFile: appointmentSoundFile,
      ),
      promoChannelId: const NotificationChannelConfig(
        id: promoChannelId,
        name: promoChannelName,
        description: promoChannelDescription,
        color: promoNotificationColor,
        icon: promoNotificationIcon,
        soundFile: promoSoundFile,
      ),
      systemChannelId: const NotificationChannelConfig(
        id: systemChannelId,
        name: systemChannelName,
        description: systemChannelDescription,
        color: systemNotificationColor,
        icon: systemNotificationIcon,
        soundFile: defaultSoundFile,
      ),
    };
  }

  /// Get predefined notification templates
  static Map<String, NotificationTemplate> getNotificationTemplates() {
    return {
      'appointment_reminder': const NotificationTemplate(
        channelId: appointmentChannelId,
        title: 'Appointment Reminder',
        body: 'Your appointment is scheduled for {time} at {salon}',
        type: appointmentNotificationType,
        screen: appointmentScreen,
      ),
      'appointment_confirmation': const NotificationTemplate(
        channelId: appointmentChannelId,
        title: 'Appointment Confirmed',
        body: 'Your appointment has been confirmed for {time} at {salon}',
        type: appointmentNotificationType,
        screen: appointmentScreen,
      ),
      'appointment_cancellation': const NotificationTemplate(
        channelId: appointmentChannelId,
        title: 'Appointment Cancelled',
        body: 'Your appointment for {time} has been cancelled',
        type: appointmentNotificationType,
        screen: homeScreen,
      ),
      'special_offer': const NotificationTemplate(
        channelId: promoChannelId,
        title: 'Special Offer!',
        body: 'Get {discount}% off on {service}. Limited time offer!',
        type: promoNotificationType,
        screen: promoScreen,
      ),
      'new_salon': const NotificationTemplate(
        channelId: promoChannelId,
        title: 'New Salon Available',
        body: 'Check out {salon} now available in your area!',
        type: promoNotificationType,
        screen: homeScreen,
      ),
      'app_update': const NotificationTemplate(
        channelId: systemChannelId,
        title: 'App Update Available',
        body: 'Update to the latest version for new features and improvements',
        type: systemNotificationType,
        screen: homeScreen,
      ),
    };
  }
}

/// Notification channel configuration
class NotificationChannelConfig {
  final String id;
  final String name;
  final String description;
  final Color color;
  final String icon;
  final String soundFile;

  const NotificationChannelConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
    required this.soundFile,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color.value,
      'icon': icon,
      'soundFile': soundFile,
    };
  }

  factory NotificationChannelConfig.fromJson(Map<String, dynamic> json) {
    return NotificationChannelConfig(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      color: Color(json['color']),
      icon: json['icon'],
      soundFile: json['soundFile'],
    );
  }
}

/// Notification template for predefined notifications
class NotificationTemplate {
  final String channelId;
  final String title;
  final String body;
  final String type;
  final String screen;

  const NotificationTemplate({
    required this.channelId,
    required this.title,
    required this.body,
    required this.type,
    required this.screen,
  });

  Map<String, dynamic> toJson() {
    return {
      'channelId': channelId,
      'title': title,
      'body': body,
      'type': type,
      'screen': screen,
    };
  }

  factory NotificationTemplate.fromJson(Map<String, dynamic> json) {
    return NotificationTemplate(
      channelId: json['channelId'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      screen: json['screen'],
    );
  }

  /// Replace placeholders in title and body with actual values
  NotificationTemplate withValues(Map<String, String> values) {
    String updatedTitle = title;
    String updatedBody = body;

    values.forEach((key, value) {
      updatedTitle = updatedTitle.replaceAll('{$key}', value);
      updatedBody = updatedBody.replaceAll('{$key}', value);
    });

    return NotificationTemplate(
      channelId: channelId,
      title: updatedTitle,
      body: updatedBody,
      type: type,
      screen: screen,
    );
  }
}

/// App-specific notification settings
class AppNotificationSettings {
  final bool enableNotifications;
  final bool enableAppointmentReminders;
  final bool enablePromotionalNotifications;
  final bool enableSystemNotifications;
  final bool enableVibration;
  final bool enableSound;
  final int reminderMinutesBefore;

  const AppNotificationSettings({
    this.enableNotifications = true,
    this.enableAppointmentReminders = true,
    this.enablePromotionalNotifications = true,
    this.enableSystemNotifications = true,
    this.enableVibration = true,
    this.enableSound = true,
    this.reminderMinutesBefore = 30,
  });

  Map<String, dynamic> toJson() {
    return {
      'enableNotifications': enableNotifications,
      'enableAppointmentReminders': enableAppointmentReminders,
      'enablePromotionalNotifications': enablePromotionalNotifications,
      'enableSystemNotifications': enableSystemNotifications,
      'enableVibration': enableVibration,
      'enableSound': enableSound,
      'reminderMinutesBefore': reminderMinutesBefore,
    };
  }

  factory AppNotificationSettings.fromJson(Map<String, dynamic> json) {
    return AppNotificationSettings(
      enableNotifications: json['enableNotifications'] ?? true,
      enableAppointmentReminders: json['enableAppointmentReminders'] ?? true,
      enablePromotionalNotifications:
          json['enablePromotionalNotifications'] ?? true,
      enableSystemNotifications: json['enableSystemNotifications'] ?? true,
      enableVibration: json['enableVibration'] ?? true,
      enableSound: json['enableSound'] ?? true,
      reminderMinutesBefore: json['reminderMinutesBefore'] ?? 30,
    );
  }

  AppNotificationSettings copyWith({
    bool? enableNotifications,
    bool? enableAppointmentReminders,
    bool? enablePromotionalNotifications,
    bool? enableSystemNotifications,
    bool? enableVibration,
    bool? enableSound,
    int? reminderMinutesBefore,
  }) {
    return AppNotificationSettings(
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableAppointmentReminders:
          enableAppointmentReminders ?? this.enableAppointmentReminders,
      enablePromotionalNotifications:
          enablePromotionalNotifications ?? this.enablePromotionalNotifications,
      enableSystemNotifications:
          enableSystemNotifications ?? this.enableSystemNotifications,
      enableVibration: enableVibration ?? this.enableVibration,
      enableSound: enableSound ?? this.enableSound,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
    );
  }
}
