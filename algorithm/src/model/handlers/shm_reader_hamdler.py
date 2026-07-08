import time
import threading
from globals.consts.logger_messages import LoggerMessages
import cv2 # type: ignore
import os
import numpy as np
from typing import Any, Dict, List, Optional

from infrastructure.interfaces.ishm_handler import IShmHandler
from globals.consts.const_strings import ConstStrings
from globals.consts.consts import Consts
from infrastructure.factories.logger_factory import LoggerFactory


class ShmRenderHandler(IShmHandler):
    def __init__(self, video_id: int, width: int = Consts.DEFAULT_WIDTH, height: int = Consts.DEFAULT_HEIGHT, frame_rate: int = Consts.DEFAULT_FRAME_RATE) -> None:
        super().__init__()
        self._video_id = video_id
        self._width = width
        self._height = height
        self._frame_rate = frame_rate
        self._shm_path = ConstStrings.SHM_PATH_TEMPLATE.format(video_id)
        self._logger = LoggerFactory.get_logger_manager()
        self._cap = None
        self._last_reconnect_attempt = 0.0
        self._reconnect_cooldown = 3.0  # seconds between reconnect attempts

    def _try_open_cap(self, pipeline: str, timeout: float = 4.0):
        """Open a GStreamer VideoCapture with a timeout. Returns cap if opened, else None."""
        result = []

        def _open():
            try:
                cap = cv2.VideoCapture(pipeline, cv2.CAP_GSTREAMER)
                result.append(cap)
            except Exception:
                result.append(None)

        t = threading.Thread(target=_open, daemon=True)
        t.start()
        t.join(timeout)
        if not result:
            return None  # timed out — thread still running in background
        return result[0]

    def start(self) -> None:
        pipeline = ConstStrings.SHARED_MEMORY_READER_PIPELINE.format(
            frame_width=self._width,
            frame_height=self._height,
            frame_rate=self._frame_rate,
            shared_memory_path=self._shm_path
        )

        max_wait = Consts.SHM_READER_OPEN_TIMEOUT

        for i in range(max_wait):
            cap = self._try_open_cap(pipeline, timeout=4.0)
            if cap is not None and cap.isOpened():
                self._cap = cap
                self._logger.log(ConstStrings.LOG_NAME_INFO,
                                 LoggerMessages.SHM_RENDER_HANDLER_OPENED.format(self._shm_path))
                return
            else:
                self._logger.log(ConstStrings.LOG_NAME_WARNING,
                                 LoggerMessages.SHM_RENDER_HANDLER_WAITING.format(self._shm_path, i + 1))
                
            if cap is not None:
                try:
                    cap.release()
                except Exception as e:
                    self._logger.log(ConstStrings.LOG_NAME_ERROR,
                                     LoggerMessages.SHM_RENDER_HANDLER_RELEASE_FAILED.format(self._shm_path, str(e)))
                
            self._cap = None
            time.sleep(1)

        self._logger.log(ConstStrings.LOG_NAME_DEBUG,
                         LoggerMessages.SHM_RENDER_HANDLER_OPEN_TIMEOUT.format(self._shm_path, max_wait))
        
        



    def read_frame(self) -> np.ndarray:
        if self._cap is None or not self._cap.isOpened():
            now = time.time()
            if now - self._last_reconnect_attempt >= self._reconnect_cooldown:
                self._last_reconnect_attempt = now
                pipeline = ConstStrings.SHARED_MEMORY_READER_PIPELINE.format(
                    frame_width=self._width,
                    frame_height=self._height,
                    frame_rate=self._frame_rate,
                    shared_memory_path=self._shm_path
                )
                cap = self._try_open_cap(pipeline, timeout=4.0)
                if cap is not None and cap.isOpened():
                    self._cap = cap
                    self._logger.log(ConstStrings.LOG_NAME_INFO,
                                     f"SHM reconnected for {self._shm_path}")
                else:
                    if cap is not None:
                        cap.release()
                    self._cap = None
            if self._cap is None:
                return np.zeros((self._height, self._width, 3), dtype=np.uint8)

        ret, frame = self._cap.read()
        if not ret:
            self._cap.release()
            self._cap = None  # Reset so reconnect is attempted next call
            return np.zeros((self._height, self._width, 3), dtype=np.uint8)

        return frame
        

    def release(self) -> None:
        if self._cap is not None:
            self._cap.release()
            self._cap = None