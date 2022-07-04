import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umbrella_reminder/service/firestore_service.dart';
import 'package:umbrella_reminder/service/location_service.dart';
import 'package:umbrella_reminder/service/weather_service.dart';
import 'package:umbrella_reminder/view/home_page.dart';
import 'config/app_config.dart' as conf;

import 'cubit/cubit_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await initializeApp();

  runApp(
    BlocProvider(
      create: (context) => CubitController(
        LocationState(),
        locationService: LocationService(),
        weatherService: WeatherService(Dio(BaseOptions(baseUrl: conf.baseUrl))),
        firestoreService: FirestoreService(),
      ),
      child: const UmbrellaReminder(),
    ),
  );
}

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  conf.AppConfig.deviceId = await _getDeviceId();

  //save device id to firebase if there is no record
  FirestoreService().getUserInfo(conf.AppConfig.deviceId).then((value) {
    if (value == null) {
      FirestoreService().addUser(
        userId: conf.AppConfig.deviceId,
        device: conf.AppConfig.device,
        notification: false,
        time: conf.AppConfig.notificationTime ?? 'unselected',
      );
    } else {
      conf.AppConfig.reminderOn = value['notification'];
      conf.AppConfig.notificationTime = value['notification_time'];
    }
  });

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: false,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   print('Got a message whilst in the foreground!');
  //   print('Message data: ${message.data}');

  //   if (message.notification != null) {
  //     print(
  //         'Message also contained a notification: ${message.notification?.title}');

  //     print(message.notification?.body);
  //   }
  // });
}

Future<String> _getDeviceId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    var iosDeviceInfo = await deviceInfo.iosInfo;
    conf.AppConfig.device = "ios";
    return iosDeviceInfo.identifierForVendor ?? "";
  } else if (Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    conf.AppConfig.device = "android";
    return androidDeviceInfo.androidId ?? "";
  }
  return "";
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
