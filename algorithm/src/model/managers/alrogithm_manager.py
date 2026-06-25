import time
import threading
import cv2 # type: ignore
import os
import numpy as np
from typing import Any, Dict, List, Optional
from queue import Full, Queue, Empty

from infrastructure.interfaces.ialgorithm_manager import IAlgorithmManager
from infrastructure.interfaces.iconfig_manager import IConfigManager
from infrastructure.interfaces.ikafka_manager import IKafkaManager
from globals.consts.const_strings import ConstStrings
from globals.consts.consts import Consts
from globals.consts.logger_messages import LoggerMessages
from infrastructure.factories.logger_factory import LoggerFactory
from infrastructure.factories.handler_factory import HandlerFactory
from infrastructure.factories.algorithm_factory import AlgorithmFactory


class AlgorithmManager(IAlgorithmManager):
    def __init__(self, video_config: List[Dict]) -> None:
        self._video_config = video_config
        self._video_count = len(video_config)
        self._readers = []
        self._algorithms = []
        self._threads: List[threading.Thread] = []
        self._running = True
        self._logger = LoggerFactory.get_logger_manager()
        self._logger.log(ConstStrings.LOG_NAME_DEBUG, LoggerMessages.MOTION_STARTING)
        self._enable_imshow = os.environ.get(ConstStrings.ENABLE_IMSHOW_ENVIRONMENT, 'False').lower() == 'true'
        self._display_windows = os.environ.get(ConstStrings.DISPLAY_ENVIRONMENT, "")
        
        if self._enable_imshow and not self._display_windows:
            self._logger.log(
                ConstStrings.LOG_NAME_DEBUG, 
                "Warning: ENABLE_IMSHOW is set to True but DISPLAY environment variable is not set. Imshow may not work properly."
            )
            self._enable_imshow = False

        # Initialize frame queues for each video stream
        self._frame_queues: List[Queue] = [Queue(maxsize=3) for _ in range(self._video_count)]

        # Initialize algorithms for each video stream
        self._initialize_algorithms()
        self._init_readers()
        

    def start_algorithm(self) -> None:
        # Start processing threads for each video stream
        for idx in range(self._video_count):
            thread = threading.Thread(target=self._process_video_stream, args=(idx,), daemon=True)
            thread.start()
            self._threads.append(thread)

        self._logger.log(ConstStrings.LOG_NAME_DEBUG, f"Started {self._video_count} video processing threads.")

        # Main loop to keep the manager running
        try:
            while self._running:
                if self._enable_imshow:
                    self._render_frames()
                else:
                    time.sleep(1)

        except KeyboardInterrupt:
            self.stop_algorithm()
        finally:
            if self._enable_imshow:
                cv2.destroyAllWindows()


    def stop_algorithm(self) -> None:
        self._running = False

        for reader in self._readers:
            reader.release()

        for algorithm in getattr(self, "_algorithms", []):
            try:
                algorithm.stop()
            except Exception as e:
                self._logger.log(ConstStrings.LOG_NAME_DEBUG, f"Error stopping algorithm: {e}")

        for thread in self._threads:
            thread.join()
        self._logger.log(ConstStrings.LOG_NAME_DEBUG, "Stopped all video processing threads.")


    def _init_readers(self) -> None:
        # Initialize video readers for each video stream
        for config in self._video_config:
            video_id = config.get("video_id")
            width = config.get("width", Consts.DEFAULT_WIDTH)
            height = config.get("height", Consts.DEFAULT_HEIGHT)
            frame_rate = config.get("frame_rate", Consts.DEFAULT_FRAME_RATE)

            reader = HandlerFactory.create_shm_handler(video_id, width, height, frame_rate)
            self._readers.append(reader)
            reader.start()


    def _initialize_algorithms(self) -> None:
        for config in self._video_config:
            algorithm_type = config.get("algorithm", "motion_detection")
            algorithm_config = config.get("algorithm_config", {})

            try:
                algorithm = AlgorithmFactory.create_algorithm(algorithm_type, algorithm_config)
                self._algorithms.append(algorithm)
            except Exception as e:
                self._logger.log(ConstStrings.LOG_NAME_DEBUG, f"Error initializing algorithm for video {config.get('video_id')}: {e}")
                self._algorithms.append(None)  # Append None to maintain index alignment

            
    def _process_video_stream(self, idx: int) -> None:
        reader = self._readers[idx]
        algorithm = self._algorithms[idx]
        queue = self._frame_queues[idx]

        frame_count = 0
        consecutive_none_frames = 0
        max_none_frames = 10  # Threshold for consecutive None frames before logging an error

        while self._running:
            try:
                frame = reader.read()
                if frame is None:
                    consecutive_none_frames += 1
                    if consecutive_none_frames >= max_none_frames:
                        self._logger.log(ConstStrings.LOG_NAME_DEBUG, f"Video stream {idx} has {consecutive_none_frames} consecutive None frames.")
                        consecutive_none_frames = 0
                    time.sleep(0.01)
                    continue

                consecutive_none_frames = 0  # Reset the counter if a valid frame is read

                if algorithm is not None:
                    processed_frame = algorithm.process(frame)
                else:
                    processed_frame = frame

                if frame_count % 30 == 0:  # Log every 30 frames
                    self._logger.log(
                        ConstStrings.LOG_NAME_DEBUG, 
                        f"Video {idx}: Processed frame {frame_count} with algorithm {algorithm.__class__.__name__ if algorithm else 'None'}"
                        )
                frame_count += 1

                try:
                    output_path = f"./output/video_{idx}_frame_{frame_count}.jpg"
                    cv2.imwrite(output_path, processed_frame)
                    self._logger.log(ConstStrings.LOG_NAME_DEBUG, f"Saved processed frame {frame_count} for video {idx} to {output_path}")
                except Exception as e:
                    self._logger.log(ConstStrings.LOG_NAME_DEBUG, f"Error saving processed frame {frame_count} for video {idx}: {e}")

                # Put the processed frame in the queue for rendering
                if self._enable_imshow:
                    try:
                        queue.put(processed_frame, timeout=1)
                    except Full:
                        self._logger.log(ConstStrings.LOG_NAME_DEBUG, f"Frame queue for video {idx} is full. Dropping frame.")
            except Exception as e:
                self._logger.log(ConstStrings.LOG_NAME_DEBUG, f"Error processing video stream {idx}: {e}")


    def _render_frames(self) -> None:
        # Render frames from each video stream using OpenCV's imshow
        for idx in range(self._video_count):
            queue = self._frame_queues[idx]
            frame = None

            # Try to get the latest frame from the queue without blocking
            try:
                while True:
                    frame = queue.get_nowait()
            except Empty:
                frame = None

            if frame is not None:
                try: 
                    cv2.imshow(f"Video Stream {idx}", frame)
                    cv2.waitKey(1)
                except Exception as e:
                    self._logger.log(ConstStrings.LOG_NAME_DEBUG, f"Error displaying frame for video {idx}: {e}")
                    self._enable_imshow = False  # Disable imshow if there's an error to prevent further issues
                    cv2.destroyAllWindows()
                    break

            if self._enable_imshow and frame is not None:
                cv2.waitKey(max(1, int(1000 / max(1, Consts.DEFAULT_FRAME_RATE))))  # Add a small delay to allow the window to update
