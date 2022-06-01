import 'package:dio/dio.dart';

import '../model/weather.dart';

abstract class IWeatherService {
  final Dio dio;

  final String endPoint = "/forecast";

  IWeatherService(this.dio);

  Future<Weather?> getWeather(double lat, double lon);
}
