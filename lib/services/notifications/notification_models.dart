import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Base notification model
abstract class NotificationModel {
  final int id;
  final String title;
  final String body;
  final String? payload;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
  });

  Map<String, dynamic> toJson();

  static int generateId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }
}

/// Local notification model for immediate notifications
class LocalNotificationModel extends NotificationModel {
  final String channelId;
  final String channelName;
  final String? channelDescription;
  final NotificationPriority priority;
  final String? icon;
  final Color? color;
  final bool enableVibration;
  final bool playSound;
  final String? soundFile;
  final String? largeIcon;
  final String? bigText;
  final String? imagePath;
  final List<String>? inboxLines;
  final String? summaryText;
  final List<NotificationActionModel>? actions;
  final NotificationCategory? category;
  final NotificationVisibility visibility;
  final bool autoCancel;
  final bool ongoing;
  final bool silent;
  final String? ticker;

  // iOS specific
  final bool presentAlert;
  final bool presentBadge;
  final int? badgeNumber;
  final String? subtitle;
  final String? threadIdentifier;
  final String? categoryIdentifier;

  const LocalNotificationModel({
    required super.id,
    required super.title,
    required super.body,
    super.payload,
    this.channelId = 'default_channel',
    this.channelName = 'Default Channel',
    this.channelDescription,
    this.priority = NotificationPriority.defaultPriority,
    this.icon,
    this.color,
    this.enableVibration = true,
    this.playSound = true,
    this.soundFile,
    this.largeIcon,
    this.bigText,
    this.imagePath,
    this.inboxLines,
    this.summaryText,
    this.actions,
    this.category,
    this.visibility = NotificationVisibility.public,
    this.autoCancel = true,
    this.ongoing = false,
    this.silent = false,
    this.ticker,
    this.presentAlert = true,
    this.presentBadge = true,
    this.badgeNumber,
    this.subtitle,
    this.threadIdentifier,
    this.categoryIdentifier,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
      'channelId': channelId,
      'channelName': channelName,
      'channelDescription': channelDescription,
      'priority': priority.index,
      'icon': icon,
      'color': color?.value,
      'enableVibration': enableVibration,
      'playSound': playSound,
      'soundFile': soundFile,
      'largeIcon': largeIcon,
      'bigText': bigText,
      'imagePath': imagePath,
      'inboxLines': inboxLines,
      'summaryText': summaryText,
      'category': category?.index,
      'visibility': visibility.index,
      'autoCancel': autoCancel,
      'ongoing': ongoing,
      'silent': silent,
      'ticker': ticker,
      'presentAlert': presentAlert,
      'presentBadge': presentBadge,
      'badgeNumber': badgeNumber,
      'subtitle': subtitle,
      'threadIdentifier': threadIdentifier,
      'categoryIdentifier': categoryIdentifier,
    };
  }

