part of 'telemetry_bloc.dart';

abstract class TelemetryEvent {
  const TelemetryEvent();
}

class TelemetryUpdatedEvent extends TelemetryEvent {
  const TelemetryUpdatedEvent();
}
