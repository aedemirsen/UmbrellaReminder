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
  late bool snackBarDismissed;
  late bool reminderChanged;

  @override
  void initState() {
    addressReceived = false;
    snackBarDismissed = false;
    reminderChanged = false;
    context.read<CubitController>().checkLocationServices();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
          return Center(
            child: SizedBox(
              width: AppConfig.screenWidth * 0.9,
              height: AppConfig.screenHeight * 0.9,
              child: Card(
                color: Colors.blueGrey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(80),
                ),
                elevation: 30,
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(AppConfig.screenWidth * 0.1),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: refresh(),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //Location Info
                        locationInfo(),
                        //Weather info
                        weatherInfo(),
                        //cloud
                        cloud(),
                        //remind me
                        remind(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
          } else if (state is LocationServiceEnable) {
            context.read<CubitController>().getCurrentPosition();
            ScaffoldMessenger.of(context).clearSnackBars();
            setState(() {
              snackBarDismissed = false;
            });
          } else if (state is LocationServiceDisable) {
            if (!snackBarDismissed) {
              _showSnackbar("Location Services Needed!", "Close");
            }
          } else if (state is ReminderLoadingState) {
            reminderChanged = state.isLoading;
          }
        },
      ),
    );
  }

  void _showSnackbar(String message, String label) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 5),
      content: Text(message),
      action: SnackBarAction(
        label: label,
        onPressed: () {
          setState(() {
            snackBarDismissed = true;
            ScaffoldMessenger.of(context).clearSnackBars();
          });
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  GestureDetector refresh() {
    return GestureDetector(
      child: const Icon(
        conf.refreshIcon,
        size: conf.refreshIconSize,
      ),
      onTap: () {
        context.read<CubitController>().getCurrentPosition();
      },
    );
  }

  Padding remind() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Remind me when it's rainy",
            style: TextStyle(
              fontSize: conf.remindMeFontSize,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20.0, right: 20, bottom: 20),
            child: Text(
              "(Sends push notification every day at selected time if it's rainy.)",
              style: TextStyle(
                fontSize: conf.remindMeSubfontSize,
              ),
            ),
          ),
          SizedBox(
            width: conf.timePickButtonWidth,
            height: conf.timePickButtonHeight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.grey.shade300,
              ),
              onPressed: () {
                context.read<CubitController>().changeSelectedTime(context);
              },
              child: Stack(
                children: [
                  Visibility(
                    visible:
                        !context.watch<CubitController>().selectedTimeLoading,
                    child: Text(
                      conf.AppConfig.notificationTime ?? 'unselected',
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Visibility(
                    visible:
                        context.watch<CubitController>().selectedTimeLoading,
                    child: const SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          remindSwitch(),
        ],
      ),
    );
  }

  Row remindSwitch() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: conf.remindSwitchLeftPadding),
          child: SizedBox(
            height: conf.switchSize,
            width: conf.switchSize,
            child: FittedBox(
              child: Switch(
                value: conf.AppConfig.reminderOn,
                onChanged: (b) {
                  //update database
                  context.read<CubitController>().toggleReminder(
                        conf.AppConfig.deviceId,
                        conf.AppConfig.device,
                        b,
                        conf.AppConfig.notificationTime ?? 'unselected',
                      );
                  conf.AppConfig.reminderOn = b;
                },
              ),
            ),
          ),
        ),
        Visibility(
          visible: reminderChanged,
          child: const CircularProgressIndicator(),
        ),
      ],
    );
  }

  SizedBox locationInfo() {
    return SizedBox(
      height: conf.locationInfoHeight,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Visibility(
              visible: context.watch<CubitController>().isWeatherLoading,
              child: const CircularProgressIndicator(),
            ),
            Visibility(
              visible: !context.watch<CubitController>().isWeatherLoading,
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
              Text(
                weatherStatus ?? "Unknown",
                style: const TextStyle(
                  fontSize: conf.weatherStatusFontSize,
                ),
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
              Text(
                temperature ?? "Unknown",
                style: const TextStyle(
                  fontSize: conf.weatherStatusFontSize,
                ),
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
