import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    await _notifications.initialize(settings: initializationSettings);
  }

  static Future<void> showProgressNotification(
      int id, int progress, String title) async {
    
    final bool isDone = progress >= 100;

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'download_channel',
      'Media Downloads',
      channelDescription: 'Showing progress of media downloads',
      importance: isDone ? Importance.high : Importance.low,
      priority: isDone ? Priority.high : Priority.low,
      onlyAlertOnce: true,
      showProgress: !isDone,
      maxProgress: 100,
      progress: progress,
      ongoing: !isDone,
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notifications.show(
      id: id,
      title: isDone ? 'TRANSFER_COMPLETE' : 'DOWNLOAD_IN_PROGRESS',
      body: isDone ? 'Done! $title secured.' : '$progress% - $title',
      notificationDetails: platformChannelSpecifics,
    );
  }
}
