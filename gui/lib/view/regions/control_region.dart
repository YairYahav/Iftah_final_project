import 'package:example_project/bloc/telemetry_bloc/telemetry_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:example_project/view/widgets/telemetry_widgets/telemetry_widget.dart';
import 'package:example_project/view/widgets/weapon_widgets/weapon_widget.dart';
import 'package:flutter/material.dart';

class ControlRegionWidget extends StatelessWidget {
  const ControlRegionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width * (1.2 / 5),
      child: Container(
        color: Theme.of(context).primaryColor,
        child: Stack(
          children: [
            const WeaponWidget(),
            BlocProvider(
              lazy: false,
              create: (context) => TelemetryBloc(),
              child: const Align(
                alignment: Alignment.bottomCenter,
                child: TelemetryWidget(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
