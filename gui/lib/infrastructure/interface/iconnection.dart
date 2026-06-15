import 'dart:async';
import 'package:example_project/infrastructure/interface/iconnection_params.dart';

abstract class IConnection {
  void connect();
  void disconnect();
  bool isConnected();
  void sendMessage(message);
  void changeConnection(IConnectionParams params);
  Stream<dynamic>? dataReceivedStream;
}


abstract class ICommandConnection extends IConnection {}

abstract class ISerialConnection extends IConnection {}
