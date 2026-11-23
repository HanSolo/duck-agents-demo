#!/bin/bash
# Stops the Duck agents demo on Linux and deletes its data, so the next start begins fresh.
cd "$(dirname "$0")" || exit 1
DEMO_IMAGE_PREFIX="$(grep -E '^DEMO_IMAGE_PREFIX=' .env 2>/dev/null | tail -n 1 | cut -d= -f2- | tr -d '\r"' | tr '[:upper:]' '[:lower:]')"
[ -n "$DEMO_IMAGE_PREFIX" ] && export DEMO_IMAGE_PREFIX || unset DEMO_IMAGE_PREFIX
read -r -p "This deletes all bookings and changes made during demos. Type yes to continue: " answer
if [ "$answer" = "yes" ]; then docker compose down -v && echo "The demo is reset. Start it again with ./start-demo.sh."; else echo "Nothing was changed."; fi
