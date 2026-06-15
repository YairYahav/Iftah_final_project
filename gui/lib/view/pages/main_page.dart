import 'package:example_project/bloc/telemetry_bloc/telemetry_bloc.dart';
import 'package:example_project/view/regions/camera_region.dart';
import 'package:example_project/view/regions/control_region.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/camera_control_bloc/camera_cotrol_bloc.dart';
import '../../bloc/theme_bloc/theme_bloc.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ThemeBloc(),
          ),
          BlocProvider(
            lazy: false,
            create: (context) => CameraControlBloc(),
          ),
        ],
        child: BlocProvider(
            create: (context) => ThemeBloc(),
            child:
                BlocBuilder<ThemeBloc, ThemeState>(builder: (context, state) {
              return MaterialApp(
                  themeMode: context.watch<ThemeBloc>().state.appTheme ==
                          AppTheme.light
                      ? ThemeMode.light
                      : ThemeMode.dark,
                  darkTheme: ThemeData(
                      useMaterial3: true,
                      iconTheme: const IconThemeData(
                          color: Color.fromARGB(255, 21, 108, 158)),
                      buttonTheme: const ButtonThemeData(
                        buttonColor: Color.fromARGB(239, 21, 108, 158),
                      ),
                      primaryColor: const Color.fromARGB(237, 4, 20, 29),
                      textTheme: const TextTheme(
                          bodyLarge: TextStyle(color: Color(0xffDDDDDD)),
                          bodyMedium: TextStyle(
                              color: Color.fromARGB(239, 21, 108, 158)),
                          bodySmall: TextStyle(color: Color(0xffDDDDDD)))),
                  theme: ThemeData(
                    useMaterial3: true,
                    iconTheme: const IconThemeData(
                        color: Color.fromARGB(255, 21, 108, 158)),
                    buttonTheme: const ButtonThemeData(
                      buttonColor: Color.fromARGB(255, 21, 108, 158),
                    ),
                    primaryColor: const Color(0xffDDDDDD),
                    textTheme: const TextTheme(
                        bodyLarge:
                            TextStyle(color: Color.fromARGB(237, 4, 20, 29)),
                        bodyMedium:
                            TextStyle(color: Color.fromARGB(239, 21, 108, 158)),
                        bodySmall:
                            TextStyle(color: Color.fromARGB(237, 4, 20, 29))),
                  ),
                  debugShowCheckedModeBanner: false,
                  home: Scaffold(
                      floatingActionButtonLocation:
                          FloatingActionButtonLocation.centerFloat,
                      floatingActionButton: Stack(
                        children: [
                          Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(10),
                              ),
                              Column(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(10),
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: IconButton(
                                        onPressed: () {
                                          context
                                              .read<ThemeBloc>()
                                              .add(ToggleThemeEvent());
                                        },
                                        icon: Icon(
                                          context
                                                      .watch<ThemeBloc>()
                                                      .state
                                                      .appTheme ==
                                                  AppTheme.light
                                              ? Icons.dark_mode_sharp
                                              : Icons.light_mode_sharp,
                                          size: 60,
                                          color: const Color.fromARGB(
                                              255, 21, 108, 158),
                                        )),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      body:  const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CameraRegionWidget(),
                            ControlRegionWidget(),
                          ],
                        ),
                      ));
            })));
  }
}
