FROM ghcr.io/home-assistant/amd64-base-debian:latest

LABEL \
  io.hass.version="2.0.2" \
  io.hass.type="addon" \
  io.hass.arch="amd64"

ENV DEBIAN_FRONTEND=noninteractive
ENV ANONYMIZED_TELEMETRY=false
ENV CHROMA_TELEMETRY=false

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-dev \
    curl \
    gcc \
    g++ \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64 \
    -o /usr/local/bin/ttyd && chmod +x /usr/local/bin/ttyd

RUN pip3 install --no-cache-dir --break-system-packages \
    "chromadb>=0.5.5,<0.6.0" \
    "mempalace" \
    "mcp-proxy"

COPY run.sh /
RUN chmod a+x /run.sh

CMD ["/run.sh"]
