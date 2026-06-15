part of 'camera_bloc.dart';

@immutable
sealed class CameraState extends Equatable {
  final VideoController videoController;
  const CameraState(this.videoController);

  @override
  List<Object> get props => [videoController];
}

class CameraInitial extends CameraState {
  const CameraInitial(super.videoController);

  @override
  List<Object> get props => [super.videoController];
}
