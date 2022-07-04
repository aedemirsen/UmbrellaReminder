import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:umbrella_reminder/config/app_config.dart';
import 'package:umbrella_reminder/model/weather.dart';
import 'package:umbrella_reminder/service/IFirestore_service.dart';
import 'package:umbrella_reminder/service/IWeather_service.dart';

import '../service/ILocation_service.dart';

class CubitController extends Cubit<AppState> {
  //location service
  final ILocationService locationService;
  //weather service
  final IWeatherService weatherService;
  //firebase service
  final IFirestoreService firestoreService;

  bool isWeatherLoading = false;
  bool reminderOn = false;
  bool locationCheck = false;
  bool selectedTimeLoading = false;
  TimeOfDay? selectedTime = const TimeOfDay(hour: 6, minute: 0);

  CubitController(AppState initialState,
      {required this.firestoreService,
      required this.locationService,
      required this.weatherService})
      : super(initialState);

  Future<void> getCurrentPosition() async {
    changeWeatherLoading(true);
    final data = await locationService.determinePosition();
    if (data is Position) {
      emit(PositionReceived(data));
    } else {
      emit(PositionFail());
    }
  }

  Future<void> getAdress(double lat, double lon) async {
    final data = await locationService.getAddressFromCoordinates(lat, lon);
    if (data is Placemark) {
      emit(AddressReceived(data));
    } else {
      emit(AddressFail());
    }
  }

  Future<void> toggleReminder(
      String userId, String device, bool notification, String time) async {
    changeRemindLoading(true);
    reminderOn = notification;
    await firestoreService.addUser(
      userId: userId,
      device: device,
      notification: notification,
      time: time,
    );
    changeRemindLoading(false);
  }

  void changeWeatherLoading(bool b) {
    isWeatherLoading = b;
  }

  Future<void> getWeatherForecast(double lat, double lon) async {
    final data = await weatherService.getWeather(lat, lon);
    changeWeatherLoading(false);
    if (data is Weather) {
      emit(WeatherReceived(data));
    } else {
      emit(WeatherFail());
    }
  }

  void checkLocationServices() {
    locationCheck = false;
    const period = Duration(seconds: 2);
    Timer.periodic(
      period,
      (Timer t) => Permission.location.serviceStatus.isEnabled.then(
        (value) {
          if (value && !locationCheck) {
            locationCheck = true;
            emit(LocationServiceEnable());
          } else if (!value) {
            locationCheck = false;
            emit(LocationServiceDisable());
          }
        },
      ),
    );
  }

  Future<void> changeSelectedTime(BuildContext context) async {
    selectedTimeLoading = true;
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    selectedTime = timeOfDay;
    String hour = selectedTime!.hour > 10
        ? selectedTime!.hour.toString()
        : '0${selectedTime!.hour}';
    String minute = selectedTime!.minute > 10
        ? selectedTime!.minute.toString()
        : '0${selectedTime!.minute}';
    String period = selectedTime!.period.name;
    AppConfig.notificationTime = '$hour : $minute $period';
    //update db
    await firestoreService.addUser(
        userId: AppConfig.deviceId,
        device: AppConfig.device,
        notification: AppConfig.reminderOn,
        time: AppConfig.notificationTime ?? 'unselected');
    selectedTimeLoading = false;
  }

  void changeRemindLoading(bool b) {
    emit(ReminderLoadingState(b));
  }
}

abstract class AppState {}

class LocationState extends AppState {}

class WeatherState extends AppState {}

class PositionReceived extends AppState {
  final Position position;

  PositionReceived(this.position);
}

class PositionFail extends AppState {}

class AddressReceived extends AppState {
  final Placemark placemark;

  AddressReceived(this.placemark);
}

class AddressFail extends AppState {}

class ReminderLoadingState extends AppState {
  final bool isLoading;

  ReminderLoadingState(this.isLoading);
}

class WeatherReceived extends AppState {
  final Weather weather;

  WeatherReceived(this.weather);
}

class WeatherFail extends AppState {}

class LocationServiceEnable extends AppState {}

class LocationServiceDisable extends AppState {}
