// ignore_for_file: must_be_immutable, overridden_fields

part of 'telemetry_bloc.dart';

abstract class TelemetryState extends Equatable {
  const TelemetryState();
}

class TelemetryInitial extends TelemetryState {
  const TelemetryInitial();

  @override
  List<Object?> get props => [];
}

class TelemetryReceivedState extends TelemetryState {
  final int angleYaw;
  final int anglePitch;
  final double voltage;
  final int range;
  final TrackingStatus trackingMode;
  const TelemetryReceivedState(this.angleYaw, this.anglePitch, this.voltage,
      this.range, this.trackingMode);

  @override
  List<Object> get props =>
      [angleYaw, anglePitch, voltage, range,  trackingMode];
}

