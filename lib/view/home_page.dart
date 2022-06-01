import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:umbrella_reminder/cubit/cubit_controller.dart';
import 'package:umbrella_reminder/config/app_config.dart';
import 'package:umbrella_reminder/config/app_config.dart' as conf;

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String? title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? city;
  String? district;
  String? weatherStatus;
  String? temperature;
  FaIcon? weatherIcon;
  late bool addressReceived;

  @override
  void initState() {
    addressReceived = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppConfig.screenHeight = MediaQuery.of(context).size.height;
    AppConfig.screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // appBar: AppBar(
      //   title: Center(child: Text(widget.title ?? "")),
      // ),
      body: BlocConsumer<CubitController, AppState>(
        builder: (context, state) {
          if (!addressReceived) {
            context.read<CubitController>().getCurrentPosition();
            addressReceived = true;
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Location Info
              locationInfo(context),
              //Weather info
              weatherInfo(),
              //cloud
              cloud(),
              //remind me
              remind(context),
            ],
          );
        },
        listener: (context, state) {
          if (state is AddressReceived) {
            setState(() {
              city = state.placemark.administrativeArea;
              district = state.placemark.subAdministrativeArea;
            });
          } else if (state is WeatherReceived) {
            setState(() {
              weatherStatus = conf
                  .weatherStatus[state.weather.currentWeather?.weathercode]
                  ?.weatherStatus;
              temperature = "${state.weather.currentWeather?.temperature}°C";
              weatherIcon = conf
                  .weatherStatus[state.weather.currentWeather?.weathercode]
                  ?.weatherIcon;
            });
          } else if (state is PositionReceived) {
            context.read<CubitController>().getAdress(
                  state.position.latitude,
                  state.position.longitude,
                );
            context.read<CubitController>().getWeatherForecast(
                  state.position.latitude,
                  state.position.longitude,
                );
          }
        },
      ),
    );
  }

  Padding remind(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Remind me when it's rainy",
            style: TextStyle(
              fontSize: conf.remindMeFontSize,
            ),
          ),
          SizedBox(
            height: conf.switchSize,
            width: conf.switchSize,
            child: FittedBox(
              child: Switch(
                value: context.watch<CubitController>().reminderOn,
                onChanged: (b) {
                  context.read<CubitController>().toggleReminder(b);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  SizedBox locationInfo(BuildContext context) {
    return SizedBox(
      height: conf.locationInfoHeight,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Visibility(
              visible: context.watch<CubitController>().isLocationLoading,
              child: const CircularProgressIndicator(),
            ),
            Visibility(
              visible: !context.watch<CubitController>().isLocationLoading,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    city ?? "Unknown",
                    style: const TextStyle(
                      fontSize: conf.cityFontSize,
                    ),
                  ),
                  city == null
                      ? const SizedBox.shrink()
                      : Text(
                          district ?? "",
                          style: const TextStyle(
                            fontSize: conf.districtFontSize,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column weatherInfo() {
    return Column(
      children: [
        temperatureInfo(),
        statusInfo(),
      ],
    );
  }

  SizedBox statusInfo() {
    return SizedBox(
      height: conf.weatherInfoHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Weather Status: ",
            style: TextStyle(
              fontSize: conf.weatherStatusFontSize,
            ),
          ),
          Stack(
            children: [
              Visibility(
                visible: !context.watch<CubitController>().isWeatherLoading,
                child: Text(
                  weatherStatus ?? "Unknown",
                  style: const TextStyle(
                    fontSize: conf.weatherStatusFontSize,
                  ),
                ),
              ),
              Visibility(
                visible: context.watch<CubitController>().isWeatherLoading,
                child: const CircularProgressIndicator(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  SizedBox temperatureInfo() {
    return SizedBox(
      height: conf.weatherInfoHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Temperature: ",
            style: TextStyle(
              fontSize: conf.weatherStatusFontSize,
            ),
          ),
          Stack(
            children: [
              Visibility(
                visible: !context.watch<CubitController>().isWeatherLoading,
                child: Text(
                  temperature ?? "Unknown",
                  style: const TextStyle(
                    fontSize: conf.weatherStatusFontSize,
                  ),
                ),
              ),
              Visibility(
                visible: context.watch<CubitController>().isWeatherLoading,
                child: const CircularProgressIndicator(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Padding cloud() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: weatherIcon ?? conf.clearSky,
    );
  }
}
