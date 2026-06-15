// ignore_for_file: depend_on_referenced_packages
import 'package:synchronized/synchronized.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:core';
import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../../global/consts/consts.dart';
import '../../infrastructure/events/events.dart';
import 'package:event_bus/event_bus.dart';
import '../../infrastructure/interface/icommunication_repository.dart';
import '../../infrastructure/interface/iconnection.dart';
import 'package:octavius_message_api/octavius_message_api.dart';

/// This repository is responsible for communication between the back and front station.
/// It is responsible for the sending and receiving of messages,
/// as well as decoding messages and sending the periodic message.
class CommunicationRepository implements ICommunicationRepository {
  final IConnection _connection;
  final EventBus _eventBus;
  final StmUserControlMessage _localUserControlMessage =
      StmUserControlMessage.encode(
          address: Addresses.pcToStm,
          xSpeedDir: 0,
          ySpeedDir: 0,
          position: 0,
          ledEnable: 0);
  final IMessageBuilder _messageBuilder;
  final Queue<IMessage> _messageSendQueue = Queue();
  final Lock _sendingLock = Lock();

  CommunicationRepository()
      : _connection = GetIt.I.get(),
        _eventBus = GetIt.I.get(),
        _messageBuilder = GetIt.I.get();
  @override
  Future<void> startConnection() async {
    _startConnection();
    _startEventBusListener();
    _startSendingFromQueue();
  }

  void _startConnection() async {
    _connection.connect();
    _startListenConnection();
  }

  Future<void> _sendMessage(Uint8List data) async {
    _connection.sendMessage(data);
  }

  Future<void> _startSendingFromQueue() async {
    Timer.periodic(const Duration(milliseconds: Consts.queueSendingInterval),
        (_) async {
      if (!_connection.isConnected()) {
        _eventBus.fire(const LostCommandConnectionEvent());
      }
      if (_messageSendQueue.isNotEmpty) {
        List<int> msgBuffer = [];
        _sendingLock.synchronized(() {
          msgBuffer.addAll(_localUserControlMessage.buffer.asUint8List());
          while (_messageSendQueue.isNotEmpty) {
            msgBuffer
                .addAll(_messageSendQueue.removeFirst().buffer.asUint8List());
          }
        });
        _sendMessage(Uint8List.fromList(msgBuffer));
      } else {
        _sendMessage(_localUserControlMessage.buffer.asUint8List());
      }
    });
  }

  Future<void> _startEventBusListener() async {
    _eventBus.on<DryMessageToSendEvent>().listen((event) {
      _sendingLock
          .synchronized(() => _messageSendQueue.add(event.messageBuffer));
    });

    _eventBus.on<DryMessageSetToSendEvent>().listen((event) {
      for (var msg in event.messages) {
        _sendingLock.synchronized(() => _messageSendQueue.add(msg));
      }
    });
    _eventBus.on<ForceFireToSendEvent>().listen((event) {
      _sendMessage(event.message.buffer.asUint8List());
    });
  }

  Future<void> _startListenConnection() async {
    try {
      _connection.dataReceivedStream?.listen((dataReceived) {
        IMessage message =
            _messageBuilder.buildMessage(messageData: dataReceived);
        if (message.isAuthentic()) {
          if (message is! FallBackMessage) {
            _eventMapForMessages(message);
          } else {
            dataReceived as Uint8List;
            log(dataReceived.toString());
          }
        }
        if (!_connection.isConnected()) {
          _eventBus.fire(const LostCommandConnectionEvent());
        }
      });
    } on Exception catch (e, stack) {
      log("$e  $stack");
    }
  }

  void _eventMapForMessages(IMessage message) {
    if (message is StmSystemStatusReplyMessage) {
      _eventBus.fire(SystemStatusReplyReceivedEvent(message));
    } else if (message is StmSafetyStatusReplyMessage) {
      _eventBus.fire(StmSafetyStatusReplyEvent(message));
    } else if (message is StmSafeSWAckMessage) {
      _eventBus.fire(StmSafetySwitchReplyEvent(message));
    } else if (message is AtmelSafetyStatusReplyMessage) {
      _eventBus.fire(AtmelSafetyStatusReplyEvent(message));
    } else if (message is AtmelSafeSW2AckMessage) {
      _eventBus.fire(AtmelSafetySwitchReplyEvent(message));
    } else if (message is DebugMessage) {
      _eventBus.fire(DebugReplyEvent(message));
    } else if (message is StmSafeSwitch1ReportMessage) {
      _eventBus.fire(StmSafeSwitchReportEvent(message));
    } else if (message is AtmelSafeSwitch2ReportMessage) {
      _eventBus.fire(AtmelSafeSwitchReportEvent(message));
    } else if (message is StmErrorMessage) {
      _eventBus.fire(StmErrorMessageEvent(message));
    } else if (message is AtmelErrorMessage) {
      _eventBus.fire(AtmelErrorMessageEvent(message));
    }
  }
}
