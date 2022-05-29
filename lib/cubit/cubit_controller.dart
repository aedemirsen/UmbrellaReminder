import 'package:bloc/bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../service/ILocation_service.dart';

class CubitController extends Cubit<AppState> {
  //location service
  final ILocationService locationService;

  bool isLoading = false;

  CubitController(AppState initialState, {required this.locationService})
      : super(initialState);

  Future<void> getCurrentPosition() async {
    changeLoading(true);
    final data = await locationService.determinePosition();
    if (data is Position) {
      emit(PositionReceived(data));
    } else {
      emit(PositionFail());
    }
  }

  Future<void> getAdress(double lat, double lon) async {
    final data = await locationService.getAddressFromCoordinates(lat, lon);
    changeLoading(false);
    if (data is Placemark) {
      emit(AddressReceived(data));
    } else {
      emit(AddressFail());
    }
  }

  void changeLoading(bool b) {
    isLoading = b;
    emit(LoadingState(isLoading));
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

class LoadingState extends AppState {
  final bool isLoading;

  LoadingState(this.isLoading);
}
