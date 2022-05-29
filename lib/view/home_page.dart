import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umbrella_reminder/cubit/cubit_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(title ?? "")),
      ),
      body: Center(
        child: Column(
          children: [
            BlocBuilder<CubitController, AppState>(
              builder: (context, state) {
                if (state is AddressReceived) {
                  String? city = state.placemark.administrativeArea;
                  String? district = state.placemark.subAdministrativeArea;
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          city ?? "Unknown",
                          style: const TextStyle(
                            fontSize: 50,
                          ),
                        ),
                        Text(
                          district ?? "",
                          style: const TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Visibility(
                          visible: context.watch<CubitController>().isLoading,
                          child: const CircularProgressIndicator(),
                        ),
                        const Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: Text(
                              "Unknown",
                              style: TextStyle(
                                fontSize: 50,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            )
          ],
        ),
      ),
      floatingActionButton: _floatingButton(context),
    );
  }

  _floatingButton(BuildContext context) {
    return BlocListener<CubitController, AppState>(
      listener: (context, state) {
        if (state is PositionReceived) {
          context
              .read<CubitController>()
              .getAdress(state.position.latitude, state.position.longitude);
        }
      },
      child: FloatingActionButton(
        onPressed: () {
          context.read<CubitController>().getCurrentPosition();
        },
      ),
    );
  }
}
