import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import '../../../global/consts/const_strings.dart';
import '../../../infrastructure/interface/ijson_manager.dart';

class JsonConfigManager implements IJsonManager {
  final Directory directory = Directory.current;
  JsonConfigManager();

  @override
  Map<String, dynamic> readJson(String path) {
    Map<String, dynamic> info = {};
    try {
      var jsondata = json.decode(
          File("${directory.path.replaceAll('\\', '/')}$path")
              .readAsStringSync()) as Map<String, dynamic>;
      return jsondata;
    } on Exception catch (e, stack) {
      log("$e,$stack");
    }
    return info;
  }

  @override
  void writeToJson(String path, Map<String, dynamic> data) {
    final file = File("${directory.path.replaceAll('\\', '/')}$path");
    try {
      file.writeAsStringSync(json.encode(data));
    } catch (e) {
      throw Exception(ConstString.errorWritingString + e.toString());
    }
  }
}
