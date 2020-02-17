#!/bin/bash
set -euxo pipefail

REPO_PATH="/home/pi/homeassistant"

docker-compose -f "$REPO_PATH"/docker-compose.yaml restart

docker network prune -f
docker volume prune -f