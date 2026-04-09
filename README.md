# MemPalace MCP Server — Home Assistant Add-on

Runs MemPalace (https://github.com/milla-jovovich/mempalace) as a Home Assistant add-on, exposing a persistent AI memory MCP server over HTTP/SSE on port 8765.

## Installation

1. Go to Settings → Apps → App Store in Home Assistant
2. Click the three-dot menu → Repositories
3. Add this repository URL: https://github.com/carlito1979/ha-mempalace-addon
4. Find MemPalace MCP Server in the store and click Install
5. Fill in your identity details in the Configuration tab
6. Click Start

## Cloudflare Tunnel

To expose the MCP server publicly (required for Claude.ai and Cowork), install the Cloudflared add-on (https://github.com/brenner-tobias/ha-addons) separately and add mempalace.yourdomain.com as an additional host pointing to http://<ha-ip>:8765.

## Notes

- Palace data is stored in /data/palace — included in all HA backups automatically
- First run initialises the palace structure; subsequent restarts skip init
- Port 8765 is exposed on the HA host for cloudflared to reach
- MemPalace v3.0.0 is very new — check GitHub issues for known problems
