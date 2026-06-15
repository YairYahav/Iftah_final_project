// ignore_for_file: overridden_fields, argument_type_not_assignable_to_error_handler

import 'package:example_project/domain/model/params/params.dart';
import 'package:example_project/global/consts/const_strings.dart';
import 'package:example_project/global/consts/consts.dart';
import 'package:example_project/infrastructure/interface/iconnection.dart';
import 'package:example_project/infrastructure/interface/iconnection_params.dart';
import 'package:example_project/infrastructure/interface/ijson_manager.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:get_it/get_it.dart';
import 'package:octavius_message_api/src/globals/constants/constants.dart';
import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:typed_data';

class SerialConnection extends IConnection {
  SerialPort? _port;
  late final SerialPortParams _params;
  Queue<int> lastMessage = Queue();

  SerialConnection() {
    var serialParams = GetIt.I
        .get<IJsonManager>()
        .readJson(ConstString.serialCommunicationConfigPath);
    _params = SerialPortParams(
      serialParams[ConstString.comPortString],
      int.parse(serialParams[ConstString.baudRateString]),
    );
  }

  @override
  late Stream? dataReceivedStream = _streamController.stream;

  @override
  void connect() {
    _connect(_params);
  }

  @override
  void disconnect() {
    _port?.close();
  }

  @override
  bool isConnected() {
    return _isConnected();
  }

  @override
  void sendMessage(message) {
    try {
      _port?.write(message);
    } on Exception catch (e, stack) {
      log("$e\n$stack");
    }
  }

  void _connect(SerialPortParams params) async {
    try {
      if (SerialPort.availablePorts.contains(params.portName)) {
        var settings = SerialPortConfig();
        settings.baudRate = params.baudRate;
        settings.stopBits = Consts.stopBits;
        settings.parity = SerialPortParity.none;
        settings.bits = Consts.dataBits;
        settings.cts = SerialPortCts.ignore;
        settings.rts = SerialPortRts.off;
        settings.dsr = SerialPortDsr.ignore;
        settings.dtr = SerialPortDtr.off;
        settings.xonXoff = SerialPortXonXoff.disabled;

        _port = SerialPort(params.portName);
        _port!.close();
        _port!.openReadWrite();
        _port!.config = settings;
        var serialListener = SerialPortReader(_port!);

        if (!_isConnected()) {
          log(ConstString.serialConnectionNotEstablished);
          _attemptReconnection(params);
        } else {
          log(ConstString.serialConnectionEstablished);
          _handleInComingMessage(serialListener.stream, params);
        }
      } else {
        log(ConstString.serialConnectionPortIsBusy);
        _attemptReconnection(params);
      }
    } on Exception catch (e, stack) {
      log("$e\n$stack");
      _attemptReconnection(params);
    }
  }

  Future<void> _attemptReconnection(SerialPortParams params) async {
    await Future.delayed(
        const Duration(seconds: Consts.defaultDelayBetweenReconnectionSerial));
    _connect(_params);
  }

  void _handleInComingMessage(Stream dataStream, SerialPortParams params) {
    try {
      dataStream.listen((event) {
        var messagebuffer = event;
        for (var element in messagebuffer) {
          lastMessage.addLast(element);
        }
        try {
          while (lastMessage.length >= Consts.messageLength) {
            if (lastMessage.first == OctaviusConstants.startByte) {
              var currentMessage = Uint8List.fromList(
                  lastMessage.take(Consts.messageLength).toList());
              _streamController.sink.add(currentMessage);
              if (lastMessage.length == Consts.messageLength) {
                lastMessage.clear();
              } else {
                for (var i = 0; i < Consts.messageLength; i++) {
                  lastMessage.removeFirst();
                }
              }
            } else {
              lastMessage.removeFirst();
            }
          }
        } on Exception catch (e) {
          log(e.toString());
          _attemptReconnection(params);
        }
      });
    } on Exception catch (e) {
      log(e.toString());
      _attemptReconnection(params);
    }
  }

  bool _isConnected() {
    if (SerialPort.availablePorts.contains(_params.portName)) {
      if (_port != null) {
        return true;
      }
    }
    return false;
  }

  final StreamController<Uint8List> _streamController =
      StreamController<Uint8List>.broadcast();


  @override
  void changeConnection(IConnectionParams params) {
 throw Exception;
  }
}
