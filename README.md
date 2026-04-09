# MemPalace MCP Server — Home Assistant Add-on

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fcarlito1979%2Fha-mempalace-addon)

Run [MemPalace](https://github.com/milla-jovovich/mempalace) as a Home Assistant add-on. MemPalace gives Claude a persistent, structured long-term memory — it remembers who you are, what you're working on, and what it has learned across sessions.

This add-on wraps the MemPalace MCP server (stdio) with [supergateway](https://github.com/nicholasgriffintn/supergateway) to expose it over **HTTP/SSE on port 8765**, making it reachable from Claude.ai, Claude Code, and Cowork.

## How it works

```
Claude  ---->  Cloudflare Tunnel  ---->  HA port 8765  ---->  supergateway  ---->  MemPalace MCP (stdio)
                (cloudflared addon)        (this addon)          (HTTP/SSE bridge)      (Python)
```

- **supergateway** translates between HTTP/SSE and stdio so MemPalace's native stdio transport works over the network.
- **Palace data** is stored in `/data/palace` inside the add-on container — this path is persistent and included in all Home Assistant backups automatically.
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

## Exposing via Cloudflare Tunnel

The MCP server listens on port 8765 on your Home Assistant host. To make it reachable from Claude.ai or Cowork you need a public URL — the easiest way is with the [Cloudflared add-on](https://github.com/brenner-tobias/ha-addons):

1. Install the **Cloudflared** add-on from the [brenner-tobias/ha-addons](https://github.com/brenner-tobias/ha-addons) repository.
2. In the Cloudflared configuration, add an additional host entry:

   | Public hostname | Service |
   |-----------------|--------|
   | `mempalace.yourdomain.com` | `http://localhost:8765` |

3. In your Claude client, add the MCP server URL as `https://mempalace.yourdomain.com/sse`.

## Architecture

```
ha-mempalace-addon/
├── repository.yaml                 # HA add-on repository metadata
├── README.md
└── mempalace/
    ├── config.yaml                 # Add-on config (ports, options, schema)
    ├── Dockerfile                  # Alpine + Python + Node + supergateway + mempalace
    ├── run.sh                      # Entrypoint: writes identity, inits palace, launches server
    └── translations/
        └── en.yaml                 # UI labels for the Configuration tab
```

| Component | Role |
|-----------|------|
| **ghcr.io/home-assistant/base** | Alpine Linux base image required by HA |
| **mempalace** (pip) | Python MCP server providing structured long-term memory |
| **supergateway** (npm) | Bridges stdio ↔ HTTP/SSE so network clients can connect |
| **bashio** | HA shell library for reading `options.json` and structured logging |

## Data and backups

| Path | Purpose |
|------|--------|
| `/data/palace/` | All palace memory data (rooms, items, indices) |
| `/data/identity.txt` | Generated identity file from your configuration |
| `/root/.mempalace/identity.txt` | Copy placed where MemPalace expects it at runtime |

The `/data` directory is persistent across restarts and is automatically included in Home Assistant snapshots and backups.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Add-on starts then stops immediately | Check the **Log** tab — usually a missing or empty configuration field |
| `connection refused` on port 8765 | Verify the add-on is running and the port mapping shows `8765:8765/tcp` |
| Cloudflare Tunnel not reaching the server | Ensure the Cloudflared service target is `http://localhost:8765`, not `https` |
| Palace data lost after update | Data in `/data` survives add-on updates; if you uninstalled and reinstalled, restore from a backup |

## License

This add-on repository is provided as-is. MemPalace itself is licensed under its own terms — see the [MemPalace repository](https://github.com/milla-jovovich/mempalace) for details.
