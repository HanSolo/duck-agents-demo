#!/bin/bash
# Starts the Duck agents demo on macOS. Double-click this file in Finder.
cd "$(dirname "$0")" || exit 1
# Image names must be lower case; GitHub names often are not, so lower-case the prefix from .env (the shell value wins over .env)
DEMO_IMAGE_PREFIX="$(grep -E '^DEMO_IMAGE_PREFIX=' .env 2>/dev/null | tail -n 1 | cut -d= -f2- | tr -d '\r"' | tr '[:upper:]' '[:lower:]')"
[ -n "$DEMO_IMAGE_PREFIX" ] && export DEMO_IMAGE_PREFIX || unset DEMO_IMAGE_PREFIX

URLS=("http://localhost:8080/duck-clinic/" "http://localhost:8081/" "http://localhost:8082/")
NAMES=("DuckClinic" "DuckInsurance" "Duck Physical Therapy Clinic")

stop_here() { echo; echo "$1"; echo; read -r -p "Press Enter to close this window." _; exit 1; }

echo "=== Duck agents demo ==="

# 1. Docker installed and running?
if ! command -v docker >/dev/null 2>&1; then
  for candidate in /usr/local/bin/docker /opt/homebrew/bin/docker "$HOME/.docker/bin/docker" /Applications/Docker.app/Contents/Resources/bin/docker; do
    [ -x "$candidate" ] && PATH="$(dirname "$candidate"):$PATH" && break
  done
fi
command -v docker >/dev/null 2>&1 || stop_here "Docker is not installed. Please install Docker Desktop (ask IT), start it once, then try again."
if ! docker info >/dev/null 2>&1; then
  echo "Starting Docker Desktop ..."
  open -a Docker >/dev/null 2>&1
  for _ in $(seq 1 60); do docker info >/dev/null 2>&1 && break; sleep 3; done
  docker info >/dev/null 2>&1 || stop_here "Docker Desktop did not start. Open it from Applications, wait until it says it is running, then try again."
fi

# 2. Model settings
if [ ! -f llm.env ]; then
  cp llm.env.example llm.env
  open -e llm.env
  stop_here "First start: the file llm.env was created and opened in TextEdit. Fill in the model name and the API key, save it, then double-click start-demo again."
fi
if grep -q '^[^#]*PASTE-' llm.env; then
  open -e llm.env
  stop_here "llm.env still contains PASTE-... placeholders. Fill in the model name and the API key, save it, then double-click start-demo again."
fi

# 3. Ports free? (skipped when the demo is already running)
if [ -z "$(docker compose ps -q 2>/dev/null)" ]; then
  for port in 8080 8081 8082; do
    if lsof -nP -iTCP:$port -sTCP:LISTEN >/dev/null 2>&1; then
      stop_here "Port $port is used by another program ($(lsof -nP -iTCP:$port -sTCP:LISTEN | awk 'NR==2{print $1}')). Close it, or restart the computer, then try again."
    fi
  done
fi

# 4. Start
echo "Downloading updates (can take a few minutes the first time) ..."
docker compose pull || echo "Could not download updates, starting the version already on this computer."
docker compose up -d || stop_here "The demo could not be started. Send a screenshot of this window to the demo maintainer."

# 5. Wait until the three web pages answer, then open them
echo "Waiting for the applications (usually 1 to 2 minutes) ..."
for i in 0 1 2; do
  ready=no
  for _ in $(seq 1 100); do
    if curl -s -f -o /dev/null --max-time 5 "${URLS[$i]}"; then ready=yes; break; fi
    sleep 3
  done
  if [ "$ready" = yes ]; then echo "  ${NAMES[$i]} is ready"; else echo "  ${NAMES[$i]} did not answer in time, opening it anyway"; fi
done
for url in "${URLS[@]}"; do open "$url"; done

echo
echo "The demo is running. DuckInsurance sign-in: admin / admin (also adjuster / adjuster, customer / customer)."
echo "Stop it with stop-demo when you are done. You can close this window now."
