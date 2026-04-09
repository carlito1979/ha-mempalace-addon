ARG BUILD_FROM=ghcr.io/home-assistant/base:latest
FROM $BUILD_FROM

LABEL \
  io.hass.version="1.0.1" \
  io.hass.type="addon" \
  io.hass.arch="aarch64|amd64"

RUN apk add --no-cache \
    python3 \
    py3-pip \
    nodejs \
    npm \
    curl \
    bash \
    gcc \
    g++ \
    musl-dev \
    rust \
    cargo

RUN npm install -g supergateway

RUN pip3 install --no-cache-dir --break-system-packages \
    "chromadb==0.5.5" \
    "mempalace"

COPY run.sh /
RUN chmod a+x /run.sh

CMD ["/run.sh"]
