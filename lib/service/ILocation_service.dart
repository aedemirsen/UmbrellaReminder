import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

abstract class ILocationService {
  Future<Position?> determinePosition();

  Future<Placemark?> getAddressFromCoordinates(double lat, double lon);
}
