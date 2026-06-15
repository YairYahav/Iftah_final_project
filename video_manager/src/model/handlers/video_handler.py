import cv2
import os
import numpy as np
from infrastructure.interfaces.handlers.ivideo_handler import IVideoHandler
from globals.consts.const_strings import ConstStrings
from globals.consts.consts import Consts
from globals.consts.logger_messages import LoggerMessages
from infrastructure.factories.logger_factory import LoggerFactory


class VideoHandler(IVideoHandler):
    def __init__(self, video_id: int, video_path: str):
        super().__init__()
        self._video_id = video_id
        self._video_path = video_path
        self._frame_width = Consts.FRAME_WIDTH
        self._frame_height = Consts.FRAME_HEIGHT
        self._frame_rate = Consts.FRAME_RATE
        self._cap = None
        self._writer = None
        self._logger = LoggerFactory.get_logger_manager()
        


        