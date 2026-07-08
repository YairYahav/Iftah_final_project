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
        self._blur_kernel: int = 5
        self._merge_boxes: bool = True
        self._merge_margin: int = 30
        self._min_aspect_ratio: float = 0.1
        self._max_aspect_ratio: float = 10.0


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

        self._blur_kernel = int(config.get(ConstStrings.MOTION_BLUR_KERNEL, self._blur_kernel))
        # Blur kernel must be odd and positive; 0 disables blur
        if self._blur_kernel > 0 and self._blur_kernel % 2 == 0:
            self._blur_kernel += 1
        self._merge_boxes = bool(config.get(ConstStrings.MOTION_MERGE_BOXES, self._merge_boxes))
        self._merge_margin = int(config.get(ConstStrings.MOTION_MERGE_MARGIN, self._merge_margin))
        self._min_aspect_ratio = float(config.get(ConstStrings.MOTION_MIN_ASPECT_RATIO, self._min_aspect_ratio))
        self._max_aspect_ratio = float(config.get(ConstStrings.MOTION_MAX_ASPECT_RATIO, self._max_aspect_ratio))

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


    def process(self, frame: Any) -> Any:
        return self.process_frame(frame)

    def process_frame(self, frame: Any) -> Any:
        if self._motion_bg_subtractor is None or self._kernel is None:
            self._logger.log(ConstStrings.LOG_NAME_ERROR, "MotionDetection not properly initialized.")
            return frame

        # 1. Gaussian pre-blur — reduces sensor/compression noise before MOG2 (cuts FP)
        if self._blur_kernel > 0:
            blurred = cv2.GaussianBlur(frame, (self._blur_kernel, self._blur_kernel), 0)
        else:
            blurred = frame

        # 2. Background subtraction on the blurred frame
        fg_mask = self._motion_bg_subtractor.apply(blurred)

        # 3. Zero out the ignored region (mask rect) before thresholding
        if self._mask_rect is not None:
            x, y, w, h = self._mask_rect
            cv2.rectangle(fg_mask, (x, y), (x + w, y + h), 0, -1)
            if self._draw_mask:
                overlay = frame.copy()
                cv2.rectangle(overlay, (x, y), (x + w, y + h), (0, 0, 255), 2)
                frame = cv2.addWeighted(frame, 1.0, overlay, 0.5, 0)

        # 4. Threshold — keep only confident foreground, discard shadow values
        _, fg_mask = cv2.threshold(fg_mask, 244, 255, cv2.THRESH_BINARY)

        # 5. Morphological open (erode→dilate) — removes isolated noise pixels (cuts FP)
        if self._erode_iter > 0:
            fg_mask = cv2.morphologyEx(fg_mask, cv2.MORPH_OPEN, self._kernel, iterations=self._erode_iter)

        # 6. Morphological close (dilate→erode) — fills holes inside real objects (cuts FN)
        if self._dilate_iter > 0:
            fg_mask = cv2.morphologyEx(fg_mask, cv2.MORPH_CLOSE, self._kernel, iterations=self._dilate_iter)

        # 7. Find external contours
        contours, _ = cv2.findContours(fg_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        # 8. Filter contours by area and aspect ratio, collect bounding boxes
        boxes: List[tuple] = []
        for contour in contours:
            area = cv2.contourArea(contour)
            if area < self._min_counter_area:
                continue
            x, y, w, h = cv2.boundingRect(contour)
            aspect = w / h if h > 0 else 0
            if aspect < self._min_aspect_ratio or aspect > self._max_aspect_ratio:
                continue
            boxes.append((x, y, x + w, y + h))

        # 9. Merge nearby/overlapping boxes into single regions (cuts both FP and FN)
        if self._merge_boxes and boxes:
            boxes = self._merge_rects(boxes, self._merge_margin)

        # 10. Draw final bounding boxes on the original frame
        regions_of_motion = len(boxes)
        if self._draw_bounding_boxes:
            for (x1, y1, x2, y2) in boxes:
                cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)

        # Log when motion is found
        self._frame_index += 1
        if regions_of_motion > 0 and (self._frame_index % max(1, Consts.DEFAULT_FRAME_RATE) == 0):
            try:
                self._logger.log(ConstStrings.LOG_NAME_INFO, f"Motion detected in frame {self._frame_index} with {regions_of_motion} regions.")
            except Exception as e:
                self._logger.log(ConstStrings.LOG_NAME_ERROR, f"Error logging motion detection: {e}")

        return frame

    def _merge_rects(self, boxes: List[tuple], margin: int) -> List[tuple]:
        """Merge boxes that overlap or are within `margin` pixels of each other."""
        merged = True
        while merged:
            merged = False
            result: List[tuple] = []
            used = [False] * len(boxes)
            for i in range(len(boxes)):
                if used[i]:
                    continue
                x1, y1, x2, y2 = boxes[i]
                for j in range(i + 1, len(boxes)):
                    if used[j]:
                        continue
                    ax1, ay1, ax2, ay2 = boxes[j]
                    # Expand each box by margin before checking overlap
                    if (x1 - margin < ax2 and x2 + margin > ax1 and
                            y1 - margin < ay2 and y2 + margin > ay1):
                        x1 = min(x1, ax1)
                        y1 = min(y1, ay1)
                        x2 = max(x2, ax2)
                        y2 = max(y2, ay2)
                        used[j] = True
                        merged = True
                result.append((x1, y1, x2, y2))
                used[i] = True
            boxes = result
        return boxes
    

    def release(self) -> None:
        self._logger.log(ConstStrings.LOG_NAME_DEBUG, "Releasing MotionDetection resources.")
        self._motion_bg_subtractor = None
        self._kernel = None