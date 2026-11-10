#!/usr/bin/env bash
# Starts Context Mode v2.1.7 on Node.js 24.15.0.
# Both are installed by the cloud environment's setup script; this script
# never installs or downloads anything.
# Usage: context-mode.sh server|hook
set -euo pipefail
CM_VERSION=2.1.7
NODE_VERSION=24.15.0
NODE="${CONTEXT_MODE_NODE:-/opt/node-v$NODE_VERSION-linux-x64/bin/node}"
PKG="${CONTEXT_MODE_PKG:-/opt/context-mode-$CM_VERSION/node_modules/context-mode}"

if [ ! -x "$NODE" ] || [ ! -f "$PKG/server.mjs" ] || [ ! -f "$PKG/hook.mjs" ]; then
  echo "context-mode: Node $NODE_VERSION or context-mode $CM_VERSION missing ($NODE, $PKG); run the environment setup script" >&2
  exit 1
fi

export CLAUDE_PLUGIN_ROOT="$PKG"
case "${1:-}" in
  server) exec "$NODE" "$PKG/server.mjs" --agent claude-code ;;
  hook)
    # Context Mode names its tools by the plugin prefix. This project loads the
    # server from .mcp.json as "context-mode", so map the names in hook output.
    set +e
    out="$("$NODE" "$PKG/hook.mjs" --agent claude-code)"
    rc=$?
    set -e
    printf '%s' "${out//mcp__plugin_context-mode_context-mode__/mcp__context-mode__}"
    exit "$rc"
    ;;
  *) echo "usage: $0 server|hook" >&2; exit 64 ;;
esac
