class ConstString {
  //! Version
  //TODO change name to suit version below
  static const String version = "example_project";

  //? Paths:
  //! remove /assets
  static const String fullSendMessagesFilePath =
      "/config/message_data_config.json";
  static const String videoDataConfigPath = "/config/video_data_config.json";
  static const String aimDefaultParametersConfigPath =
      "/config/aim_default_parameters.json";
  static const String communicationManagerConfigPath =
      "/config/communication_config.json";
  static const String serialCommunicationConfigPath =
      "/config/serial_communication_config.json";

  static const String configIp = "IP";
  static const String configPort = "Port";
  static const String configUDP = "UDP";
  static const String configTCP = "TCP";
  static const String configSerial = "Serial";
  static const String configConnection = "Connection";
  static const String configAttemptReconnect = "AttemptReconnection";
  static const String configIsUsingTransreceiver = "IsUsingTransreceiver";
  static const String configTimeBetween = "TimeBetweenReconnection";
  static const String attempttingReconnection = "attempting reconnection!";
  static const String configOwnIP = "OwnIP";
  static const String trueString = "true";
  static const String configUserName = "UserName";
  static const String configPassWord = "PassWord";
  static const String configCommand = "Command";
  static const String configPeriodic = "Periodic";
  static const String errorWritingString =
      'An error occurred while writing JSON file: ';
  static const String couldNotConnect = "Could not connect!";
  static const String connected = "Connected!";
  static const String streamSourceString = "VideoStreamSource";
  static const String recordingStreamSourceString =
      "VideoRecordingStreamSource";

  static const String comPortString = "COMPort";
  static const String baudRateString = "BaudRate";
  static const String videoFomratString = "VideoFomrat";
  static const String gstreamerFomratString = "Gstreamer";
  static const String ffmpegFomratString = "FFmpeg";
  static const String serialConnectionEstablished = "Connected To Serial!";
  static const String serialConnectionPortIsBusy =
      "The Port is either busy or does not exist";
  static const String serialConnectionNotEstablished =
      "Could not connect, check connection!";

  static const String warningNoConnection = "אין תקשורת";
  static const String safeStatusString = "סטטוס";
  static const String safe1String = " :בטיחות 1";
  static const String safe2String = " :בטיחות 2";
  static const String voltageString = " :מתח";
  static const String fireString = "ירי";
}
