part of 'status_led_bloc.dart';

@immutable
abstract class StatusLedBlocState extends Equatable {}

class StatusLedBlocInitial extends StatusLedBlocState {
  @override
  List<Object?> get props => [];
}

class TurnLedsColorState extends StatusLedBlocState {
  final Color stmColor;
  final Color atmelColor;
  TurnLedsColorState(
    this.stmColor,
    this.atmelColor,
  );
  @override
  List<Object> get props => [
        stmColor,
        atmelColor,
      ];
}
