# Real-Time Motion Detection System

A containerized, microservice-based system that reads video input, performs real-time motion detection using OpenCV + GStreamer, and displays the annotated stream in a Flutter GUI — all orchestrated with Docker Compose and connected through Kafka and ZMQ messaging.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Services](#services)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Motion Detection Details](#motion-detection-details)

---

## Overview

This project was built as a final assignment focused on real-world distributed system design. The goal is to process a video file (or RTSP stream) in real time, detect motion in each frame using computer vision techniques, and display the results live in a GUI application.

Key highlights:

- **Microservice architecture** — each concern (video ingest, algorithm, UI) lives in its own Docker container
- **GStreamer shared memory transport** — frames are passed between containers via `/dev/shm` UNIX sockets using GStreamer `shmsink` / `shmsrc`, avoiding serialisation overhead
- **MOG2 background subtraction** — motion is detected with OpenCV's `BackgroundSubtractorMOG2`, enhanced with Gaussian blur, morphological open/close, contour filtering, and bounding-box merging
- **Native-FPS pacing** — the video manager reads the source file's native frame rate and sleeps accordingly so playback is always real-time
- **Kafka event bus** — a Kafka broker (via Zookeeper) is available for streaming logs and events between services
- **ZMQ** — used for high-speed task dispatching to the algorithm service
- **Flutter GUI** — a Linux desktop Flutter app renders the processed JPEG frames at the correct aspect ratio in real time

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Docker Compose (host network)               │
│                                                                     │
│  ┌──────────────────┐   GStreamer shmsink      ┌─────────────────┐  │
│  │  video_manager   │ ──────/dev/shm/cam{id}──▶│   algorithm     │  │
│  │                  │                          │                 │  │
│  │  • Read MP4/RTSP │                          │  • MOG2 detect  │  │
│  │  • Resize frames │                          │  • Draw boxes   │  │
│  │  • Pace at       │                          │  • Write JPEG   │  │
│  │    native FPS    │                          │    → /app/logs/ │  │
│  └──────────────────┘                          └────────┬────────┘  │
│                                                         │           │
│              Kafka / ZMQ events                         │ JPEG poll │
│  ┌───────────┐  ┌──────────┐                  ┌────────▼────────┐   │
│  │ Zookeeper │  │  Kafka   │                  │      gui        │   │
│  │  :2181    │  │  :9092   │                  │  Flutter Linux  │   │
│  └───────────┘  └──────────┘                  │  display widget │   │
│                                               └─────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Services

### `video_manager`
- Reads video files (MP4) or RTSP streams using OpenCV
- Detects the source's native frame rate and sleeps precisely between writes so playback is real-time
- Resizes frames to the configured resolution and pushes them into a GStreamer `shmsink` pipeline
- Loops video files indefinitely (seeks back to frame 0 at EOF)

### `algorithm`
- Connects to the shared-memory socket via GStreamer `shmsrc`
- Runs MOG2 background subtraction with the following enhancements:
  - Gaussian blur pre-processing
  - Morphological open (erode → dilate) to remove noise
  - Morphological close (dilate → erode) to fill holes
  - Contour aspect-ratio filtering
  - Bounding-box merging with configurable margin
- Draws green bounding boxes and an FPS overlay on each processed frame
- Writes the annotated frame as a JPEG to `/app/logs/stream_{id}.jpg`
- Skips duplicate frames (same buffer re-delivered by shmsrc) to report accurate FPS

### `gui`
- Flutter Linux desktop application
- Polls the shared JPEG path and refreshes the display widget
- Adapts layout for portrait (9:16) and landscape (16:9) streams
- Uses `LayoutBuilder` to fill available viewport height without overflow

### `kafka` + `zookeeper`
- Standard Bitnami Kafka/Zookeeper stack on host network
- Used for event/log streaming between services

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Python 3.10 / 3.11, Dart (Flutter) |
| Computer Vision | OpenCV 4.x |
| Video Transport | GStreamer 1.x (`shmsink` / `shmsrc`) |
| Messaging | Apache Kafka, ZeroMQ (ZMQ) |
| Containerisation | Docker, Docker Compose |
| GUI | Flutter (Linux desktop) |
| Base Image | Ubuntu 22.04 |

---

## Project Structure

```
.
├── algorithm/                  # Motion detection microservice
│   ├── Dockerfile
│   ├── requirements.txt
│   └── src/
│       ├── globals/            # Constants, enums, utilities
│       ├── infrastructure/     # Factories, interfaces, logger, config
│       └── model/
│           ├── algorithms/     # MotionDetection class
│           ├── handlers/       # SHM reader handler
│           └── managers/       # AlgorithmManager (processing loop)
│
├── video_manager/              # Video ingest microservice
│   ├── Dockerfile
│   ├── requirements.txt
│   └── src/
│       ├── globals/
│       ├── infrastructure/
│       └── model/
│           ├── handlers/       # VideoHandler (capture + GStreamer write)
│           └── managers/       # VideoManager (frame loop)
│
├── gui/                        # Flutter Linux GUI
│   ├── Dockerfile
│   ├── nginx.conf
│   └── lib/
│       ├── bloc/               # State management (BLoC pattern)
│       ├── domain/
│       ├── infrastructure/
│       └── view/
│           ├── pages/
│           └── widgets/        # VideoStreamWidget, StreamsGridView
│
├── docker_compose/
│   ├── docker-compose.yml
│   └── configuration.xml       # Shared algorithm config
│
├── videos/                     # Place source video files here
├── logs/                       # Shared log / JPEG output directory
└── records/                    # Recording output
```

---

## Getting Started

### Prerequisites

- Docker & Docker Compose v2
- An X11 display (the GUI and optional `imshow` windows use `$DISPLAY`)
- Video files placed in `videos/`

### Run

```bash
# Allow Docker containers to access the local X server
xhost +local:root

# Build and start all services
cd docker_compose
sudo -E docker compose up --build
```

To stop and clean up volumes:

```bash
sudo docker compose down -v
```

> **Note:** On restarts, `/dev/shm/cam*` socket files are removed automatically by the video_manager before it creates new ones.

---

## Configuration

Algorithm parameters are set in `docker_compose/configuration.xml` and passed into the algorithm container.

| Parameter | Default | Description |
|---|---|---|
| `min_area` | 1000 | Minimum contour area to count as motion |
| `threshold` | 32 | MOG2 `varThreshold` |
| `history` | 300 | MOG2 background history length |
| `dilate_iter` | 2 | Morphological close iterations |
| `erode_iter` | 1 | Morphological open iterations |
| `blur_kernel` | 5 | Gaussian blur kernel size (0 = disabled) |
| `merge_boxes` | true | Merge nearby bounding boxes |
| `merge_margin` | 30 | Pixel margin for box merging |
| `min_aspect_ratio` | 0.1 | Filter out extreme contours |
| `max_aspect_ratio` | 10.0 | Filter out extreme contours |

Video resolution defaults (`1280 × 720`) and Kafka connection settings can be adjusted in the respective `consts.py` files.

---

## Motion Detection Details

The algorithm uses **MOG2** (Mixture of Gaussians background subtractor) and applies a multi-stage pipeline per frame:

```
Raw frame
   │
   ▼
Gaussian Blur  (reduces sensor noise)
   │
   ▼
MOG2 Background Subtraction  (produces foreground mask)
   │
   ▼
Threshold @ 244  (binary mask)
   │
   ▼
MORPH_OPEN  (erode → dilate, removes small noise blobs)
   │
   ▼
MORPH_CLOSE  (dilate → erode, fills gaps inside objects)
   │
   ▼
Find Contours → filter by area & aspect ratio
   │
   ▼
Merge overlapping / nearby boxes
   │
   ▼
Draw green bounding boxes + FPS overlay
   │
   ▼
Write JPEG  →  GUI polls and displays
```

