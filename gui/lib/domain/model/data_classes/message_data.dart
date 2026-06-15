import '../../../infrastructure/interface/imessage_data_params.dart';

class MessageData extends IMessageData {
  MessageData(int placement, dynamic data) {
    super.placement = placement;
    super.data = data;
  }
}
