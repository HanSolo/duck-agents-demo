#!/bin/bash
# Stops the Duck agents demo on macOS and deletes its data, so the next start begins fresh.
cd "$(dirname "$0")" || exit 1
# Image names must be lower case; GitHub names often are not, so lower-case the prefix from .env (the shell value wins over .env)
DEMO_IMAGE_PREFIX="$(grep -E '^DEMO_IMAGE_PREFIX=' .env 2>/dev/null | tail -n 1 | cut -d= -f2- | tr -d '\r"' | tr '[:upper:]' '[:lower:]')"
[ -n "$DEMO_IMAGE_PREFIX" ] && export DEMO_IMAGE_PREFIX || unset DEMO_IMAGE_PREFIX
command -v docker >/dev/null 2>&1 || PATH="/usr/local/bin:/opt/homebrew/bin:$HOME/.docker/bin:$PATH"
read -r -p "This deletes all bookings and changes made during demos. Type yes to continue: " answer
if [ "$answer" = "yes" ]; then docker compose down -v && echo "The demo is reset. Start it again with start-demo."; else echo "Nothing was changed."; fi
read -r -p "Press Enter to close this window." _
