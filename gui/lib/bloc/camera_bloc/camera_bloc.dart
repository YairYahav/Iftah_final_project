import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:example_project/global/consts/const_strings.dart';
import 'package:example_project/infrastructure/interface/ijson_manager.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:event_bus/event_bus.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final EventBus _eventBus;
  final IJsonManager _iJsonManager;
  late String _path;
  late StreamSubscription _recordingStreamSub;
  late Player _player;
  late VideoController _videoController;

  CameraBloc(int id)
      : _iJsonManager = GetIt.I.get(),
        _eventBus = GetIt.I.get(),
        super(CameraInitial(VideoController(Player()..open(Media(''))))) {
    _initPath();
    _startEventListening();
  }

  @override
  Future<void> close() {
    _recordingStreamSub.cancel();
    return super.close();
  }

  void _startEventListening() {
    on<CameraEvent>((event, emit) {});

    on<InitVideoEvent>((event, emit) async {
      _player = Player()..open(Media(_path));
      _videoController = VideoController(_player);
      emit(CameraInitial(_videoController));
    });
  }

  void _initPath() {
    _path = _iJsonManager.readJson(
        ConstString.videoDataConfigPath)[ConstString.streamSourceString];
  }
}
