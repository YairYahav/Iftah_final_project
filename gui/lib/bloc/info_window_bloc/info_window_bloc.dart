// ignore_for_file: invalid_use_of_visible_for_testing_member

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
part 'info_window_event.dart';
part 'info_window_state.dart';

class InfoWindowBloc extends Bloc<InfoWindowEvent, InfoWindowState> {
  final EventBus _eventBus;
  late StreamSubscription _errorStmEventStreamSub;
  late StreamSubscription _errorAtmelEventStreamSub;
  late StreamSubscription _errorEventStreamSub;
  Timer? _queueTimer;
  final Queue<InformationData> _widgetToShow = Queue();
  InfoWindowBloc()
      : _eventBus = GetIt.I.get(),
        super(InfoWindowInitial()) {
    _startEventBusListening();
  }

  void _startEventBusListening() {
    _errorStmEventStreamSub =
        _eventBus.on<StmErrorMessageEvent>().listen((event) {
      var message = event.decodedMessage as StmErrorMessage;
      for (int i = 0; i < InfoMessageData.values.length; i++) {
        if (InfoMessageData.values[i].errorNum == message.errorNum) {
          if (_widgetToShow.length > 10) {
            _widgetToShow.removeLast();
          }
          if (message.errorNum == InfoMessageData.octaviusBootError.errorNum) {
            try {
              var bootTimer =
                  Consts.octaviusBootingTime - (message.bootTimer / 1000);
              var bootTimerInt = bootTimer.toInt();

              _widgetToShow.addFirst(InformationData(
                  "${InfoMessageData.values[i].messageString} ${bootTimerInt.toString()}",
                  InfoMessageData.values[i].infoType));
            } catch (e) {
              log(e.toString());
            }
          } else {
            _widgetToShow.addFirst(InformationData(
                InfoMessageData.values[i].messageString,
                InfoMessageData.values[i].infoType));
          }
        }
      }
      _resetQueue();

      emit(RebuildListState(_widgetToShow.toList()));
    });

    _errorAtmelEventStreamSub =
        _eventBus.on<AtmelErrorMessageEvent>().listen((event) {
      var message = event.decodedMessage as AtmelErrorMessage;
      for (int i = 0; i < InfoMessageData.values.length; i++) {
        if (InfoMessageData.values[i].errorNum == message.errorNum) {
          if (_widgetToShow.length > 10) {
            _widgetToShow.removeLast();
          }
          _widgetToShow.addFirst(InformationData(
              InfoMessageData.values[i].messageString,
              InfoMessageData.values[i].infoType));
        }
      }
      _resetQueue();

      emit(RebuildListState(_widgetToShow.toList()));
    });

    _errorEventStreamSub = _eventBus.on<ErrorMessageEvent>().listen((event) {
      _widgetToShow.addFirst(InformationData(
          event.infoMessageData.messageString, event.infoMessageData.infoType));
      _resetQueue();

      emit(RebuildListState(_widgetToShow.toList()));
    });
  }

  void _resetQueue() {
    if (_queueTimer != null) {
      _queueTimer!.cancel();
      if (!_queueTimer!.isActive) {
        _queueTimer = Timer(
            const Duration(seconds: Consts.secondsResetQueueDuration), () {
          _widgetToShow.clear();

          emit(RebuildListState(_widgetToShow.toList()));
        });
      }
    } else {
      _queueTimer =
          Timer(const Duration(seconds: Consts.secondsResetQueueDuration), () {
        _widgetToShow.clear();

        emit(RebuildListState(_widgetToShow.toList()));
      });
    }
  }

  @override
  Future<void> close() {
    _errorStmEventStreamSub.cancel();
    _errorAtmelEventStreamSub.cancel();
    _errorEventStreamSub.cancel();
    return super.close();
  }
}
