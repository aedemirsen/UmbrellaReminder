import 'package:bloc/bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:umbrella_reminder/model/weather.dart';
import 'package:umbrella_reminder/service/IWeather_service.dart';

import '../service/ILocation_service.dart';

class CubitController extends Cubit<AppState> {
  //location service
  final ILocationService locationService;
  //weather service
  final IWeatherService weatherService;

  bool isLocationLoading = false;
  bool isWeatherLoading = false;
  bool reminderOn = false;

  CubitController(AppState initialState,
      {required this.locationService, required this.weatherService})
      : super(initialState);

  Future<void> getCurrentPosition() async {
    changeLocationLoading(true);
    final data = await locationService.determinePosition();
    if (data is Position) {
      emit(PositionReceived(data));
    } else {
      emit(PositionFail());
    }
  }

  Future<void> getAdress(double lat, double lon) async {
    final data = await locationService.getAddressFromCoordinates(lat, lon);
    changeLocationLoading(false);
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

  void changeLocationLoading(bool b) {
    isLocationLoading = b;
    emit(LocationLoadingState(isLocationLoading));
  }

  void changeWeatherLoading(bool b) {
    isWeatherLoading = b;
    emit(WeatherLoadingState(isWeatherLoading));
  }

  Future<void> getWeatherForecast(double lat, double lon) async {
    changeWeatherLoading(true);
    final data = await weatherService.getWeather(lat, lon);
    changeWeatherLoading(false);
    if (data is Weather) {
      emit(WeatherReceived(data));
    } else {
      emit(WeatherFail());
    }
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

class LocationLoadingState extends AppState {
  final bool isLoading;

  LocationLoadingState(this.isLoading);
}

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
