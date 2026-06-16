import os
from algorithm.src.model.handlers.shm_reader_hamdler import ShmRenderHandler
from infrastructure.factories.infrastructure_factory import InfrastructureFactory
from globals.consts.const_strings import ConstStrings
from infrastructure.interfaces.ishm_handler import IShmHandler

class HandlerFactory:
    @staticmethod
    def create_example_handler():
        pass

    @staticmethod
    def create_shm_handler(video_id: int, width: int, height: int, frame_rate: int) -> IShmHandler:
        return ShmRenderHandler(video_id, width, height, frame_rate)