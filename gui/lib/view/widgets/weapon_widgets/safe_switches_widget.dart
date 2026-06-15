import 'package:example_project/bloc/weapon_bloc/weapon_bloc.dart';
import 'package:example_project/global/consts/const_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SafeSwitchesWidget extends StatelessWidget {
  const SafeSwitchesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeaponBloc, WeaponState>(
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(padding: EdgeInsets.all(10)),
                BlocBuilder<WeaponBloc, WeaponState>(
                  buildWhen: (previous, current) =>
                      current is SafeSwitchOneFlippedState,
                  builder: (context, state) {
                    return SizedBox(
                      width: 100,
                      child: FittedBox(
                        child: Switch(
                            trackColor: state is SafeSwitchOneFlippedState &&
                                    state.switchValue
                                ? WidgetStatePropertyAll<Color>(
                                    Theme.of(context).iconTheme.color!)
                                : const WidgetStatePropertyAll<Color>(
                                    Colors.grey),
                            thumbColor: WidgetStatePropertyAll<Color>(
                                Theme.of(context).textTheme.bodyLarge!.color!),
                            onChanged: (newVal) {
                              context
                                  .read<WeaponBloc>()
                                  .add(SafeSwitchOneFlippedEvent(newVal));
                            },
                            value: state is SafeSwitchOneFlippedState
                                ? state.switchValue
                                : false),
                      ),
                    );
                  },
                ),
                const Padding(padding: EdgeInsets.all(10)),
                Text(
                  ConstString.safe1String,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color, //customize color here
                  ),
                ),
                const Padding(padding: EdgeInsets.all(10)),
              ],
            ),
            const Padding(padding: EdgeInsets.all(5)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BlocBuilder<WeaponBloc, WeaponState>(
                  buildWhen: (previous, current) =>
                      current is SafeSwitchTwoFlippedState,
                  builder: (context, state) {
                    return SizedBox(
                      width: 100,
                      child: FittedBox(
                        child: Switch(
                            trackColor: state is SafeSwitchTwoFlippedState &&
                                    state.safeSwitchValue
                                ? WidgetStatePropertyAll<Color>(
                                    Theme.of(context).iconTheme.color!)
                                : const WidgetStatePropertyAll<Color>(
                                    Colors.grey),
                            thumbColor: WidgetStatePropertyAll<Color>(
                              state is SafeSwitchTwoFlippedState
                                  ? state.isSwitchAllowed
                                      ? Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color!
                                      : Colors.grey
                                  : Colors.grey,
                            ),
                            onChanged: state is SafeSwitchTwoFlippedState
                                ? state.isSwitchAllowed
                                    ? (newVal) {
                                        context.read<WeaponBloc>().add(
                                            SafeSwitchTwoFlippedEvent(newVal));
                                      }
                                    : null
                                : null,
                            value: state is SafeSwitchTwoFlippedState
                                ? state.safeSwitchValue
                                : false),
                      ),
                    );
                  },
                ),
                const Padding(padding: EdgeInsets.all(10)),
                Text(
                  ConstString.safe2String,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color, //customize color here
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
