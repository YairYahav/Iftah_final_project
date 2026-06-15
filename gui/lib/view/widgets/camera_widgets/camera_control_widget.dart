import 'package:example_project/bloc/camera_bloc/camera_bloc.dart';
import 'package:example_project/view/widgets/camera_widgets/camera_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_module/view/widgets/video_widget.dart';

import '../../../bloc/camera_control_bloc/camera_cotrol_bloc.dart';

class CameraControlWidget extends StatelessWidget {
  const CameraControlWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraControlBloc, CameraControlState>(
      buildWhen: (previous, current) => current is VideoFormatUpdatedState,
      builder: (context, state) {
        return state is VideoFormatUpdatedState && state.isGstreamer
            ? LayoutBuilder(
                builder: (buildContext, boxConstraints) {
                  return VideoWidget(
                      boxConstraints.maxHeight, boxConstraints.maxWidth, 0);
                },
              )
            : BlocProvider(
                lazy: false,
                create: (context) => CameraBloc(0)..add(InitVideoEvent()),
                child: const CameraWidget(),
              );
      },
    );
  }
}
