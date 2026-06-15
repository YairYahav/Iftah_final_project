import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:example_project/domain/model/params/params.dart';
import 'package:example_project/infrastructure/interface/iconnection_params_parser.dart';
import 'package:example_project/infrastructure/interface/video_params_parser.dart';

import '../../../global/consts/const_strings.dart';
import '../../../infrastructure/interface/ijson_manager.dart';
import '../../../infrastructure/interface/imessage_params_parser.dart';

class VideoParamsParser implements IVideoParamsParser {
  @override
  VideoDataParams? parseVideoConfig(Map<String, dynamic> data) {
    try {
      return VideoDataParams(data[ConstString.streamSourceString],
          data[ConstString.recordingStreamSourceString]);
    } catch (e, stack) {
      log("$e \n $stack");
    }
    return null;
  }
}

class ConnectionParamsParser implements IConnectionParser {
  @override
  Map<String, dynamic> parseConnectionParams(Map<String, dynamic> data) {
    return {
      ConstString.configIp: data.entries
          .firstWhere((element) => element.key == ConstString.configIp)
          .value,
      ConstString.configPort: int.parse(data.entries
          .firstWhere((element) => element.key == ConstString.configPort)
          .value),
      ConstString.configAttemptReconnect: data.entries
                  .firstWhere((element) =>
                      element.key == ConstString.configAttemptReconnect)
                  .value ==
              ConstString.trueString
          ? true
          : false,
      ConstString.configIsUsingTransreceiver: data.entries
                  .firstWhere((element) =>
                      element.key == ConstString.configIsUsingTransreceiver)
                  .value ==
              ConstString.trueString
          ? true
          : false,
      ConstString.configTimeBetween: int.parse(data.entries
          .firstWhere((element) => element.key == ConstString.configTimeBetween)
          .value),
    };
  }

  @override
  Map<String, dynamic> parseSshParmas(Map<String, dynamic> data) {
    return {
      ConstString.configIp: data.entries
          .firstWhere((element) => element.key == ConstString.configIp)
          .value,
      ConstString.configPort: int.parse(data.entries
          .firstWhere((element) => element.key == ConstString.configPort)
          .value),
      ConstString.configAttemptReconnect: data.entries
                  .firstWhere((element) =>
                      element.key == ConstString.configAttemptReconnect)
                  .value ==
              ConstString.trueString
          ? true
          : false,
      ConstString.configTimeBetween: int.parse(data.entries
          .firstWhere((element) => element.key == ConstString.configTimeBetween)
          .value),
      ConstString.configUserName: data.entries
          .firstWhere((element) => element.key == ConstString.configUserName)
          .value,
      ConstString.configPassWord: data.entries
          .firstWhere((element) => element.key == ConstString.configPassWord)
          .value,
      ConstString.configCommand: data.entries
          .firstWhere((element) => element.key == ConstString.configCommand)
          .value,
      ConstString.configPeriodic: data.entries
                  .firstWhere(
                      (element) => element.key == ConstString.configPeriodic)
                  .value ==
              ConstString.trueString
          ? true
          : false,
    };
  }
}

class MessagesParamsParser implements IMessagesParamsParser {
  @override
  Map<String, dynamic> messagesParamsData = {};
  final IJsonManager _configManager;
  MessagesParamsParser() : _configManager = GetIt.I.get();
  @override
  void startParsing() {
    _parseJsonForMessages();
  }

  void _parseJsonForMessages() {
    messagesParamsData =
        _configManager.readJson(ConstString.fullSendMessagesFilePath);
  }
}
