ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base-debian:latest
FROM $BUILD_FROM

LABEL \
  io.hass.version="1.0.2" \
  io.hass.type="addon" \
  io.hass.arch="aarch64|amd64"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-dev \
    nodejs \
    npm \
    curl \
    gcc \
    g++ \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g supergateway

RUN pip3 install --no-cache-dir --break-system-packages \
    "chromadb==0.5.5" \
    "mempalace"

COPY run.sh /
RUN chmod a+x /run.sh

CMD ["/run.sh"]
