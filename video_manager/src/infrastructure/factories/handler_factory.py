import os
from infrastructure.factories.infrastructure_factory import InfrastructureFactory
from globals.consts.const_strings import ConstStrings
from infrastructure.interfaces.handlers.ivideo_handler import IVideoHandler
from model.handlers.video_handler import VideoHandler

class HandlerFactory:
    @staticmethod
    def create_video_handler(video_id: int, video_source: str, width: int = None, height: int = None) -> IVideoHandler:
        from globals.consts.consts import Consts
        w = width if width is not None else Consts.FRAME_WIDTH
        h = height if height is not None else Consts.FRAME_HEIGHT
        return VideoHandler(video_id, video_source, w, h)