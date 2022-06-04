import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:umbrella_reminder/service/location_service.dart';
import 'package:umbrella_reminder/service/weather_service.dart';
import 'package:umbrella_reminder/view/home_page.dart';
import 'config/app_config.dart' as conf;

import 'cubit/cubit_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // FirebaseMessaging messaging = FirebaseMessaging.instance;

  // NotificationSettings settings = await messaging.requestPermission(
  //   alert: true,
  //   announcement: false,
  //   badge: true,
  //   carPlay: false,
  //   criticalAlert: false,
  //   provisional: false,
  //   sound: true,
  // );

  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   print('Got a message whilst in the foreground!');
  //   print('Message data: ${message.data}');

  //   if (message.notification != null) {
  //     print('Message also contained a notification: ${message.notification}');
  //   }
  // });

  runApp(
    BlocProvider(
      create: (context) => CubitController(LocationState(),
          locationService: LocationService(),
          weatherService:
              WeatherService(Dio(BaseOptions(baseUrl: conf.baseUrl)))),
      child: const UmbrellaReminder(),
    ),
  );
}

class UmbrellaReminder extends StatelessWidget {
  const UmbrellaReminder({Key? key}) : super(key: key);

  final String title = "Umbrella Reminder";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "Trebuchet MS",
      ),
      home: HomePage(
        title: title,
      ),
    );
  }
}
