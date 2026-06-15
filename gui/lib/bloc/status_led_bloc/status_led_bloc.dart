// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:bloc/bloc.dart';
import 'package:example_project/global/consts/enums.dart';
import 'package:equatable/equatable.dart';
import 'package:octavius_message_api/octavius_message_api.dart';
import 'package:example_project/global/consts/consts.dart';
import 'package:example_project/infrastructure/events/events.dart';

part 'status_led_bloc_event.dart';
part 'status_led_bloc_state.dart';

class StatusLedBloc extends Bloc<StatusLedBlocEvent, StatusLedBlocState> {
  final EventBus _eventBus;
  bool _isSafe1Blinked = false;
  bool _isSafe2Blinked = false;
  bool _isSafe1Armed = false;
  bool _isSafe2Armed = false;
  bool _isStatusRed = false;
  bool _continueToBlink = false;
  Timer? _ledTimer;
  Color _stmLedColor = Colors.grey;
  Color _atmelLedColor = Colors.grey;
  late StreamSubscription _atmelSafetyStatusSubscription;
  late StreamSubscription _resetBlinkingEventSubscription;
  late StreamSubscription _stmSafetyStatusSubscription;
  late StreamSubscription _isStmBlinkingSubscription;

  StatusLedBloc()
      : _eventBus = GetIt.I.get(),
        super(StatusLedBlocInitial()) {
    _startEventListening();
  }

  void _startEventListening() {
    on<StatusLedBlocEvent>((event, emit) {});
    on<SendStatusRequest>((event, emit) {
      _onSendStatusRequest();
    });
    on<TurnOffLedsEvent>((event, emit) {
      _onTurnOffLedsEvent(emit);
    });

    _stmSafetyStatusSubscription =
        _eventBus.on<StmSafetyStatusReplyEvent>().listen((event) {
      _onStmSafetyStatusReplyEvent(event);
    });

    _atmelSafetyStatusSubscription =
        _eventBus.on<AtmelSafetyStatusReplyEvent>().listen((event) {
      _onAtmelSafetyStatusReplyEvent(event);
    });

    _resetBlinkingEventSubscription =
        _eventBus.on<ResetBlinkingEvent>().listen((event) {
      _isSafe1Blinked = false;
      _isSafe2Blinked = false;
    });
  }

  ///On AtmelSafetyStatusReplyMessage, function calls onSafetyStatusReply
  void _onAtmelSafetyStatusReplyEvent(AtmelSafetyStatusReplyEvent event) {
    AtmelSafetyStatusReplyMessage message =
        event.decodedMessage as AtmelSafetyStatusReplyMessage;
    _onSafetyStatusReply(message.safeVoltage, message.middleVoltage, false);
  }

  ///On StmSafetyStatusReplyMessage, function calls onSafetyStatusReply
  void _onStmSafetyStatusReplyEvent(StmSafetyStatusReplyEvent event) {
    StmSafetyStatusReplyMessage message =
        event.decodedMessage as StmSafetyStatusReplyMessage;
    _onSafetyStatusReply(message.safeVoltage, message.middleVoltage, true);
  }

  ///Function that is called when the user presses check status command
  void _onSendStatusRequest() {
    _ledTimer?.cancel();
    _continueToBlink = false;
    _eventBus.fire(DryMessageSetToSendEvent([
      StmSafetyStatusRequestMessage.encode(),
      AtmelSafetyStatusRequestMessage.encode()
    ]));
  }

  ///Function that is called when the user to turn the status leds grey
  void _onTurnOffLedsEvent(Emitter<StatusLedBlocState> emit) {
    _stmLedColor = Colors.grey;
    _atmelLedColor = Colors.grey;
    emit(TurnLedsColorState(
      _stmLedColor,
      _atmelLedColor,
    ));
  }

  ///Function that decideds what color to paint the atmel led
  void _ledAtmelColorCheck(int middleVoltage, int safeVoltage, bool isStm) {
    if (middleVoltage < Consts.atmelVoltageRed &&
        safeVoltage < Consts.atmelVoltageRed) {
      _isSafe2Blinked = false;
      _isSafe2Armed = false;
      _continueToBlink = false;
      _isStatusRed = false;
      _eventBus.fire(StatusRedCheckedEvent(_isStatusRed));

      _atmelLedColor = Colors.green;
    } else {
      if (middleVoltage >= Consts.atmelVoltageRed &&
          safeVoltage < Consts.atmelVoltageRed) {
        _isSafe2Blinked = true;
        _isSafe2Armed = false;
        _isStatusRed = false;
        _eventBus.fire(StatusRedCheckedEvent(_isStatusRed));

        _ledBlink(isStm);
      } else {
        if (middleVoltage >= Consts.atmelVoltageRed &&
            safeVoltage >= Consts.atmelVoltageRed) {
          _atmelLedColor = Colors.red;
          _isSafe2Blinked = false;
          _isSafe2Armed = true;
          _continueToBlink = false;
          if (_isSafe1Armed && _isSafe2Armed) {
            _isStatusRed = true;
          } else {
            _isStatusRed = false;
          }
          _eventBus.fire(StatusRedCheckedEvent(_isStatusRed));
        }
        if (safeVoltage >= Consts.atmelVoltageRed &&
            middleVoltage < Consts.atmelVoltageRed) {
          _eventBus
              .fire(ErrorMessageEvent(InfoMessageData.errorVoltageReading));
        }
      }
    }
    _eventBus.fire(UpdateBlinkingStatus(_isSafe1Blinked, _isSafe2Blinked));
  }

