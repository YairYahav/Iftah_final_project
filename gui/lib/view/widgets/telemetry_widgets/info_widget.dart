import 'package:example_project/global/consts/enums.dart';
import 'package:flutter/material.dart';

class InfoWidget extends StatelessWidget {
  final String infoString;
  final InformationTypes informationType;
  final String timeStamp;
  const InfoWidget(this.infoString, this.timeStamp, this.informationType,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (informationType == InformationTypes.report)
          Icon(
            Icons.info,
            color: informationType.informationColor,
          ),
        if (informationType == InformationTypes.warning)
          Icon(
            Icons.warning,
            color: informationType.informationColor,
          ),
        if (informationType == InformationTypes.error)
          Icon(
            Icons.report_sharp,
            color: informationType.informationColor,
          ),
        const Padding(padding: EdgeInsets.all(2)),
        Text(
          "$timeStamp$infoString",
          style: TextStyle(
              color: informationType.informationColor,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
