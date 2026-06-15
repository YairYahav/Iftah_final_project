abstract class IConnectionParser {
  Map<String, dynamic> parseConnectionParams(Map<String, dynamic> data);
  Map<String, dynamic> parseSshParmas(Map<String, dynamic> data);
}
