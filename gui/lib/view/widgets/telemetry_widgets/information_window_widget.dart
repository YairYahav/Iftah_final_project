import 'package:example_project/domain/model/data_classes/information_data.dart';
import 'package:example_project/view/widgets/telemetry_widgets/info_widget.dart';
import 'package:flutter/material.dart';

class InformationWindowWidget extends StatelessWidget {
  final List<InformationData> data;
  const InformationWindowWidget(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey.withAlpha(70),
      child: SizedBox(
          width: MediaQuery.of(context).size.width * (1.2 / 5),
          height: MediaQuery.of(context).size.height / 4,
          child: ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: data.length,
            itemBuilder: (context, index) => InfoWidget(data[index].infoString,
                data[index].timeStamp, data[index].informationType),
          )),
    );
  }
}
