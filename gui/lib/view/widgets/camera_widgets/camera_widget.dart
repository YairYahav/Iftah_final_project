import 'package:example_project/bloc/camera_bloc/camera_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';

class CameraWidget extends StatelessWidget {
  const CameraWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        return SizedBox(
           height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width * (3.8 / 5),
            child: Video(controller: state.videoController));
      },
    );
  }
}
