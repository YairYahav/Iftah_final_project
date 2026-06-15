import 'package:equatable/equatable.dart';
import 'package:example_project/global/consts/enums.dart';
import 'package:octavius_message_api/octavius_message_api.dart';
import '../../domain/model/data_classes/message_data.dart';

class DryMessageToSendEvent {
  final IMessage messageBuffer;
  DryMessageToSendEvent(this.messageBuffer);
}

class DataForPeriodicEvent {
  final MessageData messageData;
  DataForPeriodicEvent(this.messageData);
}

class LostCommandConnectionEvent extends Equatable {
  const LostCommandConnectionEvent();

  @override
  List<Object?> get props => [];
}

class MessageReceivedEvent {
  final IMessage decodedMessage;
  MessageReceivedEvent(this.decodedMessage);
}

class SystemStatusReplyReceivedEvent {
  final IMessage decodedMessage;
  SystemStatusReplyReceivedEvent(this.decodedMessage);
}

class StmSafetyStatusReplyEvent {
  final IMessage decodedMessage;
  StmSafetyStatusReplyEvent(this.decodedMessage);
}

class AtmelSafetyStatusReplyEvent {
  final IMessage decodedMessage;
  AtmelSafetyStatusReplyEvent(this.decodedMessage);
}

class StmSafetySwitchReplyEvent {
  final IMessage decodedMessage;
  StmSafetySwitchReplyEvent(this.decodedMessage);
}

class AtmelSafetySwitchReplyEvent {
  final IMessage decodedMessage;
  AtmelSafetySwitchReplyEvent(this.decodedMessage);
}


class StatusRedCheckedEvent {
  final bool isStatusRed;
  StatusRedCheckedEvent(this.isStatusRed);
}

class UpdateBlinkingStatus {
  final bool isStmBlinking;
  final bool isAtmelBlinking;
  UpdateBlinkingStatus(this.isStmBlinking, this.isAtmelBlinking);
}

class StmSafeSwitchReportEvent extends MessageReceivedEvent {
  StmSafeSwitchReportEvent(super.decodedMessage);
}

class AtmelSafeSwitchReportEvent extends MessageReceivedEvent {
  AtmelSafeSwitchReportEvent(super.decodedMessage);
}

class StmErrorMessageEvent extends MessageReceivedEvent {
  StmErrorMessageEvent(super.decodedMessage);
}

class AtmelErrorMessageEvent extends MessageReceivedEvent {
  AtmelErrorMessageEvent(super.decodedMessage);
}

class ErrorMessageEvent {
  InfoMessageData infoMessageData;
  ErrorMessageEvent(this.infoMessageData);
}

class ResetBlinkingEvent {
  const ResetBlinkingEvent();
}

class DebugReplyEvent extends MessageReceivedEvent {
  DebugReplyEvent(super.decodedMessage);
}

class ForceFireToSendEvent {
  final IMessage message;
  const ForceFireToSendEvent(this.message);
}

class DryMessageSetToSendEvent {
  final List<IMessage> messages;
  const DryMessageSetToSendEvent(this.messages);
}

class StartStatusCheckEvent {
  const StartStatusCheckEvent();
}

class ArmEnabledEvent {
  final bool isArmEnabled;
  ArmEnabledEvent(this.isArmEnabled);
}
