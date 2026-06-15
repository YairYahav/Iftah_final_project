import os
from infrastructure.factories.infrastructure_factory import InfrastructureFactory
from globals.consts.const_strings import ConstStrings
from video_manager.src.infrastructure.interfaces.handlers.ivideo_handler import IVideoHandler
from model.handlers.video_handler import VideoHandler

class HandlerFactory:
    @staticmethod
    def create_video_handler(video_id: int, video_source: str) -> IVideoHandler:
        return VideoHandler(video_id, video_source)