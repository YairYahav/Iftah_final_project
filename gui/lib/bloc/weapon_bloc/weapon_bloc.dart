// ignore_for_file: invalid_use_of_visible_for_testing_member, depend_on_referenced_packages

import 'dart:async';
import 'package:event_bus/event_bus.dart';
import 'package:example_project/infrastructure/events/events.dart';
import 'package:get_it/get_it.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:octavius_message_api/octavius_message_api.dart';
import '../../infrastructure/interface/imessage_params_parser.dart';

part 'weapon_event.dart';
part 'weapon_state.dart';

class WeaponBloc extends Bloc<WeaponEvent, WeaponState> {
  final List<StreamSubscription> _eventBusSubscriptionList = [];
  final EventBus _eventBus;
  bool _isSwitchOneOn = false;
  bool _isSwitchTwoOn = false;
  bool _isArmSafeEnable = false;
  final bool _isWeaponCoolDownOn = false;
  bool _isArmSafeCheckComplete = false;
  bool _isSafe1Blinked = false;
  bool _isSafe2Blinked = false;
  bool _isStatusCheckedStage1 = false;
  bool _isStatusCheckedStage2 = false;
  bool _isWeaponLoadedBySend = false;
  bool _isStatusRed = false;
  WeaponMode currentWeaponMode = WeaponMode.safe;
  final IMessagesParamsParser _messagesParamsParser;

  WeaponBloc()
      : _eventBus = GetIt.I.get(),
        _messagesParamsParser = GetIt.I.get<IMessagesParamsParser>(),
        super(const WeaponInitial(false, false)) {
    _startEventListening();
    _startEventBusListening();
  }

  @override
  Future<void> close() {
    for (var element in _eventBusSubscriptionList) {
      element.cancel();
    }
    return super.close();
  }

  void _startEventListening() {
    on<SafeSwitchOneFlippedEvent>((event, emit) {
      _onSwitchOneFlipped(event);
    });
    on<SafeSwitchTwoFlippedEvent>((event, emit) {
      _onSwitchTwoFlipped(event);
    });
  }

  void _startEventBusListening() {
    _eventBusSubscriptionList
        .add(_eventBus.on<LostCommandConnectionEvent>().listen((event) {
      _onLostCommandConnection();
    }));

    _eventBusSubscriptionList
        .add(_eventBus.on<SystemStatusReplyReceivedEvent>().listen((event) {
      _onSystemStatusReplyReceivedEvent(event);
    }));

    _eventBusSubscriptionList
        .add(_eventBus.on<UpdateBlinkingStatus>().listen((event) {
      _isSafe1Blinked = event.isStmBlinking;
      _isSafe2Blinked = event.isAtmelBlinking;
      _armSafeCheck();
    }));

    _eventBusSubscriptionList
        .add(_eventBus.on<StartStatusCheckEvent>().listen((event) {
      if (_isStatusCheckedStage1 && _isSwitchOneOn) {
        _statusCheckForSafe2();
      } else {
        _statusCheckForSafe1();
      }
    }));

    _eventBusSubscriptionList
        .add(_eventBus.on<AtmelSafeSwitchReportEvent>().listen((event) {
      var message = event.decodedMessage as AtmelSafeSwitch2ReportMessage;
      _isSwitchTwoOn = message.status == MessageBoolean.defOn.value;
      if (!_isSwitchTwoOn && !_isSwitchOneOn) {
        _isArmSafeCheckComplete = false;
        _eventBus.fire(const ResetBlinkingEvent());
      }
      _armSafeCheck();
      emit(SafeSwitchTwoFlippedState(_isSwitchTwoOn, _isStatusCheckedStage1));
    }));

    _eventBusSubscriptionList
        .add(_eventBus.on<StatusRedCheckedEvent>().listen((event) {
      _isStatusRed = event.isStatusRed;
      _statusCheckForSafe2();
    }));

    _eventBusSubscriptionList
        .add(_eventBus.on<StmSafeSwitchReportEvent>().listen((event) {
      var message = event.decodedMessage as StmSafeSwitch1ReportMessage;
      _isSwitchOneOn = message.status == MessageBoolean.defOn.value;

      if (!_isSwitchTwoOn && !_isSwitchOneOn) {
        _isArmSafeCheckComplete = false;
        _eventBus.fire(const ResetBlinkingEvent());
      }

      _statusCheckForSafe1();
      _armSafeCheck();
      emit(SafeSwitchOneFlippedState(_isSwitchOneOn));
    }));
  }

  ///Function that is called when the user has pressed the safe 2 switch
  void _onSwitchTwoFlipped(SafeSwitchTwoFlippedEvent event) {
    if (!_isSwitchTwoOn) {
      _turn2SwitchOn();
    } else {
      _turnOffSwitches();
    }
  }

