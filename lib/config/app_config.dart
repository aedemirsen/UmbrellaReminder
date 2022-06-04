import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:umbrella_reminder/model/weather.dart';

class AppConfig {
  static double screenWidth = 0, screenHeight = 0;
}

const String baseUrl = 'https://api.open-meteo.com/v1';

const double cityFontSize = 50;
const double districtFontSize = 30;
final double iconSize = AppConfig.screenWidth * 0.4;
const Color iconColor = Colors.grey;
const double locationInfoHeight = 150;
const double weatherInfoHeight = 40;
const double weatherStatusFontSize = 20;
const double remindMeFontSize = 20;
const double switchSize = 100;
const double refreshIconSize = 40;

///icons
//refresh
const IconData refreshIcon = Icons.refresh;
//clear sky
final FaIcon clearSky = FaIcon(
  FontAwesomeIcons.sun,
  color: iconColor,
  size: iconSize,
);
//partly Cloudy
final FaIcon partylCloudy = FaIcon(
  FontAwesomeIcons.cloudSun,
  color: iconColor,
  size: iconSize,
);
//overcast
final FaIcon overcast = FaIcon(
  FontAwesomeIcons.cloud,
  color: iconColor,
  size: iconSize,
);
//fog
final FaIcon fog = FaIcon(
  FontAwesomeIcons.smog,
  color: iconColor,
  size: iconSize,
);
//rain
final FaIcon rain = FaIcon(
  FontAwesomeIcons.cloudRain,
  color: iconColor,
  size: iconSize,
);
//snow
final FaIcon snow = FaIcon(
  FontAwesomeIcons.snowflake,
  color: iconColor,
  size: iconSize,
);
//thunder
final FaIcon thunder = FaIcon(
  FontAwesomeIcons.boltLightning,
  color: iconColor,
  size: iconSize,
);

final Map<int, WeatherData> weatherStatus = {
  0: WeatherData('Clear Sky', clearSky),
  1: WeatherData('Mainly Clear', clearSky),
  2: WeatherData('Partly Cloudy', partylCloudy),
  3: WeatherData('Overcast', partylCloudy),
  45: WeatherData('fog', fog),
  48: WeatherData('Depositing Rime Fog', fog),
  51: WeatherData('Light Drizzle', rain),
  53: WeatherData('Moderate Drizzle', rain),
  55: WeatherData('Dense Drizzle', rain),
  56: WeatherData('Freezing Light Drizzle', rain),
  57: WeatherData('Freezing Dense Drizzle', rain),
  61: WeatherData('Slight Rain', rain),
  63: WeatherData('Moderate Rain', rain),
  65: WeatherData('Heavy Rain', rain),
  66: WeatherData('Freezing Light Rain', rain),
  67: WeatherData('Freezing Heavy Rain', rain),
  71: WeatherData('Slight Snow Fall', snow),
  74: WeatherData('Moderate Snow Fall', snow),
  75: WeatherData('Heavy Snow Fall', snow),
  77: WeatherData('Snow Grains', snow),
  80: WeatherData('Slight Rain Shower', rain),
  81: WeatherData('Moderate Rain Shower', rain),
  82: WeatherData('Heavy Rain Shower', rain),
  85: WeatherData('Slight Snow Shower', snow),
  86: WeatherData('Heavy Snow Shower', snow),
  95: WeatherData('Thunderstorm', thunder),
  96: WeatherData('Thunderstorm', thunder),
  99: WeatherData('Thunderstorm', thunder),
};
