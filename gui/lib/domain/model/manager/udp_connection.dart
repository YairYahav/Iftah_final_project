import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:example_project/infrastructure/interface/iconnection.dart';
import 'package:example_project/infrastructure/interface/iconnection_params.dart';
import 'package:octavius_message_api/src/globals/constants/constants.dart';
import 'package:get_it/get_it.dart';
import '../../../global/consts/const_strings.dart';
import '../../../global/consts/consts.dart';

import '../../../infrastructure/interface/iconnection_params_parser.dart';
import '../../../infrastructure/interface/ijson_manager.dart';
import '../params/params.dart';

class UdpConnection implements ICommandConnection {
  late final ConnectionParams _params;
  final Queue<int> _messageBuffer = Queue();
  late RawDatagramSocket? _socket;
  late Timer _connectionTimer;
  bool _isConnected = false;

  UdpConnection() {
    IJsonManager udpJsonManager = GetIt.I.get();
    IConnectionParser connectionParser = GetIt.I.get();
    var dataFromJson =
        udpJsonManager.readJson(ConstString.communicationManagerConfigPath);
    var parsedData = connectionParser.parseConnectionParams(dataFromJson);
    _params = ConnectionParams(
        parsedData[ConstString.configIp],
        parsedData[ConstString.configPort],
        parsedData[ConstString.configAttemptReconnect],
        parsedData[ConstString.configIsUsingTransreceiver],
        ownIp: parsedData[ConstString.configOwnIP]);
  }

  @override
  late Stream? dataReceivedStream = _streamController.stream;

  @override
  void connect() {
    _connect();
  }

  @override
  void disconnect() {
    _socket?.close();
    _socket = null;
  }

  @override
  bool isConnected() {
    return _isConnected;
  }

  @override
  void sendMessage(message) {
    try {
      _socket?.send(message, InternetAddress(_params.ip), _params.port);
    } on Exception catch (e, stack) {
      log("$e $stack");
      _isConnected = false;
    }
  }

  void _connect() {
    try {
      RawDatagramSocket.bind(InternetAddress.anyIPv4, _params.port)
          .then((value) => _handleListening(value));
    } catch (e, stack) {
      log("$e $stack");
      log(ConstString.couldNotConnect);
    }
  }

  Future<void> _handleListening(RawDatagramSocket socket) async {
    _socket = socket;
    _isConnected = true;
    log(ConstString.connected);
    _startConnectionTimer();
    _socket!.listen((RawSocketEvent rawData) {
      _isConnected = true;
      var datagram = socket.receive();
      if (datagram != null) {
        if (datagram.address.address != _params.ownIp) {
          Uint8List messagebuffer = Uint8List.view(datagram.data.buffer);
          try {
            for (var element in messagebuffer) {
              _messageBuffer.addLast(element);
            }
            _restartConnectionTimer();
            _checkInComingMessages();
          } on Exception catch (e, stack) {
            log("$e $stack");
            _isConnected = false;
          }
        }
      }
    }, onDone: () {
      _isConnected = false;
    }, onError: (_) {
      _isConnected = false;
    });
  }

  Future<void> _checkInComingMessages() async {
    try {
      while (_messageBuffer.length >= Consts.messageLength) {
        if (_messageBuffer.first == OctaviusConstants.startByte) {
          var currentMessage = Uint8List.fromList(
              _messageBuffer.take(Consts.messageLength).toList());
          _restartConnectionTimer();
          _streamController.sink.add(currentMessage);
          if (_messageBuffer.length == Consts.messageLength) {
            _messageBuffer.clear();
          } else {
            for (var i = 0; i < Consts.messageLength; i++) {
              _messageBuffer.removeFirst();
            }
          }
        } else {
          _messageBuffer.removeFirst();
        }
      }
    } on Exception catch (e) {
      log(e.toString());
    }
  }

  void _startConnectionTimer() {
    _connectionTimer =
        Timer(const Duration(milliseconds: Consts.udpTimerMilliseconds), () {
      _isConnected = false;
      _socket?.close();
      _connect();
      log(ConstString.couldNotConnect);
    });
  }

  void _restartConnectionTimer() {
    _isConnected = true;
    _connectionTimer.cancel();
    _startConnectionTimer();
  }

  final StreamController<Uint8List> _streamController =
      StreamController<Uint8List>.broadcast();

  @override
  void changeConnection(IConnectionParams params) {
    throw UnimplementedError();
  }
}
