import time
import threading
import os
import logging
from typing import Any, Dict, List, Optional
from xml.sax import handler

from algorithm.src.infrastructure.factories.handler_factory import HandlerFactory
from infrastructure.interfaces.managers.ivideo_manager import IVideoManager
from infrastructure.interfaces.iconfig_manager import IConfigManager
from infrastructure.interfaces.ikafka_manager import IKafkaManager
from globals.consts.const_strings import ConstStrings
from globals.consts.consts import Consts
from globals.consts.logger_messages import LoggerMessages
from infrastructure.factories.logger_factory import LoggerFactory
from video_manager.src.model.handlers.video_handler import VideoHandler


class VideoManager(IVideoManager):
    def __init__(self, video_config: List[Dict]) -> None:
        super().__init__()
        self._video_config = video_config
        self._handlers = []
        self._videos_count = len(video_config)
        self._process_video_threads = []
        self._running = True
        self._logger = LoggerFactory.get_logger_manager()
        
        self._remove_memory_files()
        self._init_video_handler()


    def start(self) -> None:
        for i in range(self._videos_count):
            thread = threading.Thread(target=self._process_video_threads, args=(i,))
            self._process_video_threads.append(thread)
            thread.start()

        self._logger.log(ConstStrings.LOG_NAME_DEBUG, 
                         LoggerMessages.VIDEO_STREAMS_STARTED.format(self._videos_count))
        
        try:
            while self._running:
                time.sleep(1)

        except KeyboardInterrupt:
            self.stop


    def stop(self) -> None:
        self._running = False

        for h in self._handlers:
            h.release()

        for t in self._process_video_threads:
            t.join()

        self._logger.log(ConstStrings.LOG_NAME_DEBUG, 
                         LoggerMessages.VIDEO_MANAGER_STOPPED)

    def _init_video_handler(self) -> None:
        for v in self._video_config:
            video_id = v.get('video_id')
            video_path = v.get('video_path')


            video_handler = HandlerFactory.create_video_handler(video_id, video_path)
            self._handlers.append(video_handler)
            video_handler.start()

    def _process_frames(self, video_index: int) -> None:
        handler = self._handlers[video_index]

        while self._running:
            frame = handler.read_frame()

            if frame is not None:
                handler.write_frame(frame)
            else:
                self._logger.log(ConstStrings.LOG_NAME_WARNING, 
                                 LoggerMessages.VIDEO_FRAME_READ_FAILED.format(video_index))
                break

    def _remove_memory_files(self) -> None:
        file_prefix = ["cam", "shmpipe"]
        shm_path = ConstStrings.SHARED_MEMORY_PATH

        if os.path.exists(shm_path):
            for filename in os.listdir(shm_path):
                if any(filename.startswith(prefix) for prefix in file_prefix):
                    file_path = os.path.join(shm_path, filename)
                    try:
                        os.remove(file_path)
                        self._logger.log(ConstStrings.LOG_NAME_DEBUG, 
                                         LoggerMessages.REMOVED_MEMORY_FILE.format(file_path))
                    except Exception as e:
                        self._logger.log(ConstStrings.LOG_NAME_ERROR, 
                                         LoggerMessages.FAILED_TO_REMOVE_MEMORY_FILE.format(file_path, str(e)))
                        
