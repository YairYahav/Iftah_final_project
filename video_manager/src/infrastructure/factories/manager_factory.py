from infrastructure.factories.infrastructure_factory import InfrastructureFactory
from globals.consts.const_strings import ConstStrings
from infrastructure.interfaces.iexample_manager import IExampleManager
from infrastructure.interfaces.izmq_server_manager import IZmqServerManager
from model.managers.example_manager import ExampleManager
from infrastructure.interfaces.ilogger_manager import ILoggerManager
from infrastructure.interfaces.managers.ivideo_manager import IVideoManager
from model.managers.video_manager import VideoManager


class ManagerFactory:
    @staticmethod
    def create_video_manager(video_config: list) -> IVideoManager:
        return VideoManager(video_config)

    # @staticmethod
    # def create_example_manager() -> IExampleManager:
    #     config_manager = InfrastructureFactory.create_config_manager(
    #         ConstStrings.GLOBAL_CONFIG_PATH)
    #     return ExampleManager(config_manager, InfrastructureFactory.create_kafka_manager(config_manager))

    # @staticmethod
    # def create_example_zmq_manager() -> IZmqServerManager:
    #     return InfrastructureFactory.create_zmq_server_manager()

    @staticmethod
    def create_all() -> None:
        # ManagerFactory.create_example_manager()
        # ManagerFactory.create_example_zmq_manager()u

        videos_config = [
            # {
            #     'video_id': 1,
            #     'video_path': '/app/video_manager/videos/horses_video.mp4',
            #     'width': 720,   # 1080x1920 native (9:16) -> 720x1280 preserving ratio
            #     'height': 1280
            # }
            # ,
            # {
            #     'video_id': 2,
            #     'video_path': '/app/video_manager/videos/soccer_football_video.mp4',
            #     'width': 1280,  # 3840x2160 native (16:9) -> 1280x720 preserving ratio
            #     'height': 720
            # }
            # ,
            {
                'video_id': 3,
                'video_path': '/app/video_manager/videos/man_walking_video.mp4',
            }
        ]

        video_manager = ManagerFactory.create_video_manager(
            videos_config)  # Pass the videos_config list
        video_manager.start()
