import 'package:example_project/bloc/telemetry_bloc/telemetry_bloc.dart';
import 'package:example_project/global/consts/const_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TelemetryWidget extends StatelessWidget {
  const TelemetryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TelemetryBloc, TelemetryState>(
      buildWhen: (previous, current) => current is TelemetryReceivedState,
      builder: (context, state) {
        return Container(
            color: Theme.of(context).primaryColor.withAlpha(70),
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2.5,
              height: MediaQuery.of(context).size.height / 20,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state is TelemetryReceivedState
                              ? state.voltage.toString()
                              : 0.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color),
                        ),
                        Text(
                          ConstString.voltageString,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 5,
                      height: 3,
                    ),
                  ]),
            ));
      },
    );
  }
}
