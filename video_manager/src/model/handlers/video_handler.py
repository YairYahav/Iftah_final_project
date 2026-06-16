import time

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
        self._is_rtsp = self._video_path.startswith("rtsp://")
        

    def read_frame(self) -> None:
        if not self._cap or not self._cap.isOpened():
            
            if self._is_rtsp:
                self._logger.log(ConstStrings.LOG_NAME_DEBUG, 
                                 LoggerMessages.INITIALIZING_RTSP_STREAM.format(self._video_id, self._video_path))
                try: 
                    self._init_capture()
                except Exception as e:
                    self._logger.log(ConstStrings.LOG_NAME_ERROR, 
                                     LoggerMessages.FAILED_TO_INITIALIZE_RTSP_STREAM.format(self._video_id, str(e)))
                    return None
            else:
                return None
            
        if self._is_rtsp:
            self._cap.grab()
            ret, frame = self._cap.retrieve()
        else:
            ret, frame = self._cap.read()

        if not ret and self._is_rtsp:
            self._logger.log(ConstStrings.LOG_NAME_WARNING, 
                             LoggerMessages.VIDEO_FRAME_READ_FAILED.format(self._video_id))
            if self._cap:
                self._cap.release()
            return None
        return frame
    

    def write_frame(self, frame) -> None:
        if frame is None:
            self._logger.log(ConstStrings.LOG_NAME_WARNING, 
                             LoggerMessages.EMPTY_FRAME_WRITE_ATTEMPT.format(self._video_id))
            return
        
        resized_frame = cv2.resize(frame, (self._frame_width, self._frame_height))

        if self._writer and self._writer.isOpened():
            self._writer.write(resized_frame)

            if not self._is_rtsp:
                self._logger.log(ConstStrings.LOG_NAME_DEBUG, 
                                 LoggerMessages.FRAME_WRITTEN.format(self._video_id))
                time.sleep(1.0 / max(float(self._frame_rate), 1))
        else:
            self._logger.log(ConstStrings.LOG_NAME_WARNING, 
                             LoggerMessages.VIDEO_WRITER_NOT_INITIALIZED.format(self._video_id))
    

    def start(self) -> None:
        self._init_capture()
        self._init_write()
    

    def release(self) -> None:
        if self._cap and self._cap.isOpened():
            self._cap.release()
            self._logger.log(ConstStrings.LOG_NAME_DEBUG, 
                             LoggerMessages.VIDEO_CAPTURE_RELEASED.format(self._video_id))

        if self._writer and self._writer.isOpened():
            self._writer.release()
            self._logger.log(ConstStrings.LOG_NAME_DEBUG, 
                             LoggerMessages.VIDEO_WRITER_RELEASED.format(self._video_id))
    

    def _init_capture(self) -> None:
        if self._cap: 
            self._cap.release()

        self._logger.log(ConstStrings.LOG_NAME_DEBUG, 
                         LoggerMessages.INITIALIZING_VIDEO_CAPTURE.format(self._video_id, self._video_path))

        if self._is_rtsp:
            max_retries = 10
            retry_count = 0
            retry_delay = 5

            # Try to connect to the RTSP stream with retries
            for attempt in range(1, max_retries+1):
                self._logger.log(ConstStrings.LOG_NAME_DEBUG, 
                                 f"attempting to connect to RTSP stream {self._video_path} (attempt {attempt}/{max_retries})")
                
                # Set OpenCV FFMPEG options to optimize RTSP streaming BEFORE opening the stream
                os.environ['OPENCV_FFMPEG_CAPTURE_OPTIONS'] = 'rtsp_transport;tcp | ffmpeg_flags;nobuffer'
                
                
                self._cap = cv2.VideoCapture(self._video_path, cv2.CAP_FFMPEG)

                # Set buffer size to 2 frames to reduce latency
                self._cap.set(cv2.CAP_PROP_BUFFERSIZE, 2)
                
                if self._cap.isOpened():
                    self._logger.log(ConstStrings.LOG_NAME_DEBUG, 
                                     f"successfully connected to RTSP stream {self._video_path} on attempt {attempt}/{max_retries}")
                    break
                else:
                    self._logger.log(ConstStrings.LOG_NAME_WARNING, 
                                     f"failed to connect to RTSP stream {self._video_path} on attempt {attempt}/{max_retries}, retrying in {retry_delay} seconds...")
                    time.sleep(retry_delay)

            if self._cap.isOpened():
                self._logger.log(ConstStrings.LOG_NAME_DEBUG, 
                                 f"cannot connect to RTSP stream {self._video_path} after {max_retries} attempts, giving up.")
                raise ValueError(f"Cannot connect to RTSP stream {self._video_path} after {max_retries} attempts.")
        else:
            self._cap = cv2.VideoCapture(self._video_path)

            if not self._cap.isOpened():
                self._logger.log(ConstStrings.LOG_NAME_ERROR, 
                                 LoggerMessages.FAILED_TO_OPEN_VIDEO.format(self._video_id, self._video_path))
                
            self._logger.log(ConstStrings.LOG_NAME_DEBUG, 
                             LoggerMessages.VIDEO_OPENED.format(self._video_id, self._video_path))
            

    def _init_write(self) -> None:
        videos_pipeline = self._construct_pipeline()

        self._logger.log(ConstStrings.LOG_NAME_DEBUG, 
                         f"GStreamer pipeline for video {self._video_id}: {videos_pipeline}")
        
        frame_size = (self._frame_width, self._frame_height)

        self._writer = cv2.VideoWriter(videos_pipeline, cv2.CAP_GSTREAMER, 0, self._frame_rate, frame_size, True)

        if not self._writer.isOpened():
            self._logger.log(ConstStrings.LOG_NAME_ERROR, 
                             LoggerMessages.FAILED_TO_INITIALIZE_VIDEO_WRITER.format(self._video_id))
            shm_path = f"/dev/shm/cam{self._video_id}"

            self._writer = cv2.VideoWriter(shm_path, cv2.VideoWriter_fourcc(*'I420'), self._frame_rate, frame_size, True)

            if not self._writer.isOpened():
                self._logger.log(ConstStrings.LOG_NAME_ERROR, 
                                 f"Cannot open shared memory writer for video {self._video_id} at {shm_path}", level=ConstStrings.LOG_NAME_ERROR)
                raise ValueError(f"Cannot open shared memory writer for video {self._video_id} at {shm_path}")
            else:
                self._logger.log(ConstStrings.LOG_NAME_DEBUG, 
                                 f"Successfully opened shared memory writer for video {self._video_id} at {shm_path}")


    def _construct_pipeline(self) -> str:
        shared_memory_path = ConstStrings.SHARED_MEMORY_CAM_PATH.format(camera_id=self._video_id)

        if self._is_rtsp:
            pipeline = ConstStrings.SHARED_MEMORY_PIPELINE.format(
                frame_width=self._frame_width,
                frame_height=self._frame_height,
                frame_rate=self._frame_rate,
                scaled_width=self._frame_width,
                scaled_height=self._frame_height,
                shared_memory_path=shared_memory_path
            )
        else:
            pipeline = ConstStrings.SHARED_MEMORY_PIPELINE.format(
                frame_width=self._frame_width,
                frame_height=self._frame_height,
                frame_rate=self._frame_rate,
                scaled_width=self._frame_width,
                scaled_height=self._frame_height,
                shared_memory_path=shared_memory_path
            )
        return pipeline