import 'package:example_project/bloc/status_led_bloc/status_led_bloc.dart';
import 'package:example_project/global/consts/const_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SafeStatusWidget extends StatelessWidget {
  const SafeStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StatusLedBloc(),
      child: BlocConsumer<StatusLedBloc, StatusLedBlocState>(
        listener: (context, state) {},
        buildWhen: (previousState, state) {
          return state is TurnLedsColorState;
        },
        builder: (context, state) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                    onPressed: () {
                      context
                          .read<StatusLedBloc>()
                          .add(const SendStatusRequest());
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).iconTheme.color),
                    child: Text(
                      textAlign: TextAlign.center,
                      ConstString.safeStatusString,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    )),
              ),
              const Padding(padding: EdgeInsets.all(20)),
              Icon(
                Icons.brightness_1_rounded,
                size: 50,
                color:
                    state is TurnLedsColorState ? state.stmColor : Colors.grey,
              ),
              const Padding(padding: EdgeInsets.all(10)),
              Icon(
                Icons.brightness_1_rounded,
                size: 50,
                color: state is TurnLedsColorState
                    ? state.atmelColor
                    : Colors.grey,
              ),
            ],
          );
        },
      ),
    );
  }
}
