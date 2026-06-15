part of 'info_window_bloc.dart';

@immutable
abstract class InfoWindowState extends Equatable {
  const InfoWindowState();
}

class InfoWindowInitial extends InfoWindowState {
  const InfoWindowInitial();

  @override
  List<Object?> get props => [];
}

class RebuildListState extends InfoWindowState {
  final List<InformationData> infoList;
  const RebuildListState(this.infoList);

  @override
  List<Object> get props => [infoList];
}
