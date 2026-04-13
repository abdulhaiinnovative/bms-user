// Notification Services Export File
// This file provides a single entry point for all notification-related services

// Main notification service - use this for most notification operations
export 'notification_service.dart';

// Individual services (use directly if you need specific functionality)
export 'local_notification_service.dart';
export 'push_notification_service.dart';
export 'notification_handler.dart';

// Models and configuration
export 'notification_models.dart';
export 'notification_config.dart';

// Usage Examples:
//
// 1. Initialize notification services in main.dart:
//    ```dart
//    import 'package:your_app/services/notifications/notification_service.dart';
//    
//    void main() async {
//      WidgetsFlutterBinding.ensureInitialized();
//      
//      final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//      
//      // Initialize notification service
//      await NotificationService.initialize(navigatorKey: navigatorKey);
//      
//      runApp(MyApp(navigatorKey: navigatorKey));
//    }
//    ```
//
// 2. Show a simple notification:
//    ```dart
//    await NotificationService.showNotification(
//      title: 'Hello',
//      body: 'This is a test notification',
//    );
//    ```
//
// 3. Show appointment reminder:
//    ```dart
//    await NotificationService.showAppointmentReminder(
//      appointmentId: '123',
//      salonName: 'Beauty Salon',
//      appointmentTime: DateTime.now().add(Duration(hours: 2)),
//    );
//    ```
//
// 4. Schedule appointment reminder:
//    ```dart
//    await NotificationService.scheduleAppointmentReminder(
//      appointmentId: '123',
//      salonName: 'Beauty Salon',
//      appointmentTime: DateTime.now().add(Duration(days: 1)),
//      reminderBefore: Duration(hours: 2),
//    );
//    ```
//
// 5. Show promotion notification:
//    ```dart
//    await NotificationService.showPromotionNotification(
//      promoId: 'promo123',
//      title: 'Special Offer!',
//      description: '50% off on all services',
//      salonName: 'Beauty Salon',
//      discountPercentage: 50,
//    );
//    ```
//
// 6. Register custom notification callbacks:
//    ```dart
//    NotificationService.registerNotificationCallback(
//      'custom_type',
//      () => {/* custom callback */},
//    );
//    ```
//
// 7. Get FCM token for server registration:
//    ```dart
//    final String? fcmToken = NotificationService.getFCMToken();
//    if (fcmToken != null) {
//      // Send token to your server
//    }
//    ```
//
// Required Dependencies in pubspec.yaml:
//    dependencies:
//      firebase_core: ^2.24.2
//      firebase_messaging: ^14.7.10
//      flutter_local_notifications: ^16.3.2
//      permission_handler: ^11.0.1
//      timezone: ^0.9.2
//
// Required Setup:
// 1. Firebase setup (google-services.json, GoogleService-Info.plist)
// 2. Add permissions to android/app/src/main/AndroidManifest.xml:
//    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
//    <uses-permission android:name="android.permission.VIBRATE" />
//    <uses-permission android:name="android.permission.WAKE_LOCK" />
//    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
//
// 3. Add notification handling to android/app/src/main/AndroidManifest.xml:
//    <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
//    <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
//        <intent-filter>
//            <action android:name="android.intent.action.BOOT_COMPLETED"/>
//            <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
//            <action android:name="android.intent.action.QUICKBOOT_POWERON" />
//            <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
//        </intent-filter>
//    </receiver>
//
// 4. iOS setup in ios/Runner/Info.plist:
//    <key>UIBackgroundModes</key>
//    <array>
//        <string>background-fetch</string>
//        <string>remote-notification</string>
//    </array>
//
// Notes:
// - All services are designed to work independently but are best used together
// - The NotificationService class provides a high-level API for common operations
// - Individual services can be used directly for advanced functionality
// - All notification handling is centralized through NotificationHandler
// - Push notifications require Firebase setup and server-side implementation
// - Local notifications work offline and are perfect for reminders
// - The services handle permissions automatically but you can also request them manually