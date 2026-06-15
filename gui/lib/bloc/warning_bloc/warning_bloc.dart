// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';

import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'package:event_bus/event_bus.dart';
import 'package:bloc/bloc.dart';
import 'package:example_project/domain/model/data_classes/information_data.dart';
import 'package:example_project/global/consts/consts.dart';
import 'package:example_project/global/consts/enums.dart';
import 'package:example_project/infrastructure/events/events.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:octavius_message_api/octavius_message_api.dart';

part 'warning_event.dart';
part 'warning_state.dart';

class WarningBloc extends Bloc<WarningEvent, WarningState> {
  final EventBus _eventBus;
  late StreamSubscription _lostCommandConnectionSubscription;
  late StreamSubscription _systemStatusReplySubscription;
  WarningBloc()
      : _eventBus = GetIt.I.get(),
        super(const WarningInitial()) {
    _startEventBusListening();
  }

  void _startEventBusListening() {
    _systemStatusReplySubscription =
        _eventBus.on<SystemStatusReplyReceivedEvent>().listen((event) {
      emit(const WarningStateChanged(ConnectionStatus.good));
    });

    _lostCommandConnectionSubscription =
        _eventBus.on<LostCommandConnectionEvent>().listen((event) {
      emit(const WarningStateChanged(ConnectionStatus.error));
    });
  }

  @override
  Future<void> close() {
    _lostCommandConnectionSubscription.cancel();
    _systemStatusReplySubscription.cancel();
    return super.close();
  }
}
