import time
import threading
import os
import logging
from typing import Any, Dict, List, Optional

from infrastructure.interfaces.managers.ivideo_manager import IVideoManager
from infrastructure.interfaces.iconfig_manager import IConfigManager
from infrastructure.interfaces.ikafka_manager import IKafkaManager
from globals.consts.const_strings import ConstStrings
from globals.consts.consts import Consts
from globals.consts.logger_messages import LoggerMessages
from infrastructure.factories.logger_factory import LoggerFactory


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
        pass

    def _init_threading(self) -> None:
        self._message_produce_threading = threading.Thread(
            target=self._produce_kafka_message
        )
        self._message_produce_threading.start()

    def _init_consumers(self) -> None:
        self._kafka_manager.start_consuming(
            self._example_topic_consumer, self._print_consumer)

    def _produce_kafka_message(self) -> None:
        while (True):
            time.sleep(Consts.SEND_MESSAGE_DURATION)
            self._kafka_manager.send_message(
                ConstStrings.EXAMPLE_TOPIC, ConstStrings.EXAMPLE_MESSAGE)

    def _print_consumer(self, msg: str) -> None:
        self._logger.log(ConstStrings.LOG_NAME_DEBUG,
                         LoggerMessages.EXAMPLE_PRINT_CONSUMER_MSG.format(str(msg)))
