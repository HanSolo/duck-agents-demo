#!/bin/bash
# Stops the Duck agents demo on Linux. The data of the therapy clinic is kept (reset-demo.sh deletes it).
cd "$(dirname "$0")" || exit 1
DEMO_IMAGE_PREFIX="$(grep -E '^DEMO_IMAGE_PREFIX=' .env 2>/dev/null | tail -n 1 | cut -d= -f2- | tr -d '\r"' | tr '[:upper:]' '[:lower:]')"
[ -n "$DEMO_IMAGE_PREFIX" ] && export DEMO_IMAGE_PREFIX || unset DEMO_IMAGE_PREFIX
docker compose down && echo "The demo is stopped."
