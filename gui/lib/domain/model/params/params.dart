import 'dart:async';
import 'dart:io';


import '../../../global/consts/consts.dart';

class VideoDataParams {
  final String videoStreamSource;
  final String recordingStreamSource;
  VideoDataParams(
    this.videoStreamSource,
    this.recordingStreamSource,
  );
}

class ConnectionParams {
  String ip;
  int port;
  int? delayBetweenReconnections = Consts.defaultDelayBetweenReconnections;
  String? ownIp;
  Function(EventSink<Socket>)? onDone;
  Function? onError;
  bool attemptReconnections = false;
  bool isUsingTransreceiver = true;
  ConnectionParams(
      this.ip, this.port, this.attemptReconnections, this.isUsingTransreceiver,
      {this.delayBetweenReconnections, this.onDone, this.onError, this.ownIp});
}

class SerialPortParams {
  String portName;
  int baudRate;

  SerialPortParams(
    this.portName,
    this.baudRate,
  );
}
