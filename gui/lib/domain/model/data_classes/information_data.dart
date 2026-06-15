import 'package:example_project/global/consts/enums.dart';
import 'package:example_project/infrastructure/interface/iinfo_data.dart';

class InformationData implements IInfoData {
  final String infoString;
  final InformationTypes informationType;
  final String timeStamp =
      "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}.${DateTime.now().millisecond.toString().padLeft(3, '0')}: ";
  InformationData(this.infoString, this.informationType);

}
