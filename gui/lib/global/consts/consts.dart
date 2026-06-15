class Consts {
  //?TCP Manager
  static const int defaultTimeoutInSeconds = 5;
  static const int defaultDelayBetweenReconnections = 10;
  static const int defaultDelayBetweenReconnectionSerial = 5;

  //? Weapon Panel Values
  static const int octaviusBootingTime = 16;

  //? Communication Repository Values
  static const int milliSecondsInterval = 10;
  static const int counterInterval = 10;
  static const int armTimerInitial = 60;
  static const int secondsResetQueueDuration = 10;
  static const int stmVoltageRed = 84;
  static const int atmelVoltageRed = 14;
  static const int secondsLedDuration = 4;
  static const int nullBulletsValue = 0xFF;
  static const int nullbulletsDisplayNum = -1;
  static const int opCodeIndex = 2;
  static const int stopBits = 1;
  static const int parity = 0;
  static const int dataBits = 8;
  static const int rts = 0;
  static const int cts = 0;
  static const int dtr = 0;
  static const int dsr = 0;
  static const int xonXoff = 0;
  static const int messageLength = 16;
  static const int xSpeedPlacement = 3;
  static const int ySpeedPlacement = 5;
  static const int resetSpeedsPlacement = -8;
  static const int pinNumberStmSafeSwMessage = 4;
  static const int stmSafeSwMessageOff = 20;
  static const int stmSafeSwMessageOn = 4;
  static const int pinNumberAtmelSafeSwMessage = 24;
  static const int pinNumberAtmelOn = 1;
  static const int pinNumberAtmelOff = 0;
  static const int milliSecondsLedBlinkDuration = 500;
  static const int redBlinkTimes = 3;
  static const int udpTimerMilliseconds = 300;
  static const int queueSendingInterval = 100;
}
