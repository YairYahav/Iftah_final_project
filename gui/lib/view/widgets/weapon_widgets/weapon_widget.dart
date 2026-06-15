import 'package:example_project/bloc/weapon_bloc/weapon_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:example_project/global/consts/const_strings.dart';
import 'package:example_project/view/widgets/weapon_widgets/mock_fire_botton_widget.dart';
import 'package:example_project/view/widgets/weapon_widgets/safe_status_widget.dart';
import 'package:flutter/material.dart';

import 'safe_switches_widget.dart';

class WeaponWidget extends StatelessWidget {
  const WeaponWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (context) => WeaponBloc(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            ConstString.version,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge!.color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const Padding(padding: EdgeInsets.all(5.0)),
          const SafeSwitchesWidget(),
          const Padding(padding: EdgeInsets.all(10.0)),
          const SafeStatusWidget(),
          const Padding(padding: EdgeInsets.all(10.0)),
          const MockFireButtonWidget(),
        ],
      ),
    );
  }
}
