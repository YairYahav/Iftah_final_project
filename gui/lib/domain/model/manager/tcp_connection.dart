// ignore_for_file: unrelated_type_equality_checks, curly_braces_in_flow_control_structures, unused_element, depend_on_referenced_packages

import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../../global/consts/const_strings.dart';
import '../../../global/consts/consts.dart';
// ignore: unused_import
import '../../../global/utils/utils.dart';

import '../../../infrastructure/interface/iconnection.dart';
import '../../../infrastructure/interface/iconnection_params.dart';
import '../../../infrastructure/interface/iconnection_params_parser.dart';
import '../../../infrastructure/interface/ijson_manager.dart';

// ignore: unused_import
import 'package:get_it/get_it.dart';

import '../params/params.dart';

class TcpConnection implements ICommandConnection {
  Socket? _socket;
  ServerSocket? _serverSocket;
  bool _isConnected = false;
  late final ConnectionParams _params;
  Queue<int> lastMessage = Queue();

  TcpConnection() {
    IJsonManager commandJsonManager = GetIt.I.get();
    IConnectionParser connectionParser = GetIt.I.get();
    var dataFromJson =
        commandJsonManager.readJson(ConstString.communicationManagerConfigPath);
    var parsedData = connectionParser.parseConnectionParams(dataFromJson);
    _params = ConnectionParams(
        parsedData[ConstString.configIp],
        parsedData[ConstString.configPort],
        parsedData[ConstString.configAttemptReconnect],
        parsedData[ConstString.configIsUsingTransreceiver]);
  }

  @override
  late Stream? dataReceivedStream = _streamController.stream;
  @override
  void sendMessage(message) {
    try {
      _socket?.add(message);
    } on Exception catch (e, stack) {
      log("$e $stack");
      _isConnected = false;
    }
  }

  @override
  void connect() {
    try {
      if (_params.delayBetweenReconnections != null) {
        _params.delayBetweenReconnections = _params.delayBetweenReconnections!;
      }
      _params.isUsingTransreceiver = _params.isUsingTransreceiver;
      _connect(_params);
    } on Exception catch (e, stack) {
      _isConnected = false;
      log("$e $stack");
    }
  }

  @override
  void disconnect() {
    _serverSocket?.close();
    _socket?.close();
  }

  @override
  bool isConnected() {
    return _isConnected;
  }

  Future<void> _attemptReconnection(ConnectionParams params) async {
    await Future.delayed(Duration(
        seconds: _params.delayBetweenReconnections != null
            ? _params.delayBetweenReconnections!
            : Consts.defaultTimeoutInSeconds));
    _connect(_params);
  }

  void _connect(ConnectionParams params) async {
    try {
      if (_params.isUsingTransreceiver) {
        _handleListening(await Socket.connect(params.ip, params.port), params);
      } else {
        _serverSocket = await ServerSocket.bind(params.ip, params.port);
        _serverSocket!.listen((Socket event) {
          _handleListening(event, params);
        });
      }
    } on SocketException catch (e, stack) {
      log("$e $stack");
      log(ConstString.couldNotConnect);
      if (params.attemptReconnections == true) {
        log(ConstString.attempttingReconnection);
        _attemptReconnection(params);
      } else {
        if (params.onError != null) {
          params.onError!();
        } else {
          disconnect();
          _isConnected = false;
          log("$e $stack");
        }
      }
    }
  }

  void _handleListening(Socket socket, ConnectionParams params) {
    _socket = socket;
    _isConnected = true;
    log(ConstString.connected);
    _socket!.listen((Uint8List messagebuffer) {
      try {
        for (var element in messagebuffer) {
          lastMessage.addLast(element);
        }
        while (lastMessage.length >= Consts.messageLength) {
          var actualMessage = lastMessage.take(Consts.messageLength);
          _streamController.sink
              .add(Uint8List.fromList(actualMessage.toList()));
          if (lastMessage.length == Consts.messageLength) {
            lastMessage.clear();
          } else
            for (var i = 0; i < Consts.messageLength; i++) {
              lastMessage.removeFirst();
            }
        }
      } on Exception catch (e, stack) {
        log("$e $stack");
        _isConnected = false;
      }
    }, onDone: () {
      _isConnected = false;
      if (params.attemptReconnections == true) {
        log(ConstString.attempttingReconnection);
        _attemptReconnection(params);
      }
    }, onError: (_) {
      _isConnected = false;
      if (params.attemptReconnections == true) {
        log(ConstString.attempttingReconnection);
        _attemptReconnection(params);
      }
    });
  }

  final StreamController<Uint8List> _streamController =
      StreamController<Uint8List>.broadcast();

  @override
  void changeConnection(IConnectionParams params) {
    throw UnimplementedError();
  }
}
