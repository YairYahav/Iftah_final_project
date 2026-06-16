import cv2  # type: ignore
import numpy as np

from typing import Any, Dict, List, Optional

from globals.consts.const_strings import ConstStrings
from globals.consts.consts import Consts
from infrastructure.factories.logger_factory import LoggerFactory
from globals.consts.logger_messages import LoggerMessages


class MotionDetection:
    def __init__(self) -> None:
        self._logger = LoggerFactory.get_logger_manager()
        self._motion_bg_subtractor: Optional[cv2.BackgroundSubtractor] = None
        self._kernel: Optional[np.ndarray] = None
        self._init_motion_detection()
        self._min_counter_area = Consts.MOTION_MIN_AREA
        self._threshold: int = Consts.MOTION_BG_VAR_THRESHOLD
        self._dilate_iter: int = Consts.MOTION_DILATE_ITER
        self._erode_iter: int = 0
        self._history: int = Consts.MOTION_BG_HISTORY
        self._detect_shadows: bool = Consts.MOTION_DETECT_SHADOWS
        self._draw_bounding_boxes: bool = True
        self._draw_mask: bool = False
        self._mask_rect: Optional[tuple[int, int, int, int]] = None
        self._frame_index: int = 0


    def setup(self, config: Dict[str, Any]) -> None:
        self._min_counter_area = int(config.get(ConstStrings.MOTION_MIN_AREA, self._min_counter_area))
        self._threshold = int(config.get(ConstStrings.MOTION_BG_VAR_THRESHOLD, self._threshold))
        self._dilate_iter = int(config.get(ConstStrings.MOTION_DILATE_ITER, self._dilate_iter))
        self._erode_iter = int(config.get(ConstStrings.MOTION_ERODE_ITER, self._erode_iter))
        self._history = int(config.get(ConstStrings.MOTION_BG_HISTORY, self._history))
        self._detect_shadows = bool(config.get(ConstStrings.MOTION_DETECT_SHADOWS, self._detect_shadows))
        self._draw_bounding_boxes = bool(config.get(ConstStrings.MOTION_DRAW_BOUNDING_BOXES, self._draw_bounding_boxes))
        self._draw_mask = bool(config.get(ConstStrings.MOTION_DRAW_MASK, self._draw_mask))
        
        mask_rect = config.get(ConstStrings.MOTION_MASK_RECT, None)
        if isinstance(mask_rect, (list, tuple)) and len(mask_rect) == 4:
            self._mask_rect = (int(mask_rect[0]), int(mask_rect[1]), int(mask_rect[2]), int(mask_rect[3]))

        self._motion_bg_subtractor = cv2.createBackgroundSubtractorMOG2(
            history=self._history,
            varThreshold=self._threshold,
            detectShadows=self._detect_shadows
            )
        self._kernel = np.ones((Consts.MOTION_KERNEL_SIZE, Consts.MOTION_KERNEL_SIZE), np.uint8)

        try: 
            self._logger.log(ConstStrings.LOG_NAME_DEBUG, f"MotionDetection setup with config: {config}")
        except Exception as e:
            self._logger.log(ConstStrings.LOG_NAME_ERROR, f"Error logging MotionDetection setup: {e}")


    def process_frame(self, frame: Any) -> Any:
        if self._motion_bg_subtractor is None or self._kernel is None:
            self._logger.log(ConstStrings.LOG_NAME_ERROR, "MotionDetection not properly initialized.")
            return frame

        fg_mask = self._motion_bg_subtractor.apply(frame)

        if self._mask_rect is not None:
            x, y, w, h = self._mask_rect
            cv2.rectangle(fg_mask, (x, y), (x + w, y + h), 0, -1)

        if self._mask_rect is not None:
            x, y, w, h = self._mask_rect
            if self._draw_mask:
                overlay = frame.copy()
                cv2.rectangle(overlay, (x, y), (x + w, y + h), (0, 0, 255), 2)
                frame = cv2.addWeighted(frame, 1.0, overlay, 0.5, 0)
        _, fg_mask = cv2.threshold(fg_mask, 244, 255, cv2.THRESH_BINARY)

        if self._erode_iter > 0:
            fg_mask = cv2.erode(fg_mask, self._kernel, iterations=self._erode_iter)

        kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (Consts.MOTION_KERNEL_SIZE, Consts.MOTION_KERNEL_SIZE))
        fg_mask = cv2.dilate(fg_mask, kernel, iterations=self._dilate_iter)

        contours, _ = cv2.findContours(fg_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        regions_of_motion = 0

        for contour in contours:
            area = cv2.contourArea(contour)
            if area < self._min_counter_area:
                continue
            x, y, w, h = cv2.boundingRect(contour)
            regions_of_motion += 1
            if self._draw_bounding_boxes:
                cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)

        self._frame_index += 1
        if regions_of_motion > 0 and (self._frame_index % max(1, Consts.DEFAULT_FRAME_RATE) == 0):
            try:
                self._logger.log(ConstStrings.LOG_NAME_INFO, f"Motion detected in frame {self._frame_index} with {regions_of_motion} regions.")
            except Exception as e:
                self._logger.log(ConstStrings.LOG_NAME_ERROR, f"Error logging motion detection: {e}")

        return frame
    

    def release(self) -> None:
        self._logger.log(ConstStrings.LOG_NAME_DEBUG, "Releasing MotionDetection resources.")
        self._motion_bg_subtractor = None
        self._kernel = None