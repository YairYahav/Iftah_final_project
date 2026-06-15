import 'dart:developer';

import 'package:example_project/bloc/weapon_bloc/weapon_bloc.dart';
import 'package:example_project/global/consts/const_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MockFireButtonWidget extends StatelessWidget {
  const MockFireButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeaponBloc, WeaponState>(
      buildWhen: (previous, current) => current is WeaponModeChangedState,
      builder: (context, state) {
        return SizedBox(
          width: 300,
          height: 100,
          child: ElevatedButton(
              onPressed: state is WeaponModeChangedState &&
                      state.isArmSafeEnable &&
                      !state.isWeaponCooldownOn
                  ? () {
                      log("BANG!!!!");
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).iconTheme.color),
              child: Text(
                textAlign: TextAlign.center,
                ConstString.fireString,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              )),
        );
      },
    );
  }
}
