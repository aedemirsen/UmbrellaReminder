import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Weather {
  int? utcOffsetSeconds;
  double? latitude;
  double? elevation;
  double? longitude;
  double? generationtimeMs;
  CurrentWeather? currentWeather;

  Weather(
      {this.utcOffsetSeconds,
      this.latitude,
      this.elevation,
      this.longitude,
      this.generationtimeMs,
      this.currentWeather});

  Weather.fromJson(Map<String, dynamic> json) {
    utcOffsetSeconds = json['utc_offset_seconds'];
    latitude = json['latitude'].toDouble();
    elevation = json['elevation'].toDouble();
    longitude = json['longitude'].toDouble();
    generationtimeMs = json['generationtime_ms'].toDouble();
    currentWeather = json['current_weather'] != null
        ? CurrentWeather.fromJson(json['current_weather'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['utc_offset_seconds'] = utcOffsetSeconds;
    data['latitude'] = latitude;
    data['elevation'] = elevation;
    data['longitude'] = longitude;
    data['generationtime_ms'] = generationtimeMs;
    if (currentWeather != null) {
      data['current_weather'] = currentWeather!.toJson();
    }
    return data;
  }
}

class CurrentWeather {
  double? temperature;
  double? weathercode;
  String? time;
  double? windspeed;
  double? winddirection;

  CurrentWeather(
      {this.temperature,
      this.weathercode,
      this.time,
      this.windspeed,
      this.winddirection});

  CurrentWeather.fromJson(Map<String, dynamic> json) {
    temperature = json['temperature'].toDouble();
    weathercode = json['weathercode'].toDouble();
    time = json['time'];
    windspeed = json['windspeed'].toDouble();
    winddirection = json['winddirection'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['temperature'] = temperature;
    data['weathercode'] = weathercode;
    data['time'] = time;
    data['windspeed'] = windspeed;
    data['winddirection'] = winddirection;
    return data;
  }
}

class WeatherData {
  final String? weatherStatus;
  final FaIcon? weatherIcon;

  WeatherData(this.weatherStatus, this.weatherIcon);
}
