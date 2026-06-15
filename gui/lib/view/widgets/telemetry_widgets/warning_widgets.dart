// ignore_for_file: depend_on_referenced_packages

import 'package:example_project/bloc/telemetry_bloc/telemetry_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../global/consts/const_strings.dart';
import 'package:neon_widgets/neon_widgets.dart';

class ConnectionErrorWarningWidget extends StatelessWidget {
  const ConnectionErrorWarningWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
            width: MediaQuery.of(context).size.width / 5,
            height: MediaQuery.of(context).size.height / 15,
            child: NeonContainer(
              spreadColor: Colors.orangeAccent,
              borderColor: Colors.orangeAccent,
              containerColor: Colors.orangeAccent,
              borderRadius: BorderRadius.circular(15),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    NeonText(
                      textAlign: TextAlign.center,
                      text: ConstString.warningNoConnection,
                      textColor: Colors.black,
                      fontWeight: FontWeight.bold,
                      spreadColor: Color.fromARGB(255, 139, 139, 139),
                      blurRadius: 20,
                      textSize: 20,
                    ),
                    Padding(padding: EdgeInsets.all(5)),
                    Icon(
                      Icons.warning,
                      color: Colors.black,
                      size: 40,
                    ),
                  ],
                ),
              ),
            ))
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .fadeIn()
        .then(duration: 3.seconds);
  }
}
