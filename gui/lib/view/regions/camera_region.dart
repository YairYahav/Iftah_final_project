import 'package:example_project/bloc/info_window_bloc/info_window_bloc.dart';
import 'package:example_project/bloc/telemetry_bloc/telemetry_bloc.dart';
import 'package:example_project/bloc/warning_bloc/warning_bloc.dart';
import 'package:example_project/global/consts/enums.dart';
import 'package:example_project/view/widgets/camera_widgets/camera_control_widget.dart';
import 'package:example_project/view/widgets/telemetry_widgets/information_window_widget.dart';
import 'package:example_project/view/widgets/telemetry_widgets/warning_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CameraRegionWidget extends StatelessWidget {
  const CameraRegionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width * (3.8 / 5),
            child: Stack(children: [
              Container(
                alignment: Alignment.center,
                color: Theme.of(context).primaryColor,
                child: Stack(children: [
                  const CameraControlWidget(),
                  BlocProvider(
                    lazy: false,
                    create: (context) => WarningBloc(),
                    child: BlocBuilder<WarningBloc, WarningState>(
                      buildWhen: (previous, current) =>
                          current is WarningStateChanged,
                      builder: (context, state) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: state is WarningStateChanged &&
                                      state.connectionStatus ==
                                          ConnectionStatus.error
                                  ? const ConnectionErrorWarningWidget()
                                  : Container()),
                        );
                      },
                    ),
                  ),
                  BlocProvider(
                    lazy: false,
                    create: (context) => InfoWindowBloc(),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: BlocBuilder<InfoWindowBloc, InfoWindowState>(
                        buildWhen: (previous, current) =>
                            current is RebuildListState,
                        builder: (context, state) {
                          return Align(
                            alignment: Alignment.topRight,
                            child: FittedBox(
                              fit: BoxFit.none,
                              child: InformationWindowWidget(
                                  state is RebuildListState
                                      ? state.infoList
                                      : []),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                ]),
              ),
            ])),
      ],
    );
  }
}
