part of 'warning_bloc.dart';

@immutable
abstract class WarningState extends Equatable {
  const WarningState();
}

class WarningInitial extends WarningState {
  const WarningInitial();

  @override
  List<Object?> get props => [];
}

class WarningStateChanged extends WarningState {
  final ConnectionStatus connectionStatus;
  const WarningStateChanged(this.connectionStatus);

  @override
  List<Object> get props => [connectionStatus];
}