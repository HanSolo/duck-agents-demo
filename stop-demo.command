#!/bin/bash
# Stops the Duck agents demo on macOS. The data of the therapy clinic is kept (reset-demo deletes it).
cd "$(dirname "$0")" || exit 1
# Image names must be lower case; GitHub names often are not, so lower-case the prefix from .env (the shell value wins over .env)
DEMO_IMAGE_PREFIX="$(grep -E '^DEMO_IMAGE_PREFIX=' .env 2>/dev/null | tail -n 1 | cut -d= -f2- | tr -d '\r"' | tr '[:upper:]' '[:lower:]')"
[ -n "$DEMO_IMAGE_PREFIX" ] && export DEMO_IMAGE_PREFIX || unset DEMO_IMAGE_PREFIX
command -v docker >/dev/null 2>&1 || PATH="/usr/local/bin:/opt/homebrew/bin:$HOME/.docker/bin:$PATH"
docker compose down && echo "The demo is stopped."
read -r -p "Press Enter to close this window." _
