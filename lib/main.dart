import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umbrella_reminder/service/location_service.dart';
import 'package:umbrella_reminder/view/home_page.dart';

import 'cubit/cubit_controller.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) =>
          CubitController(LocationState(), locationService: LocationService()),
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
