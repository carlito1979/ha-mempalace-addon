# MemPalace MCP Server — Home Assistant Add-on

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fcarlito1979%2Fha-mempalace-addon)

Run [MemPalace](https://github.com/MemPalace/mempalace) as a Home Assistant add-on. MemPalace gives Claude a persistent, structured long-term memory with knowledge graph and specialist agents — it remembers who you are, what you're working on, and what it has learned across sessions.

This add-on wraps the MemPalace MCP server (stdio) with [mcp-proxy](https://github.com/nicholasgriffintn/mcp-proxy) to expose it over **HTTP/SSE on port 8765**, making it reachable from Claude.ai, Claude Code, and Cowork. A built-in web terminal is available via the **Open Web UI** button in Home Assistant.

## How it works

```
Claude.ai / Claude Code
    │
    ▼ (HTTPS)
Cloudflare Tunnel (cloudflared HA add-on)
    │
    ▼ (HTTP, port 8765)
mcp-proxy (Python, stdio → SSE/Streamable HTTP bridge)
    │
    ▼ (stdio)
mempalace MCP server (python -m mempalace.mcp_server)
```

- **mcp-proxy** bridges stdio to HTTP, exposing both `/sse` (SSE transport) and `/mcp` (Streamable HTTP transport) endpoints — no Node.js required.
- **ttyd** provides a web terminal on port 7681, accessible via HA ingress ("Open Web UI" button on the add-on page).
- **Palace data** is stored in `/share/mempalace` — persistent across restarts and add-on updates. Included in full HA backups (not per-add-on backups; select the "share" folder explicitly for partial backups).
- An **identity file** is generated from your add-on configuration on every start, so Claude knows who you are from the first message.

## Installation

1. Click the badge above, **or** go to **Settings > Add-ons > Add-on Store** in Home Assistant, open the three-dot menu, choose **Repositories**, and paste:
   ```
   https://github.com/carlito1979/ha-mempalace-addon
   ```
2. Find **MemPalace MCP Server** in the store and click **Install**.
3. Open the **Configuration** tab and fill in your details:

   | Option | Description |
   |--------|-------------|
   | **Your Name** | Your full name, written into the palace identity file |
   | **Role and Organisation** | e.g. "Head of Merchandise Planning, Briscoe Group NZ" |
   | **Active Projects** | Comma-separated list, e.g. "planning-tools (Claude Code, BigQuery), IA implementation" |
   | **Log Level** | Verbosity of add-on logs (default: `info`) |

4. Click **Start**.

On first launch the add-on initialises the palace directory structure. Subsequent restarts skip this step and reuse the existing palace.

## Web Terminal

Click **Open Web UI** on the add-on's Info page to get a shell inside the container. This uses `ttyd` served through HA ingress — no extra ports or authentication needed.

> **Note:** The container filesystem is ephemeral. Software installed or upgraded via the terminal (e.g. `pip install --upgrade mempalace`) will be lost on add-on update, rebuild, or host reboot. Only palace data in `/share/mempalace` persists. To change the installed mempalace version, update the Dockerfile and rebuild the add-on.

## Exposing via Cloudflare Tunnel

The MCP server listens on port 8765 on your Home Assistant host. To make it reachable from Claude.ai or Claude Code you need a public URL — the easiest way is with the [Cloudflared add-on](https://github.com/brenner-tobias/ha-addons):

1. Install the **Cloudflared** add-on from the [brenner-tobias/ha-addons](https://github.com/brenner-tobias/ha-addons) repository.
2. In the Cloudflared configuration, add an additional host entry:

   | Public hostname | Service |
   |-----------------|---------|
   | `mempalace.yourdomain.com` | `http://localhost:8765` |

### Connecting Claude.ai

Add a custom connector in Claude.ai with the URL:
```
https://mempalace.yourdomain.com/sse
```

### Connecting Claude Code

```bash
claude mcp add --transport sse mempalace https://mempalace.yourdomain.com/sse
```

### Security note

The MCP server does not require authentication. For security, use an obscure subdomain and consider adding Cloudflare IP restrictions (Access policies or WAF rules) to limit who can reach the endpoint.

## Features (MemPalace 3.3.0)

- **29 MCP tools** for structured memory management
- **Closet layer** — compact AAAK search index (R@1 boosted 0.42 → 0.58)
- **BM25 hybrid search** — 60% vector similarity + 40% Lucene IDF keyword matching
- **Knowledge graph** with temporal entity-relationship triples (SQLite-backed)
- **Cross-wing tunnels** for explicit project-to-project linking
- **Halls** — content type routing (technical, emotions, family, memory, creative, identity, consciousness)
- **Specialist agent diaries** with day-based drawer upsert
- **Internationalization** — English, French, Korean, Japanese, Spanish, German, Simplified/Traditional Chinese
- **`mempalace migrate`** command for cross-version recovery
- **Security hardened** — palace deletion guardrails, WAL redaction, file-level locking

## Architecture

```
ha-mempalace-addon/
├── repository.yaml                 # HA add-on repository metadata
├── README.md
└── mempalace/
    ├── config.yaml                 # Add-on config (ports, ingress, options, schema)
    ├── Dockerfile                  # Debian + Python + mcp-proxy + ttyd + mempalace
    ├── run.sh                      # Entrypoint: identity, palace init, ttyd, mcp-proxy
    └── translations/
        └── en.yaml                 # UI labels for the Configuration tab
```

| Component | Role |
|-----------|------|
| **ghcr.io/home-assistant/amd64-base-debian** | Debian base image for HA add-ons |
| **mempalace** (pip) | Python MCP server providing structured long-term memory |
| **mcp-proxy** (pip) | Bridges stdio to HTTP/SSE and Streamable HTTP |
| **ttyd** (apt) | Web terminal served via HA ingress |
| **bashio** | HA shell library for reading `options.json` and structured logging |

## Data and backups

| Path | Purpose |
|------|---------|
| `/share/mempalace/` | All palace memory data (rooms, drawers, knowledge graph, diaries) |
| `/data/identity.txt` | Generated identity file from your configuration |
| `/root/.mempalace/identity.txt` | Copy placed where MemPalace expects it at runtime |

The `/share` directory is persistent across restarts and add-on updates, and survives add-on uninstall/reinstall. It is included in **full** HA backups. For partial backups, select the **share** folder explicitly to include palace data.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Add-on starts then stops immediately | Check the **Log** tab — usually a missing or empty configuration field |
| `connection refused` on port 8765 | Verify the add-on is running and the port mapping shows `8765:8765/tcp` |
| Cloudflare Tunnel not reaching the server | Ensure the Cloudflared service target is `http://localhost:8765`, not `https` |
| "Open Web UI" button missing | Verify `ingress: true` and `ingress_port: 7681` are set in config.yaml |
| Palace data lost after update | Data in `/share/mempalace` survives add-on updates; if you uninstalled and reinstalled, restore from a backup |
| Knowledge graph tools return empty results | The KG is populated on demand via `mempalace_kg_add`; it starts empty on fresh palaces |
| Palace from older mempalace version won't open | Run `mempalace migrate /share/mempalace` from the web terminal to upgrade the schema |

## License

This add-on repository is provided as-is. MemPalace itself is licensed under its own terms — see the [MemPalace repository](https://github.com/MemPalace/mempalace) for details.