  factory LocalNotificationModel.fromJson(Map<String, dynamic> json) {
    return LocalNotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      payload: json['payload'],
      channelId: json['channelId'] ?? 'default_channel',
      channelName: json['channelName'] ?? 'Default Channel',
      channelDescription: json['channelDescription'],
      priority: NotificationPriority.values[json['priority'] ?? 2],
      icon: json['icon'],
      color: json['color'] != null ? Color(json['color']) : null,
      enableVibration: json['enableVibration'] ?? true,
      playSound: json['playSound'] ?? true,
      soundFile: json['soundFile'],
      largeIcon: json['largeIcon'],
      bigText: json['bigText'],
      imagePath: json['imagePath'],
      inboxLines: json['inboxLines']?.cast<String>(),
      summaryText: json['summaryText'],
      category: json['category'] != null
          ? NotificationCategory.values[json['category']]
          : null,
      visibility: NotificationVisibility.values[json['visibility'] ?? 0],
      autoCancel: json['autoCancel'] ?? true,
      ongoing: json['ongoing'] ?? false,
      silent: json['silent'] ?? false,
      ticker: json['ticker'],
      presentAlert: json['presentAlert'] ?? true,
      presentBadge: json['presentBadge'] ?? true,
      badgeNumber: json['badgeNumber'],
      subtitle: json['subtitle'],
      threadIdentifier: json['threadIdentifier'],
      categoryIdentifier: json['categoryIdentifier'],
    );
  }

  /// Create a copy with updated fields
  LocalNotificationModel copyWith({
    int? id,
    String? title,
    String? body,
    String? payload,
    String? channelId,
    String? channelName,
    String? channelDescription,
    NotificationPriority? priority,
    String? icon,
    Color? color,
    bool? enableVibration,
    bool? playSound,
    String? soundFile,
    String? largeIcon,
    String? bigText,
    String? imagePath,
    List<String>? inboxLines,
    String? summaryText,
    List<NotificationActionModel>? actions,
    NotificationCategory? category,
    NotificationVisibility? visibility,
    bool? autoCancel,
    bool? ongoing,
    bool? silent,
    String? ticker,
    bool? presentAlert,
    bool? presentBadge,
    int? badgeNumber,
    String? subtitle,
    String? threadIdentifier,
    String? categoryIdentifier,
  }) {
    return LocalNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      channelId: channelId ?? this.channelId,
      channelName: channelName ?? this.channelName,
      channelDescription: channelDescription ?? this.channelDescription,
      priority: priority ?? this.priority,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      enableVibration: enableVibration ?? this.enableVibration,
      playSound: playSound ?? this.playSound,
      soundFile: soundFile ?? this.soundFile,
      largeIcon: largeIcon ?? this.largeIcon,
      bigText: bigText ?? this.bigText,
      imagePath: imagePath ?? this.imagePath,
      inboxLines: inboxLines ?? this.inboxLines,
      summaryText: summaryText ?? this.summaryText,
      actions: actions ?? this.actions,
      category: category ?? this.category,
      visibility: visibility ?? this.visibility,
      autoCancel: autoCancel ?? this.autoCancel,
      ongoing: ongoing ?? this.ongoing,
      silent: silent ?? this.silent,
      ticker: ticker ?? this.ticker,
      presentAlert: presentAlert ?? this.presentAlert,
      presentBadge: presentBadge ?? this.presentBadge,
      badgeNumber: badgeNumber ?? this.badgeNumber,
      subtitle: subtitle ?? this.subtitle,
      threadIdentifier: threadIdentifier ?? this.threadIdentifier,
      categoryIdentifier: categoryIdentifier ?? this.categoryIdentifier,
    );
  }
}

/// Scheduled notification model
class ScheduledNotificationModel extends LocalNotificationModel {
  final tz.TZDateTime scheduledDate;

  const ScheduledNotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required this.scheduledDate,
    super.payload,
    super.channelId,
    super.channelName,
    super.channelDescription,
    super.priority,
    super.icon,
    super.color,
    super.enableVibration,
    super.playSound,
    super.soundFile,
    super.largeIcon,
    super.bigText,
    super.imagePath,
    super.inboxLines,
    super.summaryText,
    super.actions,
    super.category,
    super.visibility,
    super.autoCancel,
    super.ongoing,
    super.silent,
    super.ticker,
    super.presentAlert,
    super.presentBadge,
    super.badgeNumber,
    super.subtitle,
    super.threadIdentifier,
    super.categoryIdentifier,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['scheduledDate'] = scheduledDate.toIso8601String();
    return json;
  }

  factory ScheduledNotificationModel.fromJson(Map<String, dynamic> json) {
    final base = LocalNotificationModel.fromJson(json);
    return ScheduledNotificationModel(
      id: base.id,
      title: base.title,
      body: base.body,
      scheduledDate: tz.TZDateTime.parse(tz.local, json['scheduledDate']),
      payload: base.payload,
      channelId: base.channelId,
      channelName: base.channelName,
      channelDescription: base.channelDescription,
      priority: base.priority,
      icon: base.icon,
      color: base.color,
      enableVibration: base.enableVibration,
      playSound: base.playSound,
      soundFile: base.soundFile,
      largeIcon: base.largeIcon,
      bigText: base.bigText,
      imagePath: base.imagePath,
      inboxLines: base.inboxLines,
      summaryText: base.summaryText,
      actions: base.actions,
      category: base.category,
      visibility: base.visibility,
      autoCancel: base.autoCancel,
      ongoing: base.ongoing,
      silent: base.silent,
      ticker: base.ticker,
      presentAlert: base.presentAlert,
      presentBadge: base.presentBadge,
      badgeNumber: base.badgeNumber,
      subtitle: base.subtitle,
      threadIdentifier: base.threadIdentifier,
      categoryIdentifier: base.categoryIdentifier,
    );
  }
}

/// Repeating notification model
class RepeatingNotificationModel extends LocalNotificationModel {
  final RepeatInterval repeatInterval;

