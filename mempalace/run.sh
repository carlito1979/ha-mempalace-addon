#!/usr/bin/with-contenv bashio

PALACE_PATH="/data/palace"
IDENTITY_FILE="/data/identity.txt"
MEMPALACE_HOME="/root/.mempalace"

bashio::log.info "MemPalace MCP Server starting..."

# --- Read configuration and write identity file ---
bashio::log.info "Writing identity file from configuration..."
mkdir -p "${MEMPALACE_HOME}"

cat > "${IDENTITY_FILE}" << EOF
Name: $(bashio::config 'identity_name')
Role: $(bashio::config 'identity_role')
Projects: $(bashio::config 'identity_projects')
EOF

cp "${IDENTITY_FILE}" "${MEMPALACE_HOME}/identity.txt"

# --- Initialise palace on first run ---
mkdir -p "${PALACE_PATH}"

if [ ! -f "${PALACE_PATH}/.ha_initialized" ]; then
    bashio::log.info "First run detected — initialising MemPalace palace..."
    echo "" | mempalace init "${PALACE_PATH}" || true
    touch "${PALACE_PATH}/.ha_initialized"
    bashio::log.info "Palace initialised at ${PALACE_PATH}"
else
    bashio::log.info "Existing palace found at ${PALACE_PATH} — skipping init"
fi

# --- Start ttyd web terminal for HA ingress ---
bashio::log.info "Starting ttyd web terminal on port 7681..."
ttyd -p 7681 -W bash &

# --- Start mcp-proxy in the foreground ---
bashio::log.info "Launching MCP server on port 8765..."
exec mcp-proxy --host 0.0.0.0 --port 8765 -- python3 -m mempalace.mcp_server
