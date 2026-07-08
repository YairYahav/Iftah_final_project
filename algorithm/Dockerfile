# change the image depending on your OS/ARCH
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Python and GStreamer with OpenCV (system build has GStreamer support)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    gstreamer1.0-tools \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    libgstreamer1.0-0 \
    libgstreamer-plugins-base1.0-0 \
    python3-opencv \
    && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/bin/python3 /usr/bin/python

WORKDIR /app

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt
# add install if needed 

COPY . .

CMD [ "python", "src/main.py" ]