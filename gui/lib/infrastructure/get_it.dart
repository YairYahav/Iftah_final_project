import 'dart:developer';

import 'package:event_bus/event_bus.dart';
import 'package:example_project/domain/model/manager/serial_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:example_project/domain/model/manager/video_manager.dart';
import 'package:example_project/infrastructure/interface/ivideo_module.dart';
import 'package:octavius_message_api/octavius_message_api.dart';
import 'package:example_project/domain/model/manager/udp_connection.dart';
import 'package:example_project/infrastructure/interface/video_params_parser.dart';
import 'package:media_kit/media_kit.dart';
import 'package:video_module/infrastructure/get_it/get_it.dart';
import '../domain/model/manager/json_manager.dart';
import '../domain/model/manager/tcp_connection.dart';
import '../domain/model/params/parsers.dart';
import '../domain/repository/communication_repository.dart';
import '../global/consts/const_strings.dart';
import 'interface/icommunication_repository.dart';
import 'interface/iconnection.dart';
import 'interface/iconnection_params_parser.dart';
import 'interface/ijson_manager.dart';
import 'interface/imessage_params_parser.dart';

/// This Is your get_it file, here you register your managers and create your on-start functions for your app.
/// get_it is a dependency injector, Dependency injection is a programming technique that makes a class independent of its dependencies.
/// It achieves that by decoupling the usage of an object from its creation.
/// This helps you to follow SOLID’s dependency inversion and single responsibility principles.
/// For more information about get_it:
/// https://pub.dev/packages/get_it

void registerManager() {
  GetIt.I.registerLazySingleton<IMessageBuilder>(() => MessageBuilder());
  GetIt.I.registerLazySingleton<IJsonManager>(() => JsonConfigManager());
  GetIt.I.registerLazySingleton<IMessagesParamsParser>(
      () => MessagesParamsParser());
  GetIt.I.registerLazySingleton<ICommunicationRepository>(
      () => CommunicationRepository());
  GetIt.I.registerLazySingleton<EventBus>(() => EventBus());
  GetIt.I.registerLazySingleton<IVideoParamsParser>(() => VideoParamsParser());
  GetIt.I
      .registerLazySingleton<IConnectionParser>(() => ConnectionParamsParser());
}

void checkTypeConnection() {
  IJsonManager tcpJsonManager = GetIt.I.get();
  var dataFromJson =
      tcpJsonManager.readJson(ConstString.communicationManagerConfigPath);
  if (dataFromJson[ConstString.configConnection] == ConstString.configUDP) {
    GetIt.I.registerLazySingleton<IConnection>(() => UdpConnection());
  } else {
    if (dataFromJson[ConstString.configConnection] ==
        ConstString.configSerial) {
      GetIt.I.registerLazySingleton<IConnection>(() => SerialConnection());
    } else {
      GetIt.I.registerLazySingleton<IConnection>(() => TcpConnection());
    }
  }
}

void init() {
  GetIt.I.get<ICommunicationRepository>().startConnection();
  GetIt.I.get<IMessagesParamsParser>().startParsing();
}

void initVideo() {
  initVideoModule();
  registerVideoModels();
  try {
    MediaKit.ensureInitialized();
  } catch (e) {
    log('$e');
  }
}

void initVideoModule() {
  initVideoModuleRepositories();
}

void registerVideoModels() {
  registerVideoModuleModels();
  GetIt.I.registerSingleton<IVideoModule>(VideoManager());
  GetIt.I.get<IVideoModule>().play(0);
}
