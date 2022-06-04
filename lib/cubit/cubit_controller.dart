import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:umbrella_reminder/model/weather.dart';
import 'package:umbrella_reminder/service/IWeather_service.dart';

import '../service/ILocation_service.dart';

class CubitController extends Cubit<AppState> {
  //location service
  final ILocationService locationService;
  //weather service
  final IWeatherService weatherService;

  bool isWeatherLoading = false;
  bool reminderOn = false;
  bool locationCheck = false;

  CubitController(AppState initialState,
      {required this.locationService, required this.weatherService})
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

  void toggleReminder(bool b) {
    reminderOn = b;
    emit(ReminderState(reminderOn));
  }

  void changeWeatherLoading(bool b) {
    isWeatherLoading = b;
    emit(WeatherLoadingState(isWeatherLoading));
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

class WeatherLoadingState extends AppState {
  final bool isLoading;

  WeatherLoadingState(this.isLoading);
}

class ReminderState extends AppState {
  final bool reminderOn;

  ReminderState(this.reminderOn);
}

class WeatherReceived extends AppState {
  final Weather weather;

  WeatherReceived(this.weather);
}

class WeatherFail extends AppState {}

class LocationServiceEnable extends AppState {}

class LocationServiceDisable extends AppState {}
