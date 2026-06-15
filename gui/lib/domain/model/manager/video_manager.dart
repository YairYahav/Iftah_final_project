import '../../../global/consts/const_strings.dart';
import 'package:get_it/get_it.dart';
import 'package:video_module/infrastructure/interface/ivideo_repository.dart';
import '../../../infrastructure/interface/ijson_manager.dart';
import '../../../infrastructure/interface/ivideo_module.dart';

class VideoManager implements IVideoModule {
  final IJsonManager _configManager;
  final IVideoRepository _iVideoRepository;

  late String _primaryStreamSource;
  late String _primaryRecordingStreamSource;

  VideoManager()
      : _configManager = GetIt.I.get(),
        _iVideoRepository = GetIt.I.get() {
    var configData = _configManager.readJson(ConstString.videoDataConfigPath);
    _primaryStreamSource = configData[ConstString.streamSourceString];
    _primaryRecordingStreamSource =
        configData[ConstString.recordingStreamSourceString];
  }

  @override
  void play(int id) {
    _iVideoRepository.playVideo(
        _primaryStreamSource, _primaryRecordingStreamSource, 0);
  }

  @override
  void stop(int id) {
    _iVideoRepository.stopVideo(0);
  }

  @override
  void resume(int id) {
    _iVideoRepository.resumeVideo(0);
  }
}
