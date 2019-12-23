#!/bin/bash
set -euxo pipefail

# pi settings
REPO_PATH="/home/pi/homeassistant"

docker-compose -f "$REPO_PATH"/docker-compose.yaml down --remove-orphans
sleep 5
docker-compose -f "$REPO_PATH"/docker-compose.yaml up -d
docker network prune -f
docker volume prune -f