  ///Function that is called when the user has pressed the safe 1 switch
  void _onSwitchOneFlipped(SafeSwitchOneFlippedEvent event) {
    if (!_isSwitchOneOn) {
      _turn1SwitchOn();
    } else {
      _turnOffSwitches();
    }
  }

  ///Function that is called when the user has pressed the safe 2 switch, to turn it on
  void _turn2SwitchOn() {
    _eventBus.fire(DryMessageSetToSendEvent([
      AtmelSafeSwitch2OnMessage.encode(
          switchAddress: OctaviusConstants.atmelSwitch2SwitchAddress,
          status: MessageBoolean.defOn.value),
      StmSafeSwitch2OnMessage.encode(status: MessageBoolean.defOn.value)
    ]));
  }

  ///Function that is called when the user has pressed either switch 1 or 2 to turn them off
  void _turnOffSwitches() {
    _eventBus.fire(const ResetBlinkingEvent());
    _isSafe1Blinked = false;
    _eventBus.fire(DryMessageSetToSendEvent([
      StmSafeSwitchOffMessage.encode(status: MessageBoolean.defOff.value),
      AtmelSafeSwitchOffMessage.encode(status: MessageBoolean.defOff.value),
    ]));
    _armSafeCheck();
  }

  ///Function that is called when the user has pressed the safe 1 switch, to turn it on
  void _turn1SwitchOn() {
    _eventBus.fire(DryMessageSetToSendEvent([
      StmSafeSwitch1OnMessage.encode(
          switchAddress: OctaviusConstants.stmSwitch1SwitchAddress,
          status: MessageBoolean.defOff.value),
      AtmelSafeSwitch1OnMessage.encode(status: MessageBoolean.defOn.value),
    ]));
  }

  void _onSystemStatusReplyReceivedEvent(SystemStatusReplyReceivedEvent event) {
    StmSystemStatusReplyMessage message =
        event.decodedMessage as StmSystemStatusReplyMessage;
    _weaponModeCheck(message);
    _armSafeCheck();
  }

  void _changeArmSafeWidgetsStates() {
    emit(WeaponModeChangedState(
      currentWeaponMode,
      _isArmSafeEnable,
      _isWeaponCoolDownOn,
    ));
  }

  void _onLostCommandConnection() {
    _isWeaponLoadedBySend = false;
    _isArmSafeEnable = false;
    _isStatusRed = false;
  }

  void _checkStatus() {
    if (!_isSwitchTwoOn || !_isSwitchOneOn) {
      _isStatusRed = false;
    }
    emit(WeaponArmSafeState(
      _isArmSafeEnable,
      _isWeaponCoolDownOn,
    ));
  }

  void _statusCheckForSafe1() {
    if ((_isSwitchOneOn && _isSafe1Blinked) || _isArmSafeCheckComplete) {
      _isStatusCheckedStage1 = true;
    } else {
      _isStatusCheckedStage1 = false;
    }
    emit(SafeSwitchTwoFlippedState(_isSwitchTwoOn, _isStatusCheckedStage1));
  }

  void _statusCheckForSafe2() {
    if (_isSwitchOneOn &&
        _isSwitchTwoOn &&
        _isStatusCheckedStage1 &&
        _isStatusRed) {
      _isStatusCheckedStage2 = true;
    }
    _armSafeCheck();
  }

  void _weaponModeCheck(StmSystemStatusReplyMessage message) {
    if (message.weaponMode == WeaponMode.safe.value) {
      currentWeaponMode = WeaponMode.safe;
    }
    if (message.weaponMode == WeaponMode.loadedSafe.value) {
      currentWeaponMode = WeaponMode.safe;
    }
    if (message.weaponMode == WeaponMode.arm.value) {
      currentWeaponMode = WeaponMode.arm;
    }

    _armSafeCheck();
  }

  void _armSafeCheck() {
    _checkStatus();
    if (_isSwitchOneOn &&
        _isSwitchTwoOn &&
        _isStatusRed &&
        !_isWeaponCoolDownOn) {
      _isArmSafeEnable = true;
      _eventBus.fire(ArmEnabledEvent(_isArmSafeEnable));
      emit(WeaponArmSafeState(_isArmSafeEnable, _isWeaponCoolDownOn));
      _changeArmSafeWidgetsStates();
    } else {
      _isArmSafeEnable = false;
      _eventBus.fire(ArmEnabledEvent(_isArmSafeEnable));
      emit(WeaponArmSafeState(_isArmSafeEnable, _isWeaponCoolDownOn));
    }
  }
}
