import '../../domain/model/params/params.dart';

abstract class IVideoParamsParser {
  VideoDataParams? parseVideoConfig(Map<String, dynamic> data);
}