  const RepeatingNotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required this.repeatInterval,
    super.payload,
    super.channelId,
    super.channelName,
    super.channelDescription,
    super.priority,
    super.icon,
    super.color,
    super.enableVibration,
    super.playSound,
    super.soundFile,
    super.largeIcon,
    super.bigText,
    super.imagePath,
    super.inboxLines,
    super.summaryText,
    super.actions,
    super.category,
    super.visibility,
    super.autoCancel,
    super.ongoing,
    super.silent,
    super.ticker,
    super.presentAlert,
    super.presentBadge,
    super.badgeNumber,
    super.subtitle,
    super.threadIdentifier,
    super.categoryIdentifier,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['repeatInterval'] = repeatInterval.index;
    return json;
  }

  factory RepeatingNotificationModel.fromJson(Map<String, dynamic> json) {
    final base = LocalNotificationModel.fromJson(json);
    return RepeatingNotificationModel(
      id: base.id,
      title: base.title,
      body: base.body,
      repeatInterval: RepeatInterval.values[json['repeatInterval']],
      payload: base.payload,
      channelId: base.channelId,
      channelName: base.channelName,
      channelDescription: base.channelDescription,
      priority: base.priority,
      icon: base.icon,
      color: base.color,
      enableVibration: base.enableVibration,
      playSound: base.playSound,
      soundFile: base.soundFile,
      largeIcon: base.largeIcon,
      bigText: base.bigText,
      imagePath: base.imagePath,
      inboxLines: base.inboxLines,
      summaryText: base.summaryText,
      actions: base.actions,
      category: base.category,
      visibility: base.visibility,
      autoCancel: base.autoCancel,
      ongoing: base.ongoing,
      silent: base.silent,
      ticker: base.ticker,
      presentAlert: base.presentAlert,
      presentBadge: base.presentBadge,
      badgeNumber: base.badgeNumber,
      subtitle: base.subtitle,
      threadIdentifier: base.threadIdentifier,
      categoryIdentifier: base.categoryIdentifier,
    );
  }
}

/// Notification action model
class NotificationActionModel {
  final String id;
  final String title;
  final String? icon;
  final bool showsUserInterface;

  const NotificationActionModel({
    required this.id,
    required this.title,
    this.icon,
    this.showsUserInterface = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'showsUserInterface': showsUserInterface,
    };
  }

  factory NotificationActionModel.fromJson(Map<String, dynamic> json) {
    return NotificationActionModel(
      id: json['id'],
      title: json['title'],
      icon: json['icon'],
      showsUserInterface: json['showsUserInterface'] ?? false,
    );
  }
}

/// Notification priority levels
enum NotificationPriority {
  min,
  low,
  normal, // Added for compatibility
  defaultPriority,
  high,
  max,
}

/// Notification categories
enum NotificationCategory {
  general, // Added for default notifications
  appointment, // Added for appointment notifications
  promotion, // Added for promotional notifications
  system, // Added for system notifications
  alarm,
  call,
  email,
  event,
  message,
  recommendation,
  reminder,
  service,
  social,
  status,
  transport,
}

/// Notification visibility levels
enum NotificationVisibility {
  public,
  private,
  secret,
}

/// Push notification model for remote notifications
class PushNotificationModel {
  final String? title;
  final String? body;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final String? clickAction;
  final String? tag;
  final String? collapseKey;
  final int? ttl;
  final NotificationPriority priority;

  const PushNotificationModel({
    this.title,
    this.body,
    this.data,
    this.imageUrl,
    this.clickAction,
    this.tag,
    this.collapseKey,
    this.ttl,
    this.priority = NotificationPriority.defaultPriority,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'data': data,
      'imageUrl': imageUrl,
      'clickAction': clickAction,
      'tag': tag,
      'collapseKey': collapseKey,
      'ttl': ttl,
      'priority': priority.index,
    };
  }

  factory PushNotificationModel.fromJson(Map<String, dynamic> json) {
    return PushNotificationModel(
      title: json['title'],
      body: json['body'],
      data: json['data']?.cast<String, dynamic>(),
      imageUrl: json['imageUrl'],
      clickAction: json['clickAction'],
      tag: json['tag'],
      collapseKey: json['collapseKey'],
      ttl: json['ttl'],
      priority: json['priority'] != null
          ? NotificationPriority.values[json['priority']]
          : NotificationPriority.defaultPriority,
    );
  }
}
