// ignore_for_file: invalid_use_of_visible_for_testing_member, depend_on_referenced_packages

import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:event_bus/event_bus.dart';
import 'package:get_it/get_it.dart';
import 'package:example_project/domain/model/data_classes/information_data.dart';
import 'package:example_project/global/consts/consts.dart';
import 'package:octavius_message_api/octavius_message_api.dart';
import 'package:example_project/infrastructure/events/events.dart';

import '../../../global/consts/enums.dart';

part 'telemetry_event.dart';
part 'telemetry_state.dart';

class TelemetryBloc extends Bloc<TelemetryEvent, TelemetryState> {
  final EventBus _eventBus;
  late StreamSubscription _rssiSubScription;
  late StreamSubscription _systemStatusReplySubscription;
  late StreamSubscription _lostCommandConnectionSubscription;
  late StreamSubscription _currentTrackingModeSubscription;
  final int _angleYaw = 0;
  final int _anglePitch = 0;
  double _voltage = 0;
  int _range = 0;
  final TrackingStatus _trackingMode = TrackingStatus.off;

  TelemetryBloc()
      : _eventBus = GetIt.I.get(),
        super(const TelemetryInitial()) {
    _startEventListening();

    _startEventBusListening();
  }

  void _startEventListening() {
    on<TelemetryEvent>((event, emit) {});

    on<TelemetryUpdatedEvent>((event, emit) {
      emit(const TelemetryInitial());
    });
  }

  void _startEventBusListening() {
    _systemStatusReplySubscription =
        _eventBus.on<SystemStatusReplyReceivedEvent>().listen((event) {
      var message = event.decodedMessage as StmSystemStatusReplyMessage;
      _voltage = message.mainVoltage / 1;

      emit(TelemetryReceivedState(
          _angleYaw, _anglePitch, _voltage, _range, _trackingMode));
    });

    _lostCommandConnectionSubscription =
        _eventBus.on<LostCommandConnectionEvent>().listen((event) {
      _voltage = 0;
      _range = 0;

      emit(TelemetryReceivedState(
          _angleYaw, _anglePitch, _voltage, _range, _trackingMode));
    });
  }

  @override
  Future<void> close() {
    _currentTrackingModeSubscription.cancel();
    _lostCommandConnectionSubscription.cancel();
    _systemStatusReplySubscription.cancel();
    _rssiSubScription.cancel();
    return super.close();
  }
}
