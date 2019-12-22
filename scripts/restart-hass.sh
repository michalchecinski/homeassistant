#!/bin/bash
set -euxo pipefail

REPO_PATH="/home/pi/homeassistant"

docker-compose -f "$REPO_PATH"/docker-compose.yaml restart hass