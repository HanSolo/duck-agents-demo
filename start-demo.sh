#!/bin/bash
# Starts the Duck agents demo on Linux. Run it in a terminal: ./start-demo.sh
cd "$(dirname "$0")" || exit 1
# Image names must be lower case; GitHub names often are not, so lower-case the prefix from .env (the shell value wins over .env)
DEMO_IMAGE_PREFIX="$(grep -E '^DEMO_IMAGE_PREFIX=' .env 2>/dev/null | tail -n 1 | cut -d= -f2- | tr -d '\r"' | tr '[:upper:]' '[:lower:]')"
[ -n "$DEMO_IMAGE_PREFIX" ] && export DEMO_IMAGE_PREFIX || unset DEMO_IMAGE_PREFIX

URLS=("http://localhost:8080/duck-clinic/" "http://localhost:8081/" "http://localhost:8082/")
NAMES=("DuckClinic" "DuckInsurance" "Duck Physical Therapy Clinic")

stop_here() { echo; echo "$1"; echo; exit 1; }
open_url() { if command -v xdg-open >/dev/null 2>&1; then xdg-open "$1" >/dev/null 2>&1 & else echo "  Open $1 in your browser"; fi; }

echo "=== Duck agents demo ==="

# 1. Docker installed, running and usable without sudo?
command -v docker >/dev/null 2>&1 || stop_here "Docker is not installed. Install Docker Engine (https://docs.docker.com/engine/install/) or Docker Desktop for Linux, then try again."
docker compose version >/dev/null 2>&1 || stop_here "The Docker Compose plugin is missing. Install the package docker-compose-plugin, then try again."
if ! docker info >/dev/null 2>&1; then
  if docker info 2>&1 | grep -qi "permission denied"; then
    stop_here "Your user may not use Docker yet. Run: sudo usermod -aG docker \$USER   then log out and in again, and try again."
  fi
  echo "Starting Docker ..."
  systemctl --user start docker-desktop >/dev/null 2>&1 || sudo systemctl start docker
  for _ in $(seq 1 40); do docker info >/dev/null 2>&1 && break; sleep 3; done
  docker info >/dev/null 2>&1 || stop_here "Docker did not start. Start it yourself (sudo systemctl start docker, or open Docker Desktop), then try again."
fi

# 2. Model settings
if [ ! -f llm.env ]; then
  cp llm.env.example llm.env
  stop_here "First start: the file llm.env was created. Fill in the model name and the API key (for example: nano llm.env), save it, then run ./start-demo.sh again."
fi
if grep -q '^[^#]*PASTE-' llm.env; then
  stop_here "llm.env still contains PASTE-... placeholders. Fill in the model name and the API key (for example: nano llm.env), then run ./start-demo.sh again."
fi
if grep -q '^LLM_BASE_URL=http://host.docker.internal:11434' llm.env; then
  echo "Note: with Ollama on Linux, start it so that containers can reach it: OLLAMA_HOST=0.0.0.0 ollama serve"
fi

# 3. Ports free? (skipped when the demo is already running)
if [ -z "$(docker compose ps -q 2>/dev/null)" ]; then
  for port in 8080 8081 8082; do
    if ss -ltnH "sport = :$port" 2>/dev/null | grep -q .; then
      stop_here "Port $port is used by another program (see: ss -ltnp 'sport = :$port'). Stop it, then try again."
    fi
  done
fi

# 4. Start
echo "Downloading updates (can take a few minutes the first time) ..."
docker compose pull || echo "Could not download updates, starting the version already on this computer."
docker compose up -d || stop_here "The demo could not be started. Send the output above to the demo maintainer."

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
for url in "${URLS[@]}"; do open_url "$url"; done

echo
echo "The demo is running: ${URLS[*]}"
echo "DuckInsurance sign-in: admin / admin (also adjuster / adjuster, customer / customer)."
echo "Stop it with ./stop-demo.sh when you are done."
