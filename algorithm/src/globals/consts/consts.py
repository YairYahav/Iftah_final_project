class Consts:
    SEND_MESSAGE_DURATION = 1
    ZMQ_SERVER_LOOP_DURATION = 0.01
    ZMQ_SUB_POLL_TIMEOUT = 1000

    ALGORITHM_VIDEO_WIDTH = 1280
    ALGORITHM_VIDEO_HEIGHT = 720
    ALGORITHM_VIDEO_FRAME_RATE = 30

    # Default video dimensions (must match video_manager GStreamer pipeline output)
    DEFAULT_WIDTH = 1280
    DEFAULT_HEIGHT = 720
    DEFAULT_FRAME_RATE = 30

    # SHM reader open timeout in seconds
    SHM_READER_OPEN_TIMEOUT = 5
    
    # Motion detection parameters
    MOTION_BG_HISTORY = 300
    MOTION_BG_VAR_THRESHOLD = 32
    MOTION_DETECT_SHADOWS = True
    MOTION_MIN_AREA = 1000
    MOTION_DILATE_ITER = 2
    MOTION_KERNEL_SIZE = 3