  ///Function that decideds what color to paint the stm led
  void _ledStmColorCheck(int middleVoltage, int safeVoltage, bool isStm) {
    if (middleVoltage < Consts.stmVoltageRed &&
        safeVoltage < Consts.stmVoltageRed) {
      _isSafe1Blinked = false;
      _isSafe1Armed = false;
      _continueToBlink = false;
      _isStatusRed = false;
      _eventBus.fire(StatusRedCheckedEvent(_isStatusRed));
      _eventBus.fire(ArmEnabledEvent(false));
      _stmLedColor = Colors.green;
    } else {
      if (middleVoltage >= Consts.stmVoltageRed &&
          safeVoltage < Consts.stmVoltageRed) {
        _isSafe1Blinked = true;
        _isSafe1Armed = false;
        _isStatusRed = false;
        _eventBus.fire(StatusRedCheckedEvent(_isStatusRed));
        _eventBus.fire(ArmEnabledEvent(false));
        _ledBlink(isStm);
      } else {
        if (middleVoltage >= Consts.stmVoltageRed &&
            safeVoltage >= Consts.stmVoltageRed) {
          _stmLedColor = Colors.red;
          _isSafe1Blinked = false;
          _isSafe1Armed = true;
          _continueToBlink = false;
          if (_isSafe1Armed && _isSafe2Armed) {
            _isStatusRed = true;
          } else {
            _isStatusRed = false;
          }
          _eventBus.fire(StatusRedCheckedEvent(_isStatusRed));
          _eventBus.fire(ArmEnabledEvent(true));
        }
        if (safeVoltage >= Consts.stmVoltageRed &&
            middleVoltage < Consts.stmVoltageRed) {
          _eventBus
              .fire(ErrorMessageEvent(InfoMessageData.errorVoltageReading));
          _eventBus.fire(ArmEnabledEvent(false));
        }
      }
    }
    _eventBus.fire(UpdateBlinkingStatus(_isSafe1Blinked, _isSafe2Blinked));
  }

  ///Function that is called when a safe status reply happens to decide which color to paint it
  void _onSafetyStatusReply(int safeVoltage, int middleVoltage, bool isStm) {
    if (isStm) {
      _ledStmColorCheck(middleVoltage, safeVoltage, isStm);
    } else {
      _ledAtmelColorCheck(middleVoltage, safeVoltage, isStm);
    }
    _eventBus.fire(const StartStatusCheckEvent());

    _ledReset();
    emit(TurnLedsColorState(
      _stmLedColor,
      _atmelLedColor,
    ));
  }

  ///Function that is called to make the blinking effect when the mid voltage is high and safe voltage is low
  void _ledBlink(bool isStm) {
    if (isStm) {
      int index = 0;
      _continueToBlink = true;
      Timer.periodic(
          const Duration(milliseconds: Consts.milliSecondsLedBlinkDuration),
          (timer) {
        if (_continueToBlink) {
          if (_isSafe1Blinked) {
            if (index < Consts.redBlinkTimes * 2) {
              if (index.isEven) {
                _stmLedColor = Colors.red;
              } else {
                _stmLedColor = Colors.grey;
              }
              emit(TurnLedsColorState(
                _stmLedColor,
                _atmelLedColor,
              ));
              index++;
            } else {
              timer.cancel();
              _stmLedColor = Colors.grey;
              emit(TurnLedsColorState(
                _stmLedColor,
                _atmelLedColor,
              ));
            }
          } else {
            timer.cancel();
            _stmLedColor = Colors.grey;
            emit(TurnLedsColorState(
              _stmLedColor,
              _atmelLedColor,
            ));
          }
        }
      });
    } else {
      int index = 0;
      _continueToBlink = true;
      Timer.periodic(
          const Duration(milliseconds: Consts.milliSecondsLedBlinkDuration),
          (timer) {
        if (_continueToBlink) {
          if (_isSafe2Blinked) {
            if (index < Consts.redBlinkTimes * 2) {
              if (index.isEven) {
                _atmelLedColor = Colors.red;
              } else {
                _atmelLedColor = Colors.grey;
              }
              emit(TurnLedsColorState(
                _stmLedColor,
                _atmelLedColor,
              ));
              index++;
            } else {
              timer.cancel();
              _atmelLedColor = Colors.grey;
              emit(TurnLedsColorState(
                _stmLedColor,
                _atmelLedColor,
              ));
            }
          } else {
            timer.cancel();
            _atmelLedColor = Colors.grey;
            emit(TurnLedsColorState(
              _stmLedColor,
              _atmelLedColor,
            ));
          }
        }
      });
    }
  }

  ///Function that is called to reset the led color paint after the status check
  void _ledReset() {
    if (_ledTimer != null) {
      _ledTimer!.cancel();
      if (!_ledTimer!.isActive) {
        _ledTimer =
            Timer(const Duration(seconds: Consts.secondsLedDuration), () {
          _stmLedColor = Colors.grey;
          _atmelLedColor = Colors.grey;
          emit(TurnLedsColorState(
            _stmLedColor,
            _atmelLedColor,
          ));
        });
      }
    } else {
      if (_atmelLedColor != Colors.grey || _stmLedColor != Colors.grey) {
        _ledTimer =
            Timer(const Duration(seconds: Consts.secondsLedDuration), () {
          _stmLedColor = Colors.grey;
          _atmelLedColor = Colors.grey;
          emit(TurnLedsColorState(
            _stmLedColor,
            _atmelLedColor,
          ));
        });
      }
    }
  }

  @override
  Future<void> close() {
    _atmelSafetyStatusSubscription.cancel();
    _resetBlinkingEventSubscription.cancel();
    _stmSafetyStatusSubscription.cancel();
    _isStmBlinkingSubscription.cancel();
    return super.close();
  }
}
