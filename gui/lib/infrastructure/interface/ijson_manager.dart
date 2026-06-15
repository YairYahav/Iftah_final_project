abstract class IJsonManager {
  Map<String, dynamic> readJson(String path);
  void writeToJson(String path, Map<String, dynamic> data);
}
