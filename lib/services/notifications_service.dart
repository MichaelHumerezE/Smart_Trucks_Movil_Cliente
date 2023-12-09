import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> mostrarNotificacion() async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('channelId', 'channelName',
          importance: Importance.max, priority: Priority.high);

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
  );

  await flutterLocalNotificationsPlugin.show(
      1,
      '!Prepárate ya esta llegando¡',
      'El camion de basura ya esta cerca de tu posición registrada.',
      notificationDetails);
}