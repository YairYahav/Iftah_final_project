import threading
from infrastructure.interfaces.ialgorithm_manager import IAlgorithmManager
from model.managers.algorithm_manager import AlgorithmManager
from infrastructure.factories.infrastructure_factory import InfrastructureFactory
from globals.consts.const_strings import ConstStrings
from infrastructure.interfaces.iexample_manager import IExampleManager
from infrastructure.interfaces.izmq_server_manager import IZmqServerManager
from model.managers.example_manager import ExampleManager
from infrastructure.interfaces.ilogger_manager import ILoggerManager
from globals.consts.consts import Consts


class ManagerFactory:
    @staticmethod
    def create_example_manager() -> IExampleManager:
        config_manager = InfrastructureFactory.create_config_manager(
            ConstStrings.GLOBAL_CONFIG_PATH)
        return ExampleManager(config_manager, InfrastructureFactory.create_kafka_manager(config_manager))

    @staticmethod
    def create_example_zmq_manager() -> IZmqServerManager:
        return InfrastructureFactory.create_zmq_server_manager()

    @staticmethod
    def create_algorithm_manager() -> IAlgorithmManager:
        #
        video_config = [
            # {
            #     'video_id': 1,
            #     'width': 720,   # matches video_manager shmsink: 1080x1920 native (9:16) -> 720x1280
            #     'height': 1280,
            #     'algorithm': "motion_detection",
            #     'algorithm_config': {
            #         'min_area': Consts.MOTION_MIN_AREA,
            #         'threshold': Consts.MOTION_BG_VAR_THRESHOLD,
            #         'history': Consts.MOTION_BG_HISTORY,
            #         'detected_shadows': Consts.MOTION_DETECT_SHADOWS,
            #         'dilate_iter': Consts.MOTION_DILATE_ITER,
            #        'erode_iter': 1,
            #        'draw_bounding_boxes': True,
            #        'blur_kernel': 5,
            #        'merge_boxes': True,
            #        'merge_margin': 30,
            #        'min_aspect_ratio': 0.1,
            #        'max_aspect_ratio': 10.0
            #     }
            # }
            # ,
            # {
            #     'video_id': 2,
            #     'width': 1280,  # matches video_manager shmsink: 3840x2160 native (16:9) -> 1280x720
            #     'height': 720,
            #     'algorithm': "motion_detection",
            #     'algorithm_config': {
            #         'min_area': Consts.MOTION_MIN_AREA,
            #         'threshold': Consts.MOTION_BG_VAR_THRESHOLD,
            #         'history': Consts.MOTION_BG_HISTORY,
            #         'detected_shadows': Consts.MOTION_DETECT_SHADOWS,
            #         'dilate_iter': Consts.MOTION_DILATE_ITER,
            #        'erode_iter': 1,
            #        'draw_bounding_boxes': True,
            #        'blur_kernel': 5,
            #        'merge_boxes': True,
            #        'merge_margin': 30,
            #        'min_aspect_ratio': 0.1,
            #        'max_aspect_ratio': 10.0
            #     }
            # }
            #, 
            {
                'video_id': 3,
                'width': Consts.ALGORITHM_VIDEO_WIDTH,
                'height': Consts.ALGORITHM_VIDEO_HEIGHT,
                'algorithm': "motion_detection",
                'algorithm_config': {
                    'min_area': Consts.MOTION_MIN_AREA,
                    'threshold': Consts.MOTION_BG_VAR_THRESHOLD,
                    'history': Consts.MOTION_BG_HISTORY,
                    'detected_shadows': False,
                    'dilate_iter': Consts.MOTION_DILATE_ITER,
                    'erode_iter': 1,
                    'draw_bounding_boxes': True,
                    'blur_kernel': 5,
                    'merge_boxes': True,
                    'merge_margin': 30,
                    'min_aspect_ratio': 0.1,
                    'max_aspect_ratio': 10.0
                }
            }
        ]
        return AlgorithmManager(video_config)

    @staticmethod
    def create_all():
        ManagerFactory.create_example_manager()
        try:
            ManagerFactory.create_example_zmq_manager()
        except Exception as e:
            import logging
            logging.getLogger("debug").warning(f"ZMQ server setup failed (non-fatal): {e}")
        algorithm_manager = ManagerFactory.create_algorithm_manager()
        thread = threading.Thread(target=algorithm_manager.start_algorithm, daemon=True)
        thread.start()