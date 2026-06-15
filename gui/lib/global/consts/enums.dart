import 'package:flutter/material.dart';

enum ConnectionStatus { error, bad, ok, good }

enum AimCalStages {
  initial(0),
  setRange(1),
  adjustLaser(2),
  adjustCross(3);

  const AimCalStages(this.value);
  final int value;
}

enum InformationTypes {
  report(Colors.blue),
  warning(Colors.orangeAccent),
  error(Colors.red);

  const InformationTypes(this.informationColor);
  final Color informationColor;
}

enum InfoMessageData {
  testError(0, "Test", InformationTypes.error),
  octaviusBootError(0xA5, "סיום איתחול בעוד", InformationTypes.error),
  atmelNotResponingSafe1Error(
      0x90, "לא מגיב לבטיחות 1 Atmel", InformationTypes.error),
  stmNotResponingSafe1Error(
      0x91, "לא מגיב לבטיחות 1 Stm", InformationTypes.error),
  stmNotResponingSafe2Error(
      0x92, "2 לא מגיב מגיב לבטיחות Stm", InformationTypes.error),
  atmelNotResponingSafe2Error(
      0x93, "לא מגיב לבטיחות 2 Atmel", InformationTypes.error),
  atmelNotFunctionalError(0x64, "לא פועל Atmel", InformationTypes.error),
  errorVoltageReading(1, "מתח לא הגיוני", InformationTypes.error);

  const InfoMessageData(this.errorNum, this.messageString, this.infoType);
  final int errorNum;
  final String messageString;
  final InformationTypes infoType;
}
