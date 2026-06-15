part of 'camera_cotrol_bloc.dart';

abstract class CameraControlEvent {
  const CameraControlEvent();
}

class RecordingSwitchOn extends CameraControlEvent {
  const RecordingSwitchOn();
}

class RecordingSwitchOff extends CameraControlEvent {
  const RecordingSwitchOff();
}
