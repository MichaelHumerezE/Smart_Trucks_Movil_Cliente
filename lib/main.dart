import 'package:flutter/material.dart';
import 'package:smart_trucks_v2/services/notifications_service.dart';
import 'package:smart_trucks_v2/services/push_notifications_service.dart';

import 'screens/loading.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PushNotificationService.initializeApp();
  await initNotifications();
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _App createState() => _App();
}

class _App extends State<App> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //context
    PushNotificationService.messagesStream.listen((message) {
      print("App: $message");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Loading(),
    );
  }
}
