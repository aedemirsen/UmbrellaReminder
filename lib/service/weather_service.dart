import 'dart:io';

import 'package:umbrella_reminder/model/weather.dart';
import 'package:umbrella_reminder/service/IWeather_service.dart';

class WeatherService extends IWeatherService {
  WeatherService(super.dio);

  @override
  Future<Weather?> getWeather(double lat, double lon) async {
    try {
      final response = await dio.get(endPoint, queryParameters: {
        'latitude': lat,
        'longitude': lon,
        'current_weather': true
      });
      if (response.statusCode == HttpStatus.ok) {
        return Weather.fromJson(response.data);
      }
    } on Exception {
      return null;
    }
    return null;
  }
}
