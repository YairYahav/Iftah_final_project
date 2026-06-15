part of 'status_led_bloc.dart';

@immutable
abstract class StatusLedBlocEvent {
  const StatusLedBlocEvent();
}

class SendStatusRequest extends StatusLedBlocEvent {
  const SendStatusRequest();
}

class TurnOffLedsEvent extends StatusLedBlocEvent {
  const TurnOffLedsEvent();
}
