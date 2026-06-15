part of 'camera_cotrol_bloc.dart';

abstract class CameraControlState extends Equatable {
  const CameraControlState();

  @override
  List<Object> get props => [];
}

class CameraControlInitial extends CameraControlState {}

class RecordingSwitchOnOffState extends CameraControlState {
  final bool isRecording;
  const RecordingSwitchOnOffState(this.isRecording);

  @override
  List<Object> get props => [isRecording];
}

class VideoFormatUpdatedState extends CameraControlState {
  final bool isGstreamer;
  const VideoFormatUpdatedState(this.isGstreamer);

  @override
  List<Object> get props => [isGstreamer];
}
