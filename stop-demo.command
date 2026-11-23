#!/bin/bash
# Stops the Duck agents demo on macOS. The data of the therapy clinic is kept (reset-demo deletes it).
cd "$(dirname "$0")" || exit 1
command -v docker >/dev/null 2>&1 || PATH="/usr/local/bin:/opt/homebrew/bin:$HOME/.docker/bin:$PATH"
docker compose down && echo "The demo is stopped."
read -r -p "Press Enter to close this window." _
