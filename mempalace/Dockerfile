ARG BUILD_FROM=ghcr.io/home-assistant/base:latest
FROM $BUILD_FROM

LABEL \
  io.hass.version="1.0.0" \
  io.hass.type="addon" \
  io.hass.arch="aarch64|amd64"

RUN apk add --no-cache \
    python3 \
    py3-pip \
    nodejs \
    npm \
    curl \
    bash

RUN npm install -g supergateway

RUN pip3 install --no-cache-dir --break-system-packages mempalace

COPY run.sh /
RUN chmod a+x /run.sh

CMD ["/run.sh"]
