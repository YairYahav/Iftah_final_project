// ignore_for_file: depend_on_referenced_packages, invalid_use_of_visible_for_testing_member

import 'package:event_bus/event_bus.dart';
import 'package:example_project/global/consts/const_strings.dart';
import 'package:example_project/infrastructure/interface/ijson_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:video_module/infrastructure/events/events.dart';

part 'camera_control_event.dart';
part 'camera_control_state.dart';

/// This bloc is responsible for the video handling in your, turn on and off the recording
class CameraControlBloc extends Bloc<CameraControlEvent, CameraControlState> {
  final EventBus _eventBus;
  final IJsonManager _jsonManager;

  CameraControlBloc()
      : _eventBus = GetIt.instance.get(),
        _jsonManager = GetIt.I.get(),
        super(CameraControlInitial()) {
    _startEventListening();
    _init();
  }

  void _init() {
    if (_jsonManager.readJson(
            ConstString.videoDataConfigPath)[ConstString.videoFomratString] ==
        ConstString.gstreamerFomratString) {
      emit(const VideoFormatUpdatedState(true));
    } else {
      emit(const VideoFormatUpdatedState(false));
    }
  }

  void _startEventListening() {
    on<CameraControlEvent>((event, emit) {});

    on<RecordingSwitchOn>((event, emit) {
      _eventBus.fire(VideoRecordingEvent(true, 0));
      emit(const RecordingSwitchOnOffState(false));
    });
    on<RecordingSwitchOff>((event, emit) {
      _eventBus.fire(VideoRecordingEvent(false, 0));
      emit(const RecordingSwitchOnOffState(true));
    });
  }
}
