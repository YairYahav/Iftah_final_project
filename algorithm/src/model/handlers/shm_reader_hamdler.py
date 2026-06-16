import time
import threading
from algorithm.src.globals.consts.logger_messages import LoggerMessages
import cv2
import os
import numpy as np
from typing import Any, Dict, List, Optional

from infrastructure.interfaces.iexample_manager import IShmRenderHandler
from globals.consts.const_strings import ConstStrings
from globals.consts.consts import Consts
from infrastructure.factories.logger_factory import LoggerFactory


class ShmRenderHandler(IShmRenderHandler):
    def __init__(self, video_id: int, width: int = Consts.DEFAULT_WIDTH, height: int = Consts.DEFAULT_HEIGHT) -> None:
        super().__init__()
        self._video_id = video_id
        self._width = width
        self._height = height
        self._shm_path = ConstStrings.SHM_PATH_TEMPLATE.format(video_id)
        self._logger = LoggerFactory.get_logger_manager()
        self._cap = None

    def start(self) -> None:
        pipeline = ConstStrings.SHARED_MEMORY_PIPELINE.format(
            frame_width=self._width,
            frame_height=self._height,
            frame_rate=Consts.DEFAULT_FRAME_RATE,
            scaled_width=self._width,
            scaled_height=self._height,
            shared_memory_path=self._shm_path
        )

        max_wait = Consts.SHM_READER_OPEN_TIMEOUT

        for i in range(max_wait):
            self._cap = cv2.VideoCapture(pipeline, cv2.CAP_GSTREAMER)
            if self._cap.isOpened():
                self._logger.log(ConstStrings.LOG_NAME_INFO,
                                 LoggerMessages.SHM_RENDER_HANDLER_OPENED.format(self._shm_path))
                return
            else:
                self._logger.log(ConstStrings.LOG_NAME_WARNING,
                                 LoggerMessages.SHM_RENDER_HANDLER_WAITING.format(self._shm_path, i + 1))
                
            try:
                self._cap.release()
            except Exception as e:
                self._logger.log(ConstStrings.LOG_NAME_ERROR,
                                 LoggerMessages.SHM_RENDER_HANDLER_RELEASE_FAILED.format(self._shm_path, str(e)))
                
            self._cap = None
            time.sleep(1)

        self._logger.log(ConstStrings.LOG_NAME_DEBUG,
                         LoggerMessages.SHM_RENDER_HANDLER_OPEN_TIMEOUT.format(self._shm_path, max_wait))
        
        



    def read_frame(self) -> np.ndarray:
        if self._cap is None:
            self._cap = cv2.VideoCapture(self._shm_path)

        ret, frame = self._cap.read()
        if not ret:
            self._logger.log(ConstStrings.LOG_NAME_ERROR,
                             LoggerMessages.SHM_RENDER_HANDLER_READ_FRAME_FAILED.format(self._shm_path))
            return np.zeros((self._height, self._width, 3), dtype=np.uint8)

        return frame
        

    def release(self) -> None:
        if self._cap is not None:
            self._cap.release()
            self._cap